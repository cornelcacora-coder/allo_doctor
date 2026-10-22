/**
 * Script pour supprimer tous les comptes Firebase Auth sauf l'admin
 * Version non-interactive pour exécution automatique
 */
import { initializeApp, cert } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';
import { readFileSync, existsSync } from 'fs';
import { resolve, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));

const adminEmail = process.argv[2];
if (!adminEmail) {
  console.error('❌ Usage: node scripts/cleanUsers.mjs <email_admin>');
  process.exit(1);
}

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
  process.exit(1);
}

initializeApp({ credential: cert(serviceAccount) });
const auth = getAuth();
const db = getFirestore();

async function cleanUsers() {
  console.log(`\n🔍 Recherche de tous les comptes Firebase Auth...`);
  console.log(`✅ Compte à GARDER: ${adminEmail}\n`);

  let pageToken;
  const toDelete = [];
  let adminUser = null;

  do {
    const result = await auth.listUsers(1000, pageToken);
    result.users.forEach((user) => {
      if (user.email?.toLowerCase() === adminEmail.toLowerCase()) {
        adminUser = user;
        console.log(`✅ Admin trouvé: ${user.email} (UID: ${user.uid})`);
      } else {
        toDelete.push(user);
        console.log(`🗑️  À supprimer: ${user.email || '(sans email)'} (UID: ${user.uid})`);
      }
    });
    pageToken = result.pageToken;
  } while (pageToken);

  if (!adminUser) {
    console.warn(`\n⚠️  ATTENTION: Le compte admin "${adminEmail}" n'existe PAS dans Firebase Auth!`);
    return;
  }

  if (toDelete.length === 0) {
    console.log('\n✅ Aucun compte à supprimer - seulement l\'admin existe déjà!');
    return;
  }

  console.log(`\n🗑️  Suppression de ${toDelete.length} compte(s) Firebase Auth...`);

  const uids = toDelete.map(u => u.uid);
  for (let i = 0; i < uids.length; i += 1000) {
    const batch = uids.slice(i, i + 1000);
    const result = await auth.deleteUsers(batch);
    console.log(`   ✅ ${result.successCount} comptes Auth supprimés`);
    if (result.failureCount > 0) {
      console.log(`   ❌ ${result.failureCount} échecs`);
      result.errors.forEach(e => console.log(`      - UID ${e.index}: ${e.error.message}`));
    }
  }

  // Supprimer aussi les documents Firestore correspondants
  console.log('\n🗑️  Nettoyage Firestore (users / practitioners)...');
  for (const user of toDelete) {
    try {
      await db.collection('users').doc(user.uid).delete();
      await db.collection('practitioners').doc(user.uid).delete();
      console.log(`   ✅ Firestore nettoyé pour: ${user.email || user.uid}`);
    } catch (e) {
      console.log(`   ⚠️  Erreur Firestore pour ${user.uid}: ${e.message}`);
    }
  }

  console.log('\n🎉 Nettoyage terminé!');
  console.log(`✅ Seul le compte admin "${adminEmail}" reste dans Firebase Auth.`);
}

cleanUsers().catch(console.error);
