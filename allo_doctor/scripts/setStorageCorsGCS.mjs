import fs from 'fs';
import path from 'path';

const configPath = path.join(process.env.USERPROFILE, '.config', 'configstore', 'firebase-tools.json');
const cfg = JSON.parse(fs.readFileSync(configPath, 'utf8'));
const token = cfg.tokens.access_token;

async function checkAndApplyCors() {
  console.log('🔍 Recherche des buckets pour le projet allo-doctor-app...');
  
  // 1. Interroger l'API Firebase Project pour trouver le bucket par défaut
  let defaultBucket = null;
  try {
    const projRes = await fetch('https://firebase.googleapis.com/v1beta1/projects/allo-doctor-app', {
      headers: { 'Authorization': `Bearer ${token}` }
    });
    const projData = await projRes.json();
    defaultBucket = projData?.resources?.storageBucket;
    if (defaultBucket) {
      console.log(`✅ Bucket trouvé dans la configuration Firebase : ${defaultBucket}`);
    }
  } catch (e) {
    console.warn('Impossible de récupérer le projet via l\'API :', e.message);
  }

  const buckets = defaultBucket 
    ? [defaultBucket] 
    : ['allo-doctor-app.firebasestorage.app', 'allo-doctor-app.appspot.com'];

  for (const b of buckets) {
    console.log(`\n⏳ Configuration des règles CORS sur le bucket : ${b}...`);
    const url = `https://storage.googleapis.com/storage/v1/b/${encodeURIComponent(b)}?fields=cors`;
    const res = await fetch(url, {
      method: 'PATCH',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        cors: [
          {
            origin: ['*'],
            method: ['GET', 'POST', 'PUT', 'DELETE', 'HEAD', 'OPTIONS'],
            responseHeader: ['*'],
            maxAgeSeconds: 3600
          }
        ]
      })
    });
    
    const data = await res.json();
    if (res.ok) {
      console.log(`🎉 CORS configuré avec succès pour ${b} !`);
    } else {
      console.log(`❌ Erreur (${res.status}) sur ${b} :`, data.error?.message || data);
    }
  }
}

checkAndApplyCors().catch(console.error);
