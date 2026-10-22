import { initializeApp } from 'firebase/app';
import { getFirestore, collection, getDocs, doc, getDoc } from 'firebase/firestore';
import { getAuth, signInWithEmailAndPassword } from 'firebase/auth';

const firebaseConfig = {
  apiKey: 'AIzaSyAxBbMaDvSkEYv6bsIgwisfRTB1KRhbABQ',
  authDomain: 'allo-doctor-app.firebaseapp.com',
  projectId: 'allo-doctor-app',
  storageBucket: 'allo-doctor-app.firebasestorage.app',
  messagingSenderId: '766343053778',
  appId: '1:766343053778:web:cef082b2c9be395024880b',
  measurementId: 'G-0FLHRX36KD',
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);
const auth = getAuth(app);

async function run() {
  await signInWithEmailAndPassword(auth, 'testnetdeveloper61@gmail.com', 'Ntemo123');
  console.log('Admin connected');

  const usersSnap = await getDocs(collection(db, 'users'));
  console.log('=== USERS ===');
  usersSnap.forEach(d => {
    const data = d.data();
    console.log(`ID: ${d.id}`, JSON.stringify(data));
  });

  const pracSnap = await getDocs(collection(db, 'practitioners'));
  console.log('=== PRACTITIONERS ===');
  pracSnap.forEach(d => {
    console.log(`ID: ${d.id}`, JSON.stringify(d.data()));
  });
}

run().catch(console.error);
