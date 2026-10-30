/**
 * syncClinicsCollection.js
 * 
 * Migre tous les utilisateurs role='clinique' depuis la collection 'users'
 * vers la collection 'clinics', afin qu'ils soient visibles chez les patients.
 * 
 * Usage: node scripts/syncClinicsCollection.js
 */

const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const fs = require('fs');
const path = require('path');

// Chercher la clé de service
const possibleKeyPaths = [
  path.resolve(__dirname, '../firebase/serviceAccountKey.json'),
  path.resolve(__dirname, '../serviceAccountKey.json'),
  path.resolve(__dirname, '../firebase/functions/serviceAccountKey.json'),
];

let serviceAccount = null;
for (const keyPath of possibleKeyPaths) {
  if (fs.existsSync(keyPath)) {
    serviceAccount = JSON.parse(fs.readFileSync(keyPath, 'utf8'));
    console.log('✅ Clé trouvée:', keyPath);
    break;
  }
}

if (!serviceAccount) {
  console.error('❌ serviceAccountKey.json introuvable!');
  console.error('   Chemins vérifiés:', possibleKeyPaths);
  process.exit(1);
}

initializeApp({
  credential: cert(serviceAccount),
});

const db = getFirestore();

async function syncClinics() {
  console.log('\n🏥 Synchronisation de la collection "clinics"...\n');

  // 1. Chercher dans 'users' tous les comptes clinique
  const usersSnap = await db.collection('users')
    .where('role', '==', 'clinique')
    .get();

  // 2. Chercher aussi dans 'users' par userCategory
  const usersCatSnap = await db.collection('users')
    .where('userCategory', '==', 'clinique')
    .get();

  // Fusionner sans doublons
  const docsMap = new Map();
  for (const doc of [...usersSnap.docs, ...usersCatSnap.docs]) {
    docsMap.set(doc.id, doc);
  }

  console.log(`📋 ${docsMap.size} compte(s) clinique trouvé(s) dans 'users'\n`);

  if (docsMap.size === 0) {
    console.log('⚠️  Aucun utilisateur avec role=clinique trouvé.');
    console.log('    Vérifiez que la clinique est bien enregistrée avec role="clinique"');
    
    // Afficher tous les rôles disponibles pour debug
    const allUsers = await db.collection('users').limit(20).get();
    console.log('\n📊 Rôles existants dans users:');
    allUsers.docs.forEach(d => {
      const data = d.data();
      console.log(`  - ${d.id.substring(0,8)}... | role: ${data.role || 'N/A'} | userCategory: ${data.userCategory || 'N/A'} | display_name: ${data.display_name || data.displayName || 'N/A'}`);
    });
    process.exit(0);
  }

  const batch = db.batch();
  let count = 0;

  for (const [uid, userDoc] of docsMap) {
    const userData = userDoc.data();

    // Chercher aussi dans practitioners pour les infos supplémentaires
    let practData = {};
    try {
      const practSnap = await db.collection('practitioners').doc(uid).get();
      if (practSnap.exists) practData = practSnap.data();
    } catch (e) {
      // Pas de doc practitioners, ce n'est pas grave
    }

    const name = (
      userData['display_name'] ||
      userData['displayName'] ||
      userData['name'] ||
      practData['name'] ||
      'Clinique'
    ).trim();

    const address = (practData['address'] || userData['address'] || '').trim();
    const city = (practData['city'] || userData['city'] || 'Brazzaville').trim();
    const phone = (practData['phone_number'] || userData['phone_number'] || '').trim();
    const photoUrl = (practData['photo_url'] || userData['photo_url'] || '').trim();
    const services = practData['services'] || userData['services'] || [];
    const email = userData['email'] || '';

    const clinicData = {
      name: name || 'Clinique',
      address,
      city,
      phone_number: phone,
      photo_url: photoUrl,
      services,
      uid,
      email,
      updated_at: FieldValue.serverTimestamp(),
    };

    console.log(`  ✅ clinics/${uid}`);
    console.log(`     Nom    : ${clinicData.name}`);
    console.log(`     Ville  : ${clinicData.city}`);
    console.log(`     Tel    : ${clinicData.phone_number || '(non renseigné)'}`);
    console.log(`     Photo  : ${clinicData.photo_url ? '✓' : '(aucune)'}`);
    console.log(`     Services: ${(clinicData.services || []).join(', ') || '(aucun)'}`);
    console.log('');

    batch.set(db.collection('clinics').doc(uid), clinicData, { merge: true });
    count++;
  }

  await batch.commit();
  console.log(`\n🎉 ${count} clinique(s) synchronisée(s) dans la collection "clinics"`);
  console.log('   Les patients peuvent maintenant voir les cliniques dans l\'app.\n');
}

syncClinics().catch(err => {
  console.error('❌ Erreur:', err.message);
  process.exit(1);
});
