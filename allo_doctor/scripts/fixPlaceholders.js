const fs = require('fs');

// Fix profile_edit_widget.dart - replace Adam hints
let f1 = fs.readFileSync('lib/patient/profile_edit/profile_edit_widget.dart', 'utf8');
f1 = f1.split("'Ex : Adam Koutou'").join("'Ex: BITODI Cornelca Cora'");
f1 = f1.split("'Ex: Adam'").join("'Ex: Cora'");
fs.writeFileSync('lib/patient/profile_edit/profile_edit_widget.dart', f1, 'utf8');
console.log('Fixed profile_edit_widget.dart');

// Fix sign_up_widget.dart - replace Adam Mouele hint
let f2 = fs.readFileSync('lib/connect/sign_up/sign_up_widget.dart', 'utf8');
f2 = f2.split("'Ex: Adam Mouele'").join("'Ex: BITODI Cornelca Cora'");
fs.writeFileSync('lib/connect/sign_up/sign_up_widget.dart', f2, 'utf8');
console.log('Fixed sign_up_widget.dart');

// Fix transaction_card_widget - Adam Koutou
let f3 = fs.readFileSync('lib/components/transaction_card_widget.dart', 'utf8');
f3 = f3.split("'Adam Koutou'").join("'BITODI Cornelca Cora'");
fs.writeFileSync('lib/components/transaction_card_widget.dart', f3, 'utf8');
console.log('Fixed transaction_card_widget.dart');
