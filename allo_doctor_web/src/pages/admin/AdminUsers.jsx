import React, { useState } from 'react';
import { Users, Search } from 'lucide-react';
import { safeLower } from '../../utils/text';

export const AdminUsers = ({ usersList, onToggleUserStatus, onChangeUserRole }) => {
  const [userSearch, setUserSearch] = useState('');

  const filteredUsers = usersList.filter(u => {
    const needle = safeLower(userSearch);
    return safeLower(u.name).includes(needle) ||
      safeLower(u.role).includes(needle) ||
      safeLower(u.email).includes(needle);
  });

  return (
    <div className="card" style={{ margin: 0 }}>
      <div className="card-header" style={{ flexWrap: 'wrap', gap: '12px' }}>
        <div>
          <h3 className="card-title" style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <Users size={20} color="#14583D" />
            Gestion des Utilisateurs de la Plateforme Allo Doctor
          </h3>
          <p style={{ fontSize: '11px', color: '#56605B', marginTop: '2px' }}>
            Contrôle des comptes, activation et suspension des accès patients et praticiens.
          </p>
        </div>

        <div style={{ display: 'flex', alignItems: 'center', background: '#F2F5F4', borderRadius: '8px', padding: '6px 12px', gap: '6px' }}>
          <Search size={14} color="#9CA3AF" />
          <input 
            type="text" 
            placeholder="Filtrer par nom, email ou rôle..." 
            value={userSearch}
            onChange={(e) => setUserSearch(e.target.value)}
            style={{ border: 'none', background: 'transparent', outline: 'none', fontSize: '12px', width: '200px' }}
          />
        </div>
      </div>

      <div className="card-body">
        <div className="custom-table-container">
          <table className="custom-table">
            <thead>
              <tr>
                <th>Utilisateur</th>
                <th>Email officiel</th>
                <th>Rôle / Catégorie</th>
                <th>Date d'inscription</th>
                <th>Statut du compte</th>
                <th style={{ textAlign: 'right' }}>Action</th>
              </tr>
            </thead>
            <tbody>
              {filteredUsers.length === 0 ? (
                <tr>
                  <td colSpan="6" style={{ textAlign: 'center', padding: '40px 20px', color: '#56605B' }}>
                    Aucun utilisateur enregistré pour le moment. Les comptes s'afficheront ici en direct dès leur inscription sur l'application mobile.
                  </td>
                </tr>
              ) : (
                filteredUsers.map(u => (
                  <tr key={u.id}>
                    <td><strong>{u.name}</strong></td>
                    <td><code>{u.email}</code></td>
                    <td>
                      <select
                        value={u.role}
                        onChange={(e) => onChangeUserRole(u.id, e.target.value)}
                        style={{
                          border: '1px solid var(--border, #DADDDD)',
                          borderRadius: '8px',
                          padding: '4px 8px',
                          fontSize: '11px',
                          fontWeight: 700,
                          background: 'var(--bg-surface, #FFFFFF)',
                          color: 'var(--text-primary, #1A1C1B)',
                          cursor: 'pointer'
                        }}
                      >
                        <option value="patient">Patient</option>
                        <option value="medecin">Médecin</option>
                        <option value="pharmacie">Pharmacie</option>
                        <option value="clinique">Clinique</option>
                      </select>
                    </td>
                    <td>{u.registered}</td>
                    <td>
                      <span className={`badge ${u.status === 'actif' ? 'badge-success' : 'badge-danger'}`}>
                        {u.status === 'actif' ? '✓ Actif' : '✕ Suspendu'}
                      </span>
                    </td>
                    <td style={{ textAlign: 'right' }}>
                      <button
                        className={`btn ${u.status === 'actif' ? 'btn-danger' : 'btn-primary'}`}
                        onClick={() => onToggleUserStatus(u.id)}
                        style={{ padding: '4px 12px', fontSize: '11px' }}
                      >
                        {u.status === 'actif' ? 'Suspendre' : 'Réactiver'}
                      </button>
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};
