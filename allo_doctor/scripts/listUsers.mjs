/**
 * Script pour lister tous les utilisateurs Firebase Authentication
 * Usage: node scripts/listUsers.mjs
 */
import { initializeApp, cert } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { readFileSync, existsSync } from 'fs';
import { resolve, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));

// Chercher le fichier de clé de service
const possibleKeyPaths = [
  resolve(__dirname, '../firebase/serviceAccountKey.json'),
  resolve(__dirname, '../serviceAccountKey.json'),
  resolve(__dirname, '../firebase/functions/serviceAccountKey.json'),
];

let serviceAccount = null;
for (const keyPath of possibleKeyPaths) {
  if (existsSync(keyPath)) {
    serviceAccount = JSON.parse(readFileSync(keyPath, 'utf8'));
    console.log(`✅ Clé trouvée: ${keyPath}`);
    break;
  }
}

if (!serviceAccount) {
  console.error('❌ Fichier serviceAccountKey.json introuvable!');
  console.error('📥 Téléchargez-le depuis Firebase Console:');
  console.error('   Paramètres du projet → Comptes de service → Générer une nouvelle clé privée');
  console.error('   Puis placez-le dans: firebase/serviceAccountKey.json');
  process.exit(1);
}

initializeApp({ credential: cert(serviceAccount) });
const auth = getAuth();

async function listAllUsers() {
  console.log('\n📋 Liste de tous les utilisateurs Firebase Auth:\n');
  console.log('─'.repeat(80));

  let pageToken;
  let totalUsers = 0;
  const users = [];

  do {
    const result = await auth.listUsers(1000, pageToken);
    result.users.forEach((user) => {
      users.push(user);
      totalUsers++;
      console.log(`Email: ${user.email || '(sans email)'}`);
      console.log(`  UID: ${user.uid}`);
      console.log(`  DisplayName: ${user.displayName || '(aucun)'}`);
      console.log(`  Créé: ${new Date(user.metadata.creationTime).toLocaleString('fr-FR')}`);
      console.log(`  Dernière connexion: ${user.metadata.lastSignInTime ? new Date(user.metadata.lastSignInTime).toLocaleString('fr-FR') : 'jamais'}`);
      console.log('─'.repeat(80));
    });
    pageToken = result.pageToken;
  } while (pageToken);

  console.log(`\n✅ Total: ${totalUsers} utilisateur(s) trouvé(s)`);
  console.log('\n💡 Pour supprimer tous sauf l\'admin, lancez:');
  console.log('   node scripts/cleanUsers.mjs <email_admin_a_garder>');
}

listAllUsers().catch(console.error);
