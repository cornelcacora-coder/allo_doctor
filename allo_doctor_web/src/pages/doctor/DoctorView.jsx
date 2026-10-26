import React, { useState, useEffect } from 'react';
import { 
  Calendar, 
  Clock, 
  User, 
  CheckCircle, 
  XCircle, 
  FileText, 
  Plus, 
  DollarSign, 
  Activity, 
  Video, 
  Printer, 
  Trash2, 
  Check, 
  CreditCard, 
  ArrowUpRight, 
  ShieldCheck, 
  Search,
  Car,
  MapPin,
  Phone,
  Navigation,
  FileCheck2
} from 'lucide-react';
import { firestoreService } from '../../services/firestoreService';
import { useAuth } from '../../context/AuthContext';

export const DoctorView = ({ subTab = 'doctor_home', setSubTab }) => {
  const { currentUser } = useAuth();
  const [appointments, setAppointments] = useState([]);
  const [prescriptions, setPrescriptions] = useState([]);
  const [toastMessage, setToastMessage] = useState('');
  
  // Rédacteur d'ordonnance
  const [prescPatient, setPrescPatient] = useState('Karim Tazi');
  const [prescNotes, setPrescNotes] = useState('Bien respecter les horaires de prise. Revenir en consultation si besoin.');
  const [medLines, setMedLines] = useState([
    { name: 'Kardegic 75mg', posology: '1 sachet le midi', duration: '30 jours' }
  ]);
  const [prescSuccess, setPrescSuccess] = useState(false);

  // Recherche dans le DMP
  const [dmpSearch, setDmpSearch] = useState('');
  const [viewingRecordApt, setViewingRecordApt] = useState(null);

  // VISITES À DOMICILE (Feature fidèle à doctor/visite dans Flutter)
  const [homeVisits, setHomeVisits] = useState([
    { id: 'v1', patient: 'Lalla Aicha Alami', age: 78, address: 'Residence Les Fleurs, Apt 4, Racine, Casablanca', phone: '+212 661 88 99 00', reason: 'Difficulté à se déplacer, forte fièvre et toux', status: 'en_attente', date: 'Aujourd\'hui 17:30', fee: 500 },
    { id: 'v2', patient: 'Youssef El Amrani', age: 45, address: 'Villa 12, Rue des Palmiers, CIL, Casablanca', phone: '+212 662 33 44 55', reason: 'Lumbago aigu, blocage lombaire complet', status: 'acceptée', date: 'Demain 10:00', fee: 500 },
  ]);

  const showToast = (msg) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(''), 3000);
  };

  useEffect(() => {
    const unsubApt = firestoreService.listenAppointments(setAppointments);
    const unsubPresc = firestoreService.listenPrescriptions(setPrescriptions);

    return () => {
      unsubApt && unsubApt();
      unsubPresc && unsubPresc();
    };
  }, []);

  const handleUpdateStatus = async (id, status) => {
    await firestoreService.updateAppointmentStatus(id, status);
    setAppointments(prev => prev.map(a => a.id === id ? { ...a, status } : a));
    showToast(`Rendez-vous mis à jour : ${status.toUpperCase()}`);
  };

  const handleAddMedLine = () => {
    setMedLines([...medLines, { name: '', posology: '', duration: '7 jours' }]);
  };

  const handleRemoveMedLine = (index) => {
    setMedLines(medLines.filter((_, idx) => idx !== index));
  };

  const handleMedLineChange = (index, field, value) => {
    const updated = [...medLines];
    updated[index][field] = value;
    setMedLines(updated);
  };

  const handleCreatePrescription = async (e) => {
    e.preventDefault();
    await firestoreService.createPrescription({
      code: `ORD-${new Date().getFullYear()}-${Math.floor(1000 + Math.random() * 9000)}`,
      patient_name: prescPatient,
      doctor_name: currentUser?.display_name || 'Dr. Amina Mansouri',
      doctor_specialty: currentUser?.profCategory || 'Cardiologue',
      date: new Date().toLocaleDateString('fr-FR'),
      medicines: medLines,
      notes: prescNotes
    });

    setPrescSuccess(true);
    setTimeout(() => {
      setPrescSuccess(false);
      setSubTab('doctor_agenda');
      showToast('Ordonnance enregistrée et transmise !');
    }, 1500);
  };

  const handleAcceptVisit = (id) => {
    setHomeVisits(prev => prev.map(v => v.id === id ? { ...v, status: 'acceptée' } : v));
    showToast('Visite à domicile acceptée ! Patient prévenu par SMS.');
  };

  const handleCompleteVisit = (id) => {
    setHomeVisits(prev => prev.map(v => v.id === id ? { ...v, status: 'terminée' } : v));
    showToast('Visite à domicile terminée et rapport médical archivé.');
  };

  const confirmedAppointments = appointments.filter(a => a.status === 'confirmé');
  const totalRevenue = appointments.reduce((sum, a) => sum + (a.fee || 350), 0);

  // Patients DMP
  const dmpPatients = [
    { id: '1', name: 'Karim Tazi', age: 34, blood: 'O+', lastVisit: '10 Oct 2026', condition: 'Hypertension stade 1', status: 'Stable', vitals: { bp: '13/8', hr: '74 bpm', sugar: '0.98 g/L' } },
    { id: '2', name: 'Salma Benjelloun', age: 29, blood: 'A+', lastVisit: '04 Oct 2026', condition: 'Arythmie bénigne', status: 'Sous traitement', vitals: { bp: '12/7', hr: '82 bpm', sugar: '0.92 g/L' } },
    { id: '3', name: 'Yassine Idrissi', age: 52, blood: 'B+', lastVisit: '22 Sept 2026', condition: 'Suivi post-opératoire', status: 'Bilan satisfaisant', vitals: { bp: '12.5/8', hr: '70 bpm', sugar: '1.05 g/L' } }
  ].filter(p => p.name.toLowerCase().includes(dmpSearch.toLowerCase()));

  return (
    <div>
      {/* Toast Flottant */}
      {toastMessage && (
        <div style={{
          position: 'fixed',
          bottom: '24px',
          right: '24px',
          background: '#14583D',
          color: 'white',
          padding: '12px 20px',
          borderRadius: '12px',
          boxShadow: '0 8px 24px rgba(0,0,0,0.18)',
          display: 'flex',
          alignItems: 'center',
          gap: '10px',
          zIndex: 1000,
          fontWeight: 700,
          fontSize: '13px'
        }}>
          <CheckCircle size={18} color="#FFB300" />
          {toastMessage}
        </div>
      )}

      {/* Header Docteur */}
      <div style={{
        background: 'linear-gradient(135deg, #14583D 0%, #5B8E7B 100%)',
        borderRadius: '20px',
        padding: '28px 32px',
        color: 'white',
        marginBottom: '28px',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
        boxShadow: '0 10px 25px rgba(20, 88, 61, 0.25)'
      }}>
        <div>
          <div style={{ display: 'inline-flex', alignItems: 'center', gap: '6px', background: 'rgba(255,255,255,0.2)', padding: '4px 12px', borderRadius: '20px', fontSize: '12px', fontWeight: 700, marginBottom: '12px' }}>
            <Activity size={14} /> Cabinet Médical Agréé Allo Doctor
          </div>
          <h2 style={{ fontSize: '26px', fontWeight: 900, marginBottom: '6px' }}>
            {currentUser?.display_name || 'Dr. Amina Mansouri'}
          </h2>
          <p style={{ opacity: 0.9, fontSize: '14px' }}>
            Spécialité : <strong>{currentUser?.profCategory || 'Cardiologue'}</strong> — Synchronisation temps réel avec les patients mobiles.
          </p>
        </div>

        <div style={{ display: 'flex', gap: '10px' }}>
          <button 
            id="doctor-new-prescription-btn"
            className="btn"
            onClick={() => setSubTab('doctor_prescriptions')}
            style={{ background: 'white', color: '#14583D', fontWeight: 800, padding: '12px 18px', borderRadius: '12px' }}
          >
            <FileText size={18} /> Rédiger une Ordonnance
          </button>
        </div>
      </div>

      {/* Cartes de statistiques */}
      <div className="dashboard-grid">
        <div className="stat-card" style={{ cursor: 'pointer' }} onClick={() => setSubTab('doctor_agenda')}>
          <div>
            <div style={{ fontSize: '13px', color: '#56605B', fontWeight: 600 }}>Total Rendez-vous</div>
            <div style={{ fontSize: '26px', fontWeight: 900, color: '#1A1C1B' }}>{appointments.length}</div>
            <div style={{ fontSize: '12px', color: '#25674D', fontWeight: 700, marginTop: '4px' }}>
              {confirmedAppointments.length} confirmés
            </div>
          </div>
          <div className="stat-icon-wrapper" style={{ background: '#e8efe8', color: '#14583D' }}>
            <Calendar size={24} />
          </div>
        </div>

        <div className="stat-card" style={{ cursor: 'pointer' }} onClick={() => setSubTab('doctor_visite')}>
          <div>
            <div style={{ fontSize: '13px', color: '#56605B', fontWeight: 600 }}>Visites à Domicile</div>
            <div style={{ fontSize: '26px', fontWeight: 900, color: '#F87849' }}>
              {homeVisits.filter(v => v.status === 'en_attente').length} En attente
            </div>
            <div style={{ fontSize: '12px', color: '#F87849', fontWeight: 700, marginTop: '4px' }}>
              Demandes de déplacement →
            </div>
          </div>
          <div className="stat-icon-wrapper" style={{ background: '#fef1ec', color: '#F87849' }}>
            <Car size={24} />
          </div>
        </div>

        <div className="stat-card" style={{ cursor: 'pointer' }} onClick={() => setSubTab('doctor_wallet')}>
          <div>
            <div style={{ fontSize: '13px', color: '#56605B', fontWeight: 600 }}>Honoraires cumulés</div>
            <div style={{ fontSize: '26px', fontWeight: 900, color: '#14583D' }}>{totalRevenue} F CFA</div>
            <div style={{ fontSize: '12px', color: '#14583D', fontWeight: 700, marginTop: '4px' }}>
              Portefeuille / Wallet →
            </div>
          </div>
          <div className="stat-icon-wrapper" style={{ background: '#e2f0e8', color: '#25674D' }}>
            <DollarSign size={24} />
          </div>
        </div>

        <div className="stat-card" style={{ cursor: 'pointer' }} onClick={() => setSubTab('doctor_dmp')}>
          <div>
            <div style={{ fontSize: '13px', color: '#56605B', fontWeight: 600 }}>Dossiers DMP</div>
            <div style={{ fontSize: '26px', fontWeight: 900, color: '#14583D' }}>{dmpPatients.length} Patients</div>
            <div style={{ fontSize: '12px', color: '#14583D', fontWeight: 700, marginTop: '4px' }}>
              Constantes & antécédents →
            </div>
          </div>
          <div className="stat-icon-wrapper" style={{ background: '#e8efe8', color: '#14583D' }}>
            <User size={24} />
          </div>
        </div>
      </div>

      {/* VISITES À DOMICILE (FIDÈLE À doctor/visite DE FLUTTER) */}
      {subTab === 'doctor_visite' ? (
        <div className="card">
          <div className="card-header">
            <h3 className="card-title"><Car size={20} color="#F87849" /> Demandes de Visites Médicales à Domicile</h3>
            <span className="badge badge-warning">Géolocalisation Patient</span>
          </div>
          <div className="card-body">
            <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
              {homeVisits.map(v => (
                <div key={v.id} style={{
                  border: '1px solid #DADDDD',
                  borderRadius: '16px',
                  padding: '20px',
                  background: '#FAFBFB',
                  display: 'flex',
                  justifyContent: 'space-between',
                  alignItems: 'center',
                  flexWrap: 'wrap',
                  gap: '12px'
                }}>
                  <div>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '6px' }}>
                      <strong style={{ fontSize: '16px', color: '#1A1C1B' }}>{v.patient}</strong>
                      <span style={{ fontSize: '12px', color: '#56605B' }}>({v.age} ans)</span>
                      <span className={`badge ${v.status === 'acceptée' ? 'badge-info' : v.status === 'terminée' ? 'badge-success' : 'badge-warning'}`}>
                        {v.status === 'acceptée' ? 'Confirmée' : v.status === 'terminée' ? 'Effectuée' : 'À valider'}
                      </span>
                    </div>

                    <div style={{ fontSize: '13px', color: '#1A1C1B', fontWeight: 600, marginBottom: '4px' }}>
                      Motif : {v.reason}
                    </div>

                    <div style={{ fontSize: '12px', color: '#56605B', display: 'flex', gap: '16px', flexWrap: 'wrap' }}>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
                        <MapPin size={13} color="#F87849" /> {v.address}
                      </div>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
                        <Phone size={13} color="#5B8E7B" /> {v.phone}
                      </div>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
                        <Clock size={13} color="#14583D" /> {v.date}
                      </div>
                    </div>
                  </div>

                  <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                    <div style={{ textAlign: 'right', marginRight: '6px' }}>
                      <span style={{ fontSize: '11px', color: '#9CA3AF', textTransform: 'uppercase', fontWeight: 800 }}>Tarif Visite</span>
                      <div style={{ fontSize: '16px', fontWeight: 900, color: '#14583D' }}>{v.fee} F CFA</div>
                    </div>

                    {v.status === 'en_attente' && (
                      <button 
                        className="btn btn-primary"
                        onClick={() => handleAcceptVisit(v.id)}
                        style={{ padding: '8px 16px', fontSize: '12px' }}
                      >
                        Accepter la visite
                      </button>
                    )}

                    {v.status === 'acceptée' && (
                      <div style={{ display: 'flex', gap: '6px' }}>
                        <button 
                          className="btn btn-secondary"
                          onClick={() => showToast(`Navigation GPS lancée vers l'adresse de ${v.patient}`)}
                          style={{ padding: '8px 12px', fontSize: '12px' }}
                        >
                          <Navigation size={13} /> GPS
                        </button>
                        <button 
                          className="btn btn-primary"
                          onClick={() => handleCompleteVisit(v.id)}
                          style={{ padding: '8px 14px', fontSize: '12px' }}
                        >
                          <Check size={13} /> Clôturer
                        </button>
                      </div>
                    )}
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      ) : subTab === 'doctor_prescriptions' ? (
        <div className="card">
          <div className="card-header">
            <h3 className="card-title"><FileText size={20} color="#14583D" /> Rédacteur d'Ordonnance Médicale</h3>
            <span className="badge badge-success">Certifié Allo Doctor</span>
          </div>
          <div className="card-body">
            {prescSuccess ? (
              <div style={{ textAlign: 'center', padding: '36px 0' }}>
                <CheckCircle size={64} color="#25674D" style={{ margin: '0 auto 16px' }} />
                <h3 style={{ fontSize: '20px', fontWeight: 800, color: '#25674D' }}>Ordonnance Enregistrée !</h3>
                <p style={{ fontSize: '14px', color: '#56605B' }}>
                  L'ordonnance a été transmise au patient et stockée dans Firestore.
                </p>
              </div>
            ) : (
              <form onSubmit={handleCreatePrescription}>
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px', marginBottom: '20px' }}>
                  <div className="form-group">
                    <label className="form-label">Nom du Patient</label>
                    <input 
                      type="text" 
                      className="form-input"
                      value={prescPatient}
                      onChange={(e) => setPrescPatient(e.target.value)}
                      required
                    />
                  </div>
                  <div className="form-group">
                    <label className="form-label">Date</label>
                    <input 
                      type="text" 
                      className="form-input" 
                      value={new Date().toLocaleDateString('fr-FR')} 
                      disabled 
                      style={{ background: '#f8fafc' }}
                    />
                  </div>
                </div>

                <div style={{ marginBottom: '20px' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '10px' }}>
                    <label className="form-label" style={{ margin: 0 }}>Médicaments et Posologie</label>
                    <button 
                      type="button" 
                      className="btn btn-outline-primary" 
                      onClick={handleAddMedLine}
                      style={{ padding: '6px 12px', fontSize: '12px' }}
                    >
                      <Plus size={14} /> Ajouter un médicament
                    </button>
                  </div>

                  {medLines.map((line, idx) => (
                    <div key={idx} style={{ display: 'grid', gridTemplateColumns: '2fr 2fr 1fr 40px', gap: '10px', marginBottom: '8px', alignItems: 'center' }}>
                      <input 
                        type="text" 
                        placeholder="Ex: Doliprane 1000mg" 
                        className="form-input"
                        value={line.name}
                        onChange={(e) => handleMedLineChange(idx, 'name', e.target.value)}
                        required
                      />
                      <input 
                        type="text" 
                        placeholder="Posologie (ex: 1 cp matin et soir)" 
                        className="form-input"
                        value={line.posology}
                        onChange={(e) => handleMedLineChange(idx, 'posology', e.target.value)}
                        required
                      />
                      <input 
                        type="text" 
                        placeholder="Durée (ex: 1 mois)" 
                        className="form-input"
                        value={line.duration}
                        onChange={(e) => handleMedLineChange(idx, 'duration', e.target.value)}
                      />
                      <button 
                        type="button" 
                        onClick={() => handleRemoveMedLine(idx)}
                        style={{ border: 'none', background: 'transparent', cursor: 'pointer', color: '#BE3232' }}
                      >
                        <Trash2 size={16} />
                      </button>
                    </div>
                  ))}
                </div>

                <div className="form-group">
                  <label className="form-label">Conseils thérapeutiques</label>
                  <textarea 
                    className="form-textarea" 
                    rows={3} 
                    value={prescNotes}
                    onChange={(e) => setPrescNotes(e.target.value)}
                  ></textarea>
                </div>

                <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '12px', marginTop: '24px' }}>
                  <button type="button" className="btn btn-secondary" onClick={() => setSubTab('doctor_agenda')}>
                    Annuler
                  </button>
                  <button type="submit" className="btn btn-primary">
                    <Check size={16} /> Valider & Générer l'Ordonnance
                  </button>
                </div>
              </form>
            )}
          </div>
        </div>
      ) : subTab === 'doctor_dmp' ? (
        <div className="card">
          <div className="card-header" style={{ flexWrap: 'wrap', gap: '12px' }}>
            <h3 className="card-title"><User size={20} color="#14583D" /> Dossier Médical Partagé (DMP) des Patients</h3>
            <div style={{ display: 'flex', alignItems: 'center', background: '#F2F5F4', borderRadius: '8px', padding: '6px 12px', gap: '6px' }}>
              <Search size={14} color="#9CA3AF" />
              <input 
                type="text" 
                placeholder="Rechercher un dossier patient..." 
                value={dmpSearch}
                onChange={(e) => setDmpSearch(e.target.value)}
                style={{ border: 'none', background: 'transparent', outline: 'none', fontSize: '12px' }}
              />
            </div>
          </div>
          <div className="card-body">
            <div className="custom-table-container">
              <table className="custom-table">
                <thead>
                  <tr>
                    <th>Patient</th>
                    <th>Âge</th>
                    <th>Groupe</th>
                    <th>Constantes Vitales</th>
                    <th>Pathologie / Diagnostic</th>
                    <th>Dernière Visite</th>
                    <th>Action</th>
                  </tr>
                </thead>
                <tbody>
                  {dmpPatients.map(p => (
                    <tr key={p.id}>
                      <td><strong>{p.name}</strong></td>
                      <td>{p.age} ans</td>
                      <td><span className="badge badge-danger">{p.blood}</span></td>
                      <td>
                        <div style={{ fontSize: '11px', color: '#14583D' }}>
                          TA: <strong>{p.vitals.bp}</strong> • Pouls: <strong>{p.vitals.hr}</strong> • Glycémie: <strong>{p.vitals.sugar}</strong>
                        </div>
                      </td>
                      <td>{p.condition}</td>
                      <td>{p.lastVisit}</td>
                      <td>
                        <button 
                          className="btn btn-secondary" 
                          onClick={() => showToast(`DMP de ${p.name} ouvert : antécédents et bilans consultables.`)}
                          style={{ padding: '4px 10px', fontSize: '11px' }}
                        >
                          Consulter Dossier
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      ) : subTab === 'doctor_wallet' ? (
        <div className="card">
          <div className="card-header">
            <h3 className="card-title"><CreditCard size={20} color="#14583D" /> Portefeuille Médical & Règlements</h3>
            <button 
              className="btn btn-primary"
              onClick={() => showToast('Demande de virement vers votre compte bancaire initiée.')}
              style={{ padding: '6px 14px', fontSize: '12px' }}
            >
              <ArrowUpRight size={14} /> Demander un Virement
            </button>
          </div>
          <div className="card-body">
            <div style={{ background: '#e8efe8', borderRadius: '16px', padding: '24px', marginBottom: '20px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <div>
                <span style={{ fontSize: '12px', fontWeight: 800, color: '#56605B', textTransform: 'uppercase' }}>Solde Disponible</span>
                <div style={{ fontSize: '32px', fontWeight: 900, color: '#14583D' }}>{totalRevenue} F CFA</div>
                <span style={{ fontSize: '12px', color: '#56605B' }}>Versements sécurisés par Allo Doctor</span>
              </div>
              <ShieldCheck size={48} color="#14583D" />
            </div>

            <h4 style={{ fontSize: '15px', fontWeight: 800, marginBottom: '12px' }}>Derniers Règlements de Consultations</h4>
            <div className="custom-table-container">
              <table className="custom-table">
                <thead>
                  <tr>
                    <th>Patient</th>
                    <th>Date</th>
                    <th>Prestation</th>
                    <th>Montant</th>
                    <th>Statut</th>
                  </tr>
                </thead>
                <tbody>
                  {appointments.map(a => (
                    <tr key={a.id}>
                      <td>{a.patient_name}</td>
                      <td>{a.date_time}</td>
                      <td>Consultation ({a.consult_mode || 'Cabinet'})</td>
                      <td><strong>+{a.fee || 350} F CFA</strong></td>
                      <td><span className="badge badge-success">Crédité</span></td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      ) : (
        <div className="card">
          <div className="card-header">
            <h3 className="card-title"><Calendar size={20} color="#14583D" /> Agenda des Consultations</h3>
            <span className="badge badge-info">Temps Réel Firestore</span>
          </div>
          <div className="card-body">
            <div className="custom-table-container">
              <table className="custom-table">
                <thead>
                  <tr>
                    <th>Patient</th>
                    <th>Date & Heure</th>
                    <th>Mode</th>
                    <th>Motif</th>
                    <th>Honoraires</th>
                    <th>Statut</th>
                    <th>Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {appointments.map((apt) => {
                    const isPending = apt.status === 'en_attente' || apt.status === 'pending';
                    const isConfirmed = apt.status === 'confirmé' || apt.status === 'confirmed';
                    const isFinished = apt.status === 'terminé' || apt.status === 'completed';

                    return (
                      <tr key={apt.id}>
                        <td>
                          <strong>{apt.patient_name}</strong>
                          <div style={{ fontSize: '11px', color: '#56605B' }}>{apt.patient_phone || '+212 600...'}</div>
                          {apt.medical_record && (
                            <button
                              type="button"
                              onClick={() => setViewingRecordApt(apt)}
                              style={{
                                display: 'inline-flex',
                                alignItems: 'center',
                                gap: '4px',
                                background: '#e8efe8',
                                border: 'none',
                                borderRadius: '12px',
                                padding: '2px 8px',
                                fontSize: '10px',
                                fontWeight: 800,
                                color: '#14583D',
                                cursor: 'pointer',
                                marginTop: '4px'
                              }}
                            >
                              <FileText size={11} /> Dossier joint
                            </button>
                          )}
                        </td>
                        <td>
                          <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                            <Clock size={14} color="#14583D" />
                            <span>{apt.date_time}</span>
                          </div>
                        </td>
                        <td>
                          <span className="badge badge-secondary">{apt.consult_mode || 'Cabinet'}</span>
                        </td>
                        <td style={{ maxWidth: '220px' }}>{apt.symptoms}</td>
                        <td><strong>{apt.fee || 350} F CFA</strong></td>
                        <td>
                          <span className={`badge ${
                            isConfirmed ? 'badge-success' : 
                            isFinished ? 'badge-info' :
                            isPending ? 'badge-warning' : 'badge-danger'
                          }`}>
                            {isPending ? 'En attente' : isConfirmed ? 'Confirmé' : isFinished ? 'Terminé' : (apt.status || 'Refusé')}
                          </span>
                        </td>
                        <td>
                          <div style={{ display: 'flex', gap: '6px', flexWrap: 'wrap' }}>
                            {isPending && (
                              <>
                                <button 
                                  className="btn btn-primary" 
                                  style={{ padding: '4px 10px', fontSize: '11px', background: '#14583D' }}
                                  onClick={() => handleUpdateStatus(apt.id, 'confirmé')}
                                >
                                  Valider
                                </button>
                                <button 
                                  className="btn btn-secondary" 
                                  style={{ padding: '4px 10px', fontSize: '11px', color: '#BE3232', borderColor: '#BE3232' }}
                                  onClick={() => handleUpdateStatus(apt.id, 'refusé')}
                                >
                                  Refuser
                                </button>
                              </>
                            )}
                            {isConfirmed && (
                              <>
                                <button 
                                  className="btn btn-secondary" 
                                  style={{ padding: '4px 10px', fontSize: '11px', color: '#14583D' }}
                                  onClick={() => handleUpdateStatus(apt.id, 'terminé')}
                                >
                                  Terminer
                                </button>
                                <button 
                                  className="btn btn-secondary" 
                                  style={{ padding: '4px 8px', fontSize: '11px', color: '#BE3232' }}
                                  onClick={() => handleUpdateStatus(apt.id, 'annulé')}
                                >
                                  <XCircle size={14} />
                                </button>
                              </>
                            )}
                          </div>
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      )}

      {/* MODAL CONSULTATION DOSSIER MÉDICAL JOINT AU RDV */}
      {viewingRecordApt && (
        <div style={{
          position: 'fixed',
          inset: 0,
          background: 'rgba(11, 20, 16, 0.72)',
          backdropFilter: 'blur(6px)',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          zIndex: 9999,
          padding: '1rem'
        }}>
          <div style={{
            background: '#fff',
            borderRadius: '20px',
            width: '100%',
            maxWidth: '560px',
            boxShadow: '0 24px 48px rgba(0,0,0,0.22)',
            overflow: 'hidden'
          }}>
            <div style={{
              background: 'linear-gradient(135deg, #14583D 0%, #5B8E7B 100%)',
              padding: '20px 24px',
              color: 'white',
              display: 'flex',
              justifyContent: 'space-between',
              alignItems: 'center'
            }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                <FileCheck2 size={22} />
                <div>
                  <div style={{ fontWeight: 900, fontSize: '16px' }}>Dossier Médical du Patient</div>
                  <div style={{ fontSize: '12px', opacity: 0.9 }}>{viewingRecordApt.patient_name} — RDV {viewingRecordApt.date_time}</div>
                </div>
              </div>
              <button
                onClick={() => setViewingRecordApt(null)}
                style={{ background: 'rgba(255,255,255,0.2)', border: 'none', borderRadius: '8px', color: 'white', cursor: 'pointer', padding: '6px' }}
              >
                ✕
              </button>
            </div>

            <div style={{ padding: '24px' }}>
              <div style={{ background: '#f2f7f4', borderRadius: '12px', padding: '16px', marginBottom: '16px', borderLeft: '4px solid #14583D' }}>
                <div style={{ fontSize: '11px', fontWeight: 800, color: '#14583D', textTransform: 'uppercase', marginBottom: '6px' }}>
                  Catégorie du document
                </div>
                <div style={{ fontWeight: 800, fontSize: '15px', color: '#1A1C1B' }}>
                  📁 {viewingRecordApt.medical_record?.category || 'Comptes-rendus médicaux'}
                </div>
                <div style={{ fontSize: '13px', color: '#56605B', marginTop: '4px' }}>
                  Pièce : <strong>{viewingRecordApt.medical_record?.document_name || 'Document médical numérisé'}</strong>
                </div>
              </div>

              <div style={{ marginBottom: '16px' }}>
                <div style={{ fontSize: '12px', fontWeight: 800, color: '#1A1C1B', marginBottom: '6px' }}>Observations & Antécédents transmis :</div>
                <div style={{ background: '#FAFBFB', border: '1px solid #E5E7EB', borderRadius: '10px', padding: '12px', fontSize: '13px', color: '#374151', minHeight: '60px' }}>
                  {viewingRecordApt.medical_record?.description || 'Aucune observation textuelle renseignée par le patient.'}
                </div>
              </div>

              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px', marginTop: '20px' }}>
                <button 
                  className="btn btn-secondary" 
                  onClick={() => setViewingRecordApt(null)}
                >
                  Fermer
                </button>
                {viewingRecordApt.status === 'en_attente' && (
                  <button 
                    className="btn btn-primary"
                    onClick={() => {
                      handleUpdateStatus(viewingRecordApt.id, 'confirmé');
                      setViewingRecordApt(null);
                    }}
                  >
                    Valider ce Rendez-vous
                  </button>
                )}
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
