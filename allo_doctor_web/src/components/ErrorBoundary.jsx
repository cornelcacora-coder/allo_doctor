import React from 'react';

/**
 * Filet de securite React : une exception levee pendant le rendu ne doit
 * pas vider l'application (page blanche) sans laisser de trace.
 */
export class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props);
    this.state = { error: null };
  }

  static getDerivedStateFromError(error) {
    return { error };
  }

  componentDidCatch(error, info) {
    console.error('[AlloDoctor] Erreur de rendu :', error, info?.componentStack);
  }

  render() {
    if (!this.state.error) {
      return this.props.children;
    }

    return (
      <div
        style={{
          minHeight: '100vh',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          background: 'var(--bg-main, #F8F9FA)',
          padding: '24px',
          fontFamily: 'inherit'
        }}
      >
        <div
          className="card"
          style={{
            maxWidth: '560px',
            width: '100%',
            padding: '32px',
            background: 'var(--bg-surface, #FFFFFF)',
            border: '1px solid var(--border, #DADDDD)',
            borderRadius: '16px',
            boxShadow: '0 12px 20px -4px rgba(20, 88, 61, 0.1)'
          }}
        >
          <div
            style={{
              width: '48px',
              height: '48px',
              borderRadius: '12px',
              background: 'var(--danger-light, #fbebeb)',
              color: 'var(--danger, #BE3232)',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              fontSize: '24px',
              marginBottom: '16px'
            }}
          >
            !
          </div>

          <h2
            style={{
              margin: '0 0 8px',
              fontSize: '20px',
              fontWeight: 800,
              color: 'var(--text-primary, #1A1C1B)'
            }}
          >
            Une erreur est survenue
          </h2>

          <p
            style={{
              margin: '0 0 16px',
              fontSize: '13px',
              lineHeight: 1.6,
              color: 'var(--text-secondary, #56605B)'
            }}
          >
            Le module n'a pas pu s'afficher. Les donnees restent intactes : rechargez
            la page pour reprendre.
          </p>

          <pre
            style={{
              margin: '0 0 20px',
              padding: '12px',
              background: 'var(--bg-subtle, #F2F5F4)',
              border: '1px solid var(--border, #DADDDD)',
              borderRadius: '8px',
              fontSize: '11px',
              color: 'var(--text-secondary, #56605B)',
              whiteSpace: 'pre-wrap',
              wordBreak: 'break-word',
              maxHeight: '160px',
              overflow: 'auto'
            }}
          >
            {String(this.state.error?.message || this.state.error)}
          </pre>

          <button
            onClick={() => window.location.reload()}
            style={{
              background: 'var(--primary, #14583D)',
              color: '#FFFFFF',
              border: 'none',
              borderRadius: '12px',
              padding: '12px 20px',
              fontSize: '13px',
              fontWeight: 700,
              cursor: 'pointer'
            }}
          >
            Recharger la console
          </button>
        </div>
      </div>
    );
  }
}
