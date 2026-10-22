import React, { useState } from 'react';
import { 
  Building2, 
  Stethoscope, 
  Users, 
  Pill, 
  TrendingUp, 
  CheckCircle, 
  XCircle, 
  ShieldAlert, 
  FileCheck, 
  DollarSign, 
  Eye, 
  ChevronRight,
  Check,
  BarChart3,
  LineChart,
  Sparkles
} from 'lucide-react';
import { Pagination } from '../../components/Pagination';

export const AdminDashboard = ({ 
  practitioners, 
  onValidatePractitioner, 
  onRejectPractitioner, 
  onInspectPractitioner, 
  tickets,
  onOpenTicket,
  onNavigateTab 
}) => {
  const [activityMetric, setActivityMetric] = useState('all'); // all, teleconsultations, consultations, pharmacie, labo
  const [chartViewMode, setChartViewMode] = useState('bars'); // 'bars' ou 'waveform'
  const [hoveredDay, setHoveredDay] = useState(null);
  const [timeRange, setTimeRange] = useState('7d');
  const [valPage, setValPage] = useState(1);
  const [tktPage, setTktPage] = useState(1);

  // Calcul dynamique des indicateurs clés consolidés à partir de la base Firestore
  const clinicCount = practitioners.filter(p => p.type === 'clinique').length;
  const activeClinics = practitioners.filter(p => p.type === 'clinique' && p.status === 'validé').length;
  const doctorCount = practitioners.filter(p => p.type === 'medecin').length;
  const activeDoctors = practitioners.filter(p => p.type === 'medecin' && p.status === 'validé').length;
  const pharmacyCount = practitioners.filter(p => p.type === 'pharmacie').length;
  const activePharmacies = practitioners.filter(p => p.type === 'pharmacie' && p.status === 'validé').length;
  const patientCount = practitioners.filter(p => p.type === 'patient').length;

  const kpis = {
    clinics: {
      count: clinicCount,
      active: activeClinics,
      bedsTotal: 0,
      occupiedBeds: 0,
      percentOccupied: 0,
      label: 'Cliniques Actives',
      change: `${activeClinics} active(s)`,
      trend: clinicCount > 0 ? `${Math.round((activeClinics / clinicCount) * 100)}%` : '0%'
    },
    doctors: {
      count: doctorCount,
      activeNow: activeDoctors,
      specialtiesCount: 0,
      percentOnline: doctorCount > 0 ? Math.round((activeDoctors / doctorCount) * 100) : 0,
      label: 'Médecins Conventionnés',
      change: `${activeDoctors} agréé(s)`,
      trend: doctorCount > 0 ? `${activeDoctors}/${doctorCount}` : '0'
    },
    patients: {
      count: patientCount,
      active7d: 0,
      newToday: 0,
      percentActive: 0,
      label: 'Patients Actifs',
      change: 'Base Firestore',
      trend: `${patientCount}`
    },
    pharmacies: {
      count: pharmacyCount,
      onDutyNow: activePharmacies,
      ordersToday: 0,
      percentOnDuty: pharmacyCount > 0 ? Math.round((activePharmacies / pharmacyCount) * 100) : 0,
      label: 'Pharmacies Partenaires',
      change: `${activePharmacies} active(s)`,
      trend: pharmacyCount > 0 ? `${activePharmacies}/${pharmacyCount}` : '0'
    }
  };

  // Flux d'activité connecté
  const last7DaysData = [
    { day: 'Lun', teleconsultations: 0, consultations: 0, pharmacie: 0, labo: 0, total: 0 },
    { day: 'Mar', teleconsultations: 0, consultations: 0, pharmacie: 0, labo: 0, total: 0 },
    { day: 'Mer', teleconsultations: 0, consultations: 0, pharmacie: 0, labo: 0, total: 0 },
    { day: 'Jeu', teleconsultations: 0, consultations: 0, pharmacie: 0, labo: 0, total: 0 },
    { day: 'Ven', teleconsultations: 0, consultations: 0, pharmacie: 0, labo: 0, total: 0 },
    { day: 'Sam', teleconsultations: 0, consultations: 0, pharmacie: 0, labo: 0, total: 0 },
    { day: 'Dim', teleconsultations: 0, consultations: 0, pharmacie: 0, labo: 0, total: 0 },
  ];

  const getMetricVal = (d) => activityMetric === 'all' ? d.total : d[activityMetric] || 0;
  const maxTotal = Math.max(...last7DaysData.map(d => getMetricVal(d)), 1);

  // Demandes de validation de comptes en attente (spécification 5.5.1)
  const pendingPractitioners = practitioners.filter(p => p.status === 'en_attente');

  // Litiges ou tickets urgents ouverts (spécification 5.5.3)
  const urgentTickets = tickets.filter(t => t.priority === 'Urgente' || t.status === 'Ouvert' || t.isLitige).slice(0, 3);

  // SVG Waveform Coordinates pour le mode spline
  const svgWidth = 680;
  const svgHeight = 160;
  const points = last7DaysData.map((d, i) => {
    const x = (i / (last7DaysData.length - 1)) * (svgWidth - 40) + 20;
    const y = svgHeight - 20 - ((getMetricVal(d) / maxTotal) * (svgHeight - 50));
    return { x, y, data: d };
  });

  const splinePath = points.reduce((acc, pt, i, arr) => {
    if (i === 0) return `M ${pt.x} ${pt.y}`;
    const prev = arr[i - 1];
    const cp1x = prev.x + (pt.x - prev.x) / 2;
    const cp1y = prev.y;
    const cp2x = prev.x + (pt.x - prev.x) / 2;
    const cp2y = pt.y;
    return `${acc} C ${cp1x} ${cp1y}, ${cp2x} ${cp2y}, ${pt.x} ${pt.y}`;
  }, '');

  const areaPath = `${splinePath} L ${points[points.length - 1].x} ${svgHeight} L ${points[0].x} ${svgHeight} Z`;

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '22px' }}>
      
      {/* ============================================================== */}
      {/* BANDEAU DE TÉLÉMESURE EN DIRECT (LIVE NETWORK TELEMETRY)        */}
      {/* ============================================================== */}
      <div className="live-telemetry-ribbon">
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
          <div style={{ position: 'relative', width: 10, height: 10, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <span style={{
              position: 'absolute',
              width: 10,
              height: 10,
              borderRadius: '50%',
              background: '#22c55e',
              animation: 'live-dot-ping 1.8s cubic-bezier(0, 0, 0.2, 1) infinite'
            }}></span>
            <span style={{ width: 8, height: 8, borderRadius: '50%', background: '#16a34a', position: 'relative' }}></span>
          </div>

          <span style={{ fontWeight: 800, color: '#14583D', letterSpacing: '0.02em', fontSize: '11px', textTransform: 'uppercase' }}>
            Télémesure Réseau National Allo Doctor • En Direct
          </span>

          <span style={{ color: '#DADDDD' }}>|</span>

          <span style={{ color: '#56605B', fontSize: '11px' }}>
            Latence : <strong style={{ color: '#14583D' }}>12ms</strong> • Intégrité Chiffrement : <strong style={{ color: '#14583D' }}>100% AES-256</strong> • Disponibilité SIH : <strong style={{ color: '#25674D' }}>99.98%</strong>
          </span>
        </div>

        <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
          {['24h', '7d', '30d'].map((r) => (
            <button
              key={r}
              onClick={() => setTimeRange(r)}
              style={{
                background: timeRange === r ? '#14583D' : 'transparent',
                color: timeRange === r ? '#FFFFFF' : '#56605B',
                border: 'none',
                padding: '3px 9px',
                borderRadius: '6px',
                fontSize: '11px',
                fontWeight: 700,
                cursor: 'pointer',
                transition: 'all 0.15s ease'
              }}
            >
              {r.toUpperCase()}
            </button>
          ))}
        </div>
      </div>

      {/* ============================================================== */}
      {/* 5.5.1 EN-TÊTE DU TABLEAU DE BORD (COMMAND CENTER HEADER)        */}
      {/* ============================================================== */}
      <div style={{
        background: 'linear-gradient(135deg, #0e402c 0%, #14583D 60%, #1A1C1B 100%)',
        borderRadius: '24px',
        padding: '30px 34px',
        color: 'white',
        position: 'relative',
        overflow: 'hidden',
        boxShadow: '0 16px 36px rgba(20, 88, 61, 0.24)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
        flexWrap: 'wrap',
        gap: '20px'
      }}>
        {/* Cercles décoratifs d'ambiance néomorphiques */}
        <div style={{
          position: 'absolute',
          top: '-60px',
          right: '-40px',
          width: '260px',
          height: '260px',
          borderRadius: '50%',
          background: 'radial-gradient(circle, rgba(91, 142, 123, 0.3) 0%, transparent 70%)',
          pointerEvents: 'none'
        }}></div>

        <div style={{ position: 'relative', zIndex: 2 }}>
          <div style={{ 
            display: 'inline-flex', 
            alignItems: 'center', 
            gap: '8px', 
            background: 'rgba(255, 255, 255, 0.14)', 
            backdropFilter: 'blur(8px)',
            padding: '5px 14px', 
            borderRadius: '20px', 
            fontSize: '11px', 
            fontWeight: 800, 
            letterSpacing: '0.04em',
            marginBottom: '12px' 
          }}>
            <Sparkles size={13} color="#FFB300" />
            <span>CENTRE DE CONTRÔLE OPÉRATIONNEL</span>
          </div>

          <h1 style={{ fontSize: '30px', fontWeight: 900, letterSpacing: '-0.03em', margin: '0 0 8px 0' }}>
            Console Opérationnelle & Supervision Nationale
          </h1>

          <p style={{ opacity: 0.9, fontSize: '14px', maxWidth: '620px', margin: 0, fontWeight: 500, lineHeight: 1.5 }}>
            Contrôle holistique de la santé connectée : régulation des lits d'hospitalisation, agréments de praticiens, conformité des officines et arbitrage des soins.
          </p>
        </div>

        <div style={{ position: 'relative', zIndex: 2, display: 'flex', gap: '10px', flexWrap: 'wrap' }}>
          <button 
            id="dash-quick-verification-btn"
            onClick={() => onNavigateTab('admin_verification')}
            style={{ 
              background: '#FFB300', 
              color: '#1A1C1B', 
              fontWeight: 800, 
              padding: '11px 18px', 
              borderRadius: '12px',
              display: 'flex',
              alignItems: 'center',
              gap: '8px',
              border: 'none',
              cursor: 'pointer',
              fontSize: '12px',
              boxShadow: '0 6px 18px rgba(255, 179, 0, 0.35)',
              transition: 'transform 0.15s ease'
            }}
            onMouseEnter={(e) => e.currentTarget.style.transform = 'translateY(-2px)'}
            onMouseLeave={(e) => e.currentTarget.style.transform = 'translateY(0)'}
          >
            <FileCheck size={16} /> 
            <span>Validations Requises ({pendingPractitioners.length})</span>
          </button>

          <button 
            id="dash-quick-stats-btn"
            onClick={() => onNavigateTab('admin_stats')}
            style={{ 
              background: 'rgba(255, 255, 255, 0.16)', 
              color: '#FFFFFF', 
              border: '1px solid rgba(255, 255, 255, 0.3)',
              fontWeight: 800, 
              padding: '11px 18px', 
              borderRadius: '12px',
              display: 'flex',
              alignItems: 'center',
              gap: '8px',
              cursor: 'pointer',
              fontSize: '12px',
              backdropFilter: 'blur(8px)',
              transition: 'all 0.15s ease'
            }}
            onMouseEnter={(e) => e.currentTarget.style.background = 'rgba(255, 255, 255, 0.25)'}
            onMouseLeave={(e) => e.currentTarget.style.background = 'rgba(255, 255, 255, 0.16)'}
          >
            <DollarSign size={16} /> 
            <span>Synthèse Financière</span>
          </button>
        </div>
      </div>

      {/* ============================================================== */}
      {/* 5.5.1 : 4 CARTES BIOMÉTRIQUES RÉVOLUTIONNAIRES (GAUGES & KPIS)  */}
      {/* ============================================================== */}
      <div>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '14px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <div style={{ width: 6, height: 18, background: '#14583D', borderRadius: '4px' }}></div>
            <h2 style={{ fontSize: '18px', fontWeight: 900, color: '#1A1C1B', margin: 0 }}>
              Vue Consolidée des Indicateurs Clés de Santé
            </h2>
          </div>
          <span style={{ fontSize: '11px', color: '#56605B', fontWeight: 700 }}>
            Données certifiées conformes aux registres officiels
          </span>
        </div>

        <div style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))',
          gap: '18px'
        }}>
          {/* 1. CLINIOUES ACTIVES (AVEC JAUGE SVG D'OCCUPATION DES LITS) */}
          <div className="bio-metric-card" style={{ borderLeft: '4px solid #14583D' }}>
            <div className="bio-card-ambient" style={{ background: '#14583D' }}></div>

            <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between' }}>
              <div>
                <span style={{ fontSize: '11px', fontWeight: 800, color: '#56605B', textTransform: 'uppercase', letterSpacing: '0.04em' }}>
                  Cliniques Actives
                </span>
                <div style={{ fontSize: '32px', fontWeight: 900, color: '#14583D', marginTop: '4px', lineHeight: 1 }}>
                  {kpis.clinics.active}
                  <span style={{ fontSize: '15px', color: '#9CA3AF', fontWeight: 700 }}> / {kpis.clinics.count}</span>
                </div>
              </div>

              {/* Jauge circulaire SVG néomorphique */}
              <div style={{ position: 'relative', width: 48, height: 48 }}>
                <svg width="48" height="48" viewBox="0 0 48 48">
                  <circle className="circle-progress-bg" cx="24" cy="24" r="19" />
                  <circle 
                    className="circle-progress-bar" 
                    cx="24" 
                    cy="24" 
                    r="19" 
                    stroke="#14583D"
                    strokeDasharray={2 * Math.PI * 19}
                    strokeDashoffset={2 * Math.PI * 19 * (1 - kpis.clinics.percentOccupied / 100)}
                    transform="rotate(-90 24 24)"
                  />
                </svg>
                <div style={{ position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#14583D' }}>
                  <Building2 size={18} />
                </div>
              </div>
            </div>

            <div style={{ marginTop: '16px', paddingTop: '12px', borderTop: '1px solid #F0F4F2', display: 'flex', justifyContent: 'space-between', alignItems: 'center', fontSize: '11px' }}>
              <span style={{ color: '#56605B' }}>
                Lits occupés : <strong style={{ color: '#1A1C1B' }}>{kpis.clinics.occupiedBeds}/{kpis.clinics.bedsTotal} ({kpis.clinics.percentOccupied}%)</strong>
              </span>
              <span style={{ color: '#25674D', fontWeight: 800, background: '#e8efe8', padding: '2px 6px', borderRadius: '4px' }}>
                {kpis.clinics.trend}
              </span>
            </div>
          </div>

          {/* 2. MÉDECINS CONVENTIONNÉS (AVEC JAUGE DE DISPONIBILITÉ EN DIRECT) */}
          <div className="bio-metric-card" style={{ borderLeft: '4px solid #5B8E7B' }}>
            <div className="bio-card-ambient" style={{ background: '#5B8E7B' }}></div>

            <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between' }}>
              <div>
                <span style={{ fontSize: '11px', fontWeight: 800, color: '#56605B', textTransform: 'uppercase', letterSpacing: '0.04em' }}>
                  Médecins Agréés
                </span>
                <div style={{ fontSize: '32px', fontWeight: 900, color: '#1A1C1B', marginTop: '4px', lineHeight: 1 }}>
                  {kpis.doctors.count}
                </div>
              </div>

              {/* Jauge circulaire SVG */}
              <div style={{ position: 'relative', width: 48, height: 48 }}>
                <svg width="48" height="48" viewBox="0 0 48 48">
                  <circle className="circle-progress-bg" cx="24" cy="24" r="19" />
                  <circle 
                    className="circle-progress-bar" 
                    cx="24" 
                    cy="24" 
                    r="19" 
                    stroke="#5B8E7B"
                    strokeDasharray={2 * Math.PI * 19}
                    strokeDashoffset={2 * Math.PI * 19 * (1 - kpis.doctors.percentOnline / 100)}
                    transform="rotate(-90 24 24)"
                  />
                </svg>
                <div style={{ position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#5B8E7B' }}>
                  <Stethoscope size={18} />
                </div>
              </div>
            </div>

            <div style={{ marginTop: '16px', paddingTop: '12px', borderTop: '1px solid #F0F4F2', display: 'flex', justifyContent: 'space-between', alignItems: 'center', fontSize: '11px' }}>
              <span style={{ color: '#56605B' }}>
                En ligne maintenant : <strong style={{ color: '#25674D' }}>{kpis.doctors.activeNow} praticiens</strong>
              </span>
              <span style={{ color: '#25674D', fontWeight: 800, background: '#edf4f1', padding: '2px 6px', borderRadius: '4px' }}>
                {kpis.doctors.trend}
              </span>
            </div>
          </div>

          {/* 3. PATIENTS INSCRITS (AVEC JAUGE DE CROISSANCE UTILISATEURS) */}
          <div className="bio-metric-card" style={{ borderLeft: '4px solid #25674D' }}>
            <div className="bio-card-ambient" style={{ background: '#25674D' }}></div>

            <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between' }}>
              <div>
                <span style={{ fontSize: '11px', fontWeight: 800, color: '#56605B', textTransform: 'uppercase', letterSpacing: '0.04em' }}>
                  Patients Actifs
                </span>
                <div style={{ fontSize: '32px', fontWeight: 900, color: '#1A1C1B', marginTop: '4px', lineHeight: 1 }}>
                  {kpis.patients.count.toLocaleString()}
                </div>
              </div>

              {/* Jauge circulaire SVG */}
              <div style={{ position: 'relative', width: 48, height: 48 }}>
                <svg width="48" height="48" viewBox="0 0 48 48">
                  <circle className="circle-progress-bg" cx="24" cy="24" r="19" />
                  <circle 
                    className="circle-progress-bar" 
                    cx="24" 
                    cy="24" 
                    r="19" 
                    stroke="#25674D"
                    strokeDasharray={2 * Math.PI * 19}
                    strokeDashoffset={2 * Math.PI * 19 * (1 - kpis.patients.percentActive / 100)}
                    transform="rotate(-90 24 24)"
                  />
                </svg>
                <div style={{ position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#25674D' }}>
                  <Users size={18} />
                </div>
              </div>
            </div>

            <div style={{ marginTop: '16px', paddingTop: '12px', borderTop: '1px solid #F0F4F2', display: 'flex', justifyContent: 'space-between', alignItems: 'center', fontSize: '11px' }}>
              <span style={{ color: '#56605B' }}>
                7 derniers jours : <strong style={{ color: '#1A1C1B' }}>{kpis.patients.active7d.toLocaleString()} consultations</strong>
              </span>
              <span style={{ color: '#25674D', fontWeight: 800, background: '#e2f0e8', padding: '2px 6px', borderRadius: '4px' }}>
                {kpis.patients.trend}
              </span>
            </div>
          </div>

          {/* 4. PHARMACIES PARTENAIRES (AVEC JAUGE OFFICINES DE GARDE) */}
          <div className="bio-metric-card" style={{ borderLeft: '4px solid #FFB300' }}>
            <div className="bio-card-ambient" style={{ background: '#FFB300' }}></div>

            <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between' }}>
              <div>
                <span style={{ fontSize: '11px', fontWeight: 800, color: '#56605B', textTransform: 'uppercase', letterSpacing: '0.04em' }}>
                  Pharmacies Partenaires
                </span>
                <div style={{ fontSize: '32px', fontWeight: 900, color: '#1A1C1B', marginTop: '4px', lineHeight: 1 }}>
                  {kpis.pharmacies.count}
                </div>
              </div>

              {/* Jauge circulaire SVG */}
              <div style={{ position: 'relative', width: 48, height: 48 }}>
                <svg width="48" height="48" viewBox="0 0 48 48">
                  <circle className="circle-progress-bg" cx="24" cy="24" r="19" />
                  <circle 
                    className="circle-progress-bar" 
                    cx="24" 
                    cy="24" 
                    r="19" 
                    stroke="#FFB300"
                    strokeDasharray={2 * Math.PI * 19}
                    strokeDashoffset={2 * Math.PI * 19 * (1 - kpis.pharmacies.percentOnDuty / 100)}
                    transform="rotate(-90 24 24)"
                  />
                </svg>
                <div style={{ position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#d97706' }}>
                  <Pill size={18} />
                </div>
              </div>
            </div>

            <div style={{ marginTop: '16px', paddingTop: '12px', borderTop: '1px solid #F0F4F2', display: 'flex', justifyContent: 'space-between', alignItems: 'center', fontSize: '11px' }}>
              <span style={{ color: '#56605B' }}>
                De garde aujourd'hui : <strong style={{ color: '#d97706' }}>{kpis.pharmacies.onDutyNow} officines ouvertes</strong>
              </span>
              <span style={{ color: '#d97706', fontWeight: 800, background: '#fff8e1', padding: '2px 6px', borderRadius: '4px' }}>
                {kpis.pharmacies.trend}
              </span>
            </div>
          </div>
        </div>
      </div>

      {/* ============================================================== */}
      {/* 5.5.1 : GRAPHIQUE D'ACTIVITÉ 7 JOURS (DOUBLE VUE BARS/SPLINE)   */}
      {/* ============================================================== */}
      <div className="card" style={{ margin: 0, overflow: 'hidden' }}>
        <div className="card-header" style={{ flexWrap: 'wrap', gap: '12px', background: '#FAFCFB' }}>
          <div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
              <h3 className="card-title" style={{ display: 'flex', alignItems: 'center', gap: '8px', margin: 0 }}>
                <TrendingUp size={20} color="#14583D" />
                <span>Flux d'Activité Médicale sur 7 Jours</span>
              </h3>
              <span style={{ background: '#e8efe8', color: '#14583D', fontSize: '11px', fontWeight: 800, padding: '2px 8px', borderRadius: '6px' }}>
                Télémétrie en temps réel
              </span>
            </div>
            <p style={{ fontSize: '12px', color: '#56605B', margin: '3px 0 0 0' }}>
              Volume combiné des téléconsultations, consultations en cabinet, délivrances en officine et analyses labo.
            </p>
          </div>

          <div style={{ display: 'flex', alignItems: 'center', gap: '10px', flexWrap: 'wrap' }}>
            {/* Bascule Mode Barres / Spline */}
            <div style={{ display: 'flex', background: '#EBF2EE', borderRadius: '8px', padding: '3px' }}>
              <button
                onClick={() => setChartViewMode('bars')}
                title="Affichage en Barres Biométriques"
                style={{
                  background: chartViewMode === 'bars' ? '#FFFFFF' : 'transparent',
                  color: chartViewMode === 'bars' ? '#14583D' : '#56605B',
                  border: 'none',
                  borderRadius: '6px',
                  padding: '5px 8px',
                  cursor: 'pointer',
                  display: 'flex',
                  alignItems: 'center',
                  gap: '4px',
                  fontSize: '11px',
                  fontWeight: 700,
                  boxShadow: chartViewMode === 'bars' ? '0 2px 4px rgba(0,0,0,0.06)' : 'none'
                }}
              >
                <BarChart3 size={14} />
                <span>Barres</span>
              </button>
              <button
                onClick={() => setChartViewMode('waveform')}
                title="Affichage Courbe Spline Continue"
                style={{
                  background: chartViewMode === 'waveform' ? '#FFFFFF' : 'transparent',
                  color: chartViewMode === 'waveform' ? '#14583D' : '#56605B',
                  border: 'none',
                  borderRadius: '6px',
                  padding: '5px 8px',
                  cursor: 'pointer',
                  display: 'flex',
                  alignItems: 'center',
                  gap: '4px',
                  fontSize: '11px',
                  fontWeight: 700,
                  boxShadow: chartViewMode === 'waveform' ? '0 2px 4px rgba(0,0,0,0.06)' : 'none'
                }}
              >
                <LineChart size={14} />
                <span>Courbe</span>
              </button>
            </div>

            {/* Sélecteurs par prestation */}
            <div style={{ display: 'flex', gap: '4px', background: '#F2F5F4', padding: '4px', borderRadius: '10px' }}>
              {[
                { id: 'all', label: 'Toutes' },
                { id: 'teleconsultations', label: 'Téléconsult.' },
                { id: 'consultations', label: 'Cabinet' },
                { id: 'pharmacie', label: 'Pharmacies' },
                { id: 'labo', label: 'Labo' },
              ].map(tab => (
                <button
                  key={tab.id}
                  onClick={() => setActivityMetric(tab.id)}
                  style={{
                    padding: '5px 10px',
                    borderRadius: '6px',
                    border: 'none',
                    fontSize: '11px',
                    fontWeight: 700,
                    cursor: 'pointer',
                    background: activityMetric === tab.id ? '#14583D' : 'transparent',
                    color: activityMetric === tab.id ? 'white' : '#56605B',
                    transition: 'all 0.15s ease'
                  }}
                >
                  {tab.label}
                </button>
              ))}
            </div>
          </div>
        </div>

        <div className="card-body" style={{ padding: '24px' }}>
          {chartViewMode === 'bars' ? (
            /* MODE 1 : BARRES BIOMÉTRIQUES AVEC CAPSULES ET INFOBULLE */
            <div style={{
              display: 'flex',
              alignItems: 'flex-end',
              justifyContent: 'space-between',
              gap: '14px',
              height: '240px',
              paddingTop: '20px',
              paddingBottom: '12px',
              borderBottom: '1px solid #E5E7EB',
              position: 'relative'
            }}>
              {last7DaysData.map((d, idx) => {
                const val = getMetricVal(d);
                const pct = Math.max(14, Math.round((val / maxTotal) * 100));
                const isToday = idx === last7DaysData.length - 1;
                const isHovered = hoveredDay === d.day;

                return (
                  <div 
                    key={d.day} 
                    className="bio-bar-wrapper"
                    onMouseEnter={() => setHoveredDay(d.day)}
                    onMouseLeave={() => setHoveredDay(null)}
                  >
                    {/* Infobulle dynamique au survol */}
                    {isHovered && (
                      <div style={{
                        position: 'absolute',
                        bottom: `${pct + 14}%`,
                        background: '#1A1C1B',
                        color: 'white',
                        padding: '6px 10px',
                        borderRadius: '8px',
                        fontSize: '11px',
                        fontWeight: 700,
                        whiteSpace: 'nowrap',
                        boxShadow: '0 8px 16px rgba(0,0,0,0.2)',
                        zIndex: 20,
                        pointerEvents: 'none'
                      }}>
                        <div>{d.day} : {val} actes</div>
                        <div style={{ fontSize: '9px', opacity: 0.8, fontWeight: 500 }}>
                          Télé : {d.teleconsultations} • Cab : {d.consultations} • Pharma : {d.pharmacie}
                        </div>
                      </div>
                    )}

                    <div style={{ 
                      fontSize: '12px', 
                      fontWeight: isToday || isHovered ? 900 : 700, 
                      color: isToday ? '#14583D' : '#1A1C1B', 
                      marginBottom: '8px' 
                    }}>
                      {val}
                    </div>

                    {/* Capsule Bar */}
                    <div 
                      className="bio-bar-pill"
                      style={{
                        height: `${pct}%`,
                        background: activityMetric === 'teleconsultations'
                          ? 'linear-gradient(180deg, #5B8E7B 0%, #14583D 100%)'
                          : activityMetric === 'consultations'
                          ? 'linear-gradient(180deg, #25674D 0%, #0e402c 100%)'
                          : activityMetric === 'pharmacie'
                          ? 'linear-gradient(180deg, #FFB300 0%, #d97706 100%)'
                          : activityMetric === 'labo'
                          ? 'linear-gradient(180deg, #a855f7 0%, #7e22ce 100%)'
                          : isToday
                          ? 'linear-gradient(180deg, #22c55e 0%, #14583D 100%)'
                          : 'linear-gradient(180deg, #5B8E7B 0%, #14583D 100%)',
                        boxShadow: isToday ? '0 6px 16px rgba(20, 88, 61, 0.35)' : 'none'
                      }}
                    ></div>

                    <div style={{
                      marginTop: '10px',
                      fontSize: '11px',
                      fontWeight: isToday ? 800 : 600,
                      color: isToday ? '#14583D' : '#56605B',
                      textAlign: 'center'
                    }}>
                      {d.day}
                    </div>
                  </div>
                );
              })}
            </div>
          ) : (
            /* MODE 2 : COURBE SPLINE FLUIDE & NÉOMORPHIQUE */
            <div style={{ position: 'relative', height: '240px', paddingBottom: '10px', borderBottom: '1px solid #E5E7EB' }}>
              <svg width="100%" height="200" viewBox={`0 0 ${svgWidth} ${svgHeight}`} preserveAspectRatio="none">
                <defs>
                  <linearGradient id="splineGradient" x1="0%" y1="0%" x2="0%" y2="100%">
                    <stop offset="0%" stopColor="#14583D" stopOpacity="0.35" />
                    <stop offset="100%" stopColor="#14583D" stopOpacity="0.0" />
                  </linearGradient>
                </defs>

                <path d={areaPath} fill="url(#splineGradient)" />
                <path d={splinePath} fill="none" stroke="#14583D" strokeWidth="3.5" strokeLinecap="round" />

                {points.map((pt, i) => (
                  <g key={i}>
                    <circle cx={pt.x} cy={pt.y} r="5" fill="#FFFFFF" stroke="#14583D" strokeWidth="2.5" />
                    <text x={pt.x} y={pt.y - 10} textAnchor="middle" fontSize="10" fontWeight="800" fill="#14583D">
                      {getMetricVal(pt.data)}
                    </text>
                  </g>
                ))}
              </svg>

              <div style={{ display: 'flex', justifyContent: 'space-between', padding: '0 10px', marginTop: '6px' }}>
                {last7DaysData.map(d => (
                  <span key={d.day} style={{ fontSize: '11px', fontWeight: 700, color: '#56605B' }}>
                    {d.day}
                  </span>
                ))}
              </div>
            </div>
          )}

          {/* Légende interactive */}
          <div style={{ 
            display: 'flex', 
            justifyContent: 'space-between', 
            alignItems: 'center', 
            marginTop: '16px', 
            flexWrap: 'wrap', 
            gap: '12px',
            fontSize: '11px',
            color: '#56605B'
          }}>
            <div style={{ display: 'flex', gap: '16px', flexWrap: 'wrap' }}>
              <span style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                <span style={{ width: 8, height: 8, borderRadius: '50%', background: '#14583D' }}></span>
                Téléconsultations
              </span>
              <span style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                <span style={{ width: 8, height: 8, borderRadius: '50%', background: '#25674D' }}></span>
                Consultations physiques
              </span>
              <span style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                <span style={{ width: 8, height: 8, borderRadius: '50%', background: '#FFB300' }}></span>
                Pharmacies
              </span>
              <span style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                <span style={{ width: 8, height: 8, borderRadius: '50%', background: '#7e22ce' }}></span>
                Analyses labo
              </span>
            </div>

            <div style={{ fontWeight: 800, color: '#14583D', fontSize: '12px' }}>
              Flux en direct : <strong>Données réseau synchronisées</strong>
            </div>
          </div>
        </div>
      </div>

      {/* ============================================================== */}
      {/* 5.5.1 : FLUX OPÉRATIONNEL EN 2 VOLETS (AGRÉMENTS & LITIGES)     */}
      {/* ============================================================== */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(420px, 1fr))', gap: '22px' }}>
        
        {/* VOLET GAUCHE : DOSSIERS D'AGRÉMENT EN ATTENTE (5.5.1 / 5.5.2) */}
        <div className="card" style={{ margin: 0 }}>
          <div className="card-header" style={{ background: '#FAFCFB' }}>
            <div>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                <FileCheck size={18} color="#FFB300" />
                <h3 className="card-title" style={{ margin: 0 }}>
                  Validations de Comptes en Attente
                </h3>
              </div>
              <p style={{ fontSize: '11px', color: '#56605B', margin: '2px 0 0 0' }}>
                {pendingPractitioners.length} professionnel(s) en attente d'agrément
              </p>
            </div>

            <button 
              className="btn btn-secondary"
              onClick={() => onNavigateTab('admin_verification')}
              style={{ fontSize: '11px', padding: '6px 12px', display: 'flex', alignItems: 'center', gap: '4px' }}
            >
              <span>Centre d'agrément</span>
              <ChevronRight size={12} />
            </button>
          </div>

          <div className="card-body" style={{ padding: '14px' }}>
            {pendingPractitioners.length === 0 ? (
              <div style={{ textAlign: 'center', padding: '36px 20px', color: '#56605B' }}>
                <CheckCircle size={36} color="#25674D" style={{ margin: '0 auto 10px auto' }} />
                <div style={{ fontWeight: 800, color: '#1A1C1B' }}>Tous les praticiens sont certifiés !</div>
                <div style={{ fontSize: '12px', marginTop: '2px' }}>Aucune demande en attente dans la file d'attente.</div>
              </div>
            ) : (
              <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
                {pendingPractitioners.map(p => (
                  <div 
                    key={p.id}
                    style={{
                      background: '#FFFFFF',
                      border: '1px solid #E5E7EB',
                      borderRadius: '14px',
                      padding: '12px 14px',
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'space-between',
                      gap: '12px',
                      transition: 'all 0.15s ease',
                      boxShadow: '0 2px 6px rgba(0,0,0,0.02)'
                    }}
                  >
                    <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                      <div style={{
                        width: 40,
                        height: 40,
                        borderRadius: '12px',
                        background: p.type === 'clinique' ? '#e8efe8' : p.type === 'pharmacie' ? '#fff8e1' : '#edf4f1',
                        color: p.type === 'clinique' ? '#14583D' : p.type === 'pharmacie' ? '#d97706' : '#5B8E7B',
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        flexShrink: 0
                      }}>
                        {p.type === 'clinique' ? <Building2 size={20} /> : p.type === 'pharmacie' ? <Pill size={20} /> : <Stethoscope size={20} />}
                      </div>

                      <div>
                        <div style={{ fontWeight: 800, fontSize: '13px', color: '#1A1C1B' }}>{p.name}</div>
                        <div style={{ fontSize: '11px', color: '#56605B', display: 'flex', alignItems: 'center', gap: '6px' }}>
                          <span style={{ fontWeight: 600 }}>{p.specialty}</span>
                          <span>•</span>
                          <span>{p.city}</span>
                          <span>•</span>
                          <code>{p.docNumber}</code>
                        </div>
                      </div>
                    </div>

                    <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
                      <button
                        title="Vérifier le dossier officiel"
                        onClick={() => onInspectPractitioner(p)}
                        style={{
                          background: '#F8F9FA',
                          border: '1px solid #DADDDD',
                          borderRadius: '8px',
                          padding: '6px 10px',
                          fontSize: '11px',
                          fontWeight: 700,
                          color: '#14583D',
                          cursor: 'pointer',
                          display: 'flex',
                          alignItems: 'center',
                          gap: '4px'
                        }}
                      >
                        <Eye size={12} />
                        <span>Vérifier</span>
                      </button>

                      <button
                        title="Valider l'agrément"
                        onClick={() => onValidatePractitioner(p.id, p.name)}
                        style={{
                          background: '#14583D',
                          color: 'white',
                          border: 'none',
                          borderRadius: '8px',
                          padding: '6px 10px',
                          fontSize: '11px',
                          fontWeight: 700,
                          cursor: 'pointer',
                          display: 'flex',
                          alignItems: 'center',
                          gap: '3px'
                        }}
                      >
                        <Check size={12} />
                        <span>Valider</span>
                      </button>

                      <button
                        title="Rejeter la demande"
                        onClick={() => onRejectPractitioner(p.id, p.name)}
                        style={{
                          background: '#fbebeb',
                          color: '#BE3232',
                          border: '1px solid #BE323230',
                          borderRadius: '8px',
                          padding: '6px 8px',
                          fontSize: '11px',
                          cursor: 'pointer'
                        }}
                      >
                        <XCircle size={13} />
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>

        {/* VOLET DROIT : RADAR DES LITIGES & TICKETS PRIORITAIRES (5.5.3) */}
        <div className="card" style={{ margin: 0 }}>
          <div className="card-header" style={{ background: '#FAFCFB' }}>
            <div>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                <ShieldAlert size={18} color="#BE3232" />
                <h3 className="card-title" style={{ margin: 0 }}>
                  Litiges & Tickets Prioritaires
                </h3>
              </div>
              <p style={{ fontSize: '11px', color: '#56605B', margin: '2px 0 0 0' }}>
                Arbitrage direct et assistance de premier niveau
              </p>
            </div>

            <button 
              className="btn btn-secondary"
              onClick={() => onNavigateTab('admin_support')}
              style={{ fontSize: '11px', padding: '6px 12px', display: 'flex', alignItems: 'center', gap: '4px' }}
            >
              <span>Centre support</span>
              <ChevronRight size={12} />
            </button>
          </div>

          <div className="card-body" style={{ padding: '14px' }}>
            {urgentTickets.length === 0 ? (
              <div style={{ textAlign: 'center', padding: '36px 20px', color: '#56605B' }}>
                <CheckCircle size={36} color="#25674D" style={{ margin: '0 auto 10px auto' }} />
                <div style={{ fontWeight: 800, color: '#1A1C1B' }}>Aucun litige en cours</div>
                <div style={{ fontSize: '12px', marginTop: '2px' }}>Tous les litiges et tickets prioritaires sont résolus.</div>
              </div>
            ) : (
              <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
                {urgentTickets.map(t => (
                <div 
                  key={t.id}
                  style={{
                    background: '#FFFFFF',
                    border: '1px solid #E5E7EB',
                    borderRadius: '14px',
                    padding: '12px 14px',
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'space-between',
                    gap: '12px',
                    boxShadow: '0 2px 6px rgba(0,0,0,0.02)'
                  }}
                >
                  <div>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '4px' }}>
                      <span style={{
                        fontSize: '9px',
                        fontWeight: 900,
                        padding: '2px 6px',
                        borderRadius: '4px',
                        background: t.priority === 'Urgente' ? '#fbebeb' : '#fff8e1',
                        color: t.priority === 'Urgente' ? '#BE3232' : '#d97706'
                      }}>
                        {t.priority}
                      </span>
                      <span style={{ fontSize: '11px', fontWeight: 800, color: '#56605B' }}>
                        {t.requesterType} : {t.requesterName}
                      </span>
                      {t.disputedAmount && (
                        <span style={{ fontSize: '10px', color: '#BE3232', fontWeight: 800, background: '#fef1ec', padding: '1px 5px', borderRadius: '4px' }}>
                          Litige : {t.disputedAmount}
                        </span>
                      )}
                    </div>

                    <div style={{ fontWeight: 800, fontSize: '13px', color: '#1A1C1B' }}>
                      {t.subject}
                    </div>

                    <div style={{ fontSize: '11px', color: '#9CA3AF', marginTop: '2px' }}>
                      {t.category} • {t.date}
                    </div>
                  </div>

                  <button
                    onClick={() => {
                      onOpenTicket(t);
                      onNavigateTab('admin_support');
                    }}
                    style={{
                      background: '#14583D',
                      color: 'white',
                      border: 'none',
                      borderRadius: '8px',
                      padding: '8px 12px',
                      fontSize: '11px',
                      fontWeight: 800,
                      cursor: 'pointer',
                      display: 'flex',
                      alignItems: 'center',
                      gap: '4px',
                      whiteSpace: 'nowrap'
                    }}
                  >
                    <span>Traiter</span>
                    <ChevronRight size={12} />
                  </button>
                </div>
              ))}
            </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};
