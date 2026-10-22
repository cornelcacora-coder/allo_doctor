/**
 * Helpers de manipulation de texte robustes.
 *
 * Les documents Firestore ne garantissent pas la presence de tous les
 * champs : un `.toLowerCase()` sur un champ absent leve une TypeError qui
 * fait tomber toute l'application (page blanche).
 */

/** Convertit n'importe quelle valeur en chaine sure (jamais undefined). */
export const safeText = (value) => {
  if (value === null || value === undefined) return '';
  if (typeof value === 'string') return value;
  if (typeof value === 'number' || typeof value === 'boolean') return String(value);
  if (value instanceof Date) return value.toLocaleDateString('fr-FR');
  // Timestamp Firestore (expose un toDate())
  if (typeof value === 'object' && typeof value.toDate === 'function') {
    try {
      return value.toDate().toLocaleDateString('fr-FR');
    } catch {
      return '';
    }
  }
  if (Array.isArray(value)) return value.map(safeText).join(' ');
  if (typeof value === 'object') {
    try {
      return JSON.stringify(value);
    } catch {
      return '';
    }
  }
  return String(value);
};

/** Minuscule sur une valeur sure, pour les recherches. */
export const safeLower = (value) => safeText(value).toLowerCase();

/** Premiere valeur non vide dans la liste. */
export const firstOf = (...values) => {
  for (const v of values) {
    if (v !== null && v !== undefined && safeText(v).trim() !== '') return v;
  }
  return undefined;
};
