import React, { useState } from 'react';
import { 
  DollarSign, 
  Download, 
  TrendingUp, 
  PieChart, 
  Video, 
  Stethoscope, 
  Pill, 
  FlaskConical, 
  FileSpreadsheet, 
  Printer, 
  CreditCard,
  X
} from 'lucide-react';

export const AdminStatistics = ({ onShowToast }) => {
  const [period] = useState('month'); // week, month, year
  const [showPrintModal, setShowPrintModal] = useState(false);

  // Données financières détaillées par type d'activité (initialisées à 0, connectées à la comptabilité)
  const activitiesData = {
    teleconsultations: {
      id: 'teleconsultations',
      label: 'Téléconsultations',
      icon: Video,
      color: '#14583D',
      lightBg: '#e8efe8',
      volume: 0,
      unitPrice: 0,
      grossRevenue: 0,
      commissionRate: 15, // 15%
      commissionAmount: 0,
      providerPayout: 0,
      growth: '0%',
      description: 'Consultations vidéo à distance avec paiement sécurisé en amont'
    },
    consultations: {
      id: 'consultations',
      label: 'Consultations en Cabinet',
      icon: Stethoscope,
      color: '#25674D',
      lightBg: '#e2f0e8',
      volume: 0,
      unitPrice: 0,
      grossRevenue: 0,
      commissionRate: 10, // 10%
      commissionAmount: 0,
      providerPayout: 0,
      growth: '0%',
      description: 'Consultations physiques en cabinet médical et visites à domicile'
    },
    pharmacies: {
      id: 'pharmacies',
      label: 'Pharmacies Partenaires',
      icon: Pill,
      color: '#d97706',
      lightBg: '#fff8e1',
      volume: 0,
      unitPrice: 0,
      grossRevenue: 0,
      commissionRate: 8, // 8%
      commissionAmount: 0,
      providerPayout: 0,
      growth: '0%',
      description: 'Ordonnances numérisées et médicaments délivrés en officine conventionnée'
    },
    laboratoire: {
      id: 'laboratoire',
      label: 'Analyses de Laboratoire',
      icon: FlaskConical,
      color: '#7e22ce',
      lightBg: '#f3e8ff',
      volume: 0,
      unitPrice: 0,
      grossRevenue: 0,
      commissionRate: 12, // 12%
      commissionAmount: 0,
      providerPayout: 0,
      growth: '0%',
      description: 'Bilans sanguins, analyses de biologie médicale et radiologie hospitalière'
    }
  };

  const activityList = Object.values(activitiesData);

  // Synthèse financière globale
  const totalGrossRevenue = activityList.reduce((acc, curr) => acc + curr.grossRevenue, 0);
  const totalCommissions = activityList.reduce((acc, curr) => acc + curr.commissionAmount, 0);
  const totalPayout = activityList.reduce((acc, curr) => acc + curr.providerPayout, 0);
  const totalVolume = activityList.reduce((acc, curr) => acc + curr.volume, 0);
  const averageBasket = totalVolume > 0 ? Math.round(totalGrossRevenue / totalVolume) : 0;
  const averageCommissionRate = totalGrossRevenue > 0 ? ((totalCommissions / totalGrossRevenue) * 100).toFixed(1) : '0.0';

  // Export du rapport financier en format CSV conforme (5.5.4)
  const handleExportCSV = () => {
    const today = new Date().toISOString().split('T')[0];
    let csv = '\uFEFF'; // BOM UTF-8 pour ouverture correcte dans Microsoft Excel
    csv += 'RAPPORT FINANCIER GLOBAL & STATISTIQUES DES COMMISSIONS - ALLO DOCTOR\n';
    csv += `Date d'exportation : ${today}\n`;
    csv += `Période comptable : ${period === 'month' ? 'Mois en cours (Octobre 2026)' : period === 'year' ? 'Exercice Annuel 2026' : '7 Derniers Jours'}\n\n`;

    csv += '--- SYNTHÈSE FINANCIÈRE GLOBALE ---\n';
    csv += `Chiffre d'Affaires Brut Global (GMV);${totalGrossRevenue.toLocaleString()} F CFA\n`;
    csv += `Total Commissions Plateforme Allo Doctor;${totalCommissions.toLocaleString()} F CFA\n`;
    csv += `Revenus Reversés aux Praticiens & Partenaires;${totalPayout.toLocaleString()} F CFA\n`;
    csv += `Volume Total d'Actes & Commandes;${totalVolume.toLocaleString()}\n`;
    csv += `Panier Moyen Par Prestation;${averageBasket.toLocaleString()} F CFA\n`;
    csv += `Taux Moyen de Commission;${averageCommissionRate}%\n\n`;

    csv += '--- DÉTAIL DES REVENUS PAR TYPE D\'ACTIVITÉ (5.5.4) ---\n';
    csv += 'Type d\'Activité;Volume Actes;Prix Moyen;Revenu Brut (GMV);Taux Commission;Commission Allo Doctor;Reversé Professionnel;Croissance\n';

    activityList.forEach(act => {
      csv += `"${act.label}";${act.volume};${act.unitPrice} F CFA;${act.grossRevenue} F CFA;${act.commissionRate}%;${act.commissionAmount} F CFA;${act.providerPayout} F CFA;${act.growth}\n`;
    });

    // Création du Blob et déclenchement du téléchargement
    const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.setAttribute('href', url);
    link.setAttribute('download', `Rapport_Financier_AlloDoctor_${today}.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    URL.revokeObjectURL(url);

    onShowToast('Export du rapport financier (CSV) téléchargé avec succès !');
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
      {/* 5.5.4 : EN-TÊTE STATISTIQUES ET COMMISSIONS */}
      <div style={{
        background: 'linear-gradient(135deg, #14583D 0%, #25674D 50%, #1A1C1B 100%)',
        borderRadius: '20px',
        padding: '24px 30px',
        color: 'white',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'space-between',
        flexWrap: 'wrap',
        gap: '16px',
        boxShadow: '0 8px 24px rgba(20, 88, 61, 0.25)'
      }}>
        <div>
          <div style={{ 
            display: 'inline-flex', 
            alignItems: 'center', 
            gap: '6px', 
            background: 'rgba(255, 255, 255, 0.16)', 
            padding: '4px 12px', 
            borderRadius: '20px', 
            fontSize: '12px', 
            fontWeight: 800, 
            marginBottom: '8px' 
          }}>
            <DollarSign size={14} color="#FFB300" />
            SYNTHÈSE FINANCIÈRE • COMMISSIONS DE LA PLATEFORME
          </div>
          <h1 style={{ fontSize: '26px', fontWeight: 900, margin: '2px 0 6px 0' }}>
            Synthèse Financière & Revenus par Activité
          </h1>
          <p style={{ opacity: 0.9, fontSize: '13px', maxWidth: '680px' }}>
            Détail des revenus générés par les téléconsultations, consultations physiques, pharmacies et analyses laboratoire.
          </p>
        </div>

        {/* Boutons d'exportation conformes au 5.5.4 */}
        <div style={{ display: 'flex', gap: '10px', flexWrap: 'wrap' }}>
          <button
            onClick={() => setShowPrintModal(true)}
            style={{
              background: 'rgba(255,255,255,0.18)',
              color: 'white',
              border: '1px solid rgba(255,255,255,0.3)',
              borderRadius: '12px',
              padding: '10px 16px',
              fontSize: '12px',
              fontWeight: 800,
              cursor: 'pointer',
              display: 'flex',
              alignItems: 'center',
              gap: '6px'
            }}
          >
            <Printer size={15} />
            <span>Aperçu Impression</span>
          </button>

          <button
            id="btn-export-financial-report"
            onClick={handleExportCSV}
            style={{
              background: '#FFB300',
              color: '#1A1C1B',
              border: 'none',
              borderRadius: '12px',
              padding: '10px 20px',
              fontSize: '12px',
              fontWeight: 900,
              cursor: 'pointer',
              display: 'flex',
              alignItems: 'center',
              gap: '8px',
              boxShadow: '0 4px 14px rgba(255, 179, 0, 0.4)'
            }}
          >
            <Download size={16} />
            <span>Exporter Rapport Financier</span>
          </button>
        </div>
      </div>

      {/* SYNTHÈSE FINANCIÈRE GLOBALE (4 CARTES MAJEURES) */}
      <div style={{
        display: 'grid',
        gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))',
        gap: '16px'
      }}>
        {/* Chiffre d'Affaires Brut Global */}
        <div className="card" style={{ margin: 0, padding: '20px', borderLeft: '4px solid #14583D' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
            <div>
              <span style={{ fontSize: '11px', fontWeight: 700, color: '#56605B', textTransform: 'uppercase' }}>
                Revenus Bruts Globaux (GMV)
              </span>
              <div style={{ fontSize: '26px', fontWeight: 900, color: '#1A1C1B', marginTop: '4px' }}>
                {totalGrossRevenue.toLocaleString()} <span style={{ fontSize: '13px', color: '#56605B' }}>F CFA</span>
              </div>
            </div>
            <div style={{ width: 40, height: 40, borderRadius: '10px', background: '#e8efe8', color: '#14583D', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <TrendingUp size={22} />
            </div>
          </div>
          <div style={{ marginTop: '12px', paddingTop: '10px', borderTop: '1px solid #f0f0f0', display: 'flex', justifyContent: 'space-between', fontSize: '11px', color: '#56605B' }}>
            <span>Volume total traité</span>
            <strong style={{ color: '#25674D' }}>{totalVolume.toLocaleString()} actes & commandes</strong>
          </div>
        </div>

        {/* Total Commissions Allo Doctor */}
        <div className="card" style={{ margin: 0, padding: '20px', borderLeft: '4px solid #FFB300' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
            <div>
              <span style={{ fontSize: '11px', fontWeight: 700, color: '#56605B', textTransform: 'uppercase' }}>
                Commissions Nettes Plateforme
              </span>
              <div style={{ fontSize: '26px', fontWeight: 900, color: '#14583D', marginTop: '4px' }}>
                {totalCommissions.toLocaleString()} <span style={{ fontSize: '13px', color: '#56605B' }}>F CFA</span>
              </div>
            </div>
            <div style={{ width: 40, height: 40, borderRadius: '10px', background: '#fff8e1', color: '#d97706', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <DollarSign size={22} />
            </div>
          </div>
          <div style={{ marginTop: '12px', paddingTop: '10px', borderTop: '1px solid #f0f0f0', display: 'flex', justifyContent: 'space-between', fontSize: '11px', color: '#56605B' }}>
            <span>Taux moyen perçu</span>
            <strong style={{ color: '#d97706' }}>{averageCommissionRate}% de marge</strong>
          </div>
        </div>

        {/* Reversé aux Praticiens & Partenaires */}
        <div className="card" style={{ margin: 0, padding: '20px', borderLeft: '4px solid #5B8E7B' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
            <div>
              <span style={{ fontSize: '11px', fontWeight: 700, color: '#56605B', textTransform: 'uppercase' }}>
                Reversé aux Professionnels
              </span>
              <div style={{ fontSize: '26px', fontWeight: 900, color: '#1A1C1B', marginTop: '4px' }}>
                {totalPayout.toLocaleString()} <span style={{ fontSize: '13px', color: '#56605B' }}>F CFA</span>
              </div>
            </div>
            <div style={{ width: 40, height: 40, borderRadius: '10px', background: '#edf4f1', color: '#5B8E7B', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <CreditCard size={22} />
            </div>
          </div>
          <div style={{ marginTop: '12px', paddingTop: '10px', borderTop: '1px solid #f0f0f0', display: 'flex', justifyContent: 'space-between', fontSize: '11px', color: '#56605B' }}>
            <span>Délai de reversement</span>
            <strong style={{ color: '#25674D' }}>Automatique sous 48h</strong>
          </div>
        </div>

        {/* Panier Moyen Prestations */}
        <div className="card" style={{ margin: 0, padding: '20px', borderLeft: '4px solid #F87849' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start' }}>
            <div>
              <span style={{ fontSize: '11px', fontWeight: 700, color: '#56605B', textTransform: 'uppercase' }}>
                Panier Moyen Global
              </span>
              <div style={{ fontSize: '26px', fontWeight: 900, color: '#1A1C1B', marginTop: '4px' }}>
                {averageBasket.toLocaleString()} <span style={{ fontSize: '13px', color: '#56605B' }}>F CFA</span>
              </div>
            </div>
            <div style={{ width: 40, height: 40, borderRadius: '10px', background: '#fef1ec', color: '#F87849', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <PieChart size={22} />
            </div>
          </div>
          <div style={{ marginTop: '12px', paddingTop: '10px', borderTop: '1px solid #f0f0f0', display: 'flex', justifyContent: 'space-between', fontSize: '11px', color: '#56605B' }}>
            <span>Croissance mensuelle</span>
            <strong style={{ color: '#25674D' }}>0.0%</strong>
          </div>
        </div>
      </div>

      {/* DÉTAIL DES REVENUS PAR LES 4 TYPES D'ACTIVITÉ */}
      <div>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '14px' }}>
          <h2 style={{ fontSize: '18px', fontWeight: 900, color: '#1A1C1B', display: 'flex', alignItems: 'center', gap: '8px' }}>
            Ventilation Détaillée par Type d'Activité
          </h2>
          <span style={{ fontSize: '12px', color: '#56605B' }}>
            Téléconsultations, consultations physiques, pharmacies et analyses labo
          </span>
        </div>

        <div style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))',
          gap: '18px'
        }}>
          {activityList.map(act => {
            const Icon = act.icon;
            const pctOfTotal = totalGrossRevenue > 0 ? Math.round((act.grossRevenue / totalGrossRevenue) * 100) : 0;

            return (
              <div 
                key={act.id} 
                className="card"
                style={{ 
                  margin: 0, 
                  padding: '20px', 
                  borderTop: `4px solid ${act.color}`,
                  boxShadow: '0 4px 12px rgba(0,0,0,0.04)'
                }}
              >
                <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '12px' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                    <div style={{
                      width: 40,
                      height: 40,
                      borderRadius: '10px',
                      background: act.lightBg,
                      color: act.color,
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center'
                    }}>
                      <Icon size={20} />
                    </div>
                    <div>
                      <h3 style={{ fontSize: '15px', fontWeight: 900, color: '#1A1C1B', margin: 0 }}>
                        {act.label}
                      </h3>
                      <span style={{ fontSize: '11px', color: '#56605B' }}>
                        {pctOfTotal}% du chiffre d'affaires
                      </span>
                    </div>
                  </div>

                  <span style={{ fontSize: '11px', fontWeight: 800, color: '#25674D', background: '#e2f0e8', padding: '3px 8px', borderRadius: '6px' }}>
                    {act.growth}
                  </span>
                </div>

                <p style={{ fontSize: '11px', color: '#56605B', marginBottom: '14px', minHeight: '32px' }}>
                  {act.description}
                </p>

                {/* Métriques clés */}
                <div style={{ display: 'flex', flexDirection: 'column', gap: '8px', fontSize: '12px', background: '#F8F9FA', padding: '12px', borderRadius: '10px' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                    <span style={{ color: '#56605B' }}>Volume réalisé :</span>
                    <strong>{act.volume.toLocaleString()} actes</strong>
                  </div>
                  <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                    <span style={{ color: '#56605B' }}>Revenu brut (GMV) :</span>
                    <strong style={{ color: '#1A1C1B' }}>{act.grossRevenue.toLocaleString()} F CFA</strong>
                  </div>
                  <div style={{ display: 'flex', justifyContent: 'space-between', paddingTop: '6px', borderTop: '1px dashed #DADDDD' }}>
                    <span style={{ color: '#56605B' }}>Taux de commission :</span>
                    <span style={{ fontWeight: 800, color: act.color }}>{act.commissionRate}%</span>
                  </div>
                  <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                    <span style={{ color: '#14583D', fontWeight: 700 }}>Commission Allo Doctor :</span>
                    <strong style={{ color: '#14583D' }}>{act.commissionAmount.toLocaleString()} F CFA</strong>
                  </div>
                  <div style={{ display: 'flex', justifyContent: 'space-between' }}>
                    <span style={{ color: '#56605B' }}>Net reversé praticien :</span>
                    <strong style={{ color: '#56605B' }}>{act.providerPayout.toLocaleString()} F CFA</strong>
                  </div>
                </div>

                {/* Barre de répartition */}
                <div style={{ marginTop: '12px' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '10px', color: '#9CA3AF', marginBottom: '4px' }}>
                    <span>Part commission</span>
                    <span>{act.commissionRate}% / 100%</span>
                  </div>
                  <div style={{ height: '6px', width: '100%', background: '#E5E7EB', borderRadius: '3px', overflow: 'hidden' }}>
                    <div style={{ width: `${act.commissionRate * 2}%`, height: '100%', background: act.color, borderRadius: '3px' }}></div>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      </div>

      {/* TABLEAU RÉCAPITULATIF CONSOLIDÉ POUR AUDIT COMPTABLE */}
      <div className="card" style={{ margin: 0 }}>
        <div className="card-header" style={{ flexWrap: 'wrap', gap: '12px' }}>
          <div>
            <h3 className="card-title" style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
              <FileSpreadsheet size={18} color="#14583D" />
              Tableau Analytique des Flux et Commissions par Activité
            </h3>
            <p style={{ fontSize: '11px', color: '#56605B', marginTop: '2px' }}>
              Base officielle certifiée pour la clôture financière et le reversement bancaire.
            </p>
          </div>

          <button
            onClick={handleExportCSV}
            style={{
              background: '#14583D',
              color: 'white',
              border: 'none',
              borderRadius: '8px',
              padding: '6px 14px',
              fontSize: '11px',
              fontWeight: 700,
              cursor: 'pointer',
              display: 'flex',
              alignItems: 'center',
              gap: '6px'
            }}
          >
            <Download size={13} />
            <span>Télécharger CSV</span>
          </button>
        </div>

        <div className="card-body">
          <div className="custom-table-container">
            <table className="custom-table">
              <thead>
                <tr>
                  <th>Type d'Activité Médicale</th>
                  <th>Volume d'Actes</th>
                  <th>Prix Moyen / Panier</th>
                  <th>Chiffre d'Affaires Brut (GMV)</th>
                  <th>Taux Commission</th>
                  <th>Commission Allo Doctor</th>
                  <th>Net Reversé aux Partenaires</th>
                  <th>Statut Flux</th>
                </tr>
              </thead>
              <tbody>
                {activityList.map((act) => (
                  <tr key={act.id}>
                    <td>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                        <div style={{ width: 28, height: 28, borderRadius: '6px', background: act.lightBg, color: act.color, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                          <act.icon size={15} />
                        </div>
                        <strong>{act.label}</strong>
                      </div>
                    </td>

                    <td><strong>{act.volume.toLocaleString()}</strong> actes</td>
                    <td>{act.unitPrice.toLocaleString()} F CFA</td>
                    <td><strong style={{ color: '#1A1C1B' }}>{act.grossRevenue.toLocaleString()} F CFA</strong></td>
                    <td>
                      <span className="badge badge-warning" style={{ fontWeight: 800 }}>
                        {act.commissionRate}%
                      </span>
                    </td>
                    <td><strong style={{ color: '#14583D' }}>{act.commissionAmount.toLocaleString()} F CFA</strong></td>
                    <td>{act.providerPayout.toLocaleString()} F CFA</td>
                    <td>
                      <span className="badge badge-success">✓ Soldé</span>
                    </td>
                  </tr>
                ))}
              </tbody>
              <tfoot>
                <tr style={{ background: '#F8F9FA', fontWeight: 900, borderTop: '2px solid #14583D' }}>
                  <td>TOTAL CONSOLIDÉ</td>
                  <td>{totalVolume.toLocaleString()} actes</td>
                  <td>{averageBasket.toLocaleString()} F CFA</td>
                  <td style={{ color: '#14583D' }}>{totalGrossRevenue.toLocaleString()} F CFA</td>
                  <td>{averageCommissionRate}% moy.</td>
                  <td style={{ color: '#14583D' }}>{totalCommissions.toLocaleString()} F CFA</td>
                  <td>{totalPayout.toLocaleString()} F CFA</td>
                  <td><span className="badge badge-success">100% Audité</span></td>
                </tr>
              </tfoot>
            </table>
          </div>
        </div>
      </div>

      {/* MODAL D'APERÇU D'IMPRESSION DU RAPPORT FINANCIER */}
      {showPrintModal && (
        <div style={{
          position: 'fixed',
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          background: 'rgba(0, 0, 0, 0.6)',
          backdropFilter: 'blur(4px)',
          zIndex: 1100,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          padding: '20px'
        }}>
          <div style={{
            background: 'white',
            borderRadius: '16px',
            maxWidth: '780px',
            width: '100%',
            maxHeight: '90vh',
            overflowY: 'auto',
            padding: '30px',
            boxShadow: '0 20px 40px rgba(0,0,0,0.3)',
            display: 'flex',
            flexDirection: 'column',
            gap: '20px'
          }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', borderBottom: '2px solid #14583D', paddingBottom: '16px' }}>
              <div>
                <div style={{ fontSize: '12px', fontWeight: 800, color: '#14583D' }}>PLATEFORME MÉDICALE ALLO DOCTOR</div>
                <h2 style={{ fontSize: '20px', fontWeight: 900, margin: '4px 0' }}>Rapport Financier & Audit des Commissions</h2>
                <div style={{ fontSize: '11px', color: '#56605B' }}>Date d'émission : 18 Octobre 2026 • Réf : AUDIT-FIN-2026-Q4</div>
              </div>

              <button
                onClick={() => setShowPrintModal(false)}
                style={{ background: 'transparent', border: 'none', cursor: 'pointer', color: '#9CA3AF' }}
              >
                <X size={20} />
              </button>
            </div>

            {/* Récapitulatif officiel */}
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '14px', background: '#F8F9FA', padding: '16px', borderRadius: '10px', fontSize: '12px' }}>
              <div>
                <span style={{ color: '#56605B' }}>Volume total d'actes :</span>
                <strong> {totalVolume.toLocaleString()}</strong>
              </div>
              <div>
                <span style={{ color: '#56605B' }}>Chiffre d'affaires brut (GMV) :</span>
                <strong style={{ color: '#14583D' }}> {totalGrossRevenue.toLocaleString()} F CFA</strong>
              </div>
              <div>
                <span style={{ color: '#56605B' }}>Commissions nettes Allo Doctor :</span>
                <strong style={{ color: '#14583D' }}> {totalCommissions.toLocaleString()} F CFA</strong>
              </div>
              <div>
                <span style={{ color: '#56605B' }}>Montant total reversé aux praticiens :</span>
                <strong> {totalPayout.toLocaleString()} F CFA</strong>
              </div>
            </div>

            {/* Tableau des 4 branches */}
            <div>
              <h4 style={{ fontSize: '13px', fontWeight: 800, marginBottom: '8px' }}>
                Ventilation par Branche d'Activité de Santé :
              </h4>
              <table style={{ width: '100%', fontSize: '11px', borderCollapse: 'collapse' }}>
                <thead>
                  <tr style={{ background: '#e8efe8', textAlign: 'left' }}>
                    <th style={{ padding: '8px' }}>Activité</th>
                    <th style={{ padding: '8px' }}>Volume</th>
                    <th style={{ padding: '8px' }}>Brut</th>
                    <th style={{ padding: '8px' }}>Taux</th>
                    <th style={{ padding: '8px' }}>Commissions</th>
                    <th style={{ padding: '8px' }}>Reversé</th>
                  </tr>
                </thead>
                <tbody>
                  {activityList.map(a => (
                    <tr key={a.id} style={{ borderBottom: '1px solid #E5E7EB' }}>
                      <td style={{ padding: '8px' }}><strong>{a.label}</strong></td>
                      <td style={{ padding: '8px' }}>{a.volume.toLocaleString()}</td>
                      <td style={{ padding: '8px' }}>{a.grossRevenue.toLocaleString()} F CFA</td>
                      <td style={{ padding: '8px' }}>{a.commissionRate}%</td>
                      <td style={{ padding: '8px', color: '#14583D', fontWeight: 700 }}>{a.commissionAmount.toLocaleString()} F CFA</td>
                      <td style={{ padding: '8px' }}>{a.providerPayout.toLocaleString()} F CFA</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>

            <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px', paddingTop: '10px', borderTop: '1px solid #E5E7EB' }}>
              <button
                className="btn btn-secondary"
                onClick={() => setShowPrintModal(false)}
                style={{ fontSize: '12px', padding: '8px 14px' }}
              >
                Fermer
              </button>
              <button
                onClick={() => {
                  window.print();
                }}
                style={{
                  background: '#14583D',
                  color: 'white',
                  border: 'none',
                  borderRadius: '8px',
                  padding: '8px 18px',
                  fontSize: '12px',
                  fontWeight: 800,
                  cursor: 'pointer',
                  display: 'flex',
                  alignItems: 'center',
                  gap: '6px'
                }}
              >
                <Printer size={14} />
                <span>Imprimer / Sauvegarder PDF</span>
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
