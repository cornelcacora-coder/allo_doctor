/**
 * Test de bout en bout du parcours d'inscription d'un praticien :
 *   1. creation du compte (comme l'app mobile)
 *   2. creation du dossier d'agrement dans 'practitioners'
 *   3. lecture par la console admin
 *   4. le praticien complete son dossier (autorise)
 *   5. le praticien tente de s'auto-valider (DOIT ERE REFUSE)
 *   6. l'admin valide le dossier (autorise)
 *   7. le praticien tente de le modifier apres validation (DOIT ETRE REFUSE)
 *   8. nettoyage
 */
import { initializeApp } from 'firebase/app';
import {
  getFirestore, doc, getDoc, setDoc, deleteDoc, collection, getDocs,
} from 'firebase/firestore';
import { getAuth, signInWithEmailAndPassword, createUserWithEmailAndPassword, signOut } from 'firebase/auth';

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
const PRATICIEN_EMAIL = 'praticien.test@allo-doctor.example';
const PRATICIEN_PASSWORD = 'Test-123456';

const app = initializeApp(config);
const db = getFirestore(app);
const auth = getAuth(app);

let ok = 0;
let ko = 0;
const check = (label, condition, detail = '') => {
  if (condition) { ok++; console.log(`  ✓ ${label}`); }
  else { ko++; console.log(`  ✗ ${label} ${detail}`); }
};

const signIn = async (email, password) => {
  try {
    await signInWithEmailAndPassword(auth, email, password);
  } catch (err) {
    if (err?.code === 'auth/user-not-found' || err?.code === 'auth/invalid-credential') {
      await createUserWithEmailAndPassword(auth, email, password);
    } else throw err;
  }
  return auth.currentUser.uid;
};

