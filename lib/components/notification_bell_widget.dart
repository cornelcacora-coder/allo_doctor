import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/notification_service.dart';

/// Widget de cloche de notification avec badge dynamique en temps réel
/// et affichage du Centre de Notifications complet.
class NotificationBellWidget extends StatelessWidget {
  const NotificationBellWidget({
    super.key,
    this.iconColor = Colors.white,
    this.badgeColor = const Color(0xFFE53935),
    this.size = 24.0,
  });

  final Color iconColor;
  final Color badgeColor;
  final double size;

  void _showNotificationCenter(BuildContext context, String currentUid) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _NotificationCenterSheet(userUid: currentUid),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = currentUserUid;

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('notifications')
          .snapshots(),
      builder: (context, snapshot) {
        final allDocs = snapshot.data?.docs ?? [];
        final userDocs = allDocs.where((d) {
          final data = d.data();
          final rUid = (data['recipient_uid'] as String?) ?? '';
          final uUid = (data['user_uid'] as String?) ?? '';
          if (uid.isNotEmpty) {
            return rUid == uid || uUid == uid;
          }
          return rUid == 'patient_bitodi_cora' || uUid == 'patient_bitodi_cora';
        }).toList();

        final unreadCount = userDocs.where((d) => d.data()['is_read'] != true).length;

        return InkWell(
          onTap: () => _showNotificationCenter(context, uid.isNotEmpty ? uid : 'patient_bitodi_cora'),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  unreadCount > 0 ? Icons.notifications_active_rounded : Icons.notifications_none_rounded,
                  color: iconColor,
                  size: size,
                ),
                if (unreadCount > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(3.0),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        unreadCount > 9 ? '9+' : '$unreadCount',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 9.0,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NotificationCenterSheet extends StatelessWidget {
  const _NotificationCenterSheet({required this.userUid});

  final String userUid;

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'appointment':
        return Icons.calendar_month_rounded;
      case 'prescription':
        return Icons.receipt_long_rounded;
      case 'pharmacy_order':
        return Icons.local_pharmacy_rounded;
      case 'order_status':
      case 'delivery':
        return Icons.delivery_dining_rounded;
      case 'payment':
        return Icons.account_balance_wallet_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'appointment':
        return const Color(0xFF165AC5);
      case 'prescription':
        return const Color(0xFF16C583);
      case 'pharmacy_order':
        return Colors.orange;
      case 'order_status':
      case 'delivery':
        return const Color(0xFF673AB7);
      case 'payment':
        return const Color(0xFFE53935);
      default:
        return const Color(0xFF16C583);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (ctx, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Barre supérieure
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.notifications_rounded, color: Color(0xFF0A0E1A), size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Notifications',
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      await NotificationService.markAllAsRead(userUid);
                    },
                    icon: const Icon(Icons.done_all_rounded, size: 16, color: Color(0xFF16C583)),
                    label: Text(
                      'Tout marquer lu',
                      style: GoogleFonts.outfit(color: const Color(0xFF16C583), fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('notifications')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF16C583)));
                  }

                  final allDocs = snapshot.data?.docs ?? [];
                  final docs = allDocs.where((d) {
                    final data = d.data();
                    final rUid = (data['recipient_uid'] as String?) ?? '';
                    final uUid = (data['user_uid'] as String?) ?? '';
                    return rUid == userUid || uUid == userUid;
                  }).toList();

                  // Tri en mémoire par date décroissante (évite l'erreur d'index Firestore composite)
                  docs.sort((a, b) {
                    final tA = a.data()['created_at'];
                    final tB = b.data()['created_at'];
                    final dtA = tA is Timestamp ? tA.toDate() : DateTime(2000);
                    final dtB = tB is Timestamp ? tB.toDate() : DateTime(2000);
                    return dtB.compareTo(dtA);
                  });

                  if (docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_off_outlined, size: 50, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            'Aucune notification pour le moment',
                            style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Vos rendez-vous, ordonnances et commandes apparaîtront ici.',
                            style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final doc = docs[index];
                      final data = doc.data();
                      final isRead = data['is_read'] == true;
                      final type = data['type'] ?? 'system';
                      final title = data['title'] ?? 'Notification';
                      final message = data['message'] ?? '';
                      final createdAt = (data['created_at'] as Timestamp?)?.toDate();
                      final timeStr = createdAt != null
                          ? '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')} à ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}'
                          : '';

                      return InkWell(
                        onTap: () async {
                          if (!isRead) {
                            await NotificationService.markAsRead(doc.id);
                          }
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isRead ? Colors.white : const Color(0xFF16C583).withOpacity(0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isRead ? Colors.grey.shade200 : const Color(0xFF16C583).withOpacity(0.3),
                              width: isRead ? 1 : 1.5,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: _getTypeColor(type).withOpacity(0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getTypeIcon(type),
                                  color: _getTypeColor(type),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            title,
                                            style: GoogleFonts.outfit(
                                              fontSize: 13,
                                              fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                                              color: const Color(0xFF0A0E1A),
                                            ),
                                          ),
                                        ),
                                        if (!isRead)
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: Color(0xFF16C583),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      message,
                                      style: GoogleFonts.outfit(
                                        fontSize: 12,
                                        color: isRead ? Colors.grey.shade700 : Colors.black87,
                                      ),
                                    ),
                                    if (timeStr.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Text(
                                        timeStr,
                                        style: GoogleFonts.outfit(fontSize: 10, color: Colors.grey.shade500),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
