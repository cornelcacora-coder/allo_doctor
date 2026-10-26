const fs = require('fs');

const filePath = 'lib/doctor/dmp/dmp_widget.dart';
let lines = fs.readFileSync(filePath, 'utf8').split('\n');

// Trouver l'index de la ligne contenant 'Conifrmer la Prescription'
let targetIndex = -1;
for (let i = 0; i < lines.length; i++) {
  if (lines[i].includes('Conifrmer la Prescription')) {
    targetIndex = i;
    break;
  }
}

if (targetIndex === -1) {
  console.error('Target not found!');
  process.exit(1);
}

// Remonter pour trouver "child: Container("
let startIndex = -1;
for (let i = targetIndex; i >= 0; i--) {
  if (lines[i].includes('child: Container(')) {
    startIndex = i;
    break;
  }
}

// Descendre pour trouver la fermeture correspondante après Icons.sell_outlined
let endIndex = -1;
for (let i = targetIndex; i < lines.length; i++) {
  if (lines[i].includes('].divide(SizedBox(width: 10.0))')) {
    endIndex = i + 2; // après le Container()
    break;
  }
}

console.log('Replacing from line', startIndex + 1, 'to', endIndex + 1);

const newLines = [
`                                            child: InkWell(`,
`                                              onTap: () async {`,
`                                                await PrescriptionCreationDialog.show(`,
`                                                  context,`,
`                                                  patientUid: 'patient_bitodi_cora',`,
`                                                  patientName: 'BITODI Cornelca Cora',`,
`                                                );`,
`                                              },`,
`                                              borderRadius: BorderRadius.circular(5.0),`,
`                                              child: Container(`,
`                                                width: double.infinity,`,
`                                                height: 38.0,`,
`                                                decoration: BoxDecoration(`,
`                                                  gradient: const LinearGradient(`,
`                                                    colors: [`,
`                                                      Color(0xFF16C583),`,
`                                                      Color(0xFF0F9D58),`,
`                                                    ],`,
`                                                    stops: [0.0, 1.0],`,
`                                                    begin: AlignmentDirectional(1.0, -1.0),`,
`                                                    end: AlignmentDirectional(-1.0, 1.0),`,
`                                                  ),`,
`                                                  borderRadius: BorderRadius.circular(5.0),`,
`                                                ),`,
`                                                child: Row(`,
`                                                  mainAxisSize: MainAxisSize.max,`,
`                                                  mainAxisAlignment: MainAxisAlignment.center,`,
`                                                  children: [`,
`                                                    Text(`,
`                                                      'Émettre & Signer l\\'Ordonnance',`,
`                                                      style: FlutterFlowTheme.of(context).labelSmall.override(`,
`                                                        font: GoogleFonts.outfit(`,
`                                                          fontWeight: FontWeight.w600,`,
`                                                        ),`,
`                                                        color: Colors.white,`,
`                                                        fontSize: 12.0,`,
`                                                        fontWeight: FontWeight.w600,`,
`                                                      ),`,
`                                                    ),`,
`                                                    const SizedBox(width: 8.0),`,
`                                                    const Icon(`,
`                                                      Icons.verified_outlined,`,
`                                                      color: Colors.white,`,
`                                                      size: 16.0,`,
`                                                    ),`,
`                                                  ],`,
`                                                ),`,
`                                              ),`,
`                                            ),`
];

lines.splice(startIndex, (endIndex - startIndex + 1), ...newLines);

// S'assurer de l'import en haut
let fullText = lines.join('\n');
if (!fullText.includes("import 'prescription_creation_dialog.dart';")) {
  fullText = fullText.replace("export 'dmp_model.dart';", "import 'prescription_creation_dialog.dart';\nexport 'dmp_model.dart';");
}

fs.writeFileSync(filePath, fullText, 'utf8');
console.log('Successfully spliced new interactive button!');
