import React from 'react';
import { useAuth } from '../context/AuthContext';
import { useTheme } from '../context/ThemeContext';
import { 
  Search, 
  ShieldCheck, 
  Sun,
  Moon
} from 'lucide-react';


export const Navbar = () => {
  const { currentUser } = useAuth();
  const { isDarkMode, toggleTheme } = useTheme();

  return (
    <header className="topbar">
      <div className="topbar-left" style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
        {/* Badge d'accréditation Administrateur */}
        <div style={{
          display: 'inline-flex',
          alignItems: 'center',
          gap: '8px',
          background: '#e8efe8',
          color: '#14583D',
          padding: '6px 14px',
          borderRadius: '20px',
          fontSize: '12px',
          fontWeight: 800,
          border: '1px solid #14583D30'
        }}>
          <ShieldCheck size={16} color="#14583D" />
          <span>PORTAIL ADMINISTRATEUR ALLO DOCTOR</span>
        </div>

        {/* Barre de recherche globale administrative */}
        <div style={{ 
          display: 'flex', 
          alignItems: 'center', 
          background: '#F2F5F4', 
          borderRadius: '10px', 
          padding: '7px 14px', 
          gap: '8px',
          width: '340px'
        }}>
          <Search size={15} color="#9CA3AF" />
          <input 
            type="text" 
            placeholder="Rechercher médecin, pharmacie, clinique, ticket..." 
            style={{ border: 'none', background: 'transparent', outline: 'none', width: '100%', fontSize: '12px' }}
          />
        </div>
      </div>

      <div className="topbar-right" style={{ display: 'flex', alignItems: 'center', gap: '14px' }}>
        {/* Basculeur Mode Clair / Mode Sombre (Icône seule) */}
        <button
          onClick={toggleTheme}
          title={isDarkMode ? 'Basculer en Mode Clair' : 'Basculer en Mode Sombre'}
          id="theme-toggle-btn"
          aria-label={isDarkMode ? 'Mode Clair' : 'Mode Sombre'}
          style={{
            width: 38,
            height: 38,
            borderRadius: '10px',
            border: '1px solid var(--border)',
            background: 'var(--bg-subtle)',
            color: 'var(--text-primary)',
            cursor: 'pointer',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            transition: 'all 0.2s ease',
            flexShrink: 0
          }}
        >
          {isDarkMode ? <Sun size={18} color="#FFB300" /> : <Moon size={18} color="#14583D" />}
        </button>

        {/* Profil Super Administrateur */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px', paddingLeft: '8px' }}>
          <img 
            src={currentUser?.photo_url || 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&auto=format&fit=crop&q=80'} 
            alt="Profil Admin" 
            style={{ width: 36, height: 36, borderRadius: '50%', objectFit: 'cover', border: '2px solid #14583D' }}
          />
          <div style={{ lineHeight: 1.2 }}>
            <div style={{ fontSize: '13px', fontWeight: 800, color: '#1A1C1B' }}>
              {currentUser?.display_name || 'Superviseur Général'}
            </div>
            <div style={{ fontSize: '10px', color: '#14583D', fontWeight: 700 }}>
              Administrateur Plateforme
            </div>
          </div>
        </div>
      </div>
    </header>
  );
};
