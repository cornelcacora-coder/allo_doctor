import React, { useState, useEffect } from 'react';
import { 
  Pill, 
  AlertTriangle, 
  CheckCircle, 
  FileText, 
  Clock, 
  Plus, 
  Minus, 
  DollarSign, 
  Search, 
  Power, 
  Check, 
  PackageCheck, 
  X,
  CreditCard,
  ArrowUpRight,
  TrendingUp,
  ShieldCheck,
  CalendarDays
} from 'lucide-react';
import { firestoreService } from '../../services/firestoreService';
import { useAuth } from '../../context/AuthContext';
import { safeLower } from '../../utils/text';

export const PharmacyView = ({ subTab = 'pharma_home', setSubTab }) => {
  const { currentUser } = useAuth();
  const [medicines, setMedicines] = useState([]);
  const [prescriptions, setPrescriptions] = useState([]);
  const [isOnDuty, setIsOnDuty] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [toastMessage, setToastMessage] = useState('');
  
  // Modal Nouveau Produit
  const [modalNewMed, setModalNewMed] = useState(false);
  const [newMedName, setNewMedName] = useState('');
  const [newMedCategory, setNewMedCategory] = useState('Antalgique');
  const [newMedPrice, setNewMedPrice] = useState(25);
  const [newMedStock, setNewMedStock] = useState(50);
  const [newMedRequiresPrescription, setNewMedRequiresPrescription] = useState(false);

  // WALLET DE LA PHARMACIE (Fidèle à pharmacy_wallet_page de Flutter)
  const [salesRevenue, setSalesRevenue] = useState(14850);
  const [walletTransactions, setWalletTransactions] = useState([
    { id: 'tx_1', date: 'Aujourd\'hui 15:40', client: 'Salma B.', items: 'Augmentin + Doliprane', amount: 112.50, type: 'Comptant' },
    { id: 'tx_2', date: 'Aujourd\'hui 14:10', client: 'Karim T.', items: 'Kardegic 75mg', amount: 32.00, type: 'Tiers Payant' },
    { id: 'tx_3', date: 'Aujourd\'hui 11:05', client: 'Yassine I.', items: 'Inipomp 40mg', amount: 76.50, type: 'Comptant' },
  ]);

  // PLANNING DE GARDE (Fidèle à l'application mobile)
  const [guardSchedule, setGuardSchedule] = useState([
    { day: 'Lundi 12 Oct', hours: '20:00 - 08:30 (Nuit)', pharmacist: 'Dr. Alami (Titulaire)', status: 'Active' },
    { day: 'Samedi 17 Oct', hours: '24h/24 (Week-end)', pharmacist: 'Dr. Berrada (Adjoint)', status: 'Programmée' },
    { day: 'Dimanche 18 Oct', hours: '24h/24 (Week-end)', pharmacist: 'Dr. Berrada (Adjoint)', status: 'Programmée' },
  ]);

  const showToast = (msg) => {
    setToastMessage(msg);
    setTimeout(() => setToastMessage(''), 3000);
  };

  useEffect(() => {
    const unsubMed = firestoreService.listenMedicines(setMedicines);
    const unsubPresc = firestoreService.listenPrescriptions(setPrescriptions);

    return () => {
      unsubMed && unsubMed();
      unsubPresc && unsubPresc();
    };
  }, []);

  const handleUpdateStock = async (id, delta) => {
    const med = medicines.find(m => m.id === id);
    if (!med) return;
    const newStock = Math.max(0, (med.stock || 0) + delta);
    await firestoreService.updateMedicineStock(id, newStock);
    setMedicines(prev => prev.map(m => m.id === id ? { ...m, stock: newStock } : m));
    showToast(`Stock de ${med.name} mis à jour : ${newStock} unités`);
  };

  const handleToggleDuty = () => {
    setIsOnDuty(!isOnDuty);
    showToast(!isOnDuty ? 'Statut : Pharmacie de Garde activé 24h/24 !' : 'Statut : Horaires habituels');
  };

  const handleDeliverPrescription = (prescId) => {
    setPrescriptions(prev => prev.map(p => p.id === prescId ? { ...p, status: 'Délivrée en officine' } : p));
    setSalesRevenue(prev => prev + 125.00);
    showToast('Médicaments préparés et délivrés au patient ! Encaissement validé.');
  };

  const handleAddMedicine = (e) => {
    e.preventDefault();
    const newMed = {
      id: 'med_' + Date.now(),
      name: newMedName,
      category: newMedCategory,
      price: Number(newMedPrice),
      stock: Number(newMedStock),
      requires_prescription: newMedRequiresPrescription,
      dosage: 'Selon avis médical'
    };
    setMedicines([newMed, ...medicines]);
    setModalNewMed(false);
    setNewMedName('');
    showToast(`Produit ${newMedName} ajouté à l'inventaire Firestore !`);
  };

  const lowStockMeds = medicines.filter(m => (m.stock || 0) < 30);
  const filteredMeds = medicines.filter(m => {
    const needle = safeLower(searchTerm);
    return safeLower(m.name).includes(needle) ||
      safeLower(m.category).includes(needle);
  });

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

      {/* Banner Pharmacie */}
      <div style={{
        background: 'linear-gradient(135deg, #14583D 0%, #25674D 100%)',
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
            <Pill size={14} /> Gestion Officine & Stocks
          </div>
          <h2 style={{ fontSize: '26px', fontWeight: 900, marginBottom: '6px' }}>
            {currentUser?.display_name || 'Pharmacie Al Amal'}
          </h2>
          <p style={{ opacity: 0.9, fontSize: '14px' }}>
            Gestion des stocks en temps réel et traitement direct des ordonnances délivrées par les médecins.
          </p>
        </div>

        {/* Bouton de bascule Mode De Garde */}
        <div style={{ textAlign: 'right' }}>
          <button 
            id="pharmacy-toggle-duty-btn"
            onClick={handleToggleDuty}
            style={{
              background: isOnDuty ? '#ffffff' : 'rgba(255,255,255,0.2)',
              color: isOnDuty ? '#14583D' : '#ffffff',
              border: '2px solid white',
              padding: '10px 20px',
              borderRadius: '14px',
              fontWeight: 800,
              fontSize: '13px',
              display: 'inline-flex',
              alignItems: 'center',
              gap: '8px',
              cursor: 'pointer',
              boxShadow: isOnDuty ? '0 4px 15px rgba(0,0,0,0.1)' : 'none'
            }}
          >
            <Power size={16} />
            {isOnDuty ? 'PHARMACIE DE GARDE : ACTIVE' : 'PHARMACIE DE GARDE : INACTIVE'}
          </button>
          <div style={{ fontSize: '11px', marginTop: '6px', opacity: 0.85 }}>
            {isOnDuty ? 'Visible 24h/24 sur l\'application mobile' : 'Horaires habituels'}
          </div>
        </div>
      </div>

      {/* Cartes statistiques */}
      <div className="dashboard-grid">
        <div className="stat-card" style={{ cursor: 'pointer' }} onClick={() => setSubTab('pharma_stock')}>
          <div>
            <div style={{ fontSize: '13px', color: '#56605B', fontWeight: 600 }}>Références en Stock</div>
            <div style={{ fontSize: '26px', fontWeight: 900, color: '#1A1C1B' }}>{medicines.length}</div>
            <div style={{ fontSize: '12px', color: '#14583D', fontWeight: 700, marginTop: '4px' }}>
              Catalogue actif →
            </div>
          </div>
          <div className="stat-icon-wrapper" style={{ background: '#e8efe8', color: '#14583D' }}>
            <Pill size={24} />
          </div>
        </div>

        <div className="stat-card">
          <div>
            <div style={{ fontSize: '13px', color: '#56605B', fontWeight: 600 }}>Alertes Stock Bas</div>
            <div style={{ fontSize: '26px', fontWeight: 900, color: '#BE3232' }}>{lowStockMeds.length}</div>
            <div style={{ fontSize: '12px', color: '#BE3232', fontWeight: 700, marginTop: '4px' }}>
              Réapprovisionnement requis
            </div>
          </div>
          <div className="stat-icon-wrapper" style={{ background: '#fbebeb', color: '#BE3232' }}>
            <AlertTriangle size={24} />
          </div>
        </div>

        <div className="stat-card" style={{ cursor: 'pointer' }} onClick={() => setSubTab('pharma_orders')}>
          <div>
            <div style={{ fontSize: '13px', color: '#56605B', fontWeight: 600 }}>Ordonnances à traiter</div>
            <div style={{ fontSize: '26px', fontWeight: 900, color: '#F87849' }}>{prescriptions.length}</div>
            <div style={{ fontSize: '12px', color: '#F87849', fontWeight: 700, marginTop: '4px' }}>
              Télétransmises par les patients →
            </div>
          </div>
          <div className="stat-icon-wrapper" style={{ background: '#fef1ec', color: '#F87849' }}>
            <FileText size={24} />
          </div>
        </div>

        <div className="stat-card" style={{ cursor: 'pointer' }} onClick={() => setSubTab('pharma_wallet')}>
          <div>
            <div style={{ fontSize: '13px', color: '#56605B', fontWeight: 600 }}>Chiffre du Mois (Wallet)</div>
            <div style={{ fontSize: '24px', fontWeight: 900, color: '#14583D' }}>{salesRevenue.toLocaleString()} F CFA</div>
            <div style={{ fontSize: '12px', color: '#25674D', fontWeight: 700, marginTop: '4px' }}>
              Portefeuille Officine →
            </div>
          </div>
          <div className="stat-icon-wrapper" style={{ background: '#e2f0e8', color: '#25674D' }}>
            <CreditCard size={24} />
          </div>
        </div>
      </div>

      {/* PORTEFEUILLE OFFICINE (FIDÈLE À pharmacy_wallet_page DE FLUTTER) */}
      {subTab === 'pharma_wallet' ? (
        <div className="card">
          <div className="card-header">
            <h3 className="card-title"><CreditCard size={20} color="#14583D" /> Portefeuille Financier de la Pharmacie</h3>
            <button 
              className="btn btn-primary"
              onClick={() => showToast('Demande de virement des ventes vers votre compte bancaire initiée.')}
              style={{ padding: '6px 14px', fontSize: '12px' }}
            >
              <ArrowUpRight size={14} /> Demander un Virement
            </button>
          </div>
          <div className="card-body">
            <div style={{ background: '#e8efe8', borderRadius: '16px', padding: '24px', marginBottom: '24px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <div>
                <span style={{ fontSize: '12px', fontWeight: 800, color: '#56605B', textTransform: 'uppercase' }}>Solde des Ventes & Tiers Payant</span>
                <div style={{ fontSize: '32px', fontWeight: 900, color: '#14583D' }}>{salesRevenue.toLocaleString()} F CFA</div>
                <span style={{ fontSize: '12px', color: '#56605B' }}>Paiements sécurisés par la plateforme Allo Doctor</span>
              </div>
              <ShieldCheck size={48} color="#14583D" />
            </div>

            <h4 style={{ fontSize: '15px', fontWeight: 800, marginBottom: '12px' }}>Dernières Ventes Enregistrées</h4>
            <div className="custom-table-container">
              <table className="custom-table">
                <thead>
                  <tr>
                    <th>Date & Heure</th>
                    <th>Client / Patient</th>
                    <th>Médicaments délivrés</th>
                    <th>Mode Règlement</th>
                    <th>Montant</th>
                    <th>Statut</th>
                  </tr>
                </thead>
                <tbody>
                  {walletTransactions.map(t => (
                    <tr key={t.id}>
                      <td>{t.date}</td>
                      <td><strong>{t.client}</strong></td>
                      <td>{t.items}</td>
                      <td><span className="badge badge-secondary">{t.type}</span></td>
                      <td><strong>+{t.amount.toFixed(2)} F CFA</strong></td>
                      <td><span className="badge badge-success">Encaissé</span></td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      ) : subTab === 'pharma_duty' ? (
        <div className="card">
          <div className="card-header">
            <h3 className="card-title"><Clock size={20} color="#14583D" /> Planning Officiel des Pharmacies de Garde</h3>
            <span className="badge badge-success">Ordre Régional des Pharmaciens</span>
          </div>
          <div className="card-body">
            <div className="custom-table-container">
              <table className="custom-table">
                <thead>
                  <tr>
                    <th>Date Prévue</th>
                    <th>Horaires de Garde</th>
                    <th>Pharmacien Responsable</th>
                    <th>Statut</th>
                    <th>Action</th>
                  </tr>
                </thead>
                <tbody>
                  {guardSchedule.map((g, idx) => (
                    <tr key={idx}>
                      <td><strong>{g.day}</strong></td>
                      <td>{g.hours}</td>
                      <td>{g.pharmacist}</td>
                      <td>
                        <span className={`badge ${g.status === 'Active' ? 'badge-success' : 'badge-info'}`}>
                          {g.status}
                        </span>
                      </td>
                      <td>
                        <button 
                          className="btn btn-secondary" 
                          onClick={() => showToast(`Ronde de garde pour ${g.day} confirmée à la préfecture.`)}
                          style={{ padding: '4px 10px', fontSize: '11px' }}
                        >
                          Confirmer
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      ) : subTab === 'pharma_orders' ? (
        <div className="card">
          <div className="card-header">
            <h3 className="card-title"><FileText size={20} color="#14583D" /> Ordonnances Médicales Télétransmises</h3>
            <span className="badge badge-info">{prescriptions.length} prescriptions reçues</span>
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
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '12px' }}>
                  <div>
                    <span style={{ fontSize: '12px', fontWeight: 800, color: '#14583D' }}>{presc.code}</span>
                    <h4 style={{ fontSize: '16px', fontWeight: 800 }}>Patient : {presc.patient_name}</h4>
                    <span style={{ fontSize: '12px', color: '#56605B' }}>Prescrit par {presc.doctor_name} • {presc.date}</span>
                  </div>
                  <span className="badge badge-warning">{presc.status || 'À préparer'}</span>
                </div>

                <div style={{ background: 'white', padding: '12px', borderRadius: '10px', border: '1px solid #E5E7EB', marginBottom: '14px' }}>
                  {presc.medicines.map((m, idx) => (
                    <div key={idx} style={{ display: 'flex', justifyContent: 'space-between', padding: '4px 0' }}>
                      <span style={{ fontWeight: 700, fontSize: '13px' }}>💊 {m.name}</span>
                      <span style={{ fontSize: '13px', color: '#56605B' }}>{m.posology} ({m.duration})</span>
                    </div>
                  ))}
                </div>

                <button 
                  className="btn btn-primary"
                  onClick={() => handleDeliverPrescription(presc.id)}
                  style={{ fontSize: '12px', padding: '8px 16px' }}
                >
                  <PackageCheck size={15} /> Valider la délivrance & Encaisser
                </button>
              </div>
            ))}
          </div>
        </div>
      ) : (
        /* Inventaire des Médicaments */
        <div className="card">
          <div className="card-header" style={{ flexWrap: 'wrap', gap: '12px' }}>
            <h3 className="card-title"><Pill size={20} color="#14583D" /> Inventaire des Médicaments & Produits</h3>
            
            <div style={{ display: 'flex', gap: '10px', alignItems: 'center' }}>
              <div style={{ display: 'flex', alignItems: 'center', background: '#F2F5F4', borderRadius: '8px', padding: '6px 12px', gap: '6px' }}>
                <Search size={14} color="#9CA3AF" />
                <input 
                  type="text" 
                  placeholder="Rechercher produit..." 
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  style={{ border: 'none', background: 'transparent', outline: 'none', fontSize: '12px' }}
                />
              </div>
              <button 
                className="btn btn-primary" 
                onClick={() => setModalNewMed(true)}
                style={{ padding: '6px 14px', fontSize: '12px' }}
              >
                <Plus size={14} /> Nouveau Produit
              </button>
            </div>
          </div>

          <div className="card-body">
            <div className="custom-table-container">
              <table className="custom-table">
                <thead>
                  <tr>
                    <th>Désignation</th>
                    <th>Catégorie</th>
                    <th>Prix Public</th>
                    <th>Niveau de Stock</th>
                    <th>Ordonnance ?</th>
                    <th>Ajustement Rapide</th>
                  </tr>
                </thead>
                <tbody>
                  {filteredMeds.map((med) => {
                    const isLow = (med.stock || 0) < 30;
                    return (
                      <tr key={med.id}>
                        <td>
                          <strong>{med.name}</strong>
                          <div style={{ fontSize: '11px', color: '#56605B' }}>{med.dosage || med.description}</div>
                        </td>
                        <td>
                          <span className="badge badge-secondary">{med.category}</span>
                        </td>
                        <td><strong>{med.price.toFixed(2)} F CFA</strong></td>
                        <td>
                          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                            <span style={{ 
                              fontWeight: 900, 
                              color: isLow ? '#BE3232' : '#1A1C1B' 
                            }}>
                              {med.stock} unités
                            </span>
                            {isLow && <span className="badge badge-danger">Bas</span>}
                          </div>
                        </td>
                        <td>
                          {med.requires_prescription ? (
                            <span className="badge badge-warning">Sur ordonnance</span>
                          ) : (
                            <span className="badge badge-success">Libre accès</span>
                          )}
                        </td>
                        <td>
                          <div style={{ display: 'flex', gap: '6px' }}>
                            <button 
                              className="btn btn-secondary" 
                              style={{ padding: '4px 8px' }}
                              onClick={() => handleUpdateStock(med.id, -1)}
                            >
                              <Minus size={12} />
                            </button>
                            <button 
                              className="btn btn-secondary" 
                              style={{ padding: '4px 8px' }}
                              onClick={() => handleUpdateStock(med.id, 1)}
                            >
                              <Plus size={12} />
                            </button>
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

      {/* Modal Nouveau Médicament */}
      {modalNewMed && (
        <div className="modal-overlay">
          <div className="modal-content" style={{ maxWidth: '480px' }}>
            <div className="card-header">
              <h3 className="card-title">Ajouter un Médicament au Stock</h3>
              <button onClick={() => setModalNewMed(false)} style={{ border: 'none', background: 'transparent', cursor: 'pointer' }}>
                <X size={18} color="#9CA3AF" />
              </button>
            </div>
            <div className="card-body">
              <form onSubmit={handleAddMedicine}>
                <div className="form-group">
                  <label className="form-label">Nom du produit / dosage</label>
                  <input 
                    type="text" 
                    className="form-input" 
                    placeholder="Ex: Paracétamol Biocodex 1g" 
                    value={newMedName}
                    onChange={(e) => setNewMedName(e.target.value)}
                    required
                  />
                </div>

                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
                  <div className="form-group">
                    <label className="form-label">Prix (F CFA)</label>
                    <input 
                      type="number" 
                      className="form-input" 
                      value={newMedPrice}
                      onChange={(e) => setNewMedPrice(e.target.value)}
                      required
                    />
                  </div>
                  <div className="form-group">
                    <label className="form-label">Stock Initial</label>
                    <input 
                      type="number" 
                      className="form-input" 
                      value={newMedStock}
                      onChange={(e) => setNewMedStock(e.target.value)}
                      required
                    />
                  </div>
                </div>

                <div className="form-group">
                  <label style={{ display: 'flex', alignItems: 'center', gap: '8px', cursor: 'pointer', fontSize: '13px' }}>
                    <input 
                      type="checkbox" 
                      checked={newMedRequiresPrescription}
                      onChange={(e) => setNewMedRequiresPrescription(e.target.checked)}
                    />
                    <strong>Nécessite une ordonnance médicale obligatoire</strong>
                  </label>
                </div>

                <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px', marginTop: '16px' }}>
                  <button type="button" className="btn btn-secondary" onClick={() => setModalNewMed(false)}>
                    Annuler
                  </button>
                  <button type="submit" className="btn btn-primary">
                    Enregistrer le Médicament
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
