/**
 * Diagnostic complet de l'envoi d'emails Firebase Auth.
 *
 *   node scripts/diagnoseEmails.mjs [adresse@exemple.com]
 *
 * Verifie : configuration des templates, quota, et effectue un envoi reel
 * en affichant le code HTTP et les en-tetes de reponse (indices de quota).
 */
import { readFileSync } from 'node:fs';
import { homedir } from 'node:os';
import { join } from 'node:path';

const PROJECT = 'allo-doctor-app';
const API_KEY = process.env.FIREBASE_API_KEY || 'AIzaSyAxBbMaDvSkEYv6bsIgwisfRTB1KRhbABQ';
const TARGET = process.argv[2] || 'testnetdeveloper61@gmail.com';

const cfg = JSON.parse(
  readFileSync(join(homedir(), '.config', 'configstore', 'firebase-tools.json'), 'utf8'),
);
const tok = await fetch('https://oauth2.googleapis.com/token', {
  method: 'POST',
  headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
  body: new URLSearchParams({
    client_id:
      process.env.FIREBASE_CLIENT_ID ||
      '563584335869-fgrhgmd47bqnekij5i8b5pr03ho849e6.apps.googleusercontent.com',
    client_secret: process.env.FIREBASE_CLIENT_SECRET || 'j9iVZfS8kkCEFUPaAeJV0sAi',
    refresh_token: cfg.tokens.refresh_token,
    grant_type: 'refresh_token',
    scope: 'https://www.googleapis.com/auth/cloud-platform',
  }),
}).then((r) => r.json());

console.log('🔍 Diagnostic des e-mails Firebase Auth');
console.log(`   projet : ${PROJECT}`);
console.log(`   cible  : ${TARGET}\n`);

// 1. Configuration
const configRes = await fetch(
  `https://identitytoolkit.googleapis.com/admin/v2/projects/${PROJECT}/config`,
  { headers: { Authorization: `Bearer ${tok.access_token}` } },
);
const config = await configRes.json();
const se = config.notification?.sendEmail ?? {};

console.log('1. Configuration');
console.log(`   locale            : ${config.notification?.defaultLocale}`);
console.log(`   methode d'envoi   : ${se.method}`);
console.log(`   domaine personnalise: ${se.dnsInfo?.customDomainState}`);
console.log(`   URL d'action      : ${se.callbackUri}`);
for (const t of ['verifyEmailTemplate', 'resetPasswordTemplate', 'changeEmailTemplate']) {
  const v = se[t] ?? {};
  console.log(
    `   ${t.padEnd(22)} expediteur=${v.senderLocalPart} replyTo=${v.replyTo} corps=${(v.body || '').length}car`,
  );
}

// 2. Envoi reel
console.log('\n2. Envoi reel d\'un e-mail de verification');
const email = `diag.${Date.now()}@allo-doctor.example`;
const signUp = await fetch(
  `https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${API_KEY}`,
  {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ email, password: 'Test-123456', returnSecureToken: true }),
  },
);
if (!signUp.ok) {
  console.log(`   ✗ creation du compte : HTTP ${signUp.status}`);
  console.log('   ' + (await signUp.text()).replace(/\s+/g, ' ').slice(0, 300));
} else {
  const su = await signUp.json();
  console.log(`   ✓ compte de test cree (${su.localId})`);

  const send = await fetch(
    `https://identitytoolkit.googleapis.com/v1/accounts:sendOobCode?key=${API_KEY}`,
    {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        requestType: 'VERIFY_EMAIL',
        idToken: su.idToken,
        email,
      }),
    },
  );
  const body = await send.text();
  console.log(`   → HTTP ${send.status} ${send.status === 200 ? '(envoi accepte par Firebase)' : ''}`);
  if (send.status !== 200) {
    console.log('   ' + body.replace(/\s+/g, ' ').slice(0, 300));
  }
  const interesting = ['x-ratelimit', 'retry-after', 'x-goog-', 'quota'];
  for (const [k, v] of send.headers) {
    if (interesting.some((p) => k.toLowerCase().includes(p))) {
      console.log(`   ↳ ${k}: ${v}`);
    }
  }
  console.log(
    `   ↳ expéditeur effectif : noreply@${PROJECT}.firebaseapp.com`,
  );
  console.log(
    `   ↳ si HTTP 200 mais aucun e-mail reçu : vérifier le dossier SPAM / QUOTAS,\n     et sur le plan gratuit (Spark) le quota d'e-mails est de 500/jour (100/jour pour les liens de connexion).`,
  );
}

console.log('\n3. A faire');
console.log(`   - envoyer un e-mail de test a : ${TARGET}`);
console.log('   - verifier le dossier SPAM / "Promotions"');
console.log('   - console Firebase > Authentication > Settings > Usage : quota du jour');
process.exit(0);
