/**
 * Affiche l'etat courant des templates d'emails Firebase Auth
 * (lecture seule, aucune ecriture).
 *
 *   node scripts/checkEmailTemplates.mjs
 */
import { getAccessToken, getConfig, templateState } from './applyEmailTemplates.mjs';

const { accessToken, user } = await getAccessToken();
const config = await getConfig(accessToken);

console.log(`Projet : ${config.name}`);
console.log(`Auth   : ${user}`);
console.log(`Locale : ${config?.notification?.defaultLocale}`);
console.log(`Action : ${config?.notification?.sendEmail?.callbackUri}`);
console.log(`Domaines autorises : ${(config?.authorizedDomains ?? []).join(', ')}`);
console.log('');

for (const s of templateState(config)) {
  console.log(`${s.apiField}`);
  console.log(`  sujet      : ${s.subject}`);
  console.log(`  reponse a  : ${s.replyTo}`);
  console.log(`  expediteur : ${s.sender}`);
  console.log(`  corps      : ${s.branded ? 'DE MARQUE (HTML personnalise)' : 'standard localise'} (${s.bodyLength} car)`);
  console.log('');
}
