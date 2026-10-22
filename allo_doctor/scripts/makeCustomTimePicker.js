const fs = require('fs');

const filePath = 'lib/components/get_medical_appointment_widget.dart';
let raw = fs.readFileSync(filePath, 'utf8');
const isCrlf = raw.includes('\r\n');
let content = raw.replace(/\r\n/g, '\n');

// 1. Add state variables in _GetMedicalAppointmentWidgetState
const stateStart = 'class _GetMedicalAppointmentWidgetState\n    extends State<GetMedicalAppointmentWidget> {\n  late GetMedicalAppointmentModel _model;';
const newVars = 'DateTime? _customDate;\n  TimeOfDay? _customTime;';

if (!content.includes('_customDate') && content.includes(stateStart)) {
  content = content.replace(stateStart, stateStart + '\n  ' + newVars);
}

// 2. Add the custom date/time picker UI right above 'Lundi' container (before Container( width: double.infinity, decoration: BoxDecoration( color: FlutterFlowTheme.of(context).primaryBackground, )
const creneauTitle = "Text(\n                              'Creneau',";
const customPickerWidget = `Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).primaryBackground,
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(
                                    color: (_customDate != null && _customTime != null)
                                        ? FlutterFlowTheme.of(context).primary
                                        : FlutterFlowTheme.of(context).alternate,
                                    width: 1.5,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.schedule, color: FlutterFlowTheme.of(context).primary, size: 20),
                                        SizedBox(width: 8),
                                        Text(
                                          'Choisir ma date et mon heure précises',
                                          style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            style: OutlinedButton.styleFrom(
                                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                              side: BorderSide(color: FlutterFlowTheme.of(context).alternate),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            icon: Icon(Icons.calendar_today, size: 16),
                                            label: Text(
                                              _customDate == null
                                                  ? 'Sélectionner date'
                                                  : '\${_customDate!.day}/\${_customDate!.month}/\${_customDate!.year}',
                                              style: GoogleFonts.outfit(fontSize: 12),
                                            ),
                                            onPressed: () async {
                                              final now = DateTime.now();
                                              final picked = await showDatePicker(
                                                context: context,
                                                initialDate: _customDate ?? now,
                                                firstDate: now,
                                                lastDate: now.add(Duration(days: 365)),
                                              );
                                              if (picked != null) {
                                                safeSetState(() => _customDate = picked);
                                              }
                                            },
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            style: OutlinedButton.styleFrom(
                                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                              side: BorderSide(color: FlutterFlowTheme.of(context).alternate),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            icon: Icon(Icons.access_time, size: 16),
                                            label: Text(
                                              _customTime == null
                                                  ? 'Choisir heure'
                                                  : '\${_customTime!.hour.toString().padLeft(2, '0')}:\${_customTime!.minute.toString().padLeft(2, '0')}',
                                              style: GoogleFonts.outfit(fontSize: 12),
                                            ),
                                            onPressed: () async {
                                              final picked = await showTimePicker(
                                                context: context,
                                                initialTime: _customTime ?? TimeOfDay.now(),
                                              );
                                              if (picked != null) {
                                                safeSetState(() => _customTime = picked);
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),\n                              SizedBox(height: 12),\n                              `;

const creneauEnd = "overflow: TextOverflow.ellipsis,\n                            ),";
if (!content.includes('Choisir ma date et mon heure précises') && content.includes(creneauEnd)) {
  content = content.replace(creneauEnd, creneauEnd + '\n                              ' + customPickerWidget);
}

// 3. Update the submit validation logic
const oldSlotLogic = `if (_model.selectedCreneauValue == true) {
                          selectedDay = 'Lundi';
                          selectedSlot = _model.dropDownValue1 ?? '8h - 10h';`;

const newSlotLogic = `if (_customDate != null && _customTime != null) {
                          selectedDay = '\${_customDate!.day.toString().padLeft(2, '0')}/\${_customDate!.month.toString().padLeft(2, '0')}/\${_customDate!.year}';
                          selectedSlot = '\${_customTime!.hour.toString().padLeft(2, '0')}:\${_customTime!.minute.toString().padLeft(2, '0')}';
                        } else if (_model.selectedCreneauValue == true) {
                          selectedDay = 'Lundi';
                          selectedSlot = _model.dropDownValue1 ?? '8h - 10h';`;

if (content.includes(oldSlotLogic)) {
  content = content.replace(oldSlotLogic, newSlotLogic);
}

if (isCrlf) content = content.replace(/\n/g, '\r\n');
fs.writeFileSync(filePath, content, 'utf8');
console.log('Successfully updated get_medical_appointment_widget.dart with custom date & time picker');