const main = async () => {
  console.log('🧪 Parcours complet : inscription d\'un praticien\n');

  // 1. Compte du praticien
  const uid = await signIn(PRATICIEN_EMAIL, PRATICIEN_PASSWORD);
  console.log(`  (praticien uid=${uid})`);

  // Etat propre : on efface les residus des executions precedentes.
  await signIn(ADMIN_EMAIL, ADMIN_PASSWORD);
  await deleteDoc(doc(db, 'practitioners', uid)).catch(() => {});
  await deleteDoc(doc(db, 'users', uid)).catch(() => {});
  await signIn(PRATICIEN_EMAIL, PRATICIEN_PASSWORD);

  // 2. Profil du praticien (comme une inscription mobile)
  const linkedUser = await getDoc(doc(db, 'users', uid));
  console.log(`  (profil existant : ${linkedUser.exists() ? JSON.stringify(linkedUser.data()) : 'absent'})`);
  if (!linkedUser.exists()) {
    try {
      await setDoc(doc(db, 'users', uid), {
        uid,
        email: PRATICIEN_EMAIL,
        name: 'Dr. Test Intégration',
        role: 'patient', // compte cree avant l'activation par l'agrement
        status: 'actif',
      });
      console.log('  (profil cree avec role=patient)');
    } catch (e) {
      console.log('  (profil NON cree :', e.code || e.message, ')');
    }
  }

  // 3. Dossier d'agrement, exactement comme l'app mobile l'ecrit
  const payload = {    id: uid,
    name: 'Dr. Test Intégration',
    type: 'medecin',
    specialty: 'Cardiologie',
    city: 'Casablanca',
    docNumber: 'ORD-MED-TEST-001',
    phone: '+212 600 00 00 00',
    address: '',
    documentsCount: 0,
    status: 'en_attente',
    date: new Date().toISOString(),
    email: PRATICIEN_EMAIL,
    uid,
  };
  try {
    await setDoc(doc(db, 'practitioners', uid), payload);
    check('création du dossier d\'agrément par le praticien', true);
  } catch (e) {
    check('création du dossier d\'agrément par le praticien', false, e.message);
  }

  // Role effectif du compte : c'est la regle appliquee par l'app mobile
  // (role_guard.dart) : le profil, ou le dossier d'agrement valide.
  const effectiveRole = async (uid) => {
    const u = await getDoc(doc(db, 'users', uid));
    let role = u.exists() ? (u.data()?.role ?? '') : '';
    if (!role || role === 'patient') {
      const p = await getDoc(doc(db, 'practitioners', uid));
      if (p.exists() && ['validé', 'valide'].includes(p.data()?.status)) {
        const type = p.data()?.type ?? '';
        if (type && type !== 'patient') role = type;
      }
    }
    return role;
  };

  check(
    "le role effectif du compte est 'patient' tant que le dossier n'est pas valide",
    (await effectiveRole(uid)) === 'patient',
    `(role = ${await effectiveRole(uid)})`,
  );

  // 3. Lecture par la console admin
  await signIn(ADMIN_EMAIL, ADMIN_PASSWORD);
  const snap = await getDocs(collection(db, 'practitioners'));
  const found = snap.docs.find((d) => d.id === uid);
  check('la console admin voit le dossier', Boolean(found));
  check('le dossier porte les bonnes données', found?.data()?.name === payload.name && found?.data()?.status === 'en_attente');
  check('le dossier apparaît en "en_attente"', found?.data()?.status === 'en_attente');

  // 4. Le praticien complete son dossier
  await signIn(PRATICIEN_EMAIL, PRATICIEN_PASSWORD);
  try {
    await setDoc(doc(db, 'practitioners', uid), { phone: '+212 611 11 11 11' }, { merge: true });
    check('le praticien peut compléter son dossier en attente', true);
  } catch (e) {
    check('le praticien peut compléter son dossier en attente', false, e.message);
  }

  // 5. Le praticien tente de s'auto-valider : doit etre refuse
  try {
    await setDoc(doc(db, 'practitioners', uid), { status: 'validé' }, { merge: true });
    const after = await getDoc(doc(db, 'practitioners', uid));
    check('auto-validation refusée', after.data()?.status !== 'validé', `(statut = ${after.data()?.status})`);
  } catch (e) {
    check('auto-validation refusée', true, `(erreur : ${e.code ?? e.message})`);
  }

  // 6. L'admin valide
  await signIn(ADMIN_EMAIL, ADMIN_PASSWORD);
  try {
    await setDoc(doc(db, 'practitioners', uid), { status: 'validé', validatedAt: new Date().toISOString() }, { merge: true });
    const after = await getDoc(doc(db, 'practitioners', uid));
    check('l\'admin peut valider le dossier', after.data()?.status === 'validé');
  } catch (e) {
    check('l\'admin peut valider le dossier', false, e.message);
  }

  // 7. Apres validation, le praticien ne peut plus modifier
  await signIn(PRATICIEN_EMAIL, PRATICIEN_PASSWORD);
  try {
    await setDoc(doc(db, 'practitioners', uid), { city: 'Rabat' }, { merge: true });
    const after = await getDoc(doc(db, 'practitioners', uid));
    check('modification refusée après validation', after.data()?.city !== 'Rabat');
  } catch (e) {
    check('modification refusée après validation', true, `(erreur : ${e.code ?? e.message})`);
  }

  // 8. Apres validation, le role effectif du compte est bien celui du dossier
  check(
    "le role effectif du compte devient 'medecin' apres validation",
    (await effectiveRole(uid)) === 'medecin',
    `(role = ${await effectiveRole(uid)})`,
  );

  // 8. Nettoyage
  await signIn(ADMIN_EMAIL, ADMIN_PASSWORD);
  try {
    await deleteDoc(doc(db, 'practitioners', uid));
    check('nettoyage du dossier de test', true);
  } catch (e) {
    check('nettoyage du dossier de test', false, e.message);
  }
  try {
    await signOut(auth);
    await signIn(PRATICIEN_EMAIL, PRATICIEN_PASSWORD);
    await deleteDoc(doc(db, 'users', uid));
    check('nettoyage du compte de test', true);
  } catch (e) {
    // Un utilisateur ne peut pas supprimer son propre profil : c'est
    // l'admin qui nettoie (regle delete reservee a l'administration).
    await signIn(ADMIN_EMAIL, ADMIN_PASSWORD);
    try {
      await deleteDoc(doc(db, 'users', uid));
      check('nettoyage du compte de test (par l\'admin)', true);
    } catch (e2) {
      check('nettoyage du compte de test (par l\'admin)', false, e2.message);
    }
  }

  console.log(`\n${ok} test(s) réussi(s), ${ko} échec(s)`);
  process.exit(ko === 0 ? 0 : 1);
};

main().catch((e) => {
  console.error('ERREUR :', e?.message || e);
  process.exit(1);
});
