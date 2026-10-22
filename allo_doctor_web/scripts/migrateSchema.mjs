/**
 * Migration du schema Firestore vers le schema canonique partage entre
 * l'application mobile (Flutter) et la console admin (React).
 *
 *   - users        : name, email, phone, city, gender, role, status,
 *                    emailVerified, createdAt (+ alias francais conserves)
 *   - practitioners: name, type, specialty, city, docNumber, phone,
 *                    address, documentsCount, status, date
 *
 * Supprime aussi le champ `password` (mot de passe en clair) s'il existe.
 *
 * Usage : npm run migrate:schema
 */
import { initializeApp } from 'firebase/app';
import {
  getFirestore,
  doc,
  getDoc,
  getDocs,
  collection,
  setDoc,
  deleteField,
} from 'firebase/firestore';
import {
  getAuth,
  signInWithEmailAndPassword,
  createUserWithEmailAndPassword,
} from 'firebase/auth';

const firebaseConfig = {
  apiKey: 'AIzaSyAxBbMaDvSkEYv6bsIgwisfRTB1KRhbABQ',
  authDomain: 'allo-doctor-app.firebaseapp.com',
  projectId: 'allo-doctor-app',
  storageBucket: 'allo-doctor-app.firebasestorage.app',
  messagingSenderId: '766343053778',
  appId: '1:766343053778:web:cef082b2c9be395024880b',
  measurementId: 'G-0FLHRX36KD',
};

const ADMIN_EMAIL = 'testnetdeveloper61@gmail.com';
const ADMIN_PASSWORD = 'Ntemo123';

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);
const auth = getAuth(app);

const authenticate = async () => {
  try {
    await signInWithEmailAndPassword(auth, ADMIN_EMAIL, ADMIN_PASSWORD);
  } catch (err) {
    if (err?.code === 'auth/user-not-found' || err?.code === 'auth/invalid-credential') {
      await createUserWithEmailAndPassword(auth, ADMIN_EMAIL, ADMIN_PASSWORD);
    } else {
      throw err;
    }
  }
  console.log('✓ Authentifié administrateur');
};

const str = (v) => (v === null || v === undefined ? '' : String(v));

const migrateUsers = async () => {
  const snap = await getDocs(collection(db, 'users'));
  let changed = 0;
  for (const d of snap.docs) {
    const data = d.data();
    const name = str(data.name || data.nom);
    const email = str(data.email);
    const phone = str(data.phone || data.telephone);
    const city = str(data.city || data.ville);
    const gender = str(data.gender || data.sexe);

    const next = {
      ...data,
      uid: data.uid || d.id,
      name,
      email,
      phone,
      city,
      gender,
      role: str(data.role || data.userCategory || 'patient'),
      status: str(data.status || 'actif'),
      emailVerified: Boolean(data.emailVerified ?? data.emailVerifie ?? false),
      // Alias francais : conserves pour la compatibilite des ecrans mobiles
      nom: name,
      telephone: phone,
      ville: city,
      sexe: gender,
      emailVerifie: Boolean(data.emailVerified ?? data.emailVerifie ?? false),
    };
    // Suppression du mot de passe en clair
    if ('password' in data) {
      next.password = deleteField();
    }

    await setDoc(doc(db, 'users', d.id), next, { merge: true });
    changed++;
    console.log(`  - users/${d.id} : ${name || email}`);
  }
  console.log(`✓ ${changed} document(s) 'users' normalisé(s)`);
};

const migratePractitioners = async () => {
  const snap = await getDocs(collection(db, 'practitioners'));
  let changed = 0;
  for (const d of snap.docs) {
    const data = d.data();
    const type = str(data.type || data.category || 'medecin');
    const next = {
      ...data,
      id: data.id || d.id,
      name: str(data.name || data.nom),
      type,
      specialty: str(data.specialty || data.specialite),
      city: str(data.city || data.ville),
      docNumber: str(data.docNumber || data.numeroOrdre),
      phone: str(data.phone || data.telephone),
      address: str(data.address || data.adresse),
      documentsCount: Number.isFinite(Number(data.documentsCount))
        ? Number(data.documentsCount)
        : 0,
      status: str(data.status || 'en_attente'),
      date: str(data.date || data.createdAt),
    };
    await setDoc(doc(db, 'practitioners', d.id), next, { merge: true });
    changed++;
    console.log(`  - practitioners/${d.id} : ${next.name} (${type}, ${next.status})`);
  }
  console.log(`✓ ${changed} document(s) 'practitioners' normalisé(s)`);
};

const main = async () => {
  console.log('🔄 Migration du schéma Firestore Allo Doctor...');
  await authenticate();
  await migrateUsers();
  await migratePractitioners();
  console.log('🎉 Schéma unifié.');
  process.exit(0);
};

main().catch((err) => {
  console.error('❌ Échec de la migration :', err?.message || err);
  process.exit(1);
});
