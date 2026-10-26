const fs = require('fs');
const path = require('path');

// ─── carnet_sante_widget.dart ─────────────────────────────────────────────
const carnetPath = path.join(__dirname, '..', 'lib', 'patient', 'carnet_sante', 'carnet_sante_widget.dart');
let content = fs.readFileSync(carnetPath, 'utf8').replace(/\r\n/g, '\n');

// 1. Extract bloodGroup from userData in the existing StreamBuilder (after allergies)
const oldAllergies = `            final allergies = (userData?['allergies'] as List<dynamic>?)?.cast<String>() ?? [];`;
const newAllergies = `            final allergies = (userData?['allergies'] as List<dynamic>?)?.cast<String>() ?? [];
            final bloodGroup = ((userData?['bloodGroup'] as String?)?.isNotEmpty == true
                ? userData!['bloodGroup'] as String
                : ((userData?['blood_group'] as String?)?.isNotEmpty == true
                    ? userData!['blood_group'] as String
                    : (userData?['groupe_sanguin'] as String?) ?? '')) ;`;

if (content.includes(oldAllergies)) {
  content = content.replace(oldAllergies, newAllergies);
  console.log('✅ Added bloodGroup extraction in carnet_sante_widget.dart');
} else {
  console.log('❌ Could not find allergies extraction line');
}

// 2. Replace the entire static Groupe Sanguin section with a dynamic version
// The static section: fixed A+, A-, B+, B-, AB+, AB-, O+, O- chips.
// We replace it with a builder that highlights the matching chip.
const oldGroupeSanguin = `                Container(
                  width: double.infinity,
                  height: 130.0,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: FlutterFlowTheme.of(context).alternate,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(14.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Groupe Sanguin',`;

// Find the end of this Container — we know it ends around line 770 (the closing of the 130 height container)
// We'll do a regex replacement for the full section
const sanguidSectionRegex = /Container\(\s*width: double\.infinity,\s*height: 130\.0,[\s\S]*?'Groupe Sanguin',[\s\S]*?\),\s*\),\s*\),\s*Container\(\s*width: double\.infinity,\s*decoration: BoxDecoration\(\s*color: FlutterFlowTheme\.of\(context\)\.secondaryBackground,\s*borderRadius: BorderRadius\.circular\(12\.0\),\s*border: Border\.all\(\s*color: FlutterFlowTheme\.of\(context\)\.alternate,\s*\),\s*\),\s*child: Padding\(\s*padding: EdgeInsets\.all\(14\.0\),\s*child: Column\(\s*mainAxisSize: MainAxisSize\.max,\s*mainAxisAlignment: MainAxisAlignment\.spaceBetween,\s*crossAxisAlignment: CrossAxisAlignment\.start,\s*children: \[\s*Text\(\s*'Allergies',/m;

// We'll go with a targeted replacement using the known unique start text "Groupe Sanguin"
// First, get the index of "Groupe Sanguin" in the blood group container context
const groupeIdx = content.indexOf("'Groupe Sanguin'");
if (groupeIdx === -1) {
  console.log('❌ Groupe Sanguin not found');
  process.exit(1);
}

// Find the containing Container start (backwards from "Groupe Sanguin")
// We look for the last "height: 130.0" before "Groupe Sanguin"
const before130 = content.lastIndexOf('height: 130.0,', groupeIdx);
// Go a bit further back to find Container(
const containerStart = content.lastIndexOf('Container(', before130);

// Now find the end of this container — the closing before Allergies
const allergiesIdx = content.indexOf("'Allergies'", groupeIdx);
// We need closing of the container — find "child: Column(" before Allergies
const allergiesContainerStart = content.lastIndexOf('Container(', allergiesIdx);

// Extract the old groupe section
const oldGroupeSection = content.substring(containerStart, allergiesContainerStart);
// Sanity check
if (!oldGroupeSection.includes('Groupe Sanguin')) {
  console.log('❌ Extracted section does not contain Groupe Sanguin');
  process.exit(1);
}

const newGroupeSection = `Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: FlutterFlowTheme.of(context).alternate,
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(14.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Groupe Sanguin',
                              style: FlutterFlowTheme.of(context)
                                  .headlineSmall
                                  .override(
                                    font: GoogleFonts.outfit(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    color: FlutterFlowTheme.of(context).primaryText,
                                    fontSize: 14.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (bloodGroup.isNotEmpty)
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Color(0xFF165AC5),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.bloodtype_outlined, color: Colors.white, size: 14),
                                    SizedBox(width: 4),
                                    Text(
                                      bloodGroup,
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 12),
                        if (bloodGroup.isEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.orange.shade700, size: 16),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Groupe sanguin non renseigné. Mettez à jour votre profil.',
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      color: Colors.orange.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: ['A +', 'A -', 'B +', 'B -', 'AB +', 'AB -', 'O +', 'O -'].map((g) {
                            final normalized = g.replaceAll(' ', '');
                            final userNorm = bloodGroup.replaceAll(' ', '').toUpperCase();
                            final isSelected = userNorm == normalized.toUpperCase();
                            return Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Color(0xFF165AC5)
                                    : FlutterFlowTheme.of(context).secondaryBackground,
                                borderRadius: BorderRadius.circular(8.0),
                                border: Border.all(
                                  color: isSelected
                                      ? Color(0xFF165AC5)
                                      : Color(0x4D14583D),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(10.0, 5.0, 10.0, 5.0),
                                child: Text(
                                  g,
                                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.outfit(
                                      fontWeight: isSelected ? FontWeight.bold : FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                    ),
                                    color: isSelected
                                        ? Colors.white
                                        : FlutterFlowTheme.of(context).primaryText,
                                    letterSpacing: 0.0,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 4),
                      ].divide(SizedBox(height: 0)),
                    ),
                  ),
                ),
                `;

content = content.substring(0, containerStart) + newGroupeSection + content.substring(allergiesContainerStart);
console.log('✅ Replaced Groupe Sanguin section with dynamic version');

fs.writeFileSync(carnetPath, content, 'utf8');
console.log('✅ Done writing carnet_sante_widget.dart');
