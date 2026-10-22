import React, { useState } from 'react';
import { useAuth } from '../../context/AuthContext';
import { useTheme } from '../../context/ThemeContext';
import { 
  HeartPulse, 
  Lock, 
  Mail, 
  ShieldAlert, 
  ShieldCheck, 
  Smartphone,
  CheckCircle2,
  Users,
  Stethoscope,
  Pill,
  Building2,
  Sun,
  Moon,
  Eye,
  EyeOff
} from 'lucide-react';

export const LoginPage = () => {
  const { login, loginAdminDemo, loading, authError, setAuthError } = useAuth();
  const { isDarkMode, toggleTheme } = useTheme();
  
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [rememberMe, setRememberMe] = useState(true);
  const [localError, setLocalError] = useState('');
  const [infoToast, setInfoToast] = useState('');

  const triggerToast = (msg) => {
    setInfoToast(msg);
    setTimeout(() => setInfoToast(''), 3500);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLocalError('');
    if (setAuthError) setAuthError('');
    try {
      await login(email, password);
    } catch (err) {
      setLocalError(err.message || 'Échec de connexion administrateur');
    }
  };

  return (
    <div className="auth-split-wrapper">
      {/* Éléments décoratifs extérieurs (conformes à la maquette) */}
      <div className="auth-bg-blob-top"></div>
      <div className="auth-bg-ring-bottom"></div>
      <div className="auth-bg-dots-bottom"></div>

      {/* Bouton Flottant Mode Clair / Mode Sombre sur la page Login */}
      <button
        onClick={toggleTheme}
        title={isDarkMode ? 'Basculer en Mode Clair' : 'Basculer en Mode Sombre'}
        style={{
          position: 'fixed',
          top: '20px',
          right: '20px',
          background: 'var(--bg-surface)',
          border: '1px solid var(--border)',
          borderRadius: '12px',
          padding: '8px 14px',
          display: 'flex',
          alignItems: 'center',
          gap: '8px',
          fontSize: '12px',
          fontWeight: 800,
          color: 'var(--text-primary)',
          cursor: 'pointer',
          boxShadow: '0 4px 12px rgba(0,0,0,0.08)',
          zIndex: 100,
          transition: 'all 0.2s ease'
        }}
      >
        {isDarkMode ? <Sun size={15} color="#FFB300" /> : <Moon size={15} color="#14583D" />}
        <span>{isDarkMode ? 'Mode Clair' : 'Mode Sombre'}</span>
      </button>

      {/* Toast d'information flottant */}
      {infoToast && (
        <div style={{
          position: 'fixed',
          top: '24px',
          right: '24px',
          background: '#14583D',
          color: 'white',
          padding: '12px 20px',
          borderRadius: '12px',
          boxShadow: '0 10px 25px rgba(0,0,0,0.2)',
          zIndex: 100,
          fontSize: '12px',
          fontWeight: 700,
          display: 'flex',
          alignItems: 'center',
          gap: '8px'
        }}>
          <CheckCircle2 size={16} color="#FFB300" />
          <span>{infoToast}</span>
        </div>
      )}

      {/* CARTE CENTRALE SPLIT (Fidèle à la maquette) */}
      <div className="auth-split-card">
        
        {/* ============================================================== */}
        {/* VOLET GAUCHE (HERO / BRANDING / FORMES GÉOMÉTRIQUES MAQUETTE) */}
        {/* ============================================================== */}
        <div className="auth-hero-panel">
          {/* Forme blanche / croissant en haut à gauche */}
          <div style={{
            position: 'absolute',
            top: '-20px',
            left: '-20px',
            width: '90px',
            height: '90px',
            borderRadius: '50%',
            background: 'rgba(255, 255, 255, 0.22)',
            filter: 'blur(1px)',
            pointerEvents: 'none'
          }}></div>

          {/* Grille de points en haut à gauche (4x4) */}
          <div style={{
            position: 'absolute',
            top: '40px',
            left: '32px',
            width: '54px',
            height: '42px',
            background: 'radial-gradient(rgba(255, 255, 255, 0.5) 1.5px, transparent 1.5px)',
            backgroundSize: '11px 11px',
            pointerEvents: 'none'
          }}></div>

          {/* Barres verticales translucides / gélules flottantes (comme sur la maquette) */}
          <div style={{ position: 'absolute', top: '24px', left: '110px', display: 'flex', gap: '8px', pointerEvents: 'none' }}>
            <div style={{
              width: '18px',
              height: '70px',
              borderRadius: '12px',
              background: 'linear-gradient(180deg, rgba(255,255,255,0.28) 0%, rgba(255,255,255,0.06) 100%)',
              backdropFilter: 'blur(3px)'
            }}></div>
            <div style={{
              width: '18px',
              height: '110px',
              borderRadius: '12px',
              background: 'linear-gradient(180deg, rgba(255,255,255,0.2) 0%, rgba(255,255,255,0.03) 100%)'
            }}></div>
            <div style={{
              width: '18px',
              height: '60px',
              borderRadius: '12px',
              background: 'linear-gradient(180deg, rgba(255,255,255,0.25) 0%, rgba(255,255,255,0.05) 100%)'
            }}></div>
          </div>

          {/* Cercle orbital en haut à droite avec satellite */}
          <div style={{
            position: 'absolute',
            top: '32px',
            right: '48px',
            width: '32px',
            height: '32px',
            borderRadius: '50%',
            border: '2px solid rgba(255, 255, 255, 0.35)',
            pointerEvents: 'none'
          }}>
            <div style={{
              position: 'absolute',
              top: '-4px',
              right: '-16px',
              width: '7px',
              height: '7px',
              borderRadius: '50%',
              background: '#86efac'
            }}></div>
          </div>

          {/* En-tête supérieur gauche : Badge Admin */}
          <div style={{ position: 'relative', zIndex: 2, marginTop: '50px' }}>
            <div style={{
              display: 'inline-flex',
              alignItems: 'center',
              gap: '6px',
              background: 'rgba(255, 255, 255, 0.16)',
              padding: '5px 14px',
              borderRadius: '20px',
              fontSize: '11px',
              fontWeight: 800,
              letterSpacing: '0.04em'
            }}>
              <ShieldCheck size={13} color="#FFB300" />
              <span>GOUVERNANCE & SUPERVISION</span>
            </div>
          </div>

          {/* Contenu central : Grand Titre percutant (comme 'Advanture start here') */}
          <div style={{ position: 'relative', zIndex: 2, margin: '20px 0' }}>
            <h1 style={{
              fontSize: '38px',
              fontWeight: 900,
              lineHeight: 1.15,
              letterSpacing: '-0.03em',
              margin: '0 0 14px 0',
              textShadow: '0 2px 10px rgba(0,0,0,0.1)'
            }}>
              Supervision &<br />
              Gouvernance<br />
              Centrale.
            </h1>

            <p style={{
              fontSize: '14px',
              opacity: 0.9,
              fontWeight: 500,
              lineHeight: 1.5,
              maxWidth: '340px',
              margin: '0 0 20px 0'
            }}>
              Portail d'administration de la plateforme médicale nationale Allo Doctor.
            </p>

            {/* Carte d'information écosystème mobile préservée */}
            <div style={{
              background: 'rgba(255, 255, 255, 0.12)',
              backdropFilter: 'blur(8px)',
              border: '1px solid rgba(255, 255, 255, 0.2)',
              borderRadius: '16px',
              padding: '14px',
              maxWidth: '360px'
            }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px', fontSize: '12px', fontWeight: 800, marginBottom: '6px' }}>
                <Smartphone size={15} color="#86efac" />
                <span>Réseau Mobile Dédié</span>
              </div>
              <p style={{ fontSize: '11px', opacity: 0.9, lineHeight: 1.4, margin: '0 0 10px 0' }}>
                Les <strong>médecins, patients, cliniques et pharmacies</strong> opèrent exclusivement sur l'application mobile.
              </p>

              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '4px', textAlign: 'center' }}>
                <div style={{ background: 'rgba(255, 255, 255, 0.15)', padding: '5px 2px', borderRadius: '6px' }}>
                  <Users size={12} color="#ffffff" style={{ margin: '0 auto 2px' }} />
                  <div style={{ fontSize: '9px', fontWeight: 700 }}>Patients</div>
                </div>
                <div style={{ background: 'rgba(255, 255, 255, 0.15)', padding: '5px 2px', borderRadius: '6px' }}>
                  <Stethoscope size={12} color="#ffffff" style={{ margin: '0 auto 2px' }} />
                  <div style={{ fontSize: '9px', fontWeight: 700 }}>Médecins</div>
                </div>
                <div style={{ background: 'rgba(255, 255, 255, 0.15)', padding: '5px 2px', borderRadius: '6px' }}>
                  <Pill size={12} color="#ffffff" style={{ margin: '0 auto 2px' }} />
                  <div style={{ fontSize: '9px', fontWeight: 700 }}>Pharmas</div>
                </div>
                <div style={{ background: 'rgba(255, 255, 255, 0.15)', padding: '5px 2px', borderRadius: '6px' }}>
                  <Building2 size={12} color="#ffffff" style={{ margin: '0 auto 2px' }} />
                  <div style={{ fontSize: '9px', fontWeight: 700 }}>Cliniques</div>
                </div>
              </div>
            </div>
          </div>

          {/* Décorations du bas : Sphère brillante, arcs concentriques et croix */}
          <div style={{ position: 'relative', height: '60px', zIndex: 2 }}>
            {/* Sphère cyan / verte 3D en bas à gauche */}
            <div style={{
              position: 'absolute',
              bottom: '10px',
              left: '0px',
              width: '26px',
              height: '26px',
              borderRadius: '50%',
              background: 'radial-gradient(circle at 35% 35%, #86efac 0%, #22c55e 50%, #15803d 100%)',
              boxShadow: '0 6px 14px rgba(0, 0, 0, 0.25)'
            }}></div>

            {/* Petite grille de points sous la sphère */}
            <div style={{
              position: 'absolute',
              bottom: '-12px',
              left: '-2px',
              width: '36px',
              height: '24px',
              background: 'radial-gradient(rgba(255, 255, 255, 0.4) 1.5px, transparent 1.5px)',
              backgroundSize: '9px 9px',
              pointerEvents: 'none'
            }}></div>

            {/* Petite croix décorative (×) */}
            <div style={{
              position: 'absolute',
              bottom: '8px',
              left: '110px',
              fontSize: '16px',
              fontWeight: 900,
              opacity: 0.6,
              transform: 'rotate(45deg)'
            }}>
              +
            </div>

            {/* Grands arcs concentriques en bas à droite (comme sur la maquette) */}
            <div style={{
              position: 'absolute',
              bottom: '-80px',
              right: '-60px',
              width: '230px',
              height: '230px',
              borderRadius: '50%',
              border: '6px solid rgba(255, 255, 255, 0.75)',
              pointerEvents: 'none'
            }}>
              {/* Arc intérieur */}
              <div style={{
                position: 'absolute',
                top: '20px',
                left: '20px',
                width: '180px',
                height: '180px',
                borderRadius: '50%',
                border: '4px solid rgba(255, 255, 255, 0.35)'
              }}>
                {/* Demi-disque lumineux central */}
                <div style={{
                  position: 'absolute',
                  top: '25px',
                  left: '25px',
                  width: '120px',
                  height: '120px',
                  borderRadius: '50%',
                  background: 'linear-gradient(135deg, #4ade80 0%, #14583D 100%)',
                  boxShadow: '0 0 25px rgba(74, 222, 128, 0.5)'
                }}></div>
              </div>

              {/* Petite planète sur l'orbite */}
              <div style={{
                position: 'absolute',
                top: '22px',
                left: '6px',
                width: '22px',
                height: '22px',
                borderRadius: '50%',
                background: 'radial-gradient(circle at 35% 35%, #86efac 0%, #22c55e 100%)',
                boxShadow: '0 4px 10px rgba(0,0,0,0.2)'
              }}></div>
            </div>
          </div>
        </div>

        {/* ============================================================== */}
        {/* VOLET DROIT (FORMULAIRE DE CONNEXION IDENTIQUE À LA MAQUETTE) */}
        {/* ============================================================== */}
        <div className="auth-form-panel">
          {/* Logo élevé dans un carré blanc arrondi avec ombre (exactement comme le 'd' bleu de la maquette) */}
          <div style={{
            width: '68px',
            height: '68px',
            borderRadius: '20px',
            background: '#FFFFFF',
            boxShadow: '0 12px 28px rgba(20, 88, 61, 0.12), 0 2px 6px rgba(0,0,0,0.04)',
            border: '1px solid #E5E7EB',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            margin: '0 auto 16px',
            color: '#14583D'
          }}>
            <HeartPulse size={36} color="#14583D" strokeWidth={2.5} />
          </div>

          {/* Titre centré */}
          <div style={{ textAlign: 'center', marginBottom: '24px' }}>
            <h2 style={{
              fontSize: '24px',
              fontWeight: 850,
              color: '#1A1C1B',
              letterSpacing: '-0.02em',
              margin: '0 0 6px 0'
            }}>
              Connexion Administrateur
            </h2>
            <p style={{ fontSize: '13px', color: '#56605B', margin: 0, fontWeight: 500 }}>
              Console de Gestion Centrale • Allo Doctor
            </p>
          </div>

          {/* Alerte Erreur si présente */}
          {(localError || authError) && (
            <div style={{
              background: '#fbebeb',
              color: '#BE3232',
              padding: '10px 14px',
              borderRadius: '10px',
              fontSize: '12px',
              fontWeight: 600,
              marginBottom: '16px',
              display: 'flex',
              alignItems: 'flex-start',
              gap: '8px',
              border: '1px solid #BE323230'
            }}>
              <ShieldAlert size={16} style={{ flexShrink: 0, marginTop: '2px' }} />
              <div>{localError || authError}</div>
            </div>
          )}

          {/* Formulaire officiel */}
          <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
            {/* Champ Email */}
            <div>
              <label style={{ fontSize: '12px', fontWeight: 700, color: '#1A1C1B', display: 'block', marginBottom: '6px' }}>
                Adresse e-mail officielle
              </label>
              <div style={{ position: 'relative' }}>
                <input
                  type="email"
                  id="admin-email-field"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="admin@allodoctor.ma"
                  required
                  style={{
                    width: '100%',
                    padding: '11px 14px 11px 40px',
                    borderRadius: '8px',
                    border: '1px solid #E5E7EB',
                    background: '#F8F9FA',
                    fontSize: '13px',
                    color: '#1A1C1B',
                    boxSizing: 'border-box',
                    outline: 'none',
                    transition: 'all 0.2s ease'
                  }}
                  onFocus={(e) => {
                    e.target.style.borderColor = '#14583D';
                    e.target.style.background = '#FFFFFF';
                  }}
                  onBlur={(e) => {
                    e.target.style.borderColor = '#E5E7EB';
                    e.target.style.background = '#F8F9FA';
                  }}
                />
                <Mail size={16} color="#9CA3AF" style={{ position: 'absolute', left: '13px', top: '50%', transform: 'translateY(-50%)', pointerEvents: 'none' }} />
              </div>
            </div>

            {/* Champ Mot de Passe avec bouton pour afficher/masquer */}
            <div>
              <label style={{ fontSize: '12px', fontWeight: 700, color: '#1A1C1B', display: 'block', marginBottom: '6px' }}>
                Mot de passe
              </label>
              <div style={{ position: 'relative', display: 'flex', alignItems: 'center' }}>
                <input
                  type={showPassword ? 'text' : 'password'}
                  id="admin-password-field"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="Saisissez votre mot de passe"
                  required
                  style={{
                    width: '100%',
                    padding: '11px 42px 11px 40px',
                    borderRadius: '8px',
                    border: '1px solid #E5E7EB',
                    background: '#F8F9FA',
                    fontSize: '13px',
                    color: '#1A1C1B',
                    boxSizing: 'border-box',
                    outline: 'none',
                    transition: 'all 0.2s ease'
                  }}
                  onFocus={(e) => {
                    e.target.style.borderColor = '#14583D';
                    e.target.style.background = '#FFFFFF';
                  }}
                  onBlur={(e) => {
                    e.target.style.borderColor = '#E5E7EB';
                    e.target.style.background = '#F8F9FA';
                  }}
                />
                <Lock size={16} color="#9CA3AF" style={{ position: 'absolute', left: '13px', top: '50%', transform: 'translateY(-50%)', pointerEvents: 'none' }} />
                
                {/* Bouton pour voir / masquer le mot de passe */}
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  title={showPassword ? 'Masquer le mot de passe' : 'Afficher le mot de passe'}
                  aria-label={showPassword ? 'Masquer le mot de passe' : 'Afficher le mot de passe'}
                  style={{
                    position: 'absolute',
                    right: '10px',
                    top: '50%',
                    transform: 'translateY(-50%)',
                    background: 'transparent',
                    border: 'none',
                    cursor: 'pointer',
                    color: '#56605B',
                    padding: '4px',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    borderRadius: '4px'
                  }}
                >
                  {showPassword ? <EyeOff size={16} color="#14583D" /> : <Eye size={16} color="#9CA3AF" />}
                </button>
              </div>
            </div>

            {/* Ligne : Se souvenir de moi + Mot de passe oublié ? */}
            <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', fontSize: '12px', marginTop: '2px' }}>
              <label style={{ display: 'flex', alignItems: 'center', gap: '6px', cursor: 'pointer', color: '#56605B' }}>
                <input 
                  type="checkbox" 
                  checked={rememberMe} 
                  onChange={(e) => setRememberMe(e.target.checked)}
                  style={{ accentColor: '#14583D', cursor: 'pointer', width: '14px', height: '14px' }}
                />
                <span>Se souvenir de moi</span>
              </label>

              <button
                type="button"
                onClick={() => triggerToast('Lien de réinitialisation sécurisé envoyé à la direction technique.')}
                style={{
                  background: 'transparent',
                  border: 'none',
                  color: '#14583D',
                  fontWeight: 700,
                  fontSize: '12px',
                  cursor: 'pointer',
                  padding: 0
                }}
              >
                Mot de passe oublié ?
              </button>
            </div>

            {/* Bouton Principal : Se connecter */}
            <button
              type="submit"
              id="btn-admin-login-submit"
              disabled={loading}
              style={{
                width: '100%',
                padding: '12px',
                borderRadius: '8px',
                background: '#14583D',
                color: 'white',
                border: 'none',
                fontWeight: 800,
                fontSize: '13px',
                cursor: 'pointer',
                boxShadow: '0 4px 12px rgba(20, 88, 61, 0.25)',
                transition: 'all 0.15s ease',
                marginTop: '6px'
              }}
              onMouseEnter={(e) => e.target.style.background = '#0e402c'}
              onMouseLeave={(e) => e.target.style.background = '#14583D'}
            >
              {loading ? 'Connexion en cours...' : 'Se connecter au portail'}
            </button>
          </form>

          {/* Pied du formulaire en français sécurisé */}
          <div style={{
            marginTop: '24px',
            paddingTop: '16px',
            borderTop: '1px solid #E5E7EB',
            textAlign: 'center',
            fontSize: '11px',
            color: '#56605B',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            gap: '6px'
          }}>
            <ShieldCheck size={14} color="#14583D" />
            <span>Accès sécurisé • Réservé aux administrateurs autorisés</span>
          </div>
        </div>
      </div>
    </div>
  );
};
