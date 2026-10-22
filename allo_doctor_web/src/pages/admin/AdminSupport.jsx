import React, { useState } from 'react';
import { 
  ShieldAlert, 
  Search, 
  MessageSquare, 
  CheckCircle, 
  AlertTriangle, 
  Send, 
  User, 
  Stethoscope, 
  Pill, 
  Building2, 
  DollarSign, 
  ChevronRight,
  ShieldCheck
} from 'lucide-react';
import { safeLower } from '../../utils/text';

export const AdminSupport = ({ 
  tickets, 
  setTickets, 
  activeTicket, 
  setActiveTicket, 
  onShowToast 
}) => {
  const [filterRequester, setFilterRequester] = useState('all'); // all, Patient, Médecin, Pharmacie, Clinique
  const [filterStatus, setFilterStatus] = useState('all'); // all, Ouvert, En cours, Résolu, Litige
  const [searchQuery, setSearchQuery] = useState('');
  const [adminReplyText, setAdminReplyText] = useState('');

  // Filtrage des tickets
  const filteredTickets = tickets.filter(t => {
    const matchReq = filterRequester === 'all' || safeLower(t.requesterType).includes(safeLower(filterRequester));
    const matchStatus = filterStatus === 'all' || t.status === filterStatus;
    const needle = safeLower(searchQuery);
    const matchSearch = safeLower(t.id).includes(needle) ||
      safeLower(t.requesterName).includes(needle) ||
      safeLower(t.subject).includes(needle);
    return matchReq && matchStatus && matchSearch;
  });

  const countOpen = tickets.filter(t => t.status === 'Ouvert').length;
  const countInProgress = tickets.filter(t => t.status === 'En cours').length;
  const countLitige = tickets.filter(t => t.status === 'Litige' || t.isLitige).length;
  const countResolved = tickets.filter(t => t.status === 'Résolu').length;

  // Traiter un ticket : changement de statut
  const handleUpdateStatus = (ticketId, nextStatus) => {
    setTickets(prev => prev.map(t => {
      if (t.id === ticketId) {
        return { ...t, status: nextStatus, updatedAt: 'À l\'instant' };
      }
      return t;
    }));
    if (activeTicket && activeTicket.id === ticketId) {
      setActiveTicket(prev => ({ ...prev, status: nextStatus, updatedAt: 'À l\'instant' }));
    }
    onShowToast(`Ticket ${ticketId} mis à jour : Statut "${nextStatus}"`);
  };

  // Envoi d'une réponse officielle depuis le centre de support
  const handleSendReply = (e) => {
    e?.preventDefault();
    if (!adminReplyText.trim() || !activeTicket) return;

    const newMsg = {
      sender: 'Superviseur Support Allo Doctor',
      role: 'admin',
      text: adminReplyText.trim(),
      time: 'À l\'instant'
    };

    const updated = {
      ...activeTicket,
      messages: [...(activeTicket.messages || []), newMsg],
      status: activeTicket.status === 'Ouvert' ? 'En cours' : activeTicket.status,
      updatedAt: 'À l\'instant'
    };

    setTickets(prev => prev.map(t => t.id === activeTicket.id ? updated : t));
    setActiveTicket(updated);
    setAdminReplyText('');
    onShowToast(`Réponse transmise à ${activeTicket.requesterName}`);
  };

  // Traitement d'un litige : remboursement / arbitrage
  const handleArbitrateRefund = (ticket) => {
    handleUpdateStatus(ticket.id, 'Résolu');
    onShowToast(`Arbitrage validé : Remboursement de ${ticket.disputedAmount || '350 F CFA'} ordonné pour le patient`);
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
      {/* 5.5.3 : EN-TÊTE SUPPORT ET LITIGES */}
      <div style={{
        background: 'linear-gradient(135deg, #1A1C1B 0%, #25674D 100%)',
        borderRadius: '20px',
        padding: '24px 30px',
        color: 'white',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
        flexWrap: 'wrap',
        gap: '16px',
        boxShadow: '0 8px 24px rgba(0, 0, 0, 0.2)'
      }}>
        <div>
          <div style={{ 
            display: 'inline-flex', 
            alignItems: 'center', 
            gap: '6px', 
            background: 'rgba(255, 255, 255, 0.15)', 
            padding: '4px 12px', 
            borderRadius: '20px', 
            fontSize: '12px', 
            fontWeight: 800, 
            marginBottom: '8px' 
          }}>
            <ShieldAlert size={14} color="#FFB300" />
            CENTRE DE SUPPORT • ARBITRAGE & LITIGES
          </div>
          <h1 style={{ fontSize: '26px', fontWeight: 900, margin: '2px 0 6px 0' }}>
            Centre de Support et Résolution des Litiges
          </h1>
          <p style={{ opacity: 0.9, fontSize: '13px', maxWidth: '680px' }}>
            Traitement centralisé des demandes d'assistance et litiges ouverts par les patients et les professionnels de santé.
          </p>
        </div>

        {/* Compteurs */}
        <div style={{ display: 'flex', gap: '10px' }}>
          <div style={{ background: 'rgba(255,255,255,0.12)', padding: '8px 14px', borderRadius: '12px', textAlign: 'center' }}>
            <div style={{ fontSize: '18px', fontWeight: 900, color: '#f87171' }}>{countOpen}</div>
            <div style={{ fontSize: '10px', textTransform: 'uppercase' }}>Ouverts</div>
          </div>
          <div style={{ background: 'rgba(255,255,255,0.12)', padding: '8px 14px', borderRadius: '12px', textAlign: 'center' }}>
            <div style={{ fontSize: '18px', fontWeight: 900, color: '#FFB300' }}>{countLitige}</div>
            <div style={{ fontSize: '10px', textTransform: 'uppercase' }}>Litiges</div>
          </div>
          <div style={{ background: 'rgba(255,255,255,0.12)', padding: '8px 14px', borderRadius: '12px', textAlign: 'center' }}>
            <div style={{ fontSize: '18px', fontWeight: 900, color: '#4ade80' }}>{countResolved}</div>
            <div style={{ fontSize: '10px', textTransform: 'uppercase' }}>Résolus</div>
          </div>
        </div>
      </div>

      {/* BARRE DE FILTRES */}
      <div className="card" style={{ margin: 0, padding: '16px 20px' }}>
        <div style={{ display: 'flex', flexWrap: 'wrap', alignItems: 'center', justifyContent: 'space-between', gap: '14px' }}>
          {/* Filtres par type de demandeur : Patients ou Professionnels */}
          <div style={{ display: 'flex', gap: '6px', background: '#F2F5F4', padding: '4px', borderRadius: '10px', flexWrap: 'wrap' }}>
            {[
              { id: 'all', label: 'Tous les Demandeurs' },
              { id: 'Patient', label: 'Patients' },
              { id: 'Médecin', label: 'Médecins' },
              { id: 'Pharmacie', label: 'Pharmacies' },
              { id: 'Clinique', label: 'Cliniques' },
            ].map(f => (
              <button
                key={f.id}
                onClick={() => setFilterRequester(f.id)}
                style={{
                  padding: '6px 12px',
                  borderRadius: '8px',
                  border: 'none',
                  fontSize: '11px',
                  fontWeight: 700,
                  cursor: 'pointer',
                  background: filterRequester === f.id ? '#14583D' : 'transparent',
                  color: filterRequester === f.id ? 'white' : '#56605B',
                  transition: 'all 0.15s ease'
                }}
              >
                {f.label}
              </button>
            ))}
          </div>

          {/* Filtre statut et recherche */}
          <div style={{ display: 'flex', alignItems: 'center', gap: '10px', flexWrap: 'wrap' }}>
            <select
              value={filterStatus}
              onChange={(e) => setFilterStatus(e.target.value)}
              style={{
                padding: '8px 12px',
                borderRadius: '8px',
                border: '1px solid #DADDDD',
                fontSize: '12px',
                fontWeight: 600,
                color: '#1A1C1B',
                background: 'white',
                outline: 'none'
              }}
            >
              <option value="all">Tous les Statuts</option>
              <option value="Ouvert">🔴 Ouvert ({countOpen})</option>
              <option value="Litige">⚠️ Litige Actif ({countLitige})</option>
              <option value="En cours">⏳ En cours ({countInProgress})</option>
              <option value="Résolu">✓ Résolu ({countResolved})</option>
            </select>

            <div style={{ display: 'flex', alignItems: 'center', background: '#F2F5F4', borderRadius: '8px', padding: '6px 12px', gap: '6px' }}>
              <Search size={14} color="#9CA3AF" />
              <input 
                type="text" 
                placeholder="Réf ticket, nom, sujet..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                style={{ border: 'none', background: 'transparent', outline: 'none', fontSize: '12px', width: '180px' }}
              />
            </div>
          </div>
        </div>
      </div>

      {/* DISPOSITION EN 2 COLONNES : LISTE DES TICKETS + ACCÈS DIRECT AU CENTRE DE SUPPORT */}
      <div style={{
        display: 'grid',
        gridTemplateColumns: activeTicket ? '1.1fr 1.3fr' : '1fr',
        gap: '20px',
        alignItems: 'start'
      }}>
        {/* COLONNE GAUCHE : LISTE DES TICKETS */}
        <div className="card" style={{ margin: 0 }}>
          <div className="card-header">
            <h3 className="card-title" style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
              <MessageSquare size={18} color="#14583D" />
              Tickets Ouverts ({filteredTickets.length})
            </h3>
            <span style={{ fontSize: '11px', color: '#56605B' }}>Sélectionnez un ticket pour ouvrir le centre de support</span>
          </div>

          <div className="card-body" style={{ padding: '8px' }}>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '8px', maxHeight: '680px', overflowY: 'auto' }}>
              {filteredTickets.length === 0 ? (
                <div style={{ textAlign: 'center', padding: '40px 20px', color: '#56605B' }}>
                  <CheckCircle size={36} color="#25674D" style={{ margin: '0 auto 10px auto' }} />
                  <div style={{ fontWeight: 700 }}>Aucun ticket correspondant</div>
                  <div style={{ fontSize: '12px' }}>Tous les litiges de ce filtre ont été traités.</div>
                </div>
              ) : (
                filteredTickets.map(t => {
                  const isSelected = activeTicket?.id === t.id;
                  const isMed = safeLower(t.requesterType).includes('médecin');
                  const isPharma = safeLower(t.requesterType).includes('pharmacie');
                  const isClinic = safeLower(t.requesterType).includes('clinique');

                  return (
                    <div
                      key={t.id}
                      onClick={() => setActiveTicket(t)}
                      style={{
                        padding: '14px',
                        borderRadius: '12px',
                        border: isSelected ? '2px solid #14583D' : '1px solid #E5E7EB',
                        background: isSelected ? '#e8efe850' : t.priority === 'Urgente' ? '#fffbfb' : '#ffffff',
                        cursor: 'pointer',
                        transition: 'all 0.15s ease',
                        boxShadow: isSelected ? '0 4px 12px rgba(20, 88, 61, 0.12)' : 'none'
                      }}
                    >
                      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '8px' }}>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                          <span style={{
                            fontSize: '10px',
                            fontWeight: 800,
                            padding: '2px 6px',
                            borderRadius: '4px',
                            background: t.priority === 'Urgente' ? '#fbebeb' : t.priority === 'Haute' ? '#fff8e1' : '#f0f4f2',
                            color: t.priority === 'Urgente' ? '#BE3232' : t.priority === 'Haute' ? '#d97706' : '#14583D'
                          }}>
                            {t.priority}
                          </span>
                          <code style={{ fontSize: '11px', fontWeight: 700, color: '#56605B' }}>{t.id}</code>
                          {t.isLitige && (
                            <span style={{ fontSize: '10px', fontWeight: 800, padding: '2px 6px', borderRadius: '4px', background: '#fef1ec', color: '#F87849' }}>
                              LITIGE
                            </span>
                          )}
                        </div>

                        <span className={`badge ${
                          t.status === 'Résolu' ? 'badge-success' : 
                          t.status === 'En cours' ? 'badge-warning' : 
                          t.status === 'Litige' ? 'badge-danger' : 'badge-danger'
                        }`}>
                          {t.status}
                        </span>
                      </div>

                      <div style={{ fontWeight: 800, fontSize: '14px', color: '#1A1C1B', marginBottom: '4px' }}>
                        {t.subject}
                      </div>

                      <div style={{ fontSize: '12px', color: '#56605B', display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginTop: '6px' }}>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                          <div style={{
                            width: 20,
                            height: 20,
                            borderRadius: '50%',
                            background: isClinic ? '#e8efe8' : isPharma ? '#fff8e1' : isMed ? '#edf4f1' : '#f0f4f2',
                            color: isClinic ? '#14583D' : isPharma ? '#d97706' : isMed ? '#5B8E7B' : '#1A1C1B',
                            display: 'flex',
                            alignItems: 'center',
                            justifyContent: 'center',
                            fontSize: '10px'
                          }}>
                            {isClinic ? <Building2 size={11} /> : isPharma ? <Pill size={11} /> : isMed ? <Stethoscope size={11} /> : <User size={11} />}
                          </div>
                          <span><strong>{t.requesterName}</strong> ({t.requesterType})</span>
                        </div>
                        <span style={{ fontSize: '11px', color: '#9CA3AF' }}>{t.date}</span>
                      </div>

                      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginTop: '10px', paddingTop: '8px', borderTop: '1px solid #f0f0f0' }}>
                        <span style={{ fontSize: '11px', color: '#56605B' }}>
                          Catégorie : <strong>{t.category}</strong>
                        </span>
                        <div style={{ fontSize: '11px', color: '#14583D', fontWeight: 700, display: 'flex', alignItems: 'center', gap: '3px' }}>
                          <span>Ouvrir support</span>
                          <ChevronRight size={12} />
                        </div>
                      </div>
                    </div>
                  );
                })
              )}
            </div>
          </div>
        </div>

        {/* COLONNE DROITE : ACCÈS DIRECT AU CENTRE DE SUPPORT (TRAITEMENT DU TICKET) */}
        {activeTicket ? (
          <div className="card" style={{ margin: 0, border: '1px solid #14583D30', boxShadow: '0 8px 24px rgba(20, 88, 61, 0.08)' }}>
            <div className="card-header" style={{ background: '#F8F9FA' }}>
              <div>
                <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <code style={{ background: '#e8efe8', color: '#14583D', padding: '3px 8px', borderRadius: '4px', fontWeight: 800, fontSize: '12px' }}>
                    {activeTicket.id}
                  </code>
                  <span className={`badge ${
                    activeTicket.status === 'Résolu' ? 'badge-success' : 'badge-warning'
                  }`}>
                    {activeTicket.status}
                  </span>
                  <span style={{ fontSize: '11px', color: '#56605B' }}>
                    Priorité : <strong>{activeTicket.priority}</strong>
                  </span>
                </div>
                <h3 style={{ fontSize: '16px', fontWeight: 900, color: '#1A1C1B', margin: '6px 0 2px 0' }}>
                  {activeTicket.subject}
                </h3>
              </div>

              <div style={{ display: 'flex', gap: '6px' }}>
                <button
                  onClick={() => handleUpdateStatus(activeTicket.id, 'Résolu')}
                  style={{
                    background: '#14583D',
                    color: 'white',
                    border: 'none',
                    borderRadius: '8px',
                    padding: '6px 12px',
                    fontSize: '11px',
                    fontWeight: 700,
                    cursor: 'pointer',
                    display: 'flex',
                    alignItems: 'center',
                    gap: '4px'
                  }}
                >
                  <CheckCircle size={13} />
                  <span>Résoudre</span>
                </button>
                <button
                  onClick={() => setActiveTicket(null)}
                  style={{ background: 'transparent', border: '1px solid #DADDDD', borderRadius: '8px', padding: '6px 10px', fontSize: '11px', cursor: 'pointer' }}
                >
                  Fermer
                </button>
              </div>
            </div>

            <div className="card-body" style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
              {/* Informations du Demandeur & Contexte Transactionnel */}
              <div style={{
                background: '#F8F9FA',
                borderRadius: '12px',
                padding: '14px',
                display: 'grid',
                gridTemplateColumns: '1fr 1fr',
                gap: '12px',
                fontSize: '12px'
              }}>
                <div>
                  <span style={{ color: '#56605B', fontSize: '10px', textTransform: 'uppercase', display: 'block' }}>Demandeur :</span>
                  <strong>{activeTicket.requesterName}</strong> ({activeTicket.requesterType})
                  <div style={{ color: '#56605B', fontSize: '11px', marginTop: '2px' }}>
                    Tél : {activeTicket.requesterPhone || '+212 661 23 45 67'}
                  </div>
                </div>

                <div>
                  <span style={{ color: '#56605B', fontSize: '10px', textTransform: 'uppercase', display: 'block' }}>Dossier rattaché / Litige :</span>
                  <strong>{activeTicket.relatedEntity || 'Consultation #RDV-8820'}</strong>
                  {activeTicket.disputedAmount && (
                    <div style={{ color: '#BE3232', fontWeight: 800, marginTop: '2px' }}>
                      Montant contesté : {activeTicket.disputedAmount}
                    </div>
                  )}
                </div>
              </div>

              {/* Boîte d'action d'arbitrage de litige si applicable */}
              {activeTicket.isLitige && activeTicket.status !== 'Résolu' && (
                <div style={{
                  background: '#fef1ec',
                  border: '1px solid #F8784940',
                  borderRadius: '12px',
                  padding: '14px',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'space-between',
                  gap: '12px',
                  flexWrap: 'wrap'
                }}>
                  <div>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '6px', color: '#F87849', fontWeight: 800, fontSize: '13px' }}>
                      <AlertTriangle size={16} />
                      Procédure d'Arbitrage et Dédommagement
                    </div>
                    <p style={{ fontSize: '11px', color: '#56605B', margin: '4px 0 0 0' }}>
                      Un litige financier est signalé pour ce ticket. En tant qu'administrateur, vous pouvez débloquer le remboursement ou valider la prestation.
                    </p>
                  </div>

                  <button
                    onClick={() => handleArbitrateRefund(activeTicket)}
                    style={{
                      background: '#14583D',
                      color: 'white',
                      border: 'none',
                      borderRadius: '8px',
                      padding: '8px 16px',
                      fontSize: '11px',
                      fontWeight: 800,
                      cursor: 'pointer',
                      display: 'flex',
                      alignItems: 'center',
                      gap: '6px'
                    }}
                  >
                    <DollarSign size={14} />
                    <span>Arbitrer & Rembourser Patient</span>
                  </button>
                </div>
              )}

              {/* Fil de discussion et historique des échanges */}
              <div>
                <h4 style={{ fontSize: '13px', fontWeight: 800, color: '#1A1C1B', marginBottom: '8px' }}>
                  Historique des Échanges & Messages :
                </h4>

                <div style={{
                  display: 'flex',
                  flexDirection: 'column',
                  gap: '10px',
                  maxHeight: '260px',
                  overflowY: 'auto',
                  padding: '10px',
                  background: '#F8F9FA',
                  borderRadius: '10px',
                  border: '1px solid #E5E7EB'
                }}>
                  {(activeTicket.messages || [
                    { sender: activeTicket.requesterName, role: 'user', text: activeTicket.initialMessage || 'Bonjour, j\'ai rencontré un incident lors de ma consultation.', time: activeTicket.date }
                  ]).map((msg, idx) => {
                    const isAdmin = msg.role === 'admin';
                    return (
                      <div
                        key={idx}
                        style={{
                          alignSelf: isAdmin ? 'flex-end' : 'flex-start',
                          maxWidth: '85%',
                          background: isAdmin ? '#14583D' : 'white',
                          color: isAdmin ? 'white' : '#1A1C1B',
                          padding: '10px 14px',
                          borderRadius: isAdmin ? '12px 12px 2px 12px' : '12px 12px 12px 2px',
                          border: isAdmin ? 'none' : '1px solid #E5E7EB',
                          boxShadow: '0 2px 4px rgba(0,0,0,0.04)'
                        }}
                      >
                        <div style={{ fontSize: '10px', opacity: 0.8, marginBottom: '4px', fontWeight: 700 }}>
                          {msg.sender} • {msg.time}
                        </div>
                        <div style={{ fontSize: '12px', lineHeight: 1.4 }}>
                          {msg.text}
                        </div>
                      </div>
                    );
                  })}
                </div>
              </div>

              {/* Formulaire de réponse directe par l'administrateur */}
              <form onSubmit={handleSendReply} style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
                <label style={{ fontSize: '12px', fontWeight: 700, color: '#1A1C1B' }}>
                  Répondre directement depuis le Centre de Support :
                </label>
                <div style={{ display: 'flex', gap: '8px' }}>
                  <input
                    type="text"
                    value={adminReplyText}
                    onChange={(e) => setAdminReplyText(e.target.value)}
                    placeholder="Tapez votre réponse officielle d'administrateur..."
                    style={{
                      flex: 1,
                      padding: '10px 14px',
                      borderRadius: '8px',
                      border: '1px solid #DADDDD',
                      fontSize: '12px',
                      outline: 'none'
                    }}
                  />
                  <button
                    type="submit"
                    style={{
                      background: '#14583D',
                      color: 'white',
                      border: 'none',
                      borderRadius: '8px',
                      padding: '0 16px',
                      fontWeight: 700,
                      fontSize: '12px',
                      cursor: 'pointer',
                      display: 'flex',
                      alignItems: 'center',
                      gap: '6px'
                    }}
                  >
                    <Send size={14} />
                    <span>Envoyer</span>
                  </button>
                </div>

                {/* Modèles de réponses rapides */}
                <div style={{ display: 'flex', gap: '6px', flexWrap: 'wrap', marginTop: '4px' }}>
                  <span style={{ fontSize: '11px', color: '#56605B', alignSelf: 'center' }}>Modèles rapides :</span>
                  {[
                    'Dossier pris en charge par le médecin référent',
                    'Remboursement initié sous 24h',
                    'Identifiants réinitialisés avec succès',
                    'Litige classé résolu sans suite'
                  ].map((tpl, i) => (
                    <button
                      key={i}
                      type="button"
                      onClick={() => setAdminReplyText(tpl)}
                      style={{
                        background: '#e8efe8',
                        color: '#14583D',
                        border: 'none',
                        padding: '3px 8px',
                        borderRadius: '6px',
                        fontSize: '10px',
                        fontWeight: 600,
                        cursor: 'pointer'
                      }}
                    >
                      {tpl}
                    </button>
                  ))}
                </div>
              </form>
            </div>
          </div>
        ) : (
          <div className="card" style={{ margin: 0, padding: '40px 20px', textAlign: 'center', color: '#56605B' }}>
            <ShieldCheck size={48} color="#5B8E7B" style={{ margin: '0 auto 14px auto' }} />
            <h3 style={{ fontSize: '16px', fontWeight: 800, color: '#1A1C1B' }}>
              Accès Direct au Centre de Support
            </h3>
            <p style={{ fontSize: '12px', maxWidth: '420px', margin: '6px auto 0 auto' }}>
              Cliquez sur n'importe quel ticket dans la liste de gauche pour afficher l'historique, arbitrer les litiges et envoyer des réponses officielles.
            </p>
          </div>
        )}
      </div>
    </div>
  );
};
