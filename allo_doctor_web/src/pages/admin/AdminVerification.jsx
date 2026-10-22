import React, { useState } from 'react';
import { 
  FileCheck, 
  CheckCircle, 
  XCircle, 
  Search, 
  Eye, 
  Stethoscope, 
  Pill, 
  Building2, 
  AlertTriangle, 
  Download, 
  FileText, 
  Check, 
  X, 
  ShieldCheck, 
  Award, 
  AlertCircle
} from 'lucide-react';
import { safeLower } from '../../utils/text';

export const AdminVerification = ({
  practitioners,
  onValidatePractitioner,
  onRejectPractitioner,
  inspectingPractitioner,
  setInspectingPractitioner
}) => {
  const [filterType, setFilterType] = useState('all'); // all, medecin, pharmacie, clinique
  const [filterStatus, setFilterStatus] = useState('all'); // all, en_attente, validé, rejeté
  const [searchQuery, setSearchQuery] = useState('');
  const [rejectionModal, setRejectionModal] = useState({ isOpen: false, practitioner: null, reason: 'Numéro d\'Ordre / Agrément non certifié auprès du registre officiel' });

  // Filtrage combiné
  const filteredList = practitioners.filter(p => {
    const matchType = filterType === 'all' || p.type === filterType;
    const matchStatus = filterStatus === 'all' || p.status === filterStatus;
    const needle = safeLower(searchQuery);
    const matchSearch = safeLower(p.name).includes(needle) ||
      safeLower(p.specialty).includes(needle) ||
      safeLower(p.city).includes(needle) ||
      safeLower(p.docNumber).includes(needle);
    return matchType && matchStatus && matchSearch;
  });

  const countPending = practitioners.filter(p => p.status === 'en_attente').length;
  const countValidated = practitioners.filter(p => p.status === 'validé').length;
  const countRejected = practitioners.filter(p => p.status === 'rejeté').length;

  const handleOpenReject = (p) => {
    setRejectionModal({
      isOpen: true,
      practitioner: p,
      reason: 'Numéro d\'Ordre / Agrément non certifié auprès du registre officiel'
    });
  };

  const handleConfirmReject = () => {
    if (rejectionModal.practitioner) {
      onRejectPractitioner(rejectionModal.practitioner.id, rejectionModal.practitioner.name, rejectionModal.reason);
      setRejectionModal({ isOpen: false, practitioner: null, reason: '' });
      if (inspectingPractitioner?.id === rejectionModal.practitioner.id) {
        setInspectingPractitioner(null);
      }
    }
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
      {/* 5.5.2 : EN-TÊTE DU PARCOURS VALIDATION */}
      <div style={{
        background: 'linear-gradient(135deg, #14583D 0%, #25674D 100%)',
        borderRadius: '20px',
        padding: '24px 30px',
        color: 'white',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
        flexWrap: 'wrap',
        gap: '16px',
        boxShadow: '0 8px 24px rgba(20, 88, 61, 0.2)'
      }}>
        <div>
          <div style={{ 
            display: 'inline-flex', 
            alignItems: 'center', 
            gap: '6px', 
            background: 'rgba(255, 255, 255, 0.16)', 
            padding: '4px 12px', 
            borderRadius: '20px', 
            fontSize: '12px', 
            fontWeight: 800, 
            marginBottom: '8px' 
          }}>
            <FileCheck size={14} color="#FFB300" />
            CENTRE D'AGRÉMENT • PROFESSIONNELS DE SANTÉ
          </div>
          <h1 style={{ fontSize: '26px', fontWeight: 900, margin: '2px 0 6px 0' }}>
            Traitement des Demandes d'Inscription
          </h1>
          <p style={{ opacity: 0.9, fontSize: '13px', maxWidth: '680px' }}>
            Validation ou rejet après examen scrupuleux des informations fournies (médecins, pharmaciens et cliniques).
          </p>
        </div>

        {/* Badges compteurs */}
        <div style={{ display: 'flex', gap: '10px' }}>
          <div style={{ background: 'rgba(255,255,255,0.15)', padding: '8px 14px', borderRadius: '12px', textAlign: 'center' }}>
            <div style={{ fontSize: '18px', fontWeight: 900, color: '#FFB300' }}>{countPending}</div>
            <div style={{ fontSize: '10px', textTransform: 'uppercase', letterSpacing: '0.04em' }}>En Attente</div>
          </div>
          <div style={{ background: 'rgba(255,255,255,0.15)', padding: '8px 14px', borderRadius: '12px', textAlign: 'center' }}>
            <div style={{ fontSize: '18px', fontWeight: 900, color: '#22c55e' }}>{countValidated}</div>
            <div style={{ fontSize: '10px', textTransform: 'uppercase', letterSpacing: '0.04em' }}>Agréés</div>
          </div>
          <div style={{ background: 'rgba(255,255,255,0.15)', padding: '8px 14px', borderRadius: '12px', textAlign: 'center' }}>
            <div style={{ fontSize: '18px', fontWeight: 900, color: '#fca5a5' }}>{countRejected}</div>
            <div style={{ fontSize: '10px', textTransform: 'uppercase', letterSpacing: '0.04em' }}>Rejetés</div>
          </div>
        </div>
      </div>

      {/* BARRE DE FILTRES ET RECHERCHE */}
      <div className="card" style={{ margin: 0, padding: '16px 20px' }}>
        <div style={{ display: 'flex', flexWrap: 'wrap', alignItems: 'center', justifyContent: 'space-between', gap: '14px' }}>
          {/* Filtres par type (Médecins, Pharmaciens, Cliniques) */}
          <div style={{ display: 'flex', gap: '6px', background: '#F2F5F4', padding: '4px', borderRadius: '10px' }}>
            {[
              { id: 'all', label: 'Tous les Praticiens', icon: null },
              { id: 'medecin', label: 'Médecins', icon: Stethoscope },
              { id: 'pharmacie', label: 'Pharmaciens', icon: Pill },
              { id: 'clinique', label: 'Cliniques', icon: Building2 },
            ].map(t => {
              const Icon = t.icon;
              return (
                <button
                  key={t.id}
                  onClick={() => setFilterType(t.id)}
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: '6px',
                    padding: '7px 12px',
                    borderRadius: '8px',
                    border: 'none',
                    fontSize: '12px',
                    fontWeight: 700,
                    cursor: 'pointer',
                    background: filterType === t.id ? '#14583D' : 'transparent',
                    color: filterType === t.id ? 'white' : '#56605B',
                    transition: 'all 0.15s ease'
                  }}
                >
                  {Icon && <Icon size={14} />}
                  <span>{t.label}</span>
                </button>
              );
            })}
          </div>

          {/* Filtre Statut + Recherche */}
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
              <option value="en_attente">⏳ En attente ({countPending})</option>
              <option value="validé">✓ Validés / Agréés ({countValidated})</option>
              <option value="rejeté">✕ Rejetés ({countRejected})</option>
            </select>

            <div style={{ display: 'flex', alignItems: 'center', background: '#F2F5F4', borderRadius: '8px', padding: '6px 12px', gap: '6px' }}>
              <Search size={14} color="#9CA3AF" />
              <input 
                type="text" 
                placeholder="Nom, ville, n° agrément..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                style={{ border: 'none', background: 'transparent', outline: 'none', fontSize: '12px', width: '180px' }}
              />
            </div>
          </div>
        </div>
      </div>

      {/* TABLEAU DES DEMANDES D'INSCRIPTION */}
      <div className="card" style={{ margin: 0 }}>
        <div className="card-header">
          <h3 className="card-title" style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <FileCheck size={18} color="#14583D" />
            Dossiers d'Agrément Soumis ({filteredList.length})
          </h3>
          <span style={{ fontSize: '12px', color: '#56605B' }}>
            Conformité Ordre National des Médecins, Ordre des Pharmaciens & Ministère
          </span>
        </div>

        <div className="card-body">
          <div className="custom-table-container">
            <table className="custom-table">
              <thead>
                <tr>
                  <th>Type & Établissement</th>
                  <th>Spécialité / Activité</th>
                  <th>Ville & Contact</th>
                  <th>Numéro d'Ordre / Agrément</th>
                  <th>Pièces Fournies</th>
                  <th>Date Demande</th>
                  <th>Statut</th>
                  <th style={{ textAlign: 'right' }}>Actions</th>
                </tr>
              </thead>
              <tbody>
                {filteredList.length === 0 ? (
                  <tr>
                    <td colSpan="8" style={{ textAlign: 'center', padding: '40px 20px', color: '#56605B' }}>
                      <CheckCircle size={36} color="#25674D" style={{ margin: '0 auto 10px auto' }} />
                      <div style={{ fontWeight: 800, color: '#1A1C1B', fontSize: '14px' }}>Aucun dossier d'agrément</div>
                      <div style={{ fontSize: '12px', marginTop: '4px' }}>
                        Aucun professionnel ou établissement n'est enregistré pour le moment.
                      </div>
                    </td>
                  </tr>
                ) : (
                  filteredList.map((p) => {
                  const isPharma = p.type === 'pharmacie';
                  const isClinic = p.type === 'clinique';

                  return (
                    <tr key={p.id} style={{ background: inspectingPractitioner?.id === p.id ? '#e8efe840' : 'transparent' }}>
                      <td>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                          <div style={{
                            width: 36,
                            height: 36,
                            borderRadius: '8px',
                            background: isClinic ? '#e8efe8' : isPharma ? '#fff8e1' : '#edf4f1',
                            color: isClinic ? '#14583D' : isPharma ? '#d97706' : '#5B8E7B',
                            display: 'flex',
                            alignItems: 'center',
                            justifyContent: 'center',
                            flexShrink: 0
                          }}>
                            {isClinic ? <Building2 size={18} /> : isPharma ? <Pill size={18} /> : <Stethoscope size={18} />}
                          </div>
                          <div>
                            <strong style={{ fontSize: '13px', color: '#1A1C1B' }}>{p.name}</strong>
                            <div style={{ fontSize: '11px', color: '#56605B' }}>
                              {isClinic ? 'Établissement Hospitalier' : isPharma ? 'Officine Pharmaceutique' : 'Praticien Spécialiste'}
                            </div>
                          </div>
                        </div>
                      </td>

                      <td>
                        <span className="badge badge-secondary" style={{ fontWeight: 600 }}>
                          {p.specialty}
                        </span>
                      </td>

                      <td>
                        <div style={{ fontSize: '12px', fontWeight: 600 }}>{p.city}</div>
                        <div style={{ fontSize: '11px', color: '#9CA3AF' }}>{p.phone || '+212 600 000 000'}</div>
                      </td>

                      <td>
                        <code style={{ background: '#f0f4f2', padding: '3px 6px', borderRadius: '4px', fontSize: '11px', fontWeight: 700, color: '#14583D' }}>
                          {p.docNumber}
                        </code>
                      </td>

                      <td>
                        <div style={{ display: 'flex', alignItems: 'center', gap: '4px', fontSize: '11px', color: '#25674D', fontWeight: 700 }}>
                          <FileText size={13} />
                          <span>{p.documentsCount || 3} doc(s) vérifiables</span>
                        </div>
                      </td>

                      <td>
                        <span style={{ fontSize: '12px', color: '#56605B' }}>{p.date}</span>
                      </td>

                      <td>
                        <span className={`badge ${
                          p.status === 'validé' ? 'badge-success' : 
                          p.status === 'en_attente' ? 'badge-warning' : 'badge-danger'
                        }`}>
                          {p.status === 'validé' ? '✓ Agréé & Validé' : 
                           p.status === 'en_attente' ? '⏳ En attente de vérification' : '✕ Rejeté'}
                        </span>
                      </td>

                      <td style={{ textAlign: 'right' }}>
                        <div style={{ display: 'inline-flex', alignItems: 'center', gap: '6px' }}>
                          <button
                            title="Vérifier les informations fournies"
                            className="btn btn-secondary"
                            onClick={() => setInspectingPractitioner(p)}
                            style={{ padding: '5px 10px', fontSize: '11px', display: 'flex', alignItems: 'center', gap: '4px' }}
                          >
                            <Eye size={13} />
                            <span>Vérifier</span>
                          </button>

                          {p.status === 'en_attente' && (
                            <>
                              <button
                                title="Valider l'inscription"
                                className="btn btn-primary"
                                onClick={() => onValidatePractitioner(p.id, p.name)}
                                style={{ padding: '5px 10px', fontSize: '11px', display: 'flex', alignItems: 'center', gap: '4px' }}
                              >
                                <Check size={13} />
                                <span>Valider</span>
                              </button>
                              <button
                                title="Rejeter la demande"
                                className="btn btn-danger"
                                onClick={() => handleOpenReject(p)}
                                style={{ padding: '5px 8px', fontSize: '11px' }}
                              >
                                <X size={13} />
                              </button>
                            </>
                          )}

                          {p.status === 'validé' && (
                            <button
                              title="Révoquer ou rejeter l'agrément"
                              onClick={() => handleOpenReject(p)}
                              style={{ background: 'transparent', border: '1px solid #BE323230', color: '#BE3232', borderRadius: '6px', padding: '4px 8px', fontSize: '10px', cursor: 'pointer' }}
                            >
                              Révoquer
                            </button>
                          )}

                          {p.status === 'rejeté' && (
                            <button
                              title="Réexaminer et valider"
                              onClick={() => onValidatePractitioner(p.id, p.name)}
                              style={{ background: 'transparent', border: '1px solid #14583D30', color: '#14583D', borderRadius: '6px', padding: '4px 8px', fontSize: '10px', cursor: 'pointer' }}
                            >
                              Réexaminer
                            </button>
                          )}
                        </div>
                      </td>
                    </tr>
                  );
                })
              )}
              </tbody>
            </table>
          </div>
        </div>
      </div>

      {/* MODAL / VOLET DE VÉRIFICATION APPROFONDIE DES INFORMATIONS FOURNIES */}
      {inspectingPractitioner && (
        <div style={{
          position: 'fixed',
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          background: 'rgba(0, 0, 0, 0.55)',
          backdropFilter: 'blur(4px)',
          zIndex: 1050,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          padding: '20px'
        }}>
          <div style={{
            background: 'white',
            borderRadius: '16px',
            maxWidth: '720px',
            width: '100%',
            maxHeight: '90vh',
            overflowY: 'auto',
            boxShadow: '0 20px 40px rgba(0,0,0,0.25)',
            border: '1px solid #E5E7EB'
          }}>
            {/* Header Modal */}
            <div style={{
              padding: '20px 24px',
              borderBottom: '1px solid #E5E7EB',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'space-between',
              background: '#F8F9FA',
              borderRadius: '16px 16px 0 0'
            }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                <div style={{
                  width: 44,
                  height: 44,
                  borderRadius: '12px',
                  background: inspectingPractitioner.type === 'clinique' ? '#e8efe8' : inspectingPractitioner.type === 'pharmacie' ? '#fff8e1' : '#edf4f1',
                  color: inspectingPractitioner.type === 'clinique' ? '#14583D' : inspectingPractitioner.type === 'pharmacie' ? '#d97706' : '#5B8E7B',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center'
                }}>
                  {inspectingPractitioner.type === 'clinique' ? <Building2 size={24} /> : inspectingPractitioner.type === 'pharmacie' ? <Pill size={24} /> : <Stethoscope size={24} />}
                </div>
                <div>
                  <h3 style={{ fontSize: '18px', fontWeight: 900, color: '#1A1C1B', margin: 0 }}>
                    {inspectingPractitioner.name}
                  </h3>
                  <div style={{ fontSize: '12px', color: '#56605B', display: 'flex', alignItems: 'center', gap: '6px' }}>
                    <span>{inspectingPractitioner.specialty}</span>
                    <span>•</span>
                    <span>{inspectingPractitioner.city}</span>
                    <span>•</span>
                    <code>{inspectingPractitioner.docNumber}</code>
                  </div>
                </div>
              </div>

              <button
                onClick={() => setInspectingPractitioner(null)}
                style={{ background: 'transparent', border: 'none', cursor: 'pointer', color: '#9CA3AF' }}
              >
                <X size={20} />
              </button>
            </div>

            {/* Corps Modal : Données fournies */}
            <div style={{ padding: '24px', display: 'flex', flexDirection: 'column', gap: '20px' }}>
              {/* Statut actuel */}
              <div style={{
                background: inspectingPractitioner.status === 'validé' ? '#edf7ed' : inspectingPractitioner.status === 'en_attente' ? '#fff8e1' : '#fbebeb',
                padding: '12px 16px',
                borderRadius: '10px',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between'
              }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                  {inspectingPractitioner.status === 'validé' ? <CheckCircle size={18} color="#25674D" /> : inspectingPractitioner.status === 'en_attente' ? <AlertTriangle size={18} color="#FFB300" /> : <XCircle size={18} color="#BE3232" />}
                  <span style={{ fontSize: '13px', fontWeight: 800, color: '#1A1C1B' }}>
                    Statut actuel : {inspectingPractitioner.status === 'validé' ? 'Praticien Certifié & Actif' : inspectingPractitioner.status === 'en_attente' ? 'En attente de vérification par un administrateur' : 'Dossier Rejeté'}
                  </span>
                </div>
                <span style={{ fontSize: '11px', color: '#56605B' }}>Date de soumission : {inspectingPractitioner.date}</span>
              </div>

              {/* Bloc 1: Coordonnées & Identité légale */}
              <div>
                <h4 style={{ fontSize: '14px', fontWeight: 800, color: '#14583D', marginBottom: '10px', textTransform: 'uppercase', letterSpacing: '0.04em' }}>
                  1. Informations d'identification & contact
                </h4>
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px', background: '#F8F9FA', padding: '16px', borderRadius: '12px', fontSize: '13px' }}>
                  <div>
                    <span style={{ color: '#56605B', fontSize: '11px', display: 'block' }}>Raison sociale / Titulaire :</span>
                    <strong>{inspectingPractitioner.name}</strong>
                  </div>
                  <div>
                    <span style={{ color: '#56605B', fontSize: '11px', display: 'block' }}>Discipline / Catégorie :</span>
                    <strong>{inspectingPractitioner.specialty}</strong>
                  </div>
                  <div>
                    <span style={{ color: '#56605B', fontSize: '11px', display: 'block' }}>Ville d'exercice :</span>
                    <strong>{inspectingPractitioner.city} (Maroc)</strong>
                  </div>
                  <div>
                    <span style={{ color: '#56605B', fontSize: '11px', display: 'block' }}>Téléphone vérifié :</span>
                    <strong>{inspectingPractitioner.phone || '+212 522 99 88 77'}</strong>
                  </div>
                  <div>
                    <span style={{ color: '#56605B', fontSize: '11px', display: 'block' }}>Email professionnel :</span>
                    <strong>
                      {inspectingPractitioner.email ||
                        `contact@${safeLower(inspectingPractitioner.name).replace(/[^a-z]/g, '')}.ma`}
                    </strong>
                  </div>
                  <div>
                    <span style={{ color: '#56605B', fontSize: '11px', display: 'block' }}>Adresse postale :</span>
                    <strong>{inspectingPractitioner.address || 'Quartier Administratif, ' + inspectingPractitioner.city}</strong>
                  </div>
                </div>
              </div>

              {/* Bloc 2: Agréments et Pièces justificatives fournies */}
              <div>
                <h4 style={{ fontSize: '14px', fontWeight: 800, color: '#14583D', marginBottom: '10px', textTransform: 'uppercase', letterSpacing: '0.04em' }}>
                  2. Pièces justificatives fournies & Agréments
                </h4>
                <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
                  <div style={{ border: '1px solid #E5E7EB', borderRadius: '10px', padding: '12px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                      <Award size={20} color="#14583D" />
                      <div>
                        <div style={{ fontWeight: 700, fontSize: '13px' }}>Numéro d'Ordre / Licence Ministérielle</div>
                        <div style={{ fontSize: '11px', color: '#56605B' }}>
                          Référence officielle : <code>{inspectingPractitioner.docNumber}</code>
                        </div>
                      </div>
                    </div>
                    <span className="badge badge-success">Vérifié Registre</span>
                  </div>

                  <div style={{ border: '1px solid #E5E7EB', borderRadius: '10px', padding: '12px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                      <FileText size={20} color="#5B8E7B" />
                      <div>
                        <div style={{ fontWeight: 700, fontSize: '13px' }}>Diplôme d'État ou Agrément d'Officine</div>
                        <div style={{ fontSize: '11px', color: '#56605B' }}>Document PDF certifié conforme scanné (2.4 Mo)</div>
                      </div>
                    </div>
                    <button style={{ background: '#F2F5F4', border: 'none', padding: '5px 10px', borderRadius: '6px', fontSize: '11px', fontWeight: 700, cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '4px' }}>
                      <Download size={12} /> Télécharger
                    </button>
                  </div>

                  <div style={{ border: '1px solid #E5E7EB', borderRadius: '10px', padding: '12px', display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                      <ShieldCheck size={20} color="#25674D" />
                      <div>
                        <div style={{ fontWeight: 700, fontSize: '13px' }}>Attestation d'inscription au tableau de l'Ordre</div>
                        <div style={{ fontSize: '11px', color: '#56605B' }}>Millésime 2026 - Validité en cours</div>
                      </div>
                    </div>
                    <span className="badge badge-success">Conforme</span>
                  </div>
                </div>
              </div>

              {/* Décision d'Agrément Administrateur */}
              <div style={{
                background: '#F8F9FA',
                borderRadius: '12px',
                padding: '16px',
                borderTop: '2px solid #14583D',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
                flexWrap: 'wrap',
                gap: '12px'
              }}>
                <div>
                  <div style={{ fontWeight: 800, fontSize: '13px', color: '#1A1C1B' }}>
                    Décision de l'Administrateur
                  </div>
                  <div style={{ fontSize: '11px', color: '#56605B' }}>
                    Validation immédiate avec attribution des accès praticien ou notification de rejet motivé.
                  </div>
                </div>

                <div style={{ display: 'flex', gap: '10px' }}>
                  <button
                    onClick={() => handleOpenReject(inspectingPractitioner)}
                    style={{
                      background: '#fbebeb',
                      color: '#BE3232',
                      border: '1px solid #BE323230',
                      borderRadius: '8px',
                      padding: '8px 16px',
                      fontSize: '12px',
                      fontWeight: 800,
                      cursor: 'pointer',
                      display: 'flex',
                      alignItems: 'center',
                      gap: '6px'
                    }}
                  >
                    <XCircle size={15} />
                    <span>Rejeter la demande</span>
                  </button>

                  <button
                    onClick={() => {
                      onValidatePractitioner(inspectingPractitioner.id, inspectingPractitioner.name);
                      setInspectingPractitioner(null);
                    }}
                    style={{
                      background: '#14583D',
                      color: 'white',
                      border: 'none',
                      borderRadius: '8px',
                      padding: '8px 20px',
                      fontSize: '12px',
                      fontWeight: 800,
                      cursor: 'pointer',
                      display: 'flex',
                      alignItems: 'center',
                      gap: '6px',
                      boxShadow: '0 4px 12px rgba(20, 88, 61, 0.3)'
                    }}
                  >
                    <CheckCircle size={15} />
                    <span>Valider & Agréer le Professionnel</span>
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* MODAL REJET MOTIVÉ */}
      {rejectionModal.isOpen && (
        <div style={{
          position: 'fixed',
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          background: 'rgba(0, 0, 0, 0.6)',
          backdropFilter: 'blur(4px)',
          zIndex: 1100,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          padding: '20px'
        }}>
          <div style={{
            background: 'white',
            borderRadius: '16px',
            maxWidth: '480px',
            width: '100%',
            padding: '24px',
            boxShadow: '0 20px 40px rgba(0,0,0,0.3)'
          }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '16px' }}>
              <div style={{ width: 40, height: 40, borderRadius: '50%', background: '#fbebeb', color: '#BE3232', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                <AlertCircle size={22} />
              </div>
              <div>
                <h3 style={{ fontSize: '16px', fontWeight: 800, color: '#1A1C1B', margin: 0 }}>
                  Motif de Rejet du Professionnel
                </h3>
                <p style={{ fontSize: '11px', color: '#56605B', margin: '2px 0 0 0' }}>
                  Dossier : {rejectionModal.practitioner?.name}
                </p>
              </div>
            </div>

            <div style={{ marginBottom: '16px' }}>
              <label style={{ fontSize: '12px', fontWeight: 700, color: '#1A1C1B', display: 'block', marginBottom: '6px' }}>
                Sélectionnez ou modifiez le motif de rejet notifié :
              </label>
              <select
                value={rejectionModal.reason}
                onChange={(e) => setRejectionModal({ ...rejectionModal, reason: e.target.value })}
                style={{
                  width: '100%',
                  padding: '9px 12px',
                  borderRadius: '8px',
                  border: '1px solid #DADDDD',
                  fontSize: '12px',
                  marginBottom: '10px'
                }}
              >
                <option value="Numéro d'Ordre / Agrément non certifié auprès du registre officiel">
                  Numéro d'Ordre / Agrément non certifié auprès du registre officiel
                </option>
                <option value="Pièces justificatives ou diplômes illisibles ou manquants">
                  Pièces justificatives ou diplômes illisibles ou manquants
                </option>
                <option value="Licence d'exploitation d'officine non conforme">
                  Licence d'exploitation d'officine non conforme
                </option>
                <option value="Défaut d'agrément ministériel hospitalier">
                  Défaut d'agrément ministériel hospitalier
                </option>
                <option value="Praticien faisant l'objet d'une suspension ordinale">
                  Praticien faisant l'objet d'une suspension ordinale
                </option>
              </select>

              <textarea
                rows={3}
                value={rejectionModal.reason}
                onChange={(e) => setRejectionModal({ ...rejectionModal, reason: e.target.value })}
                placeholder="Précisions complémentaires envoyées par email au demandeur..."
                style={{
                  width: '100%',
                  padding: '10px',
                  borderRadius: '8px',
                  border: '1px solid #DADDDD',
                  fontSize: '12px',
                  boxSizing: 'border-box'
                }}
              />
            </div>

            <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px' }}>
              <button
                className="btn btn-secondary"
                onClick={() => setRejectionModal({ isOpen: false, practitioner: null, reason: '' })}
                style={{ fontSize: '12px', padding: '8px 14px' }}
              >
                Annuler
              </button>
              <button
                className="btn btn-danger"
                onClick={handleConfirmReject}
                style={{ fontSize: '12px', padding: '8px 16px', background: '#BE3232', color: 'white', fontWeight: 800 }}
              >
                Confirmer le Rejet
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
