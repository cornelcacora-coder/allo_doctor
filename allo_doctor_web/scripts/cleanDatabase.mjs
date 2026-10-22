/**
 * Script de nettoyage complet de Firestore :
 * Supprime tous les documents de toutes les collections et conserve uniquement l'administrateur.
 */
import { initializeApp } from 'firebase/app';
import {
  getFirestore,
  collection,
  getDocs,
  doc,
  deleteDoc,
  setDoc,
  serverTimestamp,
} from 'firebase/firestore';
import {
  getAuth,
  signInWithEmailAndPassword,
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

const COLLECTIONS_TO_CLEAR = [
  'practitioners',
  'appointments',
  'prescriptions',
  'medicines',
  'pharmacies',
  'clinics',
  'sos_emergencies',
  'tickets',
  'statistics',
  'lab_results',
  'transactions',
  'User',
];

async function cleanDatabase() {
  console.log('🔄 Connexion en tant qu\'administrateur...');
  const userCredential = await signInWithEmailAndPassword(auth, ADMIN_EMAIL, ADMIN_PASSWORD);
  const adminUid = userCredential.user.uid;
  console.log(`✓ Connecté avec succès : ${ADMIN_EMAIL} (UID: ${adminUid})`);

  // 1. Vider les collections annexes
  for (const colName of COLLECTIONS_TO_CLEAR) {
    try {
      const snap = await getDocs(collection(db, colName));
      if (snap.empty) {
        console.log(`- Collection [${colName}] : déjà vide.`);
        continue;
      }
      console.log(`- Nettoyage de [${colName}] (${snap.size} document(s))...`);
      for (const d of snap.docs) {
        await deleteDoc(doc(db, colName, d.id));
        console.log(`  🗑 Supprimé dans ${colName}: ${d.id}`);
      }
    } catch (err) {
      console.error(`  ⚠️ Erreur sur [${colName}]:`, err.message);
    }
  }

  // 2. Nettoyer la collection 'users' en ne gardant que l'administrateur
  console.log('\n- Nettoyage de la collection [users]...');
  const usersSnap = await getDocs(collection(db, 'users'));
  for (const d of usersSnap.docs) {
    const data = d.data();
    const isDocAdmin =
      d.id === adminUid ||
      d.id === 'admin_root' ||
      (data.email === ADMIN_EMAIL && data.role === 'admin' && d.id !== 'Hm4x7WaEDPB1fopznvbE');

    if (!isDocAdmin) {
      await deleteDoc(doc(db, 'users', d.id));
      console.log(`  🗑 Supprimé utilisateur: ${d.id} (${data.name || data.nom || data.email || 'Sans nom'})`);
    } else if (d.id === 'Hm4x7WaEDPB1fopznvbE') {
      // Nettoyage de l'ancien doublon d'admin temporaire
      await deleteDoc(doc(db, 'users', d.id));
      console.log(`  🗑 Supprimé doublon admin obsolète: ${d.id}`);
    }
  }

  // 3. Garantir que le document de l'administrateur avec son UID officiel existe et est à jour
  const adminDocData = {
    uid: adminUid,
    email: ADMIN_EMAIL,
    name: 'Super Administrateur',
    nom: 'Super Administrateur',
    displayName: 'Super Administrateur',
    role: 'admin',
    userCategory: 'admin',
    status: 'actif',
    emailVerified: true,
    emailVerifie: true,
    phone: '',
    telephone: '',
    city: 'Casablanca',
    ville: 'Casablanca',
    gender: '',
    sexe: '',
    registered: '19 Oct 2026',
    updatedAt: new Date().toISOString(),
  };

  await setDoc(doc(db, 'users', adminUid), adminDocData, { merge: true });
  console.log(`✓ Document admin créé/mis à jour dans 'users/${adminUid}'`);

  // Garder également admin_root pour la compatibilité avec d'anciens scripts
  await setDoc(doc(db, 'users', 'admin_root'), {
    ...adminDocData,
    uid: 'admin_root',
  }, { merge: true });
  console.log(`✓ Document admin_root mis à jour dans 'users/admin_root'`);

  // 4. Vérification finale
  console.log('\n========================================');
  console.log('📊 ÉTAT FINAL DE LA BASE DE DONNÉES :');
  console.log('========================================');
  for (const colName of ['users', ...COLLECTIONS_TO_CLEAR]) {
    try {
      const snap = await getDocs(collection(db, colName));
      console.log(`Collection [${colName}] : ${snap.size} document(s)`);
      snap.forEach(d => {
        const data = d.data();
        console.log(`  -> ID: ${d.id} | Email: ${data.email || 'N/A'} | Role: ${data.role || 'N/A'}`);
      });
    } catch (e) {
      console.log(`Collection [${colName}] : non accessible ou vide.`);
    }
  }

  console.log('\n✅ Nettoyage terminé avec succès ! Seul le compte Admin est conservé.');
  process.exit(0);
}

cleanDatabase().catch(err => {
  console.error('❌ Erreur lors du nettoyage :', err);
  process.exit(1);
});
