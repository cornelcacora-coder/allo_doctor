import React, { useState, useEffect } from 'react';
import { 
  Building2, 
  ShieldAlert, 
  Cross, 
  Users, 
  Phone, 
  MapPin, 
  Clock, 
  CheckCircle2, 
  FileText, 
  Activity, 
  Plus, 
  Minus, 
  Download, 
  CheckCircle,
  CreditCard,
  ArrowUpRight,
  ShieldCheck,
  FileCheck2,
  X
} from 'lucide-react';
import { firestoreService } from '../../services/firestoreService';
import { useAuth } from '../../context/AuthContext';

export const ClinicView = ({ subTab = 'clinic_home', setSubTab }) => {
  const { currentUser } = useAuth();
  const [sosList, setSosList] = useState([]);
  const [availableBeds, setAvailableBeds] = useState(14);
  const [toastMessage, setToastMessage] = useState('');
  const totalBeds = 32;

  // Modal Admission Patient
  const [modalAdmission, setModalAdmission] = useState(false);
  const [admPatientName, setAdmPatientName] = useState('');
  const [admDepartment, setAdmDepartment] = useState('Chirurgie Générale');
  const [admRoomType, setAdmRoomType] = useState('Chambre Individuelle');

  // WALLET DE LA CLINIQUE (Fidèle à clinic_wallet de Flutter)
  const [clinicRevenue, setClinicRevenue] = useState(185400);
  const [invoices, setInvoices] = useState([
    { id: 'FAC-2026-081', patient: 'Lhoussaine B.', service: 'Hospitalisation 3j + Bloc opératoire', amount: 8400, status: 'Payée', date: 'Aujourd\'hui' },
    { id: 'FAC-2026-080', patient: 'Samira M.', service: 'Maternité & Séjour néonatal', amount: 6200, status: 'Prise en charge CNSS', date: 'Hier' },
    { id: 'FAC-2026-079', patient: 'Tarik E.', service: 'Urgences & Scanner thoracique', amount: 1950, status: 'Payée', date: '10 Oct' },
  ]);

  const showToast = (msg) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(''), 3000);
  };

  useEffect(() => {
    const unsubSos = firestoreService.listenSos(setSosList);
    return () => unsubSos && unsubSos();
  }, []);

  const handleDispatchAmbulance = (sosId) => {
    setSosList(prev => prev.map(s => s.id === sosId ? { ...s, status: 'Ambulance dépêchée (Arrivée estimée : 7 min)' } : s));
    showToast('Ambulance SAMU dépêchée en urgence avec gyrophare !');
  };

  const handleAdjustBeds = (delta) => {
    const updated = Math.min(totalBeds, Math.max(0, availableBeds + delta));
    setAvailableBeds(updated);
    showToast(`Capacité mise à jour : ${updated} lits disponibles`);
  };

  const handleConfirmAdmission = (e) => {
    e.preventDefault();
    if (availableBeds > 0) {
      setAvailableBeds(prev => prev - 1);
      setModalAdmission(false);
      showToast(`Admission de ${admPatientName} confirmée en ${admDepartment} ! Lit attribué.`);
      setAdmPatientName('');
    } else {
      showToast('Aucun lit disponible pour le moment !');
    }
  };

  const labResults = [
    { id: '1', patient: 'Omar Filali', test: 'Bilan Cardiaque (Troponine, CPK)', date: 'Aujourd\'hui 11:20', status: 'Urgent', result: 'Anormal - Troponine élevée' },
    { id: '2', patient: 'Fatima Zahra', test: 'NFS & Plaquettes', date: 'Aujourd\'hui 09:45', status: 'Conforme', result: 'Hémoglobine 13.8 g/dL' },
    { id: '3', patient: 'Mohamed Tazi', test: 'Gazométrie Artérielle', date: 'Hier 18:30', status: 'Conforme', result: 'pH 7.39, PaO2 92 mmHg' },
  ];

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

      {/* Banner Clinique aux couleurs de l'application */}
      <div style={{
        background: 'linear-gradient(135deg, #14583D 0%, #4A8D72 100%)',
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
            <Building2 size={14} /> Pôle Hospitalier & Régulation des Urgences
          </div>
          <h2 style={{ fontSize: '26px', fontWeight: 900, marginBottom: '6px' }}>
            {currentUser?.display_name || 'Clinique Internationale Atlas'}
          </h2>
          <p style={{ opacity: 0.9, fontSize: '14px' }}>
            Supervision des admissions, lits d'hospitalisation et régulation des alertes SOS en direct.
          </p>
        </div>

        <div style={{ background: 'white', padding: '12px 20px', borderRadius: '14px', color: '#1A1C1B', textAlign: 'center' }}>
          <div style={{ fontSize: '11px', color: '#56605B', fontWeight: 800, textTransform: 'uppercase' }}>Urgences 24/7</div>
          <div style={{ fontSize: '18px', fontWeight: 900, color: '#BE3232' }}>SAMU ALLO DOCTOR</div>
        </div>
      </div>

      {/* Cartes Métriques Hospitalières */}
      <div className="dashboard-grid">
        <div className="stat-card" style={{ cursor: 'pointer' }} onClick={() => setSubTab('clinic_beds')}>
          <div>
            <div style={{ fontSize: '13px', color: '#56605B', fontWeight: 600 }}>Lits Disponibles</div>
            <div style={{ fontSize: '26px', fontWeight: 900, color: '#25674D' }}>{availableBeds} / {totalBeds}</div>
            <div style={{ fontSize: '12px', color: '#56605B', fontWeight: 600, marginTop: '4px' }}>
              Occupation : {Math.round(((totalBeds - availableBeds) / totalBeds) * 100)}%
            </div>
          </div>
          <div className="stat-icon-wrapper" style={{ background: '#e2f0e8', color: '#25674D' }}>
            <Cross size={24} />
          </div>
        </div>

        <div className="stat-card" style={{ cursor: 'pointer' }} onClick={() => setSubTab('clinic_sos')}>
          <div>
            <div style={{ fontSize: '13px', color: '#56605B', fontWeight: 600 }}>Alertes SOS Reçues</div>
            <div style={{ fontSize: '26px', fontWeight: 900, color: '#BE3232' }}>{sosList.length}</div>
            <div style={{ fontSize: '12px', color: '#BE3232', fontWeight: 700, marginTop: '4px' }}>
              Régulation mobile en direct
            </div>
          </div>
          <div className="stat-icon-wrapper" style={{ background: '#fbebeb', color: '#BE3232' }}>
            <ShieldAlert size={24} />
          </div>
        </div>

        <div className="stat-card" style={{ cursor: 'pointer' }} onClick={() => setSubTab('clinic_wallet')}>
          <div>
            <div style={{ fontSize: '13px', color: '#56605B', fontWeight: 600 }}>Facturation (Wallet)</div>
            <div style={{ fontSize: '24px', fontWeight: 900, color: '#14583D' }}>{clinicRevenue.toLocaleString()} F CFA</div>
            <div style={{ fontSize: '12px', color: '#25674D', fontWeight: 700, marginTop: '4px' }}>
              Comptabilité Clinique →
            </div>
          </div>
          <div className="stat-icon-wrapper" style={{ background: '#e8efe8', color: '#14583D' }}>
            <CreditCard size={24} />
          </div>
        </div>

        <div className="stat-card" style={{ cursor: 'pointer' }} onClick={() => setSubTab('clinic_lab')}>
          <div>
            <div style={{ fontSize: '13px', color: '#56605B', fontWeight: 600 }}>Analyses Labo</div>
            <div style={{ fontSize: '26px', fontWeight: 900, color: '#F87849' }}>{labResults.length} En cours</div>
            <div style={{ fontSize: '12px', color: '#F87849', fontWeight: 700, marginTop: '4px' }}>
              Résultats disponibles →
            </div>
          </div>
          <div className="stat-icon-wrapper" style={{ background: '#fef1ec', color: '#F87849' }}>
            <FileText size={24} />
          </div>
        </div>
      </div>

      {/* FACTURATION & WALLET CLINIQUE (FIDÈLE À clinic_wallet DE FLUTTER) */}
      {subTab === 'clinic_wallet' ? (
        <div className="card">
          <div className="card-header">
            <h3 className="card-title"><CreditCard size={20} color="#14583D" /> Facturation & Portefeuille Hospitalier</h3>
            <button 
              className="btn btn-primary"
              onClick={() => showToast('Export du grand livre des factures de la clinique en cours...')}
              style={{ padding: '6px 14px', fontSize: '12px' }}
            >
              <Download size={14} /> Exporter Grand Livre
            </button>
          </div>
          <div className="card-body">
            <div style={{ background: '#e8efe8', borderRadius: '16px', padding: '24px', marginBottom: '24px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <div>
                <span style={{ fontSize: '12px', fontWeight: 800, color: '#56605B', textTransform: 'uppercase' }}>Trésorerie & Encaissements Hospitaliers</span>
                <div style={{ fontSize: '32px', fontWeight: 900, color: '#14583D' }}>{clinicRevenue.toLocaleString()} F CFA</div>
                <span style={{ fontSize: '12px', color: '#56605B' }}>Flux de séjours hospitaliers & interventions chirurgicales</span>
              </div>
              <ShieldCheck size={48} color="#14583D" />
            </div>

            <h4 style={{ fontSize: '15px', fontWeight: 800, marginBottom: '12px' }}>Dernières Factures d'Hospitalisation</h4>
            <div className="custom-table-container">
              <table className="custom-table">
                <thead>
                  <tr>
                    <th>N° Facture</th>
                    <th>Patient</th>
                    <th>Prestation / Séjour</th>
                    <th>Date</th>
                    <th>Montant Total</th>
                    <th>Statut Paiement</th>
                  </tr>
                </thead>
                <tbody>
                  {invoices.map(inv => (
                    <tr key={inv.id}>
                      <td><code>{inv.id}</code></td>
                      <td><strong>{inv.patient}</strong></td>
                      <td>{inv.service}</td>
                      <td>{inv.date}</td>
                      <td><strong>{inv.amount.toLocaleString()} F CFA</strong></td>
                      <td>
                        <span className={`badge ${inv.status.includes('Payée') ? 'badge-success' : 'badge-info'}`}>
                          {inv.status}
                        </span>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      ) : subTab === 'clinic_beds' ? (
        <div className="card">
          <div className="card-header" style={{ flexWrap: 'wrap', gap: '12px' }}>
            <h3 className="card-title"><Cross size={20} color="#14583D" /> Gestion des Lits & Admissions</h3>
            <div style={{ display: 'flex', gap: '8px' }}>
              <button className="btn btn-secondary" onClick={() => handleAdjustBeds(-1)}>
                <Minus size={14} /> Libérer un lit (-1)
              </button>
              <button className="btn btn-secondary" onClick={() => handleAdjustBeds(1)}>
                <Plus size={14} /> Ajouter un lit (+1)
              </button>
              <button className="btn btn-primary" onClick={() => setModalAdmission(true)}>
                <Users size={14} /> Admettre un Patient
              </button>
            </div>
          </div>
          <div className="card-body">
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(180px, 1fr))', gap: '12px' }}>
              {Array.from({ length: totalBeds }).map((_, idx) => {
                const isOccupied = idx >= availableBeds;
                return (
                  <div key={idx} style={{
                    border: '1px solid',
                    borderColor: isOccupied ? '#BE3232' : '#25674D',
                    borderRadius: '12px',
                    padding: '14px',
                    background: isOccupied ? '#fbebeb' : '#e2f0e8',
                    textAlign: 'center'
                  }}>
                    <div style={{ fontSize: '12px', fontWeight: 800, color: isOccupied ? '#BE3232' : '#25674D' }}>
                      Lit n° {idx + 1}
                    </div>
                    <div style={{ fontSize: '13px', fontWeight: 700, marginTop: '4px' }}>
                      {isOccupied ? 'Occupé' : 'Disponible'}
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        </div>
      ) : subTab === 'clinic_lab' ? (
        <div className="card">
          <div className="card-header">
            <h3 className="card-title"><FileText size={20} color="#14583D" /> Résultats du Laboratoire d'Analyses</h3>
            <span className="badge badge-success">Validé par Biologiste</span>
          </div>
          <div className="card-body">
            <div className="custom-table-container">
              <table className="custom-table">
                <thead>
                  <tr>
                    <th>Patient</th>
                    <th>Type d'analyse</th>
                    <th>Heure prélèvement</th>
                    <th>Statut</th>
                    <th>Conclusion</th>
                    <th>Action</th>
                  </tr>
                </thead>
                <tbody>
                  {labResults.map(l => (
                    <tr key={l.id}>
                      <td><strong>{l.patient}</strong></td>
                      <td>{l.test}</td>
                      <td>{l.date}</td>
                      <td>
                        <span className={`badge ${l.status === 'Urgent' ? 'badge-danger' : 'badge-success'}`}>
                          {l.status}
                        </span>
                      </td>
                      <td>{l.result}</td>
                      <td>
                        <button 
                          className="btn btn-primary" 
                          onClick={() => showToast(`Téléchargement du rapport d'analyse de ${l.patient}`)}
                          style={{ padding: '4px 10px', fontSize: '11px' }}
                        >
                          <Download size={13} /> Rapport PDF
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      ) : (
        /* Tableau des Urgences SOS en Direct */
        <div className="card">
          <div className="card-header">
            <h3 className="card-title">
              <ShieldAlert size={20} color="#BE3232" /> 
              Régulation des Urgences SOS Mobile (Temps Réel)
            </h3>
            <span className="badge badge-danger">Liaison SAMU Active</span>
          </div>
          <div className="card-body">
            {sosList.length === 0 ? (
              <div style={{ textAlign: 'center', padding: '30px', color: '#9CA3AF' }}>
                Aucune urgence en attente.
              </div>
            ) : (
              <div style={{ display: 'flex', flexDirection: 'column', gap: '14px' }}>
                {sosList.map((sos) => (
                  <div 
                    key={sos.id} 
                    style={{
                      border: '1px solid #fbebeb',
                      borderRadius: '14px',
                      padding: '18px 20px',
                      background: '#fffbfb',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'space-between',
                      flexWrap: 'wrap',
                      gap: '12px'
                    }}
                  >
                    <div>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '4px' }}>
                        <span className="badge badge-danger" style={{ animation: 'pulse-sos 2s infinite' }}>ALERTE SOS</span>
                        <strong style={{ fontSize: '16px', color: '#1A1C1B' }}>{sos.patient_name}</strong>
                        <span style={{ fontSize: '12px', color: '#56605B' }}>({sos.phone})</span>
                      </div>
                      <div style={{ fontSize: '13px', color: '#BE3232', fontWeight: 800, marginBottom: '4px' }}>
                        Motif : {sos.emergency_type}
                      </div>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '6px', fontSize: '12px', color: '#56605B' }}>
                        <MapPin size={13} color="#9CA3AF" /> {sos.location}
                        <span style={{ margin: '0 6px' }}>•</span>
                        <Clock size={13} color="#9CA3AF" /> {sos.time || 'En direct'}
                      </div>
                    </div>

                    <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                      <div style={{ textAlign: 'right' }}>
                        <span style={{ fontSize: '11px', color: '#9CA3AF', textTransform: 'uppercase', fontWeight: 700 }}>Statut</span>
                        <div style={{ fontSize: '13px', fontWeight: 800, color: '#14583D' }}>{sos.status}</div>
                      </div>
                      <button 
                        className="btn btn-danger"
                        onClick={() => handleDispatchAmbulance(sos.id)}
                        style={{ padding: '8px 16px', fontSize: '13px' }}
                      >
                        Dépêcher Ambulance SAMU
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      )}

      {/* Modal Admission Patient */}
      {modalAdmission && (
        <div className="modal-overlay">
          <div className="modal-content" style={{ maxWidth: '480px' }}>
            <div className="card-header">
              <h3 className="card-title">Admission d'un Patient en Hospitalisation</h3>
              <button onClick={() => setModalAdmission(false)} style={{ border: 'none', background: 'transparent', cursor: 'pointer' }}>
                <X size={18} color="#9CA3AF" />
              </button>
            </div>
            <div className="card-body">
              <form onSubmit={handleConfirmAdmission}>
                <div className="form-group">
                  <label className="form-label">Nom complet du patient</label>
                  <input 
                    type="text" 
                    className="form-input" 
                    placeholder="Ex: Omar Filali" 
                    value={admPatientName}
                    onChange={(e) => setAdmPatientName(e.target.value)}
                    required
                  />
                </div>

                <div className="form-group">
                  <label className="form-label">Service d'admission</label>
                  <select 
                    className="form-select"
                    value={admDepartment}
                    onChange={(e) => setAdmDepartment(e.target.value)}
                  >
                    <option value="Chirurgie Générale">Chirurgie Générale</option>
                    <option value="Cardiologie Interventionnelle">Cardiologie Interventionnelle</option>
                    <option value="Soins Intensifs / Réanimation">Soins Intensifs / Réanimation</option>
                    <option value="Maternité & Obstétrique">Maternité & Obstétrique</option>
                    <option value="Urgences">Urgences</option>
                  </select>
                </div>

                <div className="form-group">
                  <label className="form-label">Type d'hébergement</label>
                  <select 
                    className="form-select"
                    value={admRoomType}
                    onChange={(e) => setAdmRoomType(e.target.value)}
                  >
                    <option value="Chambre Individuelle">Chambre Individuelle VIP</option>
                    <option value="Chambre Double">Chambre Double Standard</option>
                    <option value="Unité de Soins Intensifs">Box Réanimation</option>
                  </select>
                </div>

                <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px', marginTop: '16px' }}>
                  <button type="button" className="btn btn-secondary" onClick={() => setModalAdmission(false)}>
                    Annuler
                  </button>
                  <button type="submit" className="btn btn-primary">
                    Valider l'Admission
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
