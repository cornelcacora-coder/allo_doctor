import React, { useState, useEffect } from 'react';
import { 
  Calendar, 
  Clock, 
  MapPin, 
  Phone, 
  Star, 
  CheckCircle, 
  Pill, 
  FileText, 
  ShieldAlert, 
  HeartPulse, 
  User, 
  Plus, 
  Send, 
  Download, 
  QrCode, 
  X,
  Droplet,
  Video,
  AlertCircle
} from 'lucide-react';
import { firestoreService } from '../../services/firestoreService';
import { useAuth } from '../../context/AuthContext';

export const PatientView = ({ subTab = 'patient_home', setSubTab }) => {
  const { currentUser } = useAuth();
  const [appointments, setAppointments] = useState([]);
  const [prescriptions, setPrescriptions] = useState([]);
  const [pharmacies, setPharmacies] = useState([]);
  const [doctors, setDoctors] = useState([]);
  
  // Modal de réservation de RDV
  const [bookingModalOpen, setBookingModalOpen] = useState(false);
  const [selectedDoctor, setSelectedDoctor] = useState(null);
  const [bookingDate, setBookingDate] = useState('2026-10-15');
  const [bookingTime, setBookingTime] = useState('14:30');
  const [bookingMode, setBookingMode] = useState('Cabinet');
  const [bookingSymptoms, setBookingSymptoms] = useState('');
  const [bookingSuccess, setBookingSuccess] = useState(false);

  // Modal Aperçu Ordonnance / PDF
  const [selectedPrescription, setSelectedPrescription] = useState(null);
  const [toastMessage, setToastMessage] = useState('');

  // BANQUE DE SANG (Feature fidèle à blood_bank_list dans Flutter)
  const [selectedBloodGroup, setSelectedBloodGroup] = useState('Tous');
  const [bloodRequestModal, setBloodRequestModal] = useState(false);
  const [selectedBloodBank, setSelectedBloodBank] = useState(null);
  const [bloodUnitsCount, setBloodUnitsCount] = useState(2);
  const [bloodUrgencyLevel, setBloodUrgencyLevel] = useState('Extrême urgence (< 1h)');

  const bloodBanks = [
    { id: 'bb1', name: 'Centre Régional de Transfusion Sanguine Casablanca', city: 'Casablanca', address: 'Quartier des Hôpitaux', phone: '+212 522 22 11 00', stocks: { 'O+': 24, 'A+': 18, 'B+': 9, 'AB+': 4, 'O-': 6, 'A-': 3, 'B-': 2, 'AB-': 1 } },
    { id: 'bb2', name: 'Banque de Sang Clinique Atlas', city: 'Casablanca', address: 'Bd Zerktouni', phone: '+212 522 99 88 77', stocks: { 'O+': 12, 'A+': 10, 'B+': 5, 'AB+': 2, 'O-': 3, 'A-': 1, 'B-': 0, 'AB-': 1 } },
    { id: 'bb3', name: 'Centre National de Transfusion Sanguine Rabat', city: 'Rabat', address: 'Avenue de la Victoire', phone: '+212 537 77 20 20', stocks: { 'O+': 35, 'A+': 28, 'B+': 14, 'AB+': 6, 'O-': 8, 'A-': 5, 'B-': 3, 'AB-': 2 } }
  ];

  const bloodGroups = ['Tous', 'O+', 'A+', 'B+', 'AB+', 'O-', 'A-', 'B-', 'AB-'];

  const showToast = (msg) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(''), 3000);
  };

  useEffect(() => {
    setDoctors(firestoreService.getDoctors());
    const unsubApp = firestoreService.listenAppointments(setAppointments);
    const unsubPresc = firestoreService.listenPrescriptions(setPrescriptions);
    const unsubPharm = firestoreService.listenPharmacies(setPharmacies);

    return () => {
      unsubApp && unsubApp();
      unsubPresc && unsubPresc();
      unsubPharm && unsubPharm();
    };
  }, []);

  const handleBookAppointment = async (e) => {
    e.preventDefault();
    if (!selectedDoctor) return;

    await firestoreService.createAppointment({
      patient_name: currentUser?.display_name || 'Karim Tazi',
      patient_phone: currentUser?.phoneNumber || '+212 661 23 45 67',
      patient_email: currentUser?.email || 'karim@allodoctor.ma',
      doctor_name: selectedDoctor.display_name,
      doctor_specialty: selectedDoctor.profCategory,
      date_time: `${bookingDate} - ${bookingTime}`,
      appointment_type: bookingMode.toLowerCase(),
      consult_mode: bookingMode,
      fee: selectedDoctor.fee,
      symptoms: bookingSymptoms || 'Consultation standard'
    });

    setBookingSuccess(true);
    setTimeout(() => {
      setBookingSuccess(false);
      setBookingModalOpen(false);
      setBookingSymptoms('');
      showToast('Votre rendez-vous a été enregistré dans Firestore !');
    }, 1500);
  };

  const handleSendBloodRequest = (e) => {
    e.preventDefault();
    setBloodRequestModal(false);
    showToast(`Demande de ${bloodUnitsCount} poches de sang (${selectedBloodGroup !== 'Tous' ? selectedBloodGroup : 'O+'}) transmise en urgence à ${selectedBloodBank?.name} !`);
  };

  const handleCallPharmacy = (pharm) => {
    showToast(`Numérotation vers ${pharm.name} : ${pharm.phone}`);
  };

  const handleSendToPharmacy = (presc) => {
    showToast(`Ordonnance ${presc.code} transmise à la Pharmacie Al Amal !`);
  };

  const handleJoinTeleconsultation = (apt) => {
    showToast(`Connexion à la salle de téléconsultation vidéo sécurisée avec ${apt.doctor_name}...`);
  };

  return (
    <div>
      {/* Toast de notification flottant */}
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

      {/* Bannière de Bienvenue aux couleurs officielles Allo Doctor */}
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
            <HeartPulse size={14} /> Espace Santé Patient Allo Doctor
          </div>
          <h2 style={{ fontSize: '26px', fontWeight: 900, marginBottom: '6px' }}>
            Bonjour, {currentUser?.display_name || 'Karim'} !
          </h2>
          <p style={{ opacity: 0.9, fontSize: '14px', maxWidth: '540px' }}>
            Prenez rendez-vous, accédez à la banque de sang d'urgence et consultez vos ordonnances certifiées.
          </p>
        </div>

        <button 
          id="patient-quick-book-btn"
          className="btn" 
          onClick={() => {
            setSelectedDoctor(doctors[0]);
            setBookingModalOpen(true);
          }}
          style={{ background: 'white', color: '#14583D', fontWeight: 800, padding: '12px 22px', borderRadius: '12px' }}
        >
          <Calendar size={18} /> Prendre Rendez-vous
        </button>
      </div>

      {/* Cartes d'actions rapides interactives */}
      <div className="dashboard-grid">
        <div className="stat-card" style={{ cursor: 'pointer' }} onClick={() => setSubTab('patient_doctors')}>
          <div>
            <div style={{ fontSize: '13px', color: '#56605B', fontWeight: 600 }}>Médecins Agréés</div>
            <div style={{ fontSize: '26px', fontWeight: 900, color: '#1A1C1B' }}>{doctors.length} Spécialistes</div>
            <div style={{ fontSize: '12px', color: '#14583D', fontWeight: 700, marginTop: '4px' }}>Voir l'annuaire →</div>
          </div>
          <div className="stat-icon-wrapper" style={{ background: '#e8efe8', color: '#14583D' }}>
            <User size={24} />
          </div>
        </div>

        <div className="stat-card" style={{ cursor: 'pointer' }} onClick={() => setSubTab('patient_pharmacies')}>
          <div>
            <div style={{ fontSize: '13px', color: '#56605B', fontWeight: 600 }}>Pharmacies de Garde</div>
            <div style={{ fontSize: '26px', fontWeight: 900, color: '#25674D' }}>
              {pharmacies.filter(p => p.is_on_duty).length} Ouvertes 24h
            </div>
            <div style={{ fontSize: '12px', color: '#25674D', fontWeight: 700, marginTop: '4px' }}>Localiser sur la carte →</div>
          </div>
          <div className="stat-icon-wrapper" style={{ background: '#e2f0e8', color: '#25674D' }}>
            <Pill size={24} />
          </div>
        </div>

        <div className="stat-card" style={{ cursor: 'pointer' }} onClick={() => setSubTab('patient_blood_bank')}>
          <div>
            <div style={{ fontSize: '13px', color: '#56605B', fontWeight: 600 }}>Banque de Sang</div>
            <div style={{ fontSize: '26px', fontWeight: 900, color: '#BE3232' }}>Poches Disponibles</div>
            <div style={{ fontSize: '12px', color: '#BE3232', fontWeight: 700, marginTop: '4px' }}>Demande d'urgence →</div>
          </div>
          <div className="stat-icon-wrapper" style={{ background: '#fbebeb', color: '#BE3232' }}>
            <Droplet size={24} />
          </div>
        </div>

        <div className="stat-card" style={{ cursor: 'pointer' }} onClick={() => setSubTab('patient_record')}>
          <div>
            <div style={{ fontSize: '13px', color: '#56605B', fontWeight: 600 }}>Carnet & Ordonnances</div>
            <div style={{ fontSize: '26px', fontWeight: 900, color: '#F87849' }}>{prescriptions.length} Document(s)</div>
            <div style={{ fontSize: '12px', color: '#F87849', fontWeight: 700, marginTop: '4px' }}>Accéder au carnet →</div>
          </div>
          <div className="stat-icon-wrapper" style={{ background: '#fef1ec', color: '#F87849' }}>
            <FileText size={24} />
          </div>
        </div>
      </div>

      {/* BANQUE DE SANG (FIDÈLE À L'APPLICATION FLUTTER) */}
      {subTab === 'patient_blood_bank' ? (
        <div className="card">
          <div className="card-header" style={{ flexWrap: 'wrap', gap: '12px' }}>
            <h3 className="card-title">
              <Droplet size={20} color="#BE3232" /> 
              Banque de Sang & Transfusion d'Urgence
            </h3>
            
            {/* Filtres Groupes Sanguins */}
            <div style={{ display: 'flex', gap: '6px', flexWrap: 'wrap' }}>
              {bloodGroups.map(bg => (
                <button
                  key={bg}
                  onClick={() => setSelectedBloodGroup(bg)}
                  style={{
                    padding: '6px 12px',
                    borderRadius: '20px',
                    fontSize: '12px',
                    fontWeight: 800,
                    cursor: 'pointer',
                    border: '1px solid',
                    borderColor: selectedBloodGroup === bg ? '#BE3232' : '#E5E7EB',
                    background: selectedBloodGroup === bg ? '#BE3232' : '#ffffff',
                    color: selectedBloodGroup === bg ? '#ffffff' : '#56605B'
                  }}
                >
                  {bg}
                </button>
              ))}
            </div>
          </div>

          <div className="card-body">
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(320px, 1fr))', gap: '20px' }}>
              {bloodBanks.map(bb => {
                const stockCount = selectedBloodGroup === 'Tous' 
                  ? Object.values(bb.stocks).reduce((a, b) => a + b, 0)
                  : (bb.stocks[selectedBloodGroup] || 0);

                return (
                  <div key={bb.id} style={{
                    border: '1px solid #DADDDD',
                    borderRadius: '16px',
                    padding: '20px',
                    background: '#ffffff',
                    boxShadow: '0 2px 6px rgba(0,0,0,0.03)'
                  }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '10px' }}>
                      <h4 style={{ fontSize: '16px', fontWeight: 800, color: '#1A1C1B' }}>{bb.name}</h4>
                      <span className="badge badge-danger">
                        {stockCount} poches dispo
                      </span>
                    </div>

                    <div style={{ fontSize: '13px', color: '#56605B', marginBottom: '16px', display: 'flex', flexDirection: 'column', gap: '4px' }}>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                        <MapPin size={14} color="#BE3232" /> {bb.address}, {bb.city}
                      </div>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                        <Phone size={14} color="#BE3232" /> {bb.phone}
                      </div>
                    </div>

                    {/* Grille des groupes disponibles */}
                    <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '6px', marginBottom: '16px', background: '#FAFBFB', padding: '10px', borderRadius: '10px' }}>
                      {Object.entries(bb.stocks).map(([group, qty]) => (
                        <div key={group} style={{ textAlign: 'center', fontSize: '11px' }}>
                          <strong style={{ color: '#BE3232' }}>{group}</strong>: {qty}
                        </div>
                      ))}
                    </div>

                    <button 
                      className="btn btn-danger"
                      onClick={() => {
                        setSelectedBloodBank(bb);
                        setBloodRequestModal(true);
                      }}
                      style={{ width: '100%', fontSize: '13px' }}
                    >
                      <Droplet size={14} /> Demander du sang en urgence
                    </button>
                  </div>
                );
              })}
            </div>
          </div>
        </div>
      ) : subTab === 'patient_doctors' ? (
        <div className="card">
          <div className="card-header">
            <h3 className="card-title"><User size={20} color="#14583D" /> Annuaire des Médecins & Spécialistes</h3>
            <span className="badge badge-info">{doctors.length} praticiens certifiés</span>
          </div>
          <div className="card-body">
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(320px, 1fr))', gap: '20px' }}>
              {doctors.map(doc => (
                <div key={doc.id} style={{
                  border: '1px solid #DADDDD',
                  borderRadius: '16px',
                  padding: '20px',
                  background: '#ffffff',
                  boxShadow: '0 2px 6px rgba(0,0,0,0.03)',
                  display: 'flex',
                  flexDirection: 'column',
                  justifyContent: 'space-between'
                }}>
                  <div style={{ display: 'flex', gap: '14px', marginBottom: '14px' }}>
                    <img 
                      src={doc.photo_url} 
                      alt={doc.display_name} 
                      style={{ width: 68, height: 68, borderRadius: '14px', objectFit: 'cover' }}
                    />
                    <div>
                      <h4 style={{ fontSize: '16px', fontWeight: 800, color: '#1A1C1B' }}>{doc.display_name}</h4>
                      <div style={{ color: '#14583D', fontWeight: 700, fontSize: '13px' }}>{doc.profCategory}</div>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '4px', fontSize: '12px', color: '#FFB300', marginTop: '4px' }}>
                        <Star size={14} fill="#FFB300" /> <strong>{doc.rating}</strong> ({doc.reviews_count} avis)
                      </div>
                    </div>
                  </div>

                  <div style={{ fontSize: '13px', color: '#56605B', marginBottom: '16px' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '6px', marginBottom: '4px' }}>
                      <MapPin size={14} color="#5B8E7B" /> {doc.address}, {doc.city}
                    </div>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                      <Clock size={14} color="#5B8E7B" /> Dispo : <strong style={{ color: '#25674D' }}>{doc.availability}</strong>
                    </div>
                  </div>

                  <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', paddingTop: '12px', borderTop: '1px solid #E5E7EB' }}>
                    <div>
                      <span style={{ fontSize: '11px', color: '#9CA3AF', textTransform: 'uppercase', fontWeight: 800 }}>Honoraires</span>
                      <div style={{ fontSize: '16px', fontWeight: 900, color: '#1A1C1B' }}>{doc.fee} F CFA</div>
                    </div>
                    <button 
                      className="btn btn-primary"
                      onClick={() => {
                        setSelectedDoctor(doc);
                        setBookingModalOpen(true);
                      }}
                      style={{ padding: '8px 16px', fontSize: '13px' }}
                    >
                      Prendre RDV
                    </button>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      ) : subTab === 'patient_pharmacies' ? (
        <div className="card">
          <div className="card-header">
            <h3 className="card-title"><Pill size={20} color="#25674D" /> Pharmacies & Services de Garde</h3>
            <span className="badge badge-success">Mise à jour temps réel</span>
          </div>
          <div className="card-body">
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(320px, 1fr))', gap: '20px' }}>
              {pharmacies.map(pharm => (
                <div key={pharm.id} style={{
                  border: '1px solid #DADDDD',
                  borderRadius: '16px',
                  padding: '20px',
                  background: '#ffffff'
                }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '10px' }}>
                    <h4 style={{ fontSize: '16px', fontWeight: 800, color: '#1A1C1B' }}>{pharm.name}</h4>
                    {pharm.is_on_duty ? (
                      <span className="badge badge-success">DE GARDE 24H</span>
                    ) : (
                      <span className="badge badge-secondary">Fermée</span>
                    )}
                  </div>
                  <div style={{ fontSize: '13px', color: '#56605B', display: 'flex', flexDirection: 'column', gap: '6px', marginBottom: '16px' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                      <MapPin size={14} color="#5B8E7B" /> {pharm.address}
                    </div>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                      <Phone size={14} color="#5B8E7B" /> {pharm.phone}
                    </div>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                      <Clock size={14} color="#5B8E7B" /> {pharm.opening_hours}
                    </div>
                  </div>
                  <div style={{ display: 'flex', gap: '8px' }}>
                    <button 
                      className="btn btn-outline-primary" 
                      onClick={() => handleCallPharmacy(pharm)}
                      style={{ flex: 1, fontSize: '12px' }}
                    >
                      <Phone size={14} /> Appeler
                    </button>
                    <button 
                      className="btn btn-secondary" 
                      onClick={() => showToast(`Itinéraire GPS vers ${pharm.name} ouvert.`)}
                      style={{ flex: 1, fontSize: '12px' }}
                    >
                      <MapPin size={14} /> Itinéraire
                    </button>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      ) : subTab === 'patient_record' ? (
        <div className="card">
          <div className="card-header">
            <h3 className="card-title"><FileText size={20} color="#14583D" /> Ordonnances & Carnet Médical Sécurisé</h3>
            <span className="badge badge-info">Certifié Allo Doctor</span>
          </div>
          <div className="card-body">
            {prescriptions.map(presc => (
              <div key={presc.id} style={{
                border: '1px solid #DADDDD',
                borderRadius: '16px',
                padding: '20px',
                marginBottom: '16px',
                background: '#FAFBFB'
              }}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '14px' }}>
                  <div>
                    <span style={{ fontSize: '12px', fontWeight: 800, color: '#14583D' }}>{presc.code}</span>
                    <h4 style={{ fontSize: '16px', fontWeight: 800 }}>Prescrit par {presc.doctor_name} ({presc.doctor_specialty})</h4>
                    <span style={{ fontSize: '12px', color: '#56605B' }}>Date de consultation : {presc.date}</span>
                  </div>
                  <span className="badge badge-success">{presc.status}</span>
                </div>

                <div style={{ background: 'white', padding: '14px', borderRadius: '10px', border: '1px solid #E5E7EB', marginBottom: '12px' }}>
                  <div style={{ fontSize: '12px', fontWeight: 800, color: '#56605B', marginBottom: '8px', textTransform: 'uppercase' }}>
                    Médicaments prescrits :
                  </div>
                  {presc.medicines.map((m, idx) => (
                    <div key={idx} style={{ display: 'flex', justifyContent: 'space-between', padding: '6px 0', borderBottom: idx < presc.medicines.length - 1 ? '1px dashed #E5E7EB' : 'none' }}>
                      <span style={{ fontWeight: 700, fontSize: '13px', color: '#1A1C1B' }}>💊 {m.name}</span>
                      <span style={{ fontSize: '13px', color: '#56605B' }}>{m.posology} — {m.duration}</span>
                    </div>
                  ))}
                </div>

                <p style={{ fontSize: '13px', color: '#56605B', fontStyle: 'italic', marginBottom: '14px' }}>
                  <strong>Conseils du praticien :</strong> {presc.notes}
                </p>

                <div style={{ display: 'flex', gap: '10px' }}>
                  <button 
                    className="btn btn-primary" 
                    onClick={() => setSelectedPrescription(presc)}
                    style={{ padding: '8px 16px', fontSize: '12px' }}
                  >
                    <Download size={14} /> Voir Ordonnance / Imprimer PDF
                  </button>
                  <button 
                    className="btn btn-secondary" 
                    onClick={() => handleSendToPharmacy(presc)}
                    style={{ padding: '8px 16px', fontSize: '12px' }}
                  >
                    <Send size={14} /> Télétransmettre à ma pharmacie
                  </button>
                </div>
              </div>
            ))}
          </div>
        </div>
      ) : (
        <div className="card">
          <div className="card-header">
            <h3 className="card-title"><Calendar size={20} color="#14583D" /> Vos Rendez-vous Médicaux</h3>
            <button 
              className="btn btn-outline-primary"
              onClick={() => {
                setSelectedDoctor(doctors[0]);
                setBookingModalOpen(true);
              }}
              style={{ padding: '6px 14px', fontSize: '12px' }}
            >
              <Plus size={14} /> Nouveau RDV
            </button>
          </div>
          <div className="card-body">
            <div className="custom-table-container">
              <table className="custom-table">
                <thead>
                  <tr>
                    <th>Médecin / Praticien</th>
                    <th>Date & Heure</th>
                    <th>Mode</th>
                    <th>Motif</th>
                    <th>Honoraires</th>
                    <th>Statut</th>
                    <th>Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {appointments.map((apt) => (
                    <tr key={apt.id}>
                      <td>
                        <strong>{apt.doctor_name || 'Dr. Allo Doctor'}</strong>
                        <div style={{ fontSize: '11px', color: '#56605B' }}>{apt.doctor_specialty || 'Généraliste'}</div>
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
                      <td>{apt.symptoms || 'Consultation standard'}</td>
                      <td><strong>{apt.fee || 350} F CFA</strong></td>
                      <td>
                        <span className={`badge ${
                          apt.status === 'confirmé' ? 'badge-success' : 
                          apt.status === 'en_attente' ? 'badge-warning' : 'badge-secondary'
                        }`}>
                          {apt.status || 'En attente'}
                        </span>
                      </td>
                      <td>
                        <div style={{ display: 'flex', gap: '6px' }}>
                          {apt.consult_mode === 'Téléconsultation' || apt.appointment_type === 'video' ? (
                            <button 
                              className="btn btn-primary" 
                              onClick={() => handleJoinTeleconsultation(apt)}
                              style={{ padding: '4px 8px', fontSize: '11px' }}
                            >
                              <Video size={13} /> Rejoindre
                            </button>
                          ) : null}
                          <button 
                            className="btn btn-secondary" 
                            onClick={() => showToast(`Détails du RDV avec ${apt.doctor_name} affichés.`)}
                            style={{ padding: '4px 10px', fontSize: '11px' }}
                          >
                            Détails
                          </button>
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      )}

      {/* Modal Demande de Sang en Urgence */}
      {bloodRequestModal && (
        <div className="modal-overlay">
          <div className="modal-content" style={{ maxWidth: '480px' }}>
            <div className="card-header">
              <h3 className="card-title">Demande de Sang en Urgence : {selectedBloodBank?.name}</h3>
              <button onClick={() => setBloodRequestModal(false)} style={{ border: 'none', background: 'transparent', cursor: 'pointer' }}>
                <X size={18} color="#9CA3AF" />
              </button>
            </div>
            <div className="card-body">
              <form onSubmit={handleSendBloodRequest}>
                <div className="form-group">
                  <label className="form-label">Groupe Sanguin Requis</label>
                  <select 
                    className="form-select"
                    value={selectedBloodGroup !== 'Tous' ? selectedBloodGroup : 'O+'}
                    onChange={(e) => setSelectedBloodGroup(e.target.value)}
                  >
                    {['O+', 'A+', 'B+', 'AB+', 'O-', 'A-', 'B-', 'AB-'].map(g => (
                      <option key={g} value={g}>{g}</option>
                    ))}
                  </select>
                </div>

                <div className="form-group">
                  <label className="form-label">Nombre de poches demandées</label>
                  <input 
                    type="number" 
                    className="form-input" 
                    min={1} 
                    max={10} 
                    value={bloodUnitsCount}
                    onChange={(e) => setBloodUnitsCount(e.target.value)}
                    required
                  />
                </div>

                <div className="form-group">
                  <label className="form-label">Degré d'urgence</label>
                  <select 
                    className="form-select"
                    value={bloodUrgencyLevel}
                    onChange={(e) => setBloodUrgencyLevel(e.target.value)}
                  >
                    <option value="Immédiat">Extrême urgence vitale (&lt; 30 min)</option>
                    <option value="Urgent">Urgence chirurgicale (&lt; 2h)</option>
                    <option value="Programmé">Intervention programmée (Dans la journée)</option>
                  </select>
                </div>

                <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px', marginTop: '16px' }}>
                  <button type="button" className="btn btn-secondary" onClick={() => setBloodRequestModal(false)}>
                    Annuler
                  </button>
                  <button type="submit" className="btn btn-danger">
                    Transmettre l'Appel d'Urgence
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      )}

      {/* Modal Réservation RDV */}
      {bookingModalOpen && (
        <div className="modal-overlay">
          <div className="modal-content" style={{ maxWidth: '520px' }}>
            <div className="card-header">
              <h3 className="card-title">Prendre Rendez-vous avec {selectedDoctor?.display_name}</h3>
              <button 
                onClick={() => setBookingModalOpen(false)}
                style={{ background: 'transparent', border: 'none', cursor: 'pointer', fontSize: '18px', color: '#9CA3AF' }}
              >
                ✕
              </button>
            </div>
            <div className="card-body">
              {bookingSuccess ? (
                <div style={{ textAlign: 'center', padding: '24px 0' }}>
                  <CheckCircle size={56} color="#25674D" style={{ margin: '0 auto 12px' }} />
                  <h3 style={{ fontSize: '18px', fontWeight: 800, color: '#25674D' }}>Rendez-vous Enregistré !</h3>
                  <p style={{ fontSize: '13px', color: '#56605B' }}>
                    Le créneau a été transmis directement dans l'agenda du médecin.
                  </p>
                </div>
              ) : (
                <form onSubmit={handleBookAppointment}>
                  <div className="form-group">
                    <label className="form-label">Médecin sélectionné</label>
                    <select 
                      className="form-select"
                      value={selectedDoctor?.id}
                      onChange={(e) => setSelectedDoctor(doctors.find(d => d.id === e.target.value))}
                    >
                      {doctors.map(d => (
                        <option key={d.id} value={d.id}>{d.display_name} ({d.profCategory}) - {d.fee} F CFA</option>
                      ))}
                    </select>
                  </div>

                  <div className="form-group">
                    <label className="form-label">Mode de consultation</label>
                    <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '10px' }}>
                      <button
                        type="button"
                        onClick={() => setBookingMode('Cabinet')}
                        style={{
                          padding: '10px',
                          borderRadius: '8px',
                          border: '1px solid',
                          borderColor: bookingMode === 'Cabinet' ? '#14583D' : '#DADDDD',
                          background: bookingMode === 'Cabinet' ? '#e8efe8' : '#ffffff',
                          fontWeight: 700,
                          cursor: 'pointer'
                        }}
                      >
                        En Cabinet
                      </button>
                      <button
                        type="button"
                        onClick={() => setBookingMode('Téléconsultation')}
                        style={{
                          padding: '10px',
                          borderRadius: '8px',
                          border: '1px solid',
                          borderColor: bookingMode === 'Téléconsultation' ? '#14583D' : '#DADDDD',
                          background: bookingMode === 'Téléconsultation' ? '#e8efe8' : '#ffffff',
                          fontWeight: 700,
                          cursor: 'pointer'
                        }}
                      >
                        Téléconsultation Vidéo
                      </button>
                    </div>
                  </div>

                  <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
                    <div className="form-group">
                      <label className="form-label">Date du RDV</label>
                      <input 
                        type="date" 
                        className="form-input"
                        value={bookingDate}
                        onChange={(e) => setBookingDate(e.target.value)}
                        required
                      />
                    </div>
                    <div className="form-group">
                      <label className="form-label">Créneau horaire</label>
                      <select 
                        className="form-select"
                        value={bookingTime}
                        onChange={(e) => setBookingTime(e.target.value)}
                      >
                        <option value="09:30">09:30</option>
                        <option value="11:00">11:00</option>
                        <option value="14:30">14:30</option>
                        <option value="16:00">16:00</option>
                        <option value="17:30">17:30</option>
                      </select>
                    </div>
                  </div>

                  <div className="form-group">
                    <label className="form-label">Motif ou symptômes</label>
                    <textarea 
                      className="form-textarea" 
                      rows={3} 
                      placeholder="Ex: Douleurs thoraciques, renouvellement traitement..."
                      value={bookingSymptoms}
                      onChange={(e) => setBookingSymptoms(e.target.value)}
                    ></textarea>
                  </div>

                  <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px', marginTop: '20px' }}>
                    <button type="button" className="btn btn-secondary" onClick={() => setBookingModalOpen(false)}>
                      Annuler
                    </button>
                    <button type="submit" className="btn btn-primary">
                      Confirmer le Rendez-vous ({selectedDoctor?.fee || 350} F CFA)
                    </button>
                  </div>
                </form>
              )}
            </div>
          </div>
        </div>
      )}

      {/* Modal Aperçu Ordonnance PDF / QR Code — z-index maximal pour garantir la visibilité */}
      {selectedPrescription && (
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
            maxWidth: '620px',
            boxShadow: '0 24px 48px rgba(0,0,0,0.22)',
            overflow: 'hidden',
            animation: 'modal-appear 0.25s ease-out'
          }}>
            {/* En-tête ordonnance — style document officiel */}
            <div style={{
              background: 'linear-gradient(135deg, #14583D 0%, #5B8E7B 100%)',
              padding: '20px 24px',
              color: 'white',
              display: 'flex',
              justifyContent: 'space-between',
              alignItems: 'center'
            }}>
              <div>
                <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '4px' }}>
                  <FileText size={20} />
                  <span style={{ fontWeight: 900, fontSize: '16px', letterSpacing: '0.02em' }}>ORDONNANCE MÉDICALE</span>
                </div>
                <span style={{ fontSize: '12px', opacity: 0.85, fontFamily: 'monospace' }}>Réf : {selectedPrescription.code} — Allo Doctor Platform</span>
              </div>
              <button
                onClick={() => setSelectedPrescription(null)}
                style={{ background: 'rgba(255,255,255,0.2)', border: 'none', borderRadius: '8px', color: 'white', cursor: 'pointer', padding: '6px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}
              >
                <X size={20} />
              </button>
            </div>

            {/* Corps de l'ordonnance */}
            <div style={{ padding: '24px' }}>
              {/* Infos médecin & patient */}
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px', marginBottom: '20px' }}>
                <div style={{ background: '#f2f7f4', borderRadius: '12px', padding: '14px', borderLeft: '4px solid #14583D' }}>
                  <div style={{ fontSize: '10px', fontWeight: 800, color: '#14583D', textTransform: 'uppercase', marginBottom: '6px' }}>Praticien</div>
                  <div style={{ fontWeight: 800, fontSize: '14px', color: '#1A1C1B' }}>{selectedPrescription.doctor_name}</div>
                  <div style={{ fontSize: '12px', color: '#56605B' }}>{selectedPrescription.doctor_specialty}</div>
                </div>
                <div style={{ background: '#f8f9fa', borderRadius: '12px', padding: '14px', borderLeft: '4px solid #5B8E7B' }}>
                  <div style={{ fontSize: '10px', fontWeight: 800, color: '#5B8E7B', textTransform: 'uppercase', marginBottom: '6px' }}>Patient</div>
                  <div style={{ fontWeight: 800, fontSize: '14px', color: '#1A1C1B' }}>{selectedPrescription.patient_name}</div>
                  <div style={{ fontSize: '12px', color: '#56605B' }}>Date : {selectedPrescription.date}</div>
                </div>
              </div>

              {/* Liste des médicaments */}
              <div style={{ border: '1px solid #E5E7EB', borderRadius: '12px', overflow: 'hidden', marginBottom: '16px' }}>
                <div style={{ background: '#1A1C1B', padding: '10px 16px', display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <span style={{ fontSize: '11px', fontWeight: 800, color: '#FFB300', textTransform: 'uppercase', letterSpacing: '0.06em' }}>💊 Médicaments Prescrits</span>
                </div>
                {selectedPrescription.medicines?.length > 0 ? (
                  selectedPrescription.medicines.map((m, i) => (
                    <div key={i} style={{
                      padding: '14px 16px',
                      borderBottom: i < selectedPrescription.medicines.length - 1 ? '1px solid #E5E7EB' : 'none',
                      display: 'grid',
                      gridTemplateColumns: '1fr auto',
                      gap: '8px',
                      alignItems: 'center',
                      background: i % 2 === 0 ? '#FAFBFB' : 'white'
                    }}>
                      <div>
                        <div style={{ fontWeight: 800, fontSize: '14px', color: '#1A1C1B' }}>💊 {m.name}</div>
                        <div style={{ fontSize: '12px', color: '#56605B', marginTop: '2px' }}>{m.posology}</div>
                      </div>
                      <div style={{ textAlign: 'right' }}>
                        <span style={{ background: '#e8efe8', color: '#14583D', borderRadius: '20px', padding: '3px 10px', fontSize: '11px', fontWeight: 800 }}>
                          ⏱ {m.duration}
                        </span>
                      </div>
                    </div>
                  ))
                ) : (
                  <div style={{ padding: '16px', textAlign: 'center', color: '#9CA3AF', fontSize: '13px' }}>Aucun médicament listé</div>
                )}
              </div>

              {/* Notes du médecin */}
              {selectedPrescription.notes && (
                <div style={{ background: '#fff8e1', border: '1px solid #FFB30030', borderRadius: '10px', padding: '12px 14px', marginBottom: '16px' }}>
                  <div style={{ fontSize: '11px', fontWeight: 800, color: '#FFB300', marginBottom: '4px' }}>📋 CONSEILS DU PRATICIEN :</div>
                  <p style={{ fontSize: '13px', color: '#56605B', fontStyle: 'italic', margin: 0 }}>{selectedPrescription.notes}</p>
                </div>
              )}

              {/* Pied de page avec QR code et actions */}
              <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', borderTop: '1px solid #E5E7EB', paddingTop: '16px' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                  <div style={{ background: '#f2f7f4', borderRadius: '10px', padding: '8px', color: '#14583D' }}>
                    <QrCode size={36} />
                  </div>
                  <div>
                    <div style={{ fontSize: '11px', fontWeight: 800, color: '#14583D' }}>Signature Numérique</div>
                    <div style={{ fontSize: '10px', color: '#56605B' }}>Certifiée par Allo Doctor Platform</div>
                  </div>
                </div>
                <div style={{ display: 'flex', gap: '8px' }}>
                  <button
                    className="btn btn-secondary"
                    onClick={() => {
                      handleSendToPharmacy(selectedPrescription);
                      setSelectedPrescription(null);
                    }}
                    style={{ padding: '8px 14px', fontSize: '12px' }}
                  >
                    <Send size={14} /> Envoyer pharmacie
                  </button>
                  <button
                    className="btn btn-primary"
                    onClick={() => {
                      window.print();
                    }}
                    style={{ padding: '8px 16px', fontSize: '12px' }}
                  >
                    <Download size={14} /> Imprimer PDF
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
