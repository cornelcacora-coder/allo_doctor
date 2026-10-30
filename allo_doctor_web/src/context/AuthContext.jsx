import React, { createContext, useContext, useState, useEffect, useRef } from 'react';
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

// Durée de session : 30 minutes en millisecondes
const SESSION_DURATION_MS = 30 * 60 * 1000;

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

/**
 * Vérifie si la session locale est présente ET non expirée.
 * Retourne true si valide, false si absente/expirée.
 */
const isLocalSessionValid = () => {
  try {
    const saved = localStorage.getItem(SESSION_KEY);
    if (!saved) return false;
    const parsed = JSON.parse(saved);
    // Ancienne session sans expiresAt → expirée
    if (!parsed?.expiresAt) {
      localStorage.removeItem(SESSION_KEY);
      return false;
    }
    // Session expirée
    if (Date.now() > parsed.expiresAt) {
      localStorage.removeItem(SESSION_KEY);
      return false;
    }
    return true;
  } catch {
    localStorage.removeItem(SESSION_KEY);
    return false;
  }
};

export const AuthProvider = ({ children }) => {
  const [currentUser, setCurrentUser] = useState(null);
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [authReady, setAuthReady] = useState(false);
  const [loading, setLoading] = useState(false);
  const [authError, setAuthError] = useState('');

  // Indique si une connexion est en cours (pour ne pas rejeter la session pendant login)
  const isLoggingInRef = useRef(false);
  // Timer pour déconnexion automatique après 30 min
  const sessionTimerRef = useRef(null);

  /**
   * Sauvegarde la session avec une expiration à 30 min depuis maintenant.
   */
  const persist = (user) => {
    const userWithExpiry = {
      ...user,
      expiresAt: Date.now() + SESSION_DURATION_MS,
    };
    setCurrentUser(userWithExpiry);
    setIsAuthenticated(true);
    localStorage.setItem(SESSION_KEY, JSON.stringify(userWithExpiry));

    // Réinitialiser le timer de déconnexion automatique
    if (sessionTimerRef.current) clearTimeout(sessionTimerRef.current);
    sessionTimerRef.current = setTimeout(() => {
      console.info('Session expirée (30 min). Déconnexion automatique.');
      clear();
      firebaseSignOut(auth).catch(() => {});
    }, SESSION_DURATION_MS);
  };

  const clear = () => {
    setCurrentUser(null);
    setIsAuthenticated(false);
    localStorage.removeItem(SESSION_KEY);
    if (sessionTimerRef.current) {
      clearTimeout(sessionTimerRef.current);
      sessionTimerRef.current = null;
    }
  };

  // Nettoyer le timer au démontage du composant
  useEffect(() => {
    return () => {
      if (sessionTimerRef.current) clearTimeout(sessionTimerRef.current);
    };
  }, []);

  // 1. Écoute l'état Firebase Auth
  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (firebaseUser) => {
      setAuthReady(true);

      if (!firebaseUser) {
        clear();
        return;
      }

      // Si une connexion est en cours (login() vient d'être appelé),
      // on laisse persist() être appelé ci-dessous normalement.
      // Si c'est un RECHARGEMENT de page, on vérifie que la session locale est encore valide.
      if (!isLoggingInRef.current && !isLocalSessionValid()) {
        // Session locale expirée ou absente → déconnecter Firebase
        await firebaseSignOut(auth);
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

      // Fin de la phase de connexion
      isLoggingInRef.current = false;
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
      // Marquer qu'une connexion est en cours AVANT d'appeler Firebase
      isLoggingInRef.current = true;

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
          } else {
            isLoggingInRef.current = false;
            throw authErr;
          }
        }
      } else {
        await signInWithEmailAndPassword(auth, trimmedEmail, trimmedPassword);
      }
    } catch (authErr) {
      isLoggingInRef.current = false;
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

  // 3. Connexion Démo
  const loginAdminDemo = async () => {
    setLoading(true);
    setAuthError('');
    try {
      isLoggingInRef.current = true;
      try {
        await signInWithEmailAndPassword(auth, ADMIN_EMAIL, ADMIN_PASSWORD);
      } catch (authErr) {
        if (authErr.code === 'auth/user-not-found' || authErr.code === 'auth/invalid-credential') {
          await createUserWithEmailAndPassword(auth, ADMIN_EMAIL, ADMIN_PASSWORD);
        } else {
          isLoggingInRef.current = false;
          throw authErr;
        }
      }
    } catch (e) {
      isLoggingInRef.current = false;
      const message = 'Connexion démo impossible : ' + (e?.message || e);
      setAuthError(message);
      throw new Error(message);
    } finally {
      setLoading(false);
    }
  };

  // 4. Déconnexion
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
