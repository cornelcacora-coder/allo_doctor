import { 
  collection, 
  query, 
  where, 
  orderBy, 
  onSnapshot, 
  addDoc, 
  updateDoc, 
  doc, 
  serverTimestamp, 
  getDocs 
} from 'firebase/firestore';
import { db } from '../firebase/config';

// DONNÉES INITIALES RÉALISTES POUR AFFICHAGE IMMÉDIAT
const DEFAULT_DOCTORS = [
  {
    id: 'doc_1',
    display_name: 'Dr. Amina Mansouri',
    profCategory: 'Cardiologue',
    photo_url: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=200&auto=format&fit=crop&q=80',
    rating: 4.9,
    reviews_count: 128,
    city: 'Casablanca',
    address: '14 Bd d\'Anfa, Gauthier',
    fee: 25000,
    availability: 'Aujourd\'hui 16:30',
    specialties: ['Hypertension', 'Électrocardiogramme', 'Insuffisance cardiaque']
  },
  {
    id: 'doc_2',
    display_name: 'Dr. Mehdi Bennani',
    profCategory: 'Pédiatre',
    photo_url: 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=200&auto=format&fit=crop&q=80',
    rating: 4.8,
    reviews_count: 94,
    city: 'Rabat',
    address: '22 Avenue de France, Agdal',
    fee: 20000,
    availability: 'Demain 09:00',
    specialties: ['Vaccination infantile', 'Suivi du nourrisson', 'Urgences pédiatriques']
  },
  {
    id: 'doc_3',
    display_name: 'Dr. Sarah El Alami',
    profCategory: 'Dermatologue',
    photo_url: 'https://images.unsplash.com/photo-1594824813590-48283a218d99?w=200&auto=format&fit=crop&q=80',
    rating: 4.95,
    reviews_count: 210,
    city: 'Casablanca',
    address: '5 Bd Zerktouni, Racine',
    fee: 30000,
    availability: 'Jeudi 11:15',
    specialties: ['Laser médical', 'Acné', 'Dépistage mélanome']
  },
  {
    id: 'doc_4',
    display_name: 'Dr. Youssef Chaoui',
    profCategory: 'Médecin Généraliste',
    photo_url: 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=200&auto=format&fit=crop&q=80',
    rating: 4.7,
    reviews_count: 160,
    city: 'Marrakech',
    address: 'Hivernage, Guéliz',
    fee: 15000,
    availability: 'Aujourd\'hui 17:00',
    specialties: ['Bilan de santé', 'Certificats médicaux', 'Visites à domicile']
  }
];

const DEFAULT_PHARMACIES = [
  {
    id: 'pharma_1',
    name: 'Pharmacie Al Amal',
    address: '88 Avenue Hassan II, Centre Ville, Casablanca',
    phone: '+212 522 22 33 44',
    is_on_duty: true,
    distance: '350 m',
    rating: 4.9,
    opening_hours: '24h/24 (De garde ce soir)'
  },
  {
    id: 'pharma_2',
    name: 'Pharmacie Ibn Sina',
    address: '12 Rue Abou Dhabi, Agdal, Rabat',
    phone: '+212 537 77 88 99',
    is_on_duty: false,
    distance: '1.2 km',
    rating: 4.6,
    opening_hours: '08:30 - 20:30'
  },
  {
    id: 'pharma_3',
    name: 'Grande Pharmacie de la Gare',
    address: 'Place des Nations Unies, Casablanca',
    phone: '+212 522 45 67 89',
    is_on_duty: true,
    distance: '800 m',
    rating: 4.8,
    opening_hours: '24h/24 (De garde)'
  }
];

