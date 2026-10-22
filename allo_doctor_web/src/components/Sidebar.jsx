import React from 'react';
import { useAuth } from '../context/AuthContext';
import { 
  HeartPulse, 
  Activity, 
  FileCheck, 
  ShieldAlert, 
  DollarSign, 
  Users, 
  LogOut,
  ShieldCheck,
  CheckCircle2
} from 'lucide-react';

export const Sidebar = ({ activeTab, setActiveTab }) => {
  const { currentUser, logout } = useAuth();

  // Navigation exclusive au Parcours Administrateur
  const navItems = [
    { key: 'admin_home', label: 'Tableau de Bord', icon: Activity, badge: null },
    { key: 'admin_verification', label: 'Agrément & Validations', icon: FileCheck, badge: null },
    { key: 'admin_support', label: 'Support & Litiges', icon: ShieldAlert, badge: null },
    { key: 'admin_stats', label: 'Finances & Commissions', icon: DollarSign, badge: null },
    { key: 'admin_users', label: 'Gestion des Utilisateurs', icon: Users, badge: null },
  ];

  return (
    <aside className="sidebar">
      {/* Brand Header */}
      <div className="sidebar-header">
        <div className="sidebar-logo-icon">
          <HeartPulse size={26} />
        </div>
        <div className="sidebar-brand">
          <h1>Allo Doctor</h1>
          <p>Console Administrateur</p>
        </div>
      </div>

      {/* Navigation principale */}
      <nav className="sidebar-nav">
        <div className="nav-section-title" style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
          <ShieldCheck size={14} color="#14583D" />
          <span>SUPERVISION & GOUVERNANCE</span>
        </div>

        {navItems.map((item) => {
          const Icon = item.icon;
          const isActive = activeTab === item.key;
          return (
            <button
              key={item.key}
              id={`nav-item-${item.key}`}
              className={`nav-item ${isActive ? 'active' : ''}`}
              onClick={() => setActiveTab(item.key)}
              style={{
                width: '100%',
                border: 'none',
                background: isActive ? 'var(--primary-light)' : 'transparent',
                textAlign: 'left',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'space-between',
                padding: '10px 14px',
                borderRadius: '10px',
                cursor: 'pointer',
                marginBottom: '4px',
                transition: 'all 0.15s ease'
              }}
            >
              <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                <Icon size={18} color={isActive ? 'var(--primary)' : '#56605B'} />
                <span style={{ 
                  fontSize: '12px', 
                  fontWeight: isActive ? 800 : 600,
                  color: isActive ? 'var(--primary)' : '#1A1C1B'
                }}>
                  {item.label}
                </span>
              </div>

              {item.badge && (
                <span style={{
                  fontSize: '10px',
                  fontWeight: 900,
                  padding: '2px 6px',
                  borderRadius: '10px',
                  background: item.key === 'admin_support' ? '#fbebeb' : '#fff8e1',
                  color: item.key === 'admin_support' ? '#BE3232' : '#d97706'
                }}>
                  {item.badge}
                </span>
              )}
            </button>
          );
        })}

        {/* Note sur le réseau mobile */}
        <div style={{
          marginTop: 'auto',
          background: '#F8F9FA',
          borderRadius: '12px',
          padding: '12px',
          border: '1px solid #E5E7EB',
          fontSize: '11px',
          color: '#56605B',
          lineHeight: 1.4
        }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '6px', fontWeight: 800, color: '#14583D', marginBottom: '4px' }}>
            <CheckCircle2 size={14} color="#14583D" />
            <span>Réseau Mobile Actif</span>
          </div>
          Les médecins, cliniques, pharmacies et patients sont connectés via l'application mobile Flutter.
        </div>
      </nav>

      {/* Sidebar Footer */}
      <div className="sidebar-footer">
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <div style={{ 
              width: 8, 
              height: 8, 
              borderRadius: '50%', 
              background: '#22c55e',
              boxShadow: '0 0 6px #22c55e'
            }}></div>
            <div>
              <div style={{ fontSize: '11px', fontWeight: 800, color: '#1A1C1B' }}>
                {currentUser?.display_name || 'Super Administrateur'}
              </div>
              <div style={{ fontSize: '10px', color: '#56605B' }}>
                Accès Super-Admin Total
              </div>
            </div>
          </div>

          <button 
            onClick={logout}
            title="Se déconnecter de la console"
            id="sidebar-logout-btn"
            style={{ 
              background: '#fbebeb', 
              border: 'none', 
              borderRadius: '8px',
              padding: '6px',
              cursor: 'pointer', 
              color: '#BE3232',
              display: 'flex',
              alignItems: 'center'
            }}
          >
            <LogOut size={16} />
          </button>
        </div>
      </div>
    </aside>
  );
};
