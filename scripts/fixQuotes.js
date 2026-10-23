const fs = require('fs');
const path = require('path');

// 1. Fix profile_user_widget.dart
const profilePath = path.join(__dirname, '..', 'lib', 'patient', 'profile_user', 'profile_user_widget.dart');
let profileContent = fs.readFileSync(profilePath, 'utf8');
profileContent = profileContent.replace(/'Voir l['’]état'/g, `"Voir l'état"`);
profileContent = profileContent.replace(/'Voir l\\'état'/g, `"Voir l'état"`);
fs.writeFileSync(profilePath, profileContent, 'utf8');
console.log('Fixed profile_user_widget.dart');

// 2. Fix carnet_sante_widget.dart
const carnetPath = path.join(__dirname, '..', 'lib', 'patient', 'carnet_sante', 'carnet_sante_widget.dart');
let carnetContent = fs.readFileSync(carnetPath, 'utf8');
carnetContent = carnetContent.replace(/'Suivez en direct l['’]état de vos demandes \(Validé, Reporté, Refusé\)'/g, `"Suivez en direct l'état de vos demandes (Validé, Reporté, Refusé)"`);
carnetContent = carnetContent.replace(/'Suivez en direct l\\'état de vos demandes \(Validé, Reporté, Refusé\)'/g, `"Suivez en direct l'état de vos demandes (Validé, Reporté, Refusé)"`);
// Regex fallback if special characters changed encoding
carnetContent = carnetContent.replace(/Suivez en direct l.*?Refus.*?\)/g, `Suivez en direct l'état de vos demandes (Validé, Reporté, Refusé)`);
fs.writeFileSync(carnetPath, carnetContent, 'utf8');
console.log('Fixed carnet_sante_widget.dart');
