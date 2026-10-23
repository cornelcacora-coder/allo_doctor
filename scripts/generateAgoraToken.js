const { RtcTokenBuilder, RtcRole } = require('agora-token');

const appId = '1b57338080574e3ba72e5cb091a8cb45';
const appCertificate = '8c8f482b2b9949c79d918e5e012e9127';
const channelName = 'allo_doctor_channel';
const uid = 0; // 0 permet d'accepter n'importe quel uid ou uid 0
const role = RtcRole.PUBLISHER;
const expirationTimeInSeconds = 3600 * 24 * 7; // 7 jours
const currentTimestamp = Math.floor(Date.now() / 1000);
const privilegeExpiredTs = currentTimestamp + expirationTimeInSeconds;

const token = RtcTokenBuilder.buildTokenWithUid(
  appId,
  appCertificate,
  channelName,
  uid,
  role,
  tokenExpirationInSeconds = expirationTimeInSeconds,
  privilegeExpiredTs
);

console.log('--- AGORA TOKEN GENERATED ---');
console.log('AppID:', appId);
console.log('Channel:', channelName);
console.log('Token:', token);
