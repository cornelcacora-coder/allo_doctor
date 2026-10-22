/**
 * Applique / verifie les templates d'emails Firebase Auth d'Allo Docteur.
 *
 *   node scripts/applyEmailTemplates.mjs            # applique
 *   node scripts/applyEmailTemplates.mjs --dry-run  # affiche sans ecrire
 *   node scripts/checkEmailTemplates.mjs            # etat courant (lecture)
 *
 * Auth : reutilise le refresh token du CLI Firebase (firebase login).
 * Templates HTML : ./emails/*.html
 *
 * NOTE IMPORTANTE
 * Sur le plan gratuit (Spark / "billingEnabled: false"), l'API Identity
 * Toolkit applique des restrictions sur les templates :
 *   - notification.defaultLocale              -> OK   (langue des templates)
 *   - ...verifyEmailTemplate.replyTo          -> OK
 *   - ...verifyEmailTemplate.senderLocalPart  -> OK
 *   - ...verifyEmailTemplate.body             -> ecriture silencieusement
 *                                                ignoree (HTTP 200 sans effet)
 *   - ...resetPasswordTemplate.body           -> HTTP 400
 *                                                EMAIL_TEMPLATE_UPDATE_NOT_ALLOWED
 *   - ...<template>.subject                   -> HTTP 400
 *                                                EMAIL_TEMPLATE_UPDATE_NOT_ALLOWED
 * Le corps de marque et les sujets personnalises necessitent donc le plan
 * Blaze (ou une saisie manuelle dans la console Firebase).
 */
import { readFileSync, existsSync } from 'node:fs';
import { homedir } from 'node:os';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const ROOT = join(__dirname, '..');

export const PROJECT_ID = process.env.FIREBASE_PROJECT_ID || 'allo-doctor-app';
// Adresse de reponse. ATTENTION : doit pointer vers une boite reellement
// hebergee (enregistrement MX) - un Reply-To vers un domaine sans MX est
// un signal de spam majeur et les messages sont alors rejetes.
export const REPLY_TO =
  process.env.FIREBASE_REPLY_TO || 'testnetdeveloper61@gmail.com';
// Sur le service d'envoi par defaut (method: DEFAULT, sans domaine SMTP
// personnalise), l'expediteur DOIT rester "noreply" : une autre partie
// locale est acceptee par l'API mais les messages ne sont plus distribues.
export const SENDER_LOCAL_PART = process.env.FIREBASE_SENDER || 'noreply';
const DEFAULT_LOCALE = 'fr';

const API = `https://identitytoolkit.googleapis.com/admin/v2/projects/${PROJECT_ID}/config`;

export const TEMPLATES = [
  {
    apiField: 'verifyEmailTemplate',
    file: 'verification-email.html',
    subject: 'Vérifiez votre adresse e-mail - Allo Docteur',
  },
  {
    apiField: 'resetPasswordTemplate',
    file: 'reset-password-email.html',
    subject: 'Réinitialisez votre mot de passe - Allo Docteur',
  },
  {
    apiField: 'changeEmailTemplate',
    file: 'change-email-email.html',
    subject: 'Votre adresse e-mail a été modifiée - Allo Docteur',
  },
];

/** Emplacement du fichier de configuration du CLI Firebase (configstore). */
function cliConfigPaths() {
  const home = homedir();
  const xdg = process.env.XDG_CONFIG_HOME || join(home, '.config');
  return [
    join(xdg, 'configstore', 'firebase-tools.json'),
    join(process.env.APPDATA || '', 'configstore', 'firebase-tools.json'),
    join(process.env.LOCALAPPDATA || '', 'configstore', 'firebase-tools.json'),
  ];
}

export function readCliRefreshToken() {
  for (const path of cliConfigPaths()) {
    if (!existsSync(path)) continue;
    try {
      const cfg = JSON.parse(readFileSync(path, 'utf8'));
      if (cfg?.tokens?.refresh_token) {
        return { token: cfg.tokens.refresh_token, user: cfg?.user?.email };
      }
    } catch {
      /* fichier illisible, on essaie le suivant */
    }
  }
  throw new Error(
    'Refresh token Firebase CLI introuvable.\n' +
      "Connecte-toi d'abord avec :  firebase login",
  );
}

export async function getAccessToken() {
  const { token, user } = readCliRefreshToken();
  const res = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      client_id:
        process.env.FIREBASE_CLIENT_ID ||
        '563584335869-fgrhgmd47bqnekij5i8b5pr03ho849e6.apps.googleusercontent.com',
      client_secret:
        process.env.FIREBASE_CLIENT_SECRET || 'j9iVZfS8kkCEFUPaAeJV0sAi',
      refresh_token: token,
      grant_type: 'refresh_token',
      scope:
        'https://www.googleapis.com/auth/firebase ' +
        'https://www.googleapis.com/auth/cloud-platform',
    }),
  });
  if (!res.ok) throw new Error(`Echange du refresh token impossible (HTTP ${res.status})`);
  const json = await res.json();
  return { accessToken: json.access_token, user };
}

/**
 * PATCH avec un updateMask feuille (obligatoire : sans masque l'API tente une
 * mise a jour complete et refuse tout avec EMAIL_TEMPLATE_UPDATE_NOT_ALLOWED).
 */
