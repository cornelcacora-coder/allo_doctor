/**
 * Normalisation des documents Firestore avant affichage.
 *
 * Deux sources de donnees coexistent :
 *  - la console web (seed) : champs en anglais (name, specialty, city...)
 *  - l'application mobile Flutter : champs en francais (nom, ville, telephone...)
 *
 * On accepte les deux et on garantit la presence de tous les champs attendus
 * par l'interface, afin qu'aucun filtre ne puisse lever d'exception.
 */
import { safeText, firstOf } from './text';

const TYPE_LABELS = {
  medecin: 'Médecin',
  pharmacie: 'Pharmacie',
  clinique: 'Clinique',
};

export const normalizePractitioner = (data = {}, id = '') => {
  const type = safeText(firstOf(data.type, data.category, 'medecin'));
  const name = safeText(
    firstOf(data.name, data.nom, data.fullName, data.displayName, data.praticien),
  );

  return {
    ...data,
    id: id || safeText(data.id),
    name: name || 'Professionnel non renseigné',
    type,
    typeLabel: TYPE_LABELS[type] || safeText(data.typeLabel) || type,
    specialty: safeText(firstOf(data.specialty, data.specialite, data.specialtyName)),
    city: safeText(firstOf(data.city, data.ville)),
    docNumber: safeText(firstOf(data.docNumber, data.numeroOrdre, data.ordre, data.docNumber)),
    phone: safeText(firstOf(data.phone, data.telephone, data.tel)),
    email: safeText(firstOf(data.email, data.mail)),
    address: safeText(firstOf(data.address, data.adresse)),
    date: safeText(firstOf(data.date, data.createdAt, data.registered)),
    documentsCount: Number.isFinite(Number(data.documentsCount))
      ? Number(data.documentsCount)
      : 0,
    status: safeText(firstOf(data.status, 'en_attente')),
    rejectionReason: safeText(firstOf(data.rejectionReason, data.motifRejet)),
  };
};

export const normalizeTicket = (data = {}, id = '') => {
  const requesterId = safeText(firstOf(data.requesterId, data.userId, data.uid));

  return {
    ...data,
    id: id || safeText(firstOf(data.id, data.ticketId)),
    requesterId,
    requesterType: safeText(firstOf(data.requesterType, data.type, data.role)),
    requesterName: safeText(firstOf(data.requesterName, data.name, data.nom)),
    subject: safeText(firstOf(data.subject, data.titre, data.title)),
    category: safeText(firstOf(data.category, data.categorie)),
    priority: safeText(firstOf(data.priority, 'normale')),
    status: safeText(firstOf(data.status, 'ouvert')),
    date: safeText(firstOf(data.date, data.createdAt)),
    isLitige: Boolean(firstOf(data.isLitige, false)),
    disputedAmount: Number.isFinite(Number(data.disputedAmount))
      ? Number(data.disputedAmount)
      : 0,
  };
};

export const normalizeUser = (data = {}, id = '') => {
  const email = safeText(firstOf(data.email, data.mail));
  const name = safeText(firstOf(data.name, data.nom, data.displayName, data.display_name));

  return {
    ...data,
    id: id || safeText(data.id),
    name: name || email || 'Utilisateur',
    email,
    role: safeText(firstOf(data.role, data.userCategory, 'patient')),
    status: safeText(firstOf(data.status, 'actif')),
    registered: safeText(firstOf(data.registered, data.createdAt)),
    city: safeText(firstOf(data.city, data.ville)),
    phone: safeText(firstOf(data.phone, data.telephone, data.tel)),
    emailVerified: Boolean(firstOf(data.emailVerified, data.emailVerifie, false)),
  };
};
