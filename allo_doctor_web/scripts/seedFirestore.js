import { initializeApp } from "firebase/app";
import { getFirestore, doc, setDoc } from "firebase/firestore";
import { getAuth, signInWithEmailAndPassword, createUserWithEmailAndPassword } from "firebase/auth";

const firebaseConfig = {
  apiKey: "AIzaSyAxBbMaDvSkEYv6bsIgwisfRTB1KRhbABQ",
  authDomain: "allo-doctor-app.firebaseapp.com",
  projectId: "allo-doctor-app",
  storageBucket: "allo-doctor-app.firebasestorage.app",
  messagingSenderId: "766343053778",
  appId: "1:766343053778:web:cef082b2c9be395024880b",
  measurementId: "G-0FLHRX36KD"
};

const ADMIN_EMAIL = "testnetdeveloper61@gmail.com";
const ADMIN_PASSWORD = "Ntemo123";

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);
const auth = getAuth(app);

/**
 * Les regles Firestore exigent request.auth : une ecriture anonyme est
 * refusee ("Missing or insufficient permissions"). On s'authentifie donc
 * avec le compte administrateur avant toute ecriture.
 */
const authenticate = async () => {
  try {
    await signInWithEmailAndPassword(auth, ADMIN_EMAIL, ADMIN_PASSWORD);
    console.log("✓ Authentifié administrateur :", ADMIN_EMAIL);
  } catch (err) {
    if (err?.code === "auth/user-not-found" || err?.code === "auth/invalid-credential") {
      await createUserWithEmailAndPassword(auth, ADMIN_EMAIL, ADMIN_PASSWORD);
      console.log("✓ Compte administrateur créé :", ADMIN_EMAIL);
    } else {
      throw err;
    }
  }
};

const seedData = async () => {
  console.log("🚀 Initialisation des collections Firestore pour Allo Doctor...");

  await authenticate();

  // 1. Collection 'users'
  const adminUser = {
    email: "testnetdeveloper61@gmail.com",
    name: "Super Administrateur",
    role: "admin",
    userCategory: "admin",
    status: "actif",
    registered: "19 Oct 2026"
  };
  await setDoc(doc(db, "users", "admin_root"), adminUser);
  console.log("✓ Utilisateur Administrateur créé dans 'users'");

  // 2. Collection 'practitioners' (5.5.2)
  const practitioners = [
    {
      id: "doc-01",
      name: "Dr. Yassine Kadiri",
      type: "medecin",
      specialty: "Ophtalmologie",
      city: "Casablanca",
      docNumber: "ORD-MED-1249",
      phone: "+212 661 88 99 00",
      address: "Boulevard d'Anfa, Casablanca",
      documentsCount: 4,
      status: "en_attente",
      date: "Aujourd'hui 10:30"
    },
    {
      id: "pharma-01",
      name: "Pharmacie Atlas Agdal",
      type: "pharmacie",
      specialty: "Officine & Garde",
      city: "Rabat",
      docNumber: "LIC-PHARM-4401",
      phone: "+212 537 77 88 99",
      address: "Place Ibn Yassine, Agdal, Rabat",
      documentsCount: 3,
      status: "en_attente",
      date: "Aujourd'hui 09:15"
    },
    {
      id: "clinic-01",
      name: "Clinique Internationale Oasis",
      type: "clinique",
      specialty: "Chirurgie & Maternité",
      city: "Casablanca",
      docNumber: "AGR-MS-CLIN-802",
      phone: "+212 522 33 44 55",
      address: "Quartier Oasis, Casablanca",
      documentsCount: 5,
      status: "en_attente",
      date: "Aujourd'hui 11:30"
    },
    {
      id: "doc-02",
      name: "Dr. Mehdi Bennani",
      type: "medecin",
      specialty: "Pédiatrie",
      city: "Rabat",
      docNumber: "ORD-MED-9941",
      phone: "+212 662 11 22 33",
      address: "Rue Al Mariniyine, Rabat",
      documentsCount: 4,
      status: "validé",
      date: "11 Oct 2026"
    }
  ];

  for (const p of practitioners) {
    await setDoc(doc(db, "practitioners", p.id), p);
  }
  console.log("✓ Praticiens et établissements créés dans 'practitioners'");

  // 3. Collection 'tickets' (5.5.3)
  const tickets = [
    {
      id: "TK-1082",
      subject: "Litige : Téléconsultation interrompue incident technique",
      requesterType: "Patient",
      requesterName: "Salma Benjelloun",
      requesterPhone: "+212 664 12 34 56",
      category: "Téléconsultation & Remboursement",
      priority: "Urgente",
      status: "Ouvert",
      isLitige: true,
      disputedAmount: "350 MAD",
      relatedEntity: "Dr. Yassine Kadiri",
      date: "19 Oct 2026",
      messages: [
        {
          sender: "Salma Benjelloun",
          role: "user",
          text: "La téléconsultation a coupé après 2 minutes suite à un problème serveur. Mon compte a été débité de 350 MAD.",
          time: "19 Oct 09:15"
        }
      ]
    },
    {
      id: "TK-1081",
      subject: "Vérification licence officine et convention tiers-payant",
      requesterType: "Pharmacie",
      requesterName: "Pharmacie Atlas Agdal",
      requesterPhone: "+212 537 77 88 99",
      category: "Délivrance Médicaments",
      priority: "Haute",
      status: "En cours",
      isLitige: false,
      relatedEntity: "Conseil National de l'Ordre",
      date: "18 Oct 2026",
      messages: [
        {
          sender: "Dr. Benzekri (Pharmacien)",
          role: "user",
          text: "Nous souhaitons activer la synchronisation des ordonnances électroniques.",
          time: "18 Oct 14:00"
        }
      ]
    }
  ];

  for (const t of tickets) {
    await setDoc(doc(db, "tickets", t.id), t);
  }
  console.log("✓ Tickets de support et litiges créés dans 'tickets'");
};

seedData()
  .then(() => {
    console.log("🎉 Toutes les collections ont été initialisées avec succès dans Firebase Firestore !");
    // Le SDK Auth garde une connexion ouverte : on termine explicitement.
    process.exit(0);
  })
  .catch((err) => {
    console.error("❌ Échec du seed :", err?.message || err);
    process.exit(1);
  });
