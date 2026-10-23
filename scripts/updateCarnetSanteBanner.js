const fs = require('fs');
const path = require('path');

const targetPath = path.join(__dirname, '..', 'lib', 'patient', 'carnet_sante', 'carnet_sante_widget.dart');
let content = fs.readFileSync(targetPath, 'utf8');

// 1. Add import
if (!content.includes('patient_appointments_widget.dart')) {
  content = `import '/components/patient_appointments_widget.dart';\n` + content;
  console.log('Added import for PatientAppointmentsWidget in carnet_sante_widget.dart');
}

// 2. Insert Appointment Live Banner before "Groupe Sanguin"
const normContent = content.replace(/\r\n/g, '\n');

const targetStr = `                Container(
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

const appointmentBanner = `                // ── Banner Mes Rendez-vous & Consultations ──
                InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (bCtx) => PatientAppointmentsWidget(),
                    );
                  },
                  borderRadius: BorderRadius.circular(14.0),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(14.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF165AC5), Color(0xFF1E1458)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14.0),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF165AC5).withOpacity(0.25),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.calendar_month_rounded, color: Colors.white, size: 22),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Mes Rendez-vous Médicaux',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Suivez en direct l\'état de vos demandes (Validé, Reporté, Refusé)',
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.85),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Consulter',
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF165AC5),
                                ),
                              ),
                              Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF165AC5)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 14.0),
                Container(
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

if (normContent.includes(targetStr)) {
  const updated = normContent.replace(targetStr, appointmentBanner);
  fs.writeFileSync(targetPath, updated, 'utf8');
  console.log('Successfully added Appointment Live Banner in carnet_sante_widget.dart');
} else {
  console.log('Target string not found in carnet_sante_widget.dart');
}
