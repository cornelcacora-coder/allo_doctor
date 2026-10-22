/**
 * Tests de securite des regles Firestore.
 *
 *   1. un utilisateur ne peut pas creer de profil avec role 'admin'
 *   2. un utilisateur ne peut pas changer son propre role
 *   3. un utilisateur peut modifier les champs ordinaires de son profil
 *   4. l'admin peut gerer tous les comptes (statut compris)
 *   5. un utilisateur ne peut pas lire le profil d'un autre
 *   6. un praticien peut creer son dossier d'agrement, mais pas s'auto-valider
 *
 * Usage : npm run test:security
 */
import { initializeApp } from 'firebase/app';
import {
  getFirestore, doc, getDoc, setDoc, deleteDoc, getDocs, collection,
} from 'firebase/firestore';
import {
  getAuth, signInWithEmailAndPassword, createUserWithEmailAndPassword, signOut,
} from 'firebase/auth';

const config = {
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
const USER_EMAIL = 'securite.test@allo-doctor.example';
const USER_PASSWORD = 'Test-123456';

const app = initializeApp(config);
const db = getFirestore(app);
const auth = getAuth(app);

let ok = 0;
let ko = 0;
const check = (label, condition, detail = '') => {
  if (condition) { ok++; console.log(`  ✓ ${label}`); }
  else { ko++; console.log(`  ✗ ${label} ${detail}`); }
};
const denied = async (fn) => {
  try { await fn(); return false; } catch { return true; }
};

const main = async () => {
  console.log('🔐 Tests de sécurité des règles Firestore\n');

  // Compte utilisateur ordinaire (comme une inscription mobile)
  try {
    await signInWithEmailAndPassword(auth, USER_EMAIL, USER_PASSWORD);
  } catch {
    await createUserWithEmailAndPassword(auth, USER_EMAIL, USER_PASSWORD);
  }
  const uid = auth.currentUser.uid;
  console.log(`  (utilisateur uid=${uid})`);

  // 1. Création d'un profil avec role 'admin' -> REFUSE
  check(
    "création d'un profil avec role 'admin' refusée",
    await denied(() => setDoc(doc(db, 'users', uid), { email: USER_EMAIL, role: 'admin' })),
  );

  // 2. Création d'un profil avec un role applicatif -> AUTORISE
  let roleOk = true;
  try {
    await setDoc(doc(db, 'users', uid), {
      email: USER_EMAIL, name: 'Test Sécurité', role: 'patient', status: 'actif',
    });
  } catch { roleOk = false; }
  check("création d'un profil 'patient' autorisée", roleOk);

  // 3. Auto-promotion en admin -> REFUSE
  check(
    "auto-promotion en admin refusée",
    await denied(() => setDoc(doc(db, 'users', uid), { role: 'admin' }, { merge: true })),
  );
  const after = await getDoc(doc(db, 'users', uid));
  check('le role est resté patient', after.data()?.role === 'patient', `(role = ${after.data()?.role})`);

  // 4. Modification d'un champ ordinaire -> AUTORISE
  let phoneOk = true;
  try {
    await setDoc(doc(db, 'users', uid), { phone: '+212 600 11 22 33' }, { merge: true });
  } catch (e) { phoneOk = false; console.log('    -> erreur :', e.code, e.message); }
  check('modification du téléphone autorisée', phoneOk);

  // 5. Lecture du profil d'un autre -> REFUSE
  check(
    "lecture du profil d'un autre refusée",
    await denied(() => getDoc(doc(db, 'users', 'nrTa3B1PEoVRpBiQgAMe3kxZmQE3'))),
  );

  // 6. Dossier d'agrement : creation OK, auto-validation REFUSE
  check(
    'création du dossier d\'agrément autorisée',
    !(await denied(() => setDoc(doc(db, 'practitioners', uid), {
      id: uid, name: 'Dr. Test', type: 'medecin', status: 'en_attente', uid,
    }))),
  );
  check(
    'auto-validation du dossier refusée',
    await denied(() => setDoc(doc(db, 'practitioners', uid), { status: 'validé' }, { merge: true })),
  );

  // 7. L'admin peut tout gerer
  await signInWithEmailAndPassword(auth, ADMIN_EMAIL, ADMIN_PASSWORD);
  let adminOk = true;
  try {
    await setDoc(doc(db, 'users', uid), { status: 'suspendu' }, { merge: true });
  } catch { adminOk = false; }
  check("l'admin peut suspendre un compte", adminOk);
  let adminRoleOk = true;
  try {
    await setDoc(doc(db, 'users', uid), { role: 'admin' }, { merge: true });
  } catch { adminRoleOk = false; }
  check("l'admin peut attribuer un rôle", adminRoleOk);
  const list = await getDocs(collection(db, 'users'));
  check("l'admin lit la collection users", list.docs.length > 0);

  // Nettoyage
  await deleteDoc(doc(db, 'users', uid));
  await deleteDoc(doc(db, 'practitioners', uid));
  console.log('  ✓ nettoyage effectué');

  console.log(`\n${ok} test(s) réussi(s), ${ko} échec(s)`);
  process.exit(ko === 0 ? 0 : 1);
};

main().catch((e) => {
  console.error('ERREUR :', e?.message || e);
  process.exit(1);
});
