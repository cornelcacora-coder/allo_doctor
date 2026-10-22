import React from 'react';
import { ChevronLeft, ChevronRight } from 'lucide-react';

export const Pagination = ({
  currentPage = 1,
  totalPages = 1,
  totalItems = 0,
  pageSize = 5,
  onPageChange
}) => {
  if (totalPages <= 1 && totalItems <= pageSize) return null;

  const startItem = totalItems === 0 ? 0 : (currentPage - 1) * pageSize + 1;
  const endItem = Math.min(currentPage * pageSize, totalItems);

  // Génération des numéros de pages
  const pageNumbers = [];
  for (let i = 1; i <= totalPages; i++) {
    pageNumbers.push(i);
  }

  return (
    <div style={{
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      padding: '12px 16px',
      borderTop: '1px solid var(--border-light)',
      fontSize: '12px',
      color: 'var(--text-secondary)',
      flexWrap: 'wrap',
      gap: '10px'
    }}>
      <div style={{ fontWeight: 600 }}>
        Affichage de <strong style={{ color: 'var(--text-primary)' }}>{startItem}</strong> à <strong style={{ color: 'var(--text-primary)' }}>{endItem}</strong> sur <strong style={{ color: 'var(--text-primary)' }}>{totalItems}</strong> résultats
      </div>

      <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
        <button
          onClick={() => onPageChange(currentPage - 1)}
          disabled={currentPage <= 1}
          style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            width: '32px',
            height: '32px',
            borderRadius: '8px',
            border: '1px solid var(--border)',
            background: 'var(--bg-surface)',
            color: currentPage <= 1 ? 'var(--text-muted)' : 'var(--text-primary)',
            cursor: currentPage <= 1 ? 'not-allowed' : 'pointer',
            opacity: currentPage <= 1 ? 0.5 : 1,
            transition: 'all 0.15s ease'
          }}
          title="Page précédente"
        >
          <ChevronLeft size={16} />
        </button>

        {pageNumbers.map(num => {
          const isActive = num === currentPage;
          return (
            <button
              key={num}
              onClick={() => onPageChange(num)}
              style={{
                width: '32px',
                height: '32px',
                borderRadius: '8px',
                border: isActive ? 'none' : '1px solid var(--border)',
                background: isActive ? 'var(--primary)' : 'var(--bg-surface)',
                color: isActive ? '#FFFFFF' : 'var(--text-primary)',
                fontWeight: isActive ? 800 : 600,
                fontSize: '12px',
                cursor: 'pointer',
                boxShadow: isActive ? '0 2px 6px rgba(20, 88, 61, 0.25)' : 'none',
                transition: 'all 0.15s ease'
              }}
            >
              {num}
            </button>
          );
        })}

        <button
          onClick={() => onPageChange(currentPage + 1)}
          disabled={currentPage >= totalPages}
          style={{
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            width: '32px',
            height: '32px',
            borderRadius: '8px',
            border: '1px solid var(--border)',
            background: 'var(--bg-surface)',
            color: currentPage >= totalPages ? 'var(--text-muted)' : 'var(--text-primary)',
            cursor: currentPage >= totalPages ? 'not-allowed' : 'pointer',
            opacity: currentPage >= totalPages ? 0.5 : 1,
            transition: 'all 0.15s ease'
          }}
          title="Page suivante"
        >
          <ChevronRight size={16} />
        </button>
      </div>
    </div>
  );
};