const DEFAULT_MEDICINES = [
  {
    id: 'med_1',
    name: 'Doliprane 1000mg',
    category: 'Antalgique / Fièvre',
    price: 1200,
    stock: 142,
    description: 'Paracétamol pour douleurs et fièvre',
    dosage: '1 comprimé toutes les 6h si besoin',
    requires_prescription: false
  },
  {
    id: 'med_2',
    name: 'Augmentin 1g/125mg',
    category: 'Antibiotique',
    price: 6100,
    stock: 28,
    description: 'Amoxicilline / Acide clavulanique',
    dosage: '1 comprimé matin et soir',
    requires_prescription: true
  },
  {
    id: 'med_3',
    name: 'Kardegic 75mg',
    category: 'Cardiologie',
    price: 2100,
    stock: 65,
    description: 'Antiagrégant plaquettaire',
    dosage: '1 sachet par jour au déjeuner',
    requires_prescription: true
  },
  {
    id: 'med_4',
    name: 'Inipomp 40mg',
    category: 'Gastro-entérologie',
    price: 4975,
    stock: 44,
    description: 'Pantoprazole - Reflux gastrique',
    dosage: '1 comprimé à jeun le matin',
    requires_prescription: true
  },
  {
    id: 'med_5',
    name: 'Ventoline 100µg',
    category: 'Pneumologie',
    price: 2925,
    stock: 19,
    description: 'Inhalateur pour crises d\'asthme',
    dosage: '1 à 2 bouffées en cas de crise',
    requires_prescription: true
  }
];

const DEFAULT_APPOINTMENTS = [
  {
    id: 'apt_1',
    patient_name: 'Karim Tazi',
    patient_phone: '+237 655 23 45 67',
    doctor_name: 'Dr. Amina Mansouri',
    doctor_specialty: 'Cardiologue',
    date_time: '14 Oct 2026 - 15:00',
    appointment_type: 'cabinet',
    consult_mode: 'En cabinet',
    status: 'confirmé',
    fee: 25000,
    symptoms: 'Palpitations et essoufflement à l\'effort'
  },
  {
    id: 'apt_2',
    patient_name: 'Salma Benjelloun',
    patient_phone: '+237 699 11 22 33',
    doctor_name: 'Dr. Amina Mansouri',
    doctor_specialty: 'Cardiologue',
    date_time: '14 Oct 2026 - 16:30',
    appointment_type: 'video',
    consult_mode: 'Téléconsultation',
    status: 'en_attente',
    fee: 20000,
    symptoms: 'Suivi traitement hypertension'
  },
  {
    id: 'apt_3',
    patient_name: 'Yassine Idrissi',
    patient_phone: '+237 677 44 55 66',
    doctor_name: 'Dr. Amina Mansouri',
    doctor_specialty: 'Cardiologue',
    date_time: '15 Oct 2026 - 10:00',
    appointment_type: 'cabinet',
    consult_mode: 'En cabinet',
    status: 'confirmé',
    fee: 25000,
    symptoms: 'Bilan cardiaque annuel'
  }
];

const DEFAULT_PRESCRIPTIONS = [
  {
    id: 'presc_1',
    code: 'ORD-2026-8941',
    patient_name: 'Karim Tazi',
    doctor_name: 'Dr. Amina Mansouri',
    doctor_specialty: 'Cardiologie',
    date: '10 Oct 2026',
    status: 'Délivrée',
    medicines: [
      { name: 'Kardegic 75mg', posology: '1 sachet le midi', duration: '30 jours' },
      { name: 'Aprovel 150mg', posology: '1 comprimé le matin', duration: '30 jours' }
    ],
    notes: 'Contrôler la tension artérielle 2 fois par semaine. Éviter le sel.'
  }
];

const DEFAULT_SOS = [
  {
    id: 'sos_1',
    patient_name: 'Omar Filali',
    phone: '+212 670 12 34 56',
    location: 'Bd Mohammed V, Casablanca (Coord: 33.5928, -7.6192)',
    emergency_type: 'Douleur thoracique aiguë',
    status: 'Ambulance dépêchée',
    time: 'Il y a 6 min'
  }
];

