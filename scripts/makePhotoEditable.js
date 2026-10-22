const fs = require('fs');

// 1. Update profile_edit_widget.dart
let raw1 = fs.readFileSync('lib/patient/profile_edit/profile_edit_widget.dart', 'utf8');
const isCrlf1 = raw1.includes('\r\n');
let content1 = raw1.replace(/\r\n/g, '\n');

if (!content1.includes('package:cloud_firestore/cloud_firestore.dart')) {
  content1 = content1.replace("import 'dart:ui';", "import 'dart:ui';\nimport 'package:cloud_firestore/cloud_firestore.dart';\nimport '/auth/firebase_auth/auth_util.dart';");
}

const photoHelper = `
  Future<void> _changePhotoDialog(BuildContext context) async {
    final controller = TextEditingController(text: currentUserPhoto);
    final chosen = await showDialog<String>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: Text('Modifier ma photo', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Entrez le lien d\\'une image ou choisissez un avatar :', style: GoogleFonts.outfit(fontSize: 13)),
            SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'https://...',
                labelText: 'URL de votre photo',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            SizedBox(height: 14),
            Text('Avatars disponibles :', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200',
                'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
                'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=200',
                'https://images.unsplash.com/photo-1594824813511-133a886f4a86?w=200',
              ].map((url) => InkWell(
                onTap: () {
                  controller.text = url;
                },
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(url),
                ),
              )).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: FlutterFlowTheme.of(context).primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogCtx, controller.text.trim()),
            child: Text('Enregistrer'),
          ),
        ],
      ),
    );
    if (chosen != null && chosen.isNotEmpty && currentUserUid.isNotEmpty) {
      await FirebaseFirestore.instance.collection('users').doc(currentUserUid).update({
        'photoUrl': chosen,
        'photo_url': chosen,
      });
      try {
        await currentUser?.updatePhotoURL(chosen);
      } catch (_) {}
      safeSetState(() {});
    }
  }
`;

// Insert _changePhotoDialog before @override Widget build
const buildMarker = '@override\n  Widget build(BuildContext context) {';
if (!content1.includes('_changePhotoDialog') && content1.includes(buildMarker)) {
  content1 = content1.replace(buildMarker, photoHelper + '\n  ' + buildMarker);
}

// Replace the static image in profile_edit
const oldAvatarBlock = `ClipRRect(
                                borderRadius: BorderRadius.circular(50.0),
                                child: CachedNetworkImage(
                                  fadeInDuration: Duration(milliseconds: 0),
                                  fadeOutDuration: Duration(milliseconds: 0),
                                  imageUrl:
                                      'https://dimg.dreamflow.cloud/v1/image/professional%20male%20doctor%20portrait',
                                  width: 96.0,
                                  height: 96.0,
                                  fit: BoxFit.cover,
                                  alignment: Alignment(0.0, 0.0),
                                ),
                              ),`;

const newAvatarBlock = `ClipRRect(
                                borderRadius: BorderRadius.circular(50.0),
                                child: currentUserPhoto.isNotEmpty
                                    ? CachedNetworkImage(
                                        fadeInDuration: Duration(milliseconds: 0),
                                        fadeOutDuration: Duration(milliseconds: 0),
                                        imageUrl: currentUserPhoto,
                                        width: 96.0,
                                        height: 96.0,
                                        fit: BoxFit.cover,
                                        alignment: Alignment(0.0, 0.0),
                                      )
                                    : Container(
                                        width: 96.0,
                                        height: 96.0,
                                        color: FlutterFlowTheme.of(context).primary,
                                        alignment: Alignment.center,
                                        child: Icon(Icons.person, size: 48.0, color: Colors.white),
                                      ),
                              ),`;

content1 = content1.replace(oldAvatarBlock, newAvatarBlock);

// Make Changer Photo Profile clickable
const oldChangeText = `Text(
                      'Changer Photo Profile',
                      style: FlutterFlowTheme.of(context).labelLarge.override(
                            font: GoogleFonts.outfit(
                              fontWeight: FontWeight.w600,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .labelLarge
                                  .fontStyle,
                            ),
                            color: FlutterFlowTheme.of(context).primary,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w600,
                            fontStyle: FlutterFlowTheme.of(context)
                                .labelLarge
                                .fontStyle,
                            lineHeight: 1.4,
                          ),
                    ),`;

