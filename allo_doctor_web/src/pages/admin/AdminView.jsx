import React, { useState, useEffect } from 'react';
import { 
  Activity, 
  FileCheck, 
  ShieldAlert, 
  DollarSign, 
  Users, 
  CheckCircle,
  Cloud
} from 'lucide-react';
import { collection, onSnapshot, doc, updateDoc, getDoc, setDoc } from 'firebase/firestore';
import { db } from '../../firebase/config';
import { useAuth } from '../../context/AuthContext';
import { normalizePractitioner, normalizeTicket, normalizeUser } from '../../utils/normalize';
import { AdminDashboard } from './AdminDashboard';
import { AdminVerification } from './AdminVerification';
import { AdminSupport } from './AdminSupport';
import { AdminStatistics } from './AdminStatistics';
import { AdminUsers } from './AdminUsers';

export const AdminView = ({ subTab = 'admin_home', setSubTab }) => {
  const { currentUser, authReady } = useAuth();
  const [localTab, setLocalTab] = useState(subTab);
  const activeTab = setSubTab ? subTab : localTab;
  const navigateTab = (t) => {
    if (setSubTab) setSubTab(t);
    setLocalTab(t);
  };

  // Données dynamiques connectées en temps réel à Firestore (initialisées vides)
  const [practitioners, setPractitioners] = useState([]);
  const [tickets, setTickets] = useState([]);
  const [inspectingPractitioner, setInspectingPractitioner] = useState(null);
  const [activeTicket, setActiveTicket] = useState(null);
  const [usersList, setUsersList] = useState([]);
  // Diagnostic : dernière erreur Firestore rencontrée (affichée en bannière)
  const [firestoreError, setFirestoreError] = useState(null);

  // Synchronisation temps réel avec Firebase Cloud Firestore
  useEffect(() => {
    let unsubPractitioners;
    let unsubTickets;
    let unsubUsers;

    try {
      // 1. Ecoute des professionnels (médecins, cliniques, pharmacies)
      unsubPractitioners = onSnapshot(collection(db, 'practitioners'), (snapshot) => {
        const remoteList = snapshot.docs.map(docSnap =>
          normalizePractitioner(docSnap.data(), docSnap.id)
        );
        setPractitioners(remoteList);
      }, (err) => {
        console.warn('Erreur Firestore practitioners:', err.message);
        setFirestoreError({ collection: 'practitioners', ...err });
      });

      // 2. Ecoute des tickets de support & litiges
      unsubTickets = onSnapshot(collection(db, 'tickets'), (snapshot) => {
        const remoteTickets = snapshot.docs.map(docSnap =>
          normalizeTicket(docSnap.data(), docSnap.id)
        );
        setTickets(remoteTickets);
      }, (err) => {
        console.warn('Erreur Firestore tickets:', err.message);
        setFirestoreError({ collection: 'tickets', ...err });
      });

      // 3. Ecoute des comptes utilisateurs
      unsubUsers = onSnapshot(collection(db, 'users'), (snapshot) => {
        const remoteUsers = snapshot.docs.map(docSnap =>
          normalizeUser(docSnap.data(), docSnap.id)
        );
        setUsersList(remoteUsers);
      }, (err) => {
        console.warn('Erreur Firestore users:', err.message);
        setFirestoreError({ collection: 'users', ...err });
      });
    } catch (e) {
      console.warn('Initialisation Firestore:', e);
    }

    return () => {
      if (unsubPractitioners) unsubPractitioners();
      if (unsubTickets) unsubTickets();
      if (unsubUsers) unsubUsers();
    };
  }, []);

  // Notifications toast
  const [toastMessage, setToastMessage] = useState('');

  const showToast = (msg) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(''), 3500);
  };

  // Actions d'agrément (Synchronisées en temps réel avec Firestore)
  const handleValidatePractitioner = async (id, name) => {
    setPractitioners(prev => prev.map(p => p.id === id ? { ...p, status: 'validé', isValidated: true } : p));
    showToast(`✓ Le dossier de ${name} a été certifié et activé sur le réseau !`);
    try {
      await updateDoc(doc(db, 'practitioners', id), { 
        status: 'validé',
        isValidated: true,
        validatedAt: new Date().toISOString()
      });
    } catch (err) {
      console.log('Action enregistrée localement (Firestore initialisé):', err.message);
    }
    // L'agrément validé active l'espace métier du praticien : le role et le statut du
    // compte lie au dossier (id = uid pour les inscriptions depuis l'app).
    await syncPractitionerRole(id, 'validé');
  };

  const handleRejectPractitioner = async (id, name, reason) => {
    setPractitioners(prev => prev.map(p => p.id === id ? { ...p, status: 'rejeté', isValidated: false, rejectionReason: reason } : p));
    showToast(`✕ Demande de ${name} rejetée : ${reason || 'Non-conformité réglementaire'}`);
    try {
      await updateDoc(doc(db, 'practitioners', id), { 
        status: 'rejeté', 
        isValidated: false,
        rejectionReason: reason || 'Non-conformité réglementaire',
        rejectedAt: new Date().toISOString()
      });
    } catch (err) {
      console.log('Action enregistrée localement (Firestore initialisé):', err.message);
    }
    // Un dossier rejeté retire l'accès à l'espace métier.
    await syncPractitionerRole(id, 'rejeté');
  };

  /**
   * Aligne le role et le statut du compte lie au dossier d'agrement.
   * - validation  -> role = type du dossier (medecin / pharmacie / clinique), status = 'validé', isValidated = true
   * - rejet       -> retour au role patient, status = 'rejeté', isValidated = false
   */
  const syncPractitionerRole = async (practitionerId, action) => {
    try {
      const dossierSnap = await getDoc(doc(db, 'practitioners', practitionerId));
      if (!dossierSnap.exists()) return;
      const dossier = dossierSnap.data();
      const type = dossier?.type;
      if (!type || type === 'patient') return;

      const isVal = action === 'validé';
      const nextRole = isVal ? type : 'patient';
      const updateData = {
        role: nextRole,
        userCategory: nextRole,
        status: isVal ? 'validé' : 'rejeté',
        isValidated: isVal,
        is_validated: isVal,
        validatedAt: isVal ? new Date().toISOString() : null,
      };

      // Mettre à jour 'users' (collection principale)
      const userRef = doc(db, 'users', practitionerId);
      await setDoc(userRef, updateData, { merge: true });

      // Mettre à jour 'User' (collection FlutterFlow si existante)
      try {
        await setDoc(doc(db, 'User', practitionerId), updateData, { merge: true });
      } catch (_) {}

      // Si c'est une pharmacie validée, créer/mettre à jour dans 'pharmacies'
      if (type === 'pharmacie') {
        try {
          await setDoc(doc(db, 'pharmacies', practitionerId), {
            id: practitionerId,
            uid: practitionerId,
            name: dossier.name || 'Pharmacie',
            phone: dossier.phone || '',
            city: dossier.city || 'Brazzaville',
            address: dossier.address || dossier.city || 'Brazzaville',
            status: isVal ? 'validé' : 'en_attente',
            isValidated: isVal,
            is_guard: false,
            hours: '08h - 20h',
            photo_url: dossier.photoUrl || dossier.photo_url || '',
            updatedAt: new Date().toISOString(),
          }, { merge: true });
        } catch (e) {
          console.warn('Erreur synchro collection pharmacies:', e);
        }
      }

      setUsersList(prev =>
        prev.map(u => (u.id === practitionerId ? { ...u, role: nextRole, status: isVal ? 'validé' : 'rejeté', isValidated: isVal } : u))
      );
    } catch (err) {
      console.log('Rôle du praticien non synchronisé:', err.message);
    }
  };

  const handleToggleUserStatus = async (userId) => {
    let nextStatus = 'actif';
    setUsersList(prev => prev.map(u => {
      if (u.id === userId) {
        nextStatus = u.status === 'actif' ? 'suspendu' : 'actif';
        showToast(`Compte de ${u.name} : ${nextStatus.toUpperCase()}`);
        return { ...u, status: nextStatus };
      }
      return u;
    }));

    try {
      await updateDoc(doc(db, 'users', userId), { status: nextStatus });
    } catch (err) {
      console.log('Statut utilisateur synchronisé en local:', err.message);
    }
  };

  // Changement du rôle d'un compte (patient / médecin / pharmacie / clinique).
  // Seul l'admin est autorisé à le faire (règles Firestore).
  const handleChangeUserRole = async (userId, role) => {
    const previous = usersList.find(u => u.id === userId);
    setUsersList(prev =>
      prev.map(u => (u.id === userId ? { ...u, role } : u))
    );
    showToast(`Rôle mis à jour : ${role}`);
    try {
      await updateDoc(doc(db, 'users', userId), { role });
    } catch (err) {
      console.log('Rôle synchronisé en local:', err.message);
      setUsersList(prev =>
        prev.map(u => (u.id === userId ? { ...u, role: previous?.role } : u))
      );
    }
  };

  // Nombre de demandes en attente et tickets ouverts pour les badges
  const pendingCount = practitioners.filter(p => p.status === 'en_attente').length;
  const openTicketsCount = tickets.filter(t => t.status === 'Ouvert' || t.status === 'Litige').length;

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
      {/* Panneau de diagnostic : session Firebase + etats des collections */}
      <div
        style={{
          display: 'flex',
          flexWrap: 'wrap',
          alignItems: 'center',
          gap: '10px',
          padding: '10px 14px',
          borderRadius: '12px',
          border: `1px solid ${firestoreError ? '#BE3232' : 'var(--border, #DADDDD)'}`,
          background: firestoreError ? '#fbebeb' : 'var(--bg-subtle, #F2F5F4)',
          fontSize: '11px',
          color: 'var(--text-secondary, #56605B)',
          fontWeight: 600
        }}
      >
        <span
          style={{
            display: 'inline-flex',
            alignItems: 'center',
            gap: '6px',
            padding: '3px 9px',
            borderRadius: '20px',
            background: firestoreError ? '#BE3232' : '#14583D',
            color: '#FFFFFF',
            fontWeight: 800
          }}
        >
          {firestoreError ? 'ERREUR FIRESTORE' : 'SESSION OK'}
        </span>

        <span>
          Compte : <strong>{currentUser?.email || '—'}</strong>
        </span>
        <span>
          Firestore : <strong>users {usersList.length}</strong> ·{' '}
          <strong>praticiens {practitioners.length}</strong> ·{' '}
          <strong>tickets {tickets.length}</strong>
        </span>
        {!authReady && (
          <span style={{ color: '#B26A00' }}>Connexion en cours…</span>
        )}

        {firestoreError && (
          <span style={{ color: '#BE3232' }}>
            {firestoreError.collection} → {firestoreError.code || firestoreError.message}
          </span>
        )}
      </div>

      {/* Toast Flottant Dynamique */}
      {toastMessage && (
        <div style={{
          position: 'fixed',
          bottom: '28px',
          right: '28px',
          background: '#14583D',
          color: 'white',
          padding: '14px 22px',
          borderRadius: '14px',
          boxShadow: '0 12px 30px rgba(0,0,0,0.22)',
          display: 'flex',
          alignItems: 'center',
          gap: '12px',
          zIndex: 2000,
          fontWeight: 700,
          fontSize: '13px',
          animation: 'slideIn 0.3s ease'
        }}>
          <CheckCircle size={20} color="#FFB300" />
          <span>{toastMessage}</span>
        </div>
      )}

      {/* BARRE DE NAVIGATION ADMINISTRATIVE DES 4 SECTIONS OFFICIELLES DU PARCOURS ADMINISTRATEUR */}
      <div style={{
        background: 'rgba(255, 255, 255, 0.92)',
        backdropFilter: 'blur(16px)',
        borderRadius: '18px',
        padding: '6px 8px',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
        border: '1px solid rgba(20, 88, 61, 0.12)',
        boxShadow: '0 8px 24px rgba(20, 88, 61, 0.04)',
        flexWrap: 'wrap',
        gap: '8px'
      }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '4px', flexWrap: 'wrap' }}>
          {/* 5.5.1 Tableau de bord administrateur */}
          <button
            id="admin-tab-home"
            onClick={() => navigateTab('admin_home')}
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: '8px',
              padding: '9px 16px',
              borderRadius: '12px',
              border: 'none',
              fontSize: '12px',
              fontWeight: 800,
              cursor: 'pointer',
              background: activeTab === 'admin_home' ? '#14583D' : 'transparent',
              color: activeTab === 'admin_home' ? '#FFFFFF' : '#56605B',
              boxShadow: activeTab === 'admin_home' ? '0 4px 12px rgba(20, 88, 61, 0.25)' : 'none',
              transition: 'all 0.2s cubic-bezier(0.34, 1.56, 0.64, 1)'
            }}
          >
            <Activity size={15} />
            <span>Tableau de Bord</span>
          </button>

          {/* Validation des professionnels */}
          <button
            id="admin-tab-verification"
            onClick={() => navigateTab('admin_verification')}
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: '8px',
              padding: '9px 16px',
              borderRadius: '12px',
              border: 'none',
              fontSize: '12px',
              fontWeight: 800,
              cursor: 'pointer',
              background: activeTab === 'admin_verification' ? '#14583D' : 'transparent',
              color: activeTab === 'admin_verification' ? '#FFFFFF' : '#56605B',
              boxShadow: activeTab === 'admin_verification' ? '0 4px 12px rgba(20, 88, 61, 0.25)' : 'none',
              transition: 'all 0.2s cubic-bezier(0.34, 1.56, 0.64, 1)'
            }}
          >
            <FileCheck size={15} />
            <span>Agrément & Validations</span>
            {pendingCount > 0 && (
              <span style={{
                background: activeTab === 'admin_verification' ? '#FFB300' : '#d97706',
                color: '#1A1C1B',
                fontSize: '10px',
                fontWeight: 900,
                padding: '2px 7px',
                borderRadius: '10px'
              }}>
                {pendingCount}
              </span>
            )}
          </button>

          {/* Support et litiges */}
          <button
            id="admin-tab-support"
            onClick={() => navigateTab('admin_support')}
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: '8px',
              padding: '9px 16px',
              borderRadius: '12px',
              border: 'none',
              fontSize: '12px',
              fontWeight: 800,
              cursor: 'pointer',
              background: activeTab === 'admin_support' ? '#14583D' : 'transparent',
              color: activeTab === 'admin_support' ? '#FFFFFF' : '#56605B',
              boxShadow: activeTab === 'admin_support' ? '0 4px 12px rgba(20, 88, 61, 0.25)' : 'none',
              transition: 'all 0.2s cubic-bezier(0.34, 1.56, 0.64, 1)'
            }}
          >
            <ShieldAlert size={15} />
            <span>Support & Litiges</span>
            {openTicketsCount > 0 && (
              <span style={{
                background: activeTab === 'admin_support' ? '#f87171' : '#BE3232',
                color: 'white',
                fontSize: '10px',
                fontWeight: 900,
                padding: '2px 7px',
                borderRadius: '10px'
              }}>
                {openTicketsCount}
              </span>
            )}
          </button>

          {/* Statistiques et commissions */}
          <button
            id="admin-tab-stats"
            onClick={() => navigateTab('admin_stats')}
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: '8px',
              padding: '9px 16px',
              borderRadius: '12px',
              border: 'none',
              fontSize: '12px',
              fontWeight: 800,
              cursor: 'pointer',
              background: activeTab === 'admin_stats' ? '#14583D' : 'transparent',
              color: activeTab === 'admin_stats' ? '#FFFFFF' : '#56605B',
              boxShadow: activeTab === 'admin_stats' ? '0 4px 12px rgba(20, 88, 61, 0.25)' : 'none',
              transition: 'all 0.2s cubic-bezier(0.34, 1.56, 0.64, 1)'
            }}
          >
            <DollarSign size={15} />
            <span>Finances & Commissions</span>
          </button>

          {/* Gestion Utilisateurs */}
          <button
            id="admin-tab-users"
            onClick={() => navigateTab('admin_users')}
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: '8px',
              padding: '9px 16px',
              borderRadius: '12px',
              border: 'none',
              fontSize: '12px',
              fontWeight: 800,
              cursor: 'pointer',
              background: activeTab === 'admin_users' ? '#14583D' : 'transparent',
              color: activeTab === 'admin_users' ? '#FFFFFF' : '#56605B',
              boxShadow: activeTab === 'admin_users' ? '0 4px 12px rgba(20, 88, 61, 0.25)' : 'none',
              transition: 'all 0.2s cubic-bezier(0.34, 1.56, 0.64, 1)'
            }}
          >
            <Users size={15} />
            <span>Utilisateurs ({usersList.length})</span>
          </button>
        </div>

        {/* Indicateurs Firebase & Accréditation Super-Admin */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px', flexWrap: 'wrap' }}>
          <div style={{
            display: 'inline-flex',
            alignItems: 'center',
            gap: '6px',
            background: 'rgba(20, 88, 61, 0.08)',
            padding: '5px 10px',
            borderRadius: '20px',
            fontSize: '11px',
            fontWeight: 800,
            color: '#14583D'
          }}>
            <Cloud size={13} color="#14583D" />
            <span>Firebase : allo-doctor-app</span>
          </div>

          <div style={{ display: 'flex', alignItems: 'center', gap: '8px', padding: '0 8px', fontSize: '11px', color: '#14583D', fontWeight: 800 }}>
            <div style={{ width: 8, height: 8, borderRadius: '50%', background: '#22c55e', boxShadow: '0 0 8px #22c55e' }}></div>
            <span>SUPER-ADMIN EN DIRECT</span>
          </div>
        </div>
      </div>

      {/* RENDU DU MODULE SÉLECTIONNÉ SELON LES SPÉCIFICATIONS PARCOURS ADMINISTRATEUR */}
      {activeTab === 'admin_home' && (
        <AdminDashboard
          practitioners={practitioners}
          onValidatePractitioner={handleValidatePractitioner}
          onRejectPractitioner={handleRejectPractitioner}
          onInspectPractitioner={(p) => {
            setInspectingPractitioner(p);
            navigateTab('admin_verification');
          }}
          tickets={tickets}
          onOpenTicket={(t) => {
            setActiveTicket(t);
            navigateTab('admin_support');
          }}
          onNavigateTab={(tab) => navigateTab(tab)}
        />
      )}

      {activeTab === 'admin_verification' && (
        <AdminVerification
          practitioners={practitioners}
          onValidatePractitioner={handleValidatePractitioner}
          onRejectPractitioner={handleRejectPractitioner}
          inspectingPractitioner={inspectingPractitioner}
          setInspectingPractitioner={setInspectingPractitioner}
        />
      )}

      {activeTab === 'admin_support' && (
        <AdminSupport
          tickets={tickets}
          setTickets={setTickets}
          activeTicket={activeTicket}
          setActiveTicket={setActiveTicket}
          onShowToast={showToast}
        />
      )}

      {activeTab === 'admin_stats' && (
        <AdminStatistics onShowToast={showToast} />
      )}

      {activeTab === 'admin_users' && (
        <AdminUsers
          usersList={usersList}
          onToggleUserStatus={handleToggleUserStatus}
          onChangeUserRole={handleChangeUserRole}
        />
      )}
    </div>
  );
};