// SERVICE FIRESTORE TEMPS RÉEL AVEC FALLBACK HARMONIEUX
export const firestoreService = {
  // --- RENDEZ-VOUS ---
  listenAppointments: (callback) => {
    try {
      const q = query(collection(db, 'appointments'));
      return onSnapshot(q, (snapshot) => {
        if (!snapshot.empty) {
          const list = snapshot.docs.map(d => ({ id: d.id, ...d.data() }));
          callback(list);
        } else {
          callback(DEFAULT_APPOINTMENTS);
        }
      }, (err) => {
        console.warn('Mode Firestore local utilisé pour Appointments:', err.message);
        callback(DEFAULT_APPOINTMENTS);
      });
    } catch (e) {
      callback(DEFAULT_APPOINTMENTS);
      return () => {};
    }
  },

  createAppointment: async (appointmentData) => {
    try {
      const docRef = await addDoc(collection(db, 'appointments'), {
        ...appointmentData,
        created_at: serverTimestamp(),
        status: 'en_attente'
      });
      return docRef.id;
    } catch (e) {
      console.warn('Simulation enregistrement RDV local:', e.message);
      return 'apt_' + Date.now();
    }
  },

  updateAppointmentStatus: async (id, status) => {
    try {
      await updateDoc(doc(db, 'appointments', id), {
        status,
        updated_at: serverTimestamp()
      });
    } catch (e) {
      console.warn('Simulation mise à jour statut:', e.message);
    }
  },

  // --- ORDONNANCES ---
  listenPrescriptions: (callback) => {
    try {
      const q = query(collection(db, 'prescriptions'));
      return onSnapshot(q, (snapshot) => {
        if (!snapshot.empty) {
          const list = snapshot.docs.map(d => ({ id: d.id, ...d.data() }));
          callback(list);
        } else {
          callback(DEFAULT_PRESCRIPTIONS);
        }
      }, (err) => {
        console.warn('Firestore fallback pour Prescriptions:', err.message);
        callback(DEFAULT_PRESCRIPTIONS);
      });
    } catch (e) {
      callback(DEFAULT_PRESCRIPTIONS);
      return () => {};
    }
  },

  createPrescription: async (data) => {
    try {
      const docRef = await addDoc(collection(db, 'prescriptions'), {
        ...data,
        created_at: serverTimestamp(),
        status: 'Active'
      });
      return docRef.id;
    } catch (e) {
      console.warn('Simulation création ordonnance:', e.message);
      return 'presc_' + Date.now();
    }
  },

  // --- MÉDICAMENTS & PHARMACIE ---
  listenMedicines: (callback) => {
    try {
      const q = query(collection(db, 'medicines'));
      return onSnapshot(q, (snapshot) => {
        if (!snapshot.empty) {
          const list = snapshot.docs.map(d => ({ id: d.id, ...d.data() }));
          callback(list);
        } else {
          callback(DEFAULT_MEDICINES);
        }
      }, (err) => {
        console.warn('Firestore fallback pour Medicines:', err.message);
        callback(DEFAULT_MEDICINES);
      });
    } catch (e) {
      callback(DEFAULT_MEDICINES);
      return () => {};
    }
  },

  updateMedicineStock: async (id, newStock) => {
    try {
      await updateDoc(doc(db, 'medicines', id), { stock: Number(newStock) });
    } catch (e) {
      console.warn('Simulation mise à jour stock:', e.message);
    }
  },

  // --- PHARMACIES ---
  listenPharmacies: (callback) => {
    try {
      const q = query(collection(db, 'pharmacies'));
      return onSnapshot(q, (snapshot) => {
        if (!snapshot.empty) {
          const list = snapshot.docs.map(d => ({ id: d.id, ...d.data() }));
          callback(list);
        } else {
          callback(DEFAULT_PHARMACIES);
        }
      }, () => callback(DEFAULT_PHARMACIES));
    } catch (e) {
      callback(DEFAULT_PHARMACIES);
      return () => {};
    }
  },

  // --- URGENCES SOS ---
  listenSos: (callback) => {
    try {
      const q = query(collection(db, 'sos_emergencies'));
      return onSnapshot(q, (snapshot) => {
        if (!snapshot.empty) {
          const list = snapshot.docs.map(d => ({ id: d.id, ...d.data() }));
          callback(list);
        } else {
          callback(DEFAULT_SOS);
        }
      }, () => callback(DEFAULT_SOS));
    } catch (e) {
      callback(DEFAULT_SOS);
      return () => {};
    }
  },

  triggerSos: async (sosData) => {
    try {
      const docRef = await addDoc(collection(db, 'sos_emergencies'), {
        ...sosData,
        timestamp: serverTimestamp(),
        status: 'Alerte SOS Déclenchée'
      });
      return docRef.id;
    } catch (e) {
      console.warn('Simulation déclenchement SOS:', e.message);
      return 'sos_' + Date.now();
    }
  },

  // --- MÉDECINS ---
  getDoctors: () => DEFAULT_DOCTORS
};
