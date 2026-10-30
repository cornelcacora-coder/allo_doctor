import React, { useState } from 'react';
import { AuthProvider, useAuth } from './context/AuthContext';
import { ThemeProvider } from './context/ThemeContext';
import { LoginPage } from './pages/auth/LoginPage';
import { Navbar } from './components/Navbar';
import { Sidebar } from './components/Sidebar';
import { AdminView } from './pages/admin/AdminView';
import { ErrorBoundary } from './components/ErrorBoundary';

const MainAppContent = () => {
  const { isAuthenticated, authReady } = useAuth();

  // Navigation active de la console administrateur
  const [activeTab, setActiveTab] = useState('admin_home');

  // Attendre que Firebase ait vérifié la session avant d'afficher quoi que ce soit.
  // Sans ce garde, on voit un "flash" : login page → dashboard lors d'un rechargement.
  if (!authReady) {
    return (
      <div style={{
        minHeight: '100vh',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        background: '#F2F5F4',
        flexDirection: 'column',
        gap: '16px'
      }}>
        <div style={{
          width: 48,
          height: 48,
          borderRadius: '50%',
          border: '4px solid #E5E7EB',
          borderTop: '4px solid #14583D',
          animation: 'spin 0.8s linear infinite'
        }} />
        <style>{`@keyframes spin { to { transform: rotate(360deg); } }`}</style>
        <span style={{ fontSize: '13px', color: '#56605B', fontWeight: 600 }}>
          Vérification de la session...
        </span>
      </div>
    );
  }

  // Firebase a répondu → décision d'affichage
  if (!isAuthenticated) {
    return <LoginPage />;
  }

  return (
    <div className="app-layout">
      {/* Barre latérale officielle de la Console Administrateur */}
      <Sidebar activeTab={activeTab} setActiveTab={setActiveTab} />

      {/* Contenu principal de supervision */}
      <div className="main-wrapper">
        <Navbar />

        <main className="content-area">
          {/* Console d'Administration Allo Doctor (5.5.1 à 5.5.4) */}
          <AdminView subTab={activeTab} setSubTab={setActiveTab} />
        </main>
      </div>
    </div>
  );
};

export default function App() {
  return (
    <ErrorBoundary>
      <ThemeProvider>
        <AuthProvider>
          <MainAppContent />
        </AuthProvider>
      </ThemeProvider>
    </ErrorBoundary>
  );
}