const newChangeText = `InkWell(
                      onTap: () => _changePhotoDialog(context),
                      child: ` + oldChangeText + `\n                    ),`;

content1 = content1.replace(oldChangeText, newChangeText);

if (isCrlf1) content1 = content1.replace(/\n/g, '\r\n');
fs.writeFileSync('lib/patient/profile_edit/profile_edit_widget.dart', content1, 'utf8');
console.log('Successfully updated profile_edit_widget.dart photo picker');


// 2. Update carnet_sante_widget.dart
let raw2 = fs.readFileSync('lib/patient/carnet_sante/carnet_sante_widget.dart', 'utf8');
const isCrlf2 = raw2.includes('\r\n');
let content2 = raw2.replace(/\r\n/g, '\n');

if (!content2.includes('_changePhotoDialog') && content2.includes(buildMarker)) {
  content2 = content2.replace(buildMarker, photoHelper + '\n  ' + buildMarker);
}

// Make the avatar in carnet_sante tap to change photo
const oldAlignAvatar = `Align(
                      alignment: AlignmentDirectional(0.0, -1.0),
                      child: Container(
                        width: 58.0,
                        height: 60.0,
                        decoration: BoxDecoration(),
                        child: Stack(
                          children: [
                            Container(
                              width: 55.0,
                              height: 55.0,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: photoUrl.isNotEmpty
                                  ? CachedNetworkImage(
                                      fadeInDuration: Duration(milliseconds: 0),
                                      fadeOutDuration: Duration(milliseconds: 0),
                                      imageUrl: photoUrl,
                                      fit: BoxFit.cover,
                                      alignment: Alignment(0.0, 0.0),
                                    )
                                  : Container(
                                      color: FlutterFlowTheme.of(context).primary,
                                      alignment: Alignment.center,
                                      child: Text(
                                        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'B',
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontSize: 22.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                            ),
                            Align(
                              alignment: AlignmentDirectional(1.0, 1.0),
                              child: Container(
                                width: 22.0,
                                height: 22.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    width: 2.0,
                                  ),
                                ),
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Icon(
                                  Icons.check_outlined,
                                  color: Colors.white,
                                  size: 14.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),`;

const newAlignAvatar = `InkWell(
                      onTap: () => _changePhotoDialog(context),
                      child: Align(
                      alignment: AlignmentDirectional(0.0, -1.0),
                      child: Container(
                        width: 58.0,
                        height: 60.0,
                        decoration: BoxDecoration(),
                        child: Stack(
                          children: [
                            Container(
                              width: 55.0,
                              height: 55.0,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: photoUrl.isNotEmpty
                                  ? CachedNetworkImage(
                                      fadeInDuration: Duration(milliseconds: 0),
                                      fadeOutDuration: Duration(milliseconds: 0),
                                      imageUrl: photoUrl,
                                      fit: BoxFit.cover,
                                      alignment: Alignment(0.0, 0.0),
                                    )
                                  : Container(
                                      color: FlutterFlowTheme.of(context).primary,
                                      alignment: Alignment.center,
                                      child: Text(
                                        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'B',
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontSize: 22.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                            ),
                            Align(
                              alignment: AlignmentDirectional(1.0, 1.0),
                              child: Container(
                                width: 22.0,
                                height: 22.0,
                                decoration: BoxDecoration(
                                  color: FlutterFlowTheme.of(context).primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryBackground,
                                    width: 2.0,
                                  ),
                                ),
                                alignment: AlignmentDirectional(0.0, 0.0),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 13.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ),`;

content2 = content2.replace(oldAlignAvatar, newAlignAvatar);

if (isCrlf2) content2 = content2.replace(/\n/g, '\r\n');
fs.writeFileSync('lib/patient/carnet_sante/carnet_sante_widget.dart', content2, 'utf8');
console.log('Successfully updated carnet_sante_widget.dart photo picker');
