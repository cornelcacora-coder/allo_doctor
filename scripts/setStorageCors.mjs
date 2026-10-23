import { initializeApp, cert } from 'firebase-admin/app';
import { getStorage } from 'firebase-admin/storage';
import { readFileSync, existsSync } from 'fs';
import { resolve, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));

const keyPath = resolve(__dirname, '../firebase/serviceAccountKey.json');
if (!existsSync(keyPath)) {
  console.error('Service account key not found at', keyPath);
  process.exit(1);
}

const serviceAccount = JSON.parse(readFileSync(keyPath, 'utf8'));

// Try both possible bucket names: allo-doctor-app.firebasestorage.app and allo-doctor-app.appspot.com
const bucketNames = [
  'allo-doctor-app.firebasestorage.app',
  'allo-doctor-app.appspot.com'
];

const corsConfiguration = [
  {
    origin: ['*'],
    method: ['GET', 'POST', 'PUT', 'DELETE', 'HEAD', 'OPTIONS'],
    responseHeader: [
      'Content-Type',
      'Authorization',
      'Content-Length',
      'User-Agent',
      'x-goog-resumable',
      'x-firebase-storage-version'
    ],
    maxAgeSeconds: 3600
  }
];

async function run() {
  initializeApp({
    credential: cert(serviceAccount)
  });

  const storage = getStorage();

  for (const bName of bucketNames) {
    try {
      console.log(`Setting CORS for bucket: ${bName}...`);
      const bucket = storage.bucket(bName);
      await bucket.setCorsConfiguration(corsConfiguration);
      console.log(`✅ CORS successfully set for ${bName}!`);
      const [cors] = await bucket.getCorsConfiguration();
      console.log('Current CORS config:', JSON.stringify(cors, null, 2));
    } catch (err) {
      console.warn(`⚠️ Warning for ${bName}:`, err.message);
    }
  }
}

run().catch(console.error);