export async function patchField(accessToken, mask, body) {
  const res = await fetch(`${API}?updateMask=${encodeURIComponent(mask)}`, {
    method: 'PATCH',
    headers: {
      Authorization: `Bearer ${accessToken}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(body),
  });
  const text = await res.text();
  if (!res.ok) {
    const err = new Error(`HTTP ${res.status} sur [${mask}]`);
    err.payload = text;
    throw err;
  }
  return text ? JSON.parse(text) : {};
}

export async function getConfig(accessToken) {
  const res = await fetch(API, {
    headers: { Authorization: `Bearer ${accessToken}` },
  });
  if (!res.ok) throw new Error(`Lecture de la config impossible (HTTP ${res.status})`);
  return res.json();
}

export function readTemplateBody(file) {
  const path = join(ROOT, 'emails', file);
  if (!existsSync(path)) throw new Error(`Template introuvable : ${path}`);
  const body = readFileSync(path, 'utf8');
  if (!body.includes('%LINK%')) {
    throw new Error(`${file} : le placeholder %LINK% est introuvable.`);
  }
  return body;
}

export function templateState(config) {
  const sendEmail = config?.notification?.sendEmail ?? {};
  return TEMPLATES.map((t) => {
    const v = sendEmail[t.apiField] ?? {};
    return {
      ...t,
      subject: v.subject ?? '',
      replyTo: v.replyTo ?? '',
      sender: v.senderLocalPart ?? '',
      branded: Boolean(v.body?.includes('Allo Docteur')),
      bodyLength: (v.body ?? '').length,
    };
  });
}

/* ------------------------------------------------------------------ */
/* Execution directe :                                                 */
/* ------------------------------------------------------------------ */
if (process.argv[1] && import.meta.url.endsWith(process.argv[1].split(/[\\/]/).pop())) {
  const DRY_RUN = process.argv.includes('--dry-run');

  async function main() {
    console.log(`Projet : ${PROJECT_ID}`);
    console.log(`Mode   : ${DRY_RUN ? 'DRY-RUN (aucune ecriture)' : 'APPLICATION'}`);

    if (DRY_RUN) {
      for (const t of TEMPLATES) {
        const body = readTemplateBody(t.file);
        console.log(
          `  ${t.apiField.padEnd(24)} ${t.file} (${body.length} car) sujet="${t.subject}"`,
        );
      }
      return;
    }

    const { accessToken, user } = await getAccessToken();
    console.log(`Authentifie en tant que ${user}`);

    // 1. Langue des templates
    await patchField(accessToken, 'notification.defaultLocale', {
      notification: { defaultLocale: DEFAULT_LOCALE },
    });
    console.log(`  OK  notification.defaultLocale = ${DEFAULT_LOCALE}`);

    const blocked = [];

    for (const t of TEMPLATES) {
      // 2. Reponse a + expéditeur (autorises sur tous les plans)
      for (const [field, value] of [
        ['replyTo', REPLY_TO],
        ['senderLocalPart', SENDER_LOCAL_PART],
      ]) {
        try {
          await patchField(accessToken, `notification.sendEmail.${t.apiField}.${field}`, {
            notification: { sendEmail: { [t.apiField]: { [field]: value } } },
          });
          console.log(`  OK  ${t.apiField}.${field} = ${value}`);
        } catch (e) {
          blocked.push(`${t.apiField}.${field} : ${e.payload?.slice(0, 120) ?? e.message}`);
        }
      }

      // 3. Corps de marque + sujet personnalise (exige le plan Blaze)
      const body = readTemplateBody(t.file);
      try {
        await patchField(accessToken, `notification.sendEmail.${t.apiField}.body`, {
          notification: { sendEmail: { [t.apiField]: { body } } },
        });
        // Sur le plan gratuit l'API renvoie 200 sans rien ecrire : on relit
        // la config pour le constater.
        const check = await getConfig(accessToken);
        const stored = check?.notification?.sendEmail?.[t.apiField]?.body ?? '';
        if (stored.includes('Allo Docteur')) {
          console.log(`  OK  ${t.apiField}.body (corps de marque applique)`);
        } else {
          console.log(`  --  ${t.apiField}.body IGNORE (plan gratuit)`);
          blocked.push(
            `${t.apiField}.body : ecriture acceptee (HTTP 200) mais ignoree par le plan gratuit`,
          );
        }
      } catch (e) {
        console.log(`  --  ${t.apiField}.body REFUSE (plan gratuit)`);
        blocked.push(`${t.apiField}.body : ${e.payload?.slice(0, 120) ?? e.message}`);
      }
      try {
        await patchField(accessToken, `notification.sendEmail.${t.apiField}.subject`, {
          notification: { sendEmail: { [t.apiField]: { subject: t.subject } } },
        });
        console.log(`  OK  ${t.apiField}.subject`);
      } catch (e) {
        console.log(`  --  ${t.apiField}.subject REFUSE (plan gratuit)`);
        blocked.push(`${t.apiField}.subject : ${e.payload?.slice(0, 120) ?? e.message}`);
      }
    }

    // 4. Verification
    const config = await getConfig(accessToken);
    console.log('\nEtat final :');
    for (const s of templateState(config)) {
      console.log(
        `  ${s.apiField.padEnd(24)} sujet="${s.subject}"  ` +
          `replyTo=${s.replyTo}  expéditeur=${s.sender}  ` +
          `corps=${s.branded ? 'DE MARQUE' : 'standard FR'}`,
      );
    }
    console.log(`  locale = ${config?.notification?.defaultLocale}`);

    if (blocked.length) {
      console.log(
        '\nBloques par le plan gratuit (Spark) :\n  ' +
          blocked.join('\n  ') +
          '\n\nPour les debloquer : activer le plan Blaze (pay-as-you-go) dans la\n' +
          'console Firebase, puis relancer :  npm run emails:apply',
      );
    }
  }

  main().catch((err) => {
    console.error(`\nERREUR : ${err.message}`);
    process.exit(1);
  });
}
