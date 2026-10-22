import React, { createContext, useContext, useState, useEffect } from 'react';
import { 
  signInWithEmailAndPassword, 
  createUserWithEmailAndPassword,
  signOut as firebaseSignOut,
  onAuthStateChanged
} from 'firebase/auth';
import { doc, getDoc } from 'firebase/firestore';
import { auth, db } from '../firebase/config';

const ADMIN_EMAIL = 'testnetdeveloper61@gmail.com';
const ADMIN_PASSWORD = 'Ntemo123';
const SESSION_KEY = 'allo_doctor_admin_session';

const defaultAuthState = {
  currentUser: null,
  isAuthenticated: false,
  isAdmin: true,
  authReady: false,
  login: async () => {},
  loginAdminDemo: async () => {},
  logout: async () => {},
  loading: false,
  authError: ''
};

const AuthContext = createContext(defaultAuthState);

/** Une session locale n'accorde aucun acces Firestore : les regles exigent
 *  request.auth. Elle ne sert donc qu'a afficher l'interface. */
const readLocalSession = () => {
  try {
    const saved = localStorage.getItem(SESSION_KEY);
    if (!saved) return null;
    const parsed = JSON.parse(saved);
    if (parsed?.email === ADMIN_EMAIL || parsed?.role === 'admin') return parsed;
  } catch {
    localStorage.removeItem(SESSION_KEY);
  }
  return null;
};

export const AuthProvider = ({ children }) => {
  const [currentUser, setCurrentUser] = useState(() => readLocalSession());
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  // true une fois que Firebase Auth a repondu (session reelle etablie ou non)
  const [authReady, setAuthReady] = useState(false);
  const [loading, setLoading] = useState(false);
  const [authError, setAuthError] = useState('');

  const persist = (user) => {
    setCurrentUser(user);
    setIsAuthenticated(true);
    localStorage.setItem(SESSION_KEY, JSON.stringify(user));
  };

  const clear = () => {
    setCurrentUser(null);
    setIsAuthenticated(false);
    localStorage.removeItem(SESSION_KEY);
  };

  // 1. L'etat d'authentification reelle (Firebase Auth) fait foi.
  //    Sans session Auth, toutes les requetes Firestore sont anonymes et
  //    donc refusees par les regles de securite.
  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (firebaseUser) => {
      setAuthReady(true);
      if (!firebaseUser) {
        // Plus de session Firebase : on ne peut rien lire/ecrire dans
        // Firestore. On revient a l'ecran de connexion plutot que d'afficher
        // une console vide qui plante sur chaque requete.
        clear();
        return;
      }

      const emailLower = (firebaseUser.email || '').toLowerCase().trim();
      const isAdminEmail = emailLower === ADMIN_EMAIL;

      let userData = {
        uid: firebaseUser.uid,
        email: firebaseUser.email,
        display_name:
          firebaseUser.displayName || emailLower.split('@')[0] || 'Administrateur',
        userCategory: isAdminEmail ? 'admin' : 'patient'
      };

      try {
        const userDoc = await getDoc(doc(db, 'users', firebaseUser.uid));
        if (userDoc.exists()) {
          userData = { ...userData, ...userDoc.data() };
        }
      } catch (e) {
        console.warn('Vérification rôle Firestore:', e.message);
      }

      if (isAdminEmail || userData.userCategory === 'admin' || userData.role === 'admin') {
        userData.userCategory = 'admin';
        userData.role = 'admin';
        persist(userData);
      } else {
        await firebaseSignOut(auth);
        clear();
        setAuthError('Accès réservé exclusivement aux Administrateurs.');
      }
    });

    return () => unsubscribe();
  }, []);

  // 2. Connexion : une VRAIE session Firebase Auth est obligatoire.
  const login = async (email, password) => {
    setLoading(true);
    setAuthError('');
    const trimmedEmail = email.trim().toLowerCase();
    const trimmedPassword = password.trim();

    try {
      // Cas A : compte administrateur de reference. On cree le compte Auth
      // a la volee s'il n'existe pas encore.
      if (trimmedEmail === ADMIN_EMAIL && trimmedPassword === ADMIN_PASSWORD) {
        try {
          await signInWithEmailAndPassword(auth, trimmedEmail, trimmedPassword);
        } catch (authErr) {
          if (authErr.code === 'auth/user-not-found' || authErr.code === 'auth/invalid-credential') {
            try {
              await createUserWithEmailAndPassword(auth, trimmedEmail, trimmedPassword);
            } catch (createErr) {
              console.warn('Auto create in Auth:', createErr.message);
            }
          }
        }
      } else {
        // Cas B : authentification Firebase standard
        await signInWithEmailAndPassword(auth, trimmedEmail, trimmedPassword);
      }
    } catch (authErr) {
      let message = 'Email ou mot de passe incorrect.';
      if (authErr.code === 'auth/invalid-credential' || authErr.code === 'auth/wrong-password') {
        message = 'Mot de passe incorrect pour cet administrateur.';
      } else if (authErr.code === 'auth/user-not-found') {
        message = 'Aucun administrateur trouvé avec cette adresse e-mail.';
      } else if (authErr.code === 'auth/too-many-requests') {
        message = 'Trop de tentatives. Réessayez dans quelques minutes.';
      }
      setAuthError(message);
      throw new Error(message);
    } finally {
      setLoading(false);
    }
  };

  // 3. Connexion Démo : passe par une vraie session Firebase Auth.
  const loginAdminDemo = async () => {
    setLoading(true);
    setAuthError('');
    try {
      try {
        await signInWithEmailAndPassword(auth, ADMIN_EMAIL, ADMIN_PASSWORD);
      } catch (authErr) {
        if (authErr.code === 'auth/user-not-found' || authErr.code === 'auth/invalid-credential') {
          await createUserWithEmailAndPassword(auth, ADMIN_EMAIL, ADMIN_PASSWORD);
        } else {
          throw authErr;
        }
      }
    } catch (e) {
      const message = 'Connexion démo impossible : ' + (e?.message || e);
      setAuthError(message);
      throw new Error(message);
    } finally {
      setLoading(false);
    }
  };

  // 4. Deconnexion
  const logout = async () => {
    try {
      await firebaseSignOut(auth);
    } catch (e) {
      console.warn('Erreur déconnexion:', e);
    }
    clear();
    setAuthError('');
  };

  return (
    <AuthContext.Provider value={{
      currentUser,
      isAuthenticated,
      isAdmin: true,
      authReady,
      login,
      loginAdminDemo,
      logout,
      loading,
      authError,
      setAuthError
    }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  return context || defaultAuthState;
};
