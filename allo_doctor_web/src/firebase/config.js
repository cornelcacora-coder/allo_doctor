import { initializeApp } from "firebase/app";
import { getAuth } from "firebase/auth";
import { getFirestore } from "firebase/firestore";
import { getStorage } from "firebase/storage";

// Configuration Firebase partagée directement avec l'application Flutter Allo Doctor
const firebaseConfig = {
  apiKey: "AIzaSyAxBbMaDvSkEYv6bsIgwisfRTB1KRhbABQ",
  authDomain: "allo-doctor-app.firebaseapp.com",
  projectId: "allo-doctor-app",
  storageBucket: "allo-doctor-app.firebasestorage.app",
  messagingSenderId: "766343053778",
  appId: "1:766343053778:web:cef082b2c9be395024880b",
  measurementId: "G-0FLHRX36KD"
};

// Initialisation de Firebase
const app = initializeApp(firebaseConfig);

// Services exportés pour l'application Web
export const auth = getAuth(app);
export const db = getFirestore(app);
export const storage = getStorage(app);

export default app;
