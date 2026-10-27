import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/flutter_flow/flutter_flow_theme.dart';

/// Bottom sheet de messagerie en temps réel entre un patient et une pharmacie.
/// Utilise la collection Firestore : chats/{chatId}/messages/{messageId}
/// chatId = pharmacyId + '_' + patientUid (trié alphabétiquement pour cohérence)
class PharmacyChatSheet extends StatefulWidget {
  const PharmacyChatSheet({
    super.key,
    required this.pharmacyId,
    required this.pharmacyName,
  });

  final String pharmacyId;
  final String pharmacyName;

  @override
  State<PharmacyChatSheet> createState() => _PharmacyChatSheetState();
}

class _PharmacyChatSheetState extends State<PharmacyChatSheet> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _sending = false;

  late final String _chatId;
  late final CollectionReference<Map<String, dynamic>> _messagesRef;

  @override
  void initState() {
    super.initState();
    // ID de conversation déterministe
    final ids = [widget.pharmacyId, currentUserUid]..sort();
    _chatId = ids.join('_');
    _messagesRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(_chatId)
        .collection('messages');

    // Créer ou mettre à jour le doc parent de la conversation
    _ensureChatDoc();
  }

  Future<void> _ensureChatDoc() async {
    await FirebaseFirestore.instance.collection('chats').doc(_chatId).set({
      'pharmacyId': widget.pharmacyId,
      'pharmacyName': widget.pharmacyName,
      'patientId': currentUserUid,
      'patientName': currentUserDisplayName ?? 'Patient',
      'participants': [widget.pharmacyId, currentUserUid],
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    _msgController.clear();
    try {
      await _messagesRef.add({
        'text': text,
        'senderId': currentUserUid,
        'senderName': currentUserDisplayName ?? 'Patient',
        'senderRole': 'patient',
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });
      // Mettre à jour le dernier message
      await FirebaseFirestore.instance.collection('chats').doc(_chatId).update({
        'lastMessage': text,
        'lastMessageAt': FieldValue.serverTimestamp(),
        'lastSenderId': currentUserUid,
        'unreadByPharmacy': FieldValue.increment(1),
      });
      // Scroll vers le bas
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erreur envoi: $e'),
          backgroundColor: Colors.red.shade700,
        ));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      child: Column(
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12.0, bottom: 8.0),
              width: 40.0,
              height: 4.0,
              decoration: BoxDecoration(
                color: theme.alternate,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: Row(
              children: [
                Container(
                  width: 42.0,
                  height: 42.0,
                  decoration: BoxDecoration(
                    color: const Color(0x2219BF82),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: const Icon(
                    Icons.local_pharmacy_rounded,
                    color: Color(0xFF19BF82),
                    size: 24.0,
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.pharmacyName,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.0,
                          color: theme.primaryText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Container(
                            width: 8.0,
                            height: 8.0,
                            decoration: const BoxDecoration(
                              color: Color(0xFF19BF82),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4.0),
                          Text(
                            'En ligne',
                            style: GoogleFonts.outfit(
                              color: const Color(0xFF19BF82),
                              fontSize: 11.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: theme.secondaryText),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Divider(height: 1.0, color: theme.alternate),
          // Messages list
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _messagesRef
                  .orderBy('createdAt', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded,
                            size: 56, color: theme.alternate),
                        const SizedBox(height: 12.0),
                        Text(
                          'Démarrez la conversation',
                          style: GoogleFonts.outfit(
                            color: theme.secondaryText,
                            fontSize: 14.0,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          'Posez vos questions sur les médicaments,\nhorraires ou disponibilités.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            color: theme.secondaryText,
                            fontSize: 12.0,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Scroll to bottom on new messages
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                    );
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 12.0),
                  itemCount: docs.length,
                  itemBuilder: (context, i) {
                    final data = docs[i].data();
                    final isMe = data['senderId'] == currentUserUid;
                    final text = (data['text'] as String?) ?? '';
                    final ts = data['createdAt'] as Timestamp?;
                    final time = ts != null
                        ? '${ts.toDate().hour.toString().padLeft(2, '0')}:${ts.toDate().minute.toString().padLeft(2, '0')}'
                        : '';
                    return _MessageBubble(
                      text: text,
                      time: time,
                      isMe: isMe,
                      senderName: (data['senderName'] as String?) ?? '',
                    );
                  },
                );
              },
            ),
          ),
          // Input bar
          Container(
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              border: Border(top: BorderSide(color: theme.alternate)),
            ),
            padding: EdgeInsets.fromLTRB(
              16.0,
              8.0,
              16.0,
              MediaQuery.of(context).viewInsets.bottom + 12.0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.primaryBackground,
                      borderRadius: BorderRadius.circular(24.0),
                      border: Border.all(color: theme.alternate),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: TextField(
                            controller: _msgController,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            decoration: InputDecoration(
                              hintText: 'Votre message...',
                              hintStyle: GoogleFonts.outfit(
                                color: theme.secondaryText,
                                fontSize: 14.0,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 10.0),
                            ),
                            style: GoogleFonts.outfit(
                              color: theme.primaryText,
                              fontSize: 14.0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                GestureDetector(
                  onTap: _sending ? null : _sendMessage,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 44.0,
                    height: 44.0,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF14563C), Color(0xFF19BF82)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF19BF82).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _sending
                        ? const Center(
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            ),
                          )
                        : const Icon(Icons.send_rounded,
                            color: Colors.white, size: 20.0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.text,
    required this.time,
    required this.isMe,
    required this.senderName,
  });

  final String text;
  final String time;
  final bool isMe;
  final String senderName;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            Container(
              width: 28.0,
              height: 28.0,
              decoration: const BoxDecoration(
                color: Color(0x2219BF82),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.local_pharmacy_rounded,
                  size: 16, color: Color(0xFF19BF82)),
            ),
            const SizedBox(width: 6.0),
          ],
          Flexible(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: isMe ? const Color(0xFF14563C) : theme.secondaryBackground,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16.0),
                  topRight: const Radius.circular(16.0),
                  bottomLeft: Radius.circular(isMe ? 16.0 : 4.0),
                  bottomRight: Radius.circular(isMe ? 4.0 : 16.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    text,
                    style: GoogleFonts.outfit(
                      color: isMe ? Colors.white : theme.primaryText,
                      fontSize: 13.0,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    time,
                    style: GoogleFonts.outfit(
                      color: isMe
                          ? Colors.white.withOpacity(0.6)
                          : theme.secondaryText,
                      fontSize: 10.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) const SizedBox(width: 6.0),
        ],
      ),
    );
  }
}
