import React, { useState } from 'react';
import { AuthProvider, useAuth } from './context/AuthContext';
import { ThemeProvider } from './context/ThemeContext';
import { LoginPage } from './pages/auth/LoginPage';
import { Navbar } from './components/Navbar';
import { Sidebar } from './components/Sidebar';
import { AdminView } from './pages/admin/AdminView';
import { ErrorBoundary } from './components/ErrorBoundary';

const MainAppContent = () => {
  const { isAuthenticated } = useAuth();
  
  // Navigation active de la console administrateur
  const [activeTab, setActiveTab] = useState('admin_home');

  // Si l'administrateur n'est pas encore connecté, afficher la page de connexion admin
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
