const fs = require('fs');
const path = require('path');

const targetPath = path.join(__dirname, '..', 'lib', 'patient', 'profile_user', 'profile_user_widget.dart');
let content = fs.readFileSync(targetPath, 'utf8');

// 1. Add import if not present
if (!content.includes('patient_appointments_widget.dart')) {
  content = `import '/components/patient_appointments_widget.dart';\n` + content;
  console.log('Added import for PatientAppointmentsWidget');
}

// 2. Wrap "MES CONSULTATIONS" in InkWell that opens PatientAppointmentsWidget
const normContent = content.replace(/\r\n/g, '\n');

const oldConsultationCard = `Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context)
                                      .primaryBackground,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(14.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Icon(
                                            Icons.edit_calendar,
                                            color: Color(0xFF8A0DCE),
                                            size: 18.0,
                                          ),
                                          Text(
                                            'MES CONSULTATIONS',
                                            style: FlutterFlowTheme.of(context)
                                                .bodySmall
                                                .override(
                                                  font: GoogleFonts.outfit(
                                                    fontWeight: FontWeight.w500,
                                                    fontStyle:
                                                        FlutterFlowTheme.of(
                                                                context)
                                                            .bodySmall
                                                            .fontStyle,
                                                  ),
                                                  color: Color(0xFF8A0DCE),
                                                  fontSize: 12.0,
                                                  letterSpacing: 0.0,
                                                  fontWeight: FontWeight.w500,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodySmall
                                                          .fontStyle,
                                                ),
                                          ),
                                        ].divide(SizedBox(width: 10.0)),
                                      ),
                                      Icon(
                                        Icons.keyboard_arrow_right_rounded,
                                        color: FlutterFlowTheme.of(context)
                                            .success,
                                        size: 24.0,
                                      ),
                                    ].divide(SizedBox(width: 20.0)),
                                  ),
                                ),
                              ),`;

const newConsultationCard = `InkWell(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (bCtx) => PatientAppointmentsWidget(),
                                  );
                                },
                                borderRadius: BorderRadius.circular(8.0),
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: FlutterFlowTheme.of(context).primaryBackground,
                                    borderRadius: BorderRadius.circular(8.0),
                                    border: Border.all(color: Color(0xFF8A0DCE).withOpacity(0.2)),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(14.0),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            Icon(
                                              Icons.edit_calendar,
                                              color: Color(0xFF8A0DCE),
                                              size: 18.0,
                                            ),
                                            Text(
                                              'MES CONSULTATIONS',
                                              style: FlutterFlowTheme.of(context)
                                                  .bodySmall
                                                  .override(
                                                    font: GoogleFonts.outfit(
                                                      fontWeight: FontWeight.w600,
                                                      fontStyle: FlutterFlowTheme.of(context).bodySmall.fontStyle,
                                                    ),
                                                    color: Color(0xFF8A0DCE),
                                                    fontSize: 12.0,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ].divide(SizedBox(width: 10.0)),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              'Voir l\'état',
                                              style: GoogleFonts.outfit(
                                                fontSize: 11.0,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF165AC5),
                                              ),
                                            ),
                                            SizedBox(width: 4.0),
                                            Icon(
                                              Icons.keyboard_arrow_right_rounded,
                                              color: Color(0xFF165AC5),
                                              size: 24.0,
                                            ),
                                          ],
                                        ),
                                      ].divide(SizedBox(width: 20.0)),
                                    ),
                                  ),
                                ),
                              ),`;

if (normContent.includes(oldConsultationCard)) {
  const updated = normContent.replace(oldConsultationCard, newConsultationCard);
  fs.writeFileSync(targetPath, updated, 'utf8');
  console.log('Successfully updated MES CONSULTATIONS in profile_user_widget.dart');
} else {
  console.log('Could not find exact oldConsultationCard');
}
