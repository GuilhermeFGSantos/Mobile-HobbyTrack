import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotification {
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final Color iconColor;
  final bool isUnread;

  AppNotification({
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.iconColor,
    this.isUnread = false,
  });
}

class TelaNotificacoes extends StatelessWidget {
  TelaNotificacoes({super.key});

  final Color _bg = const Color(0xFFF9F9F9);
  final Color _purple = const Color(0xFF7B61FF);
  final Color _textPrimary = const Color(0xFF333333);
  final Color _textSecondary = const Color(0xFF888888);

  IconData _getIcon(String? iconName) {
    switch (iconName) {
      case 'warning': return Icons.warning_rounded;
      case 'check': return Icons.check_circle_rounded;
      case 'reminder': return Icons.notifications_rounded;
      case 'fire': return Icons.local_fire_department_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color _getColor(String? colorName) {
    switch (colorName) {
      case 'orange': return const Color(0xFFFF7A00);
      case 'green': return Colors.green;
      case 'purple': return const Color(0xFF7B61FF);
      default: return const Color(0xFF7B61FF);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: _textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notificações',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('notificacoes').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState(context);
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final dados = docs[index].data() as Map<String, dynamic>;

              final notification = AppNotification(
                title: dados['title'] ?? '',
                message: dados['message'] ?? '',
                time: dados['time'] ?? '',
                icon: _getIcon(dados['icon']),
                iconColor: _getColor(dados['iconColor']),
                isUnread: dados['isUnread'] ?? false,
              );

              return _NotificationCard(
                notification: notification,
                purple: _purple,
                textPrimary: _textPrimary,
                textSecondary: _textSecondary,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off_outlined, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Nenhuma notificação por aqui',
              style: TextStyle(
                color: _textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Voltar para o Início'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _purple,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final Color purple;
  final Color textPrimary;
  final Color textSecondary;

  const _NotificationCard({
    required this.notification,
    required this.purple,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notification.isUnread ? Colors.white : const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(14),
        border: notification.isUnread
            ? Border.all(color: purple.withOpacity(0.3), width: 1)
            : Border.all(color: Colors.transparent),
        boxShadow: notification.isUnread
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ]
            : [],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: notification.iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(notification.icon, color: notification.iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 14,
                          fontWeight: notification.isUnread ? FontWeight.bold : FontWeight.w600,
                        ),
                      ),
                    ),
                    if (notification.isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(color: purple, shape: BoxShape.circle),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.message,
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  notification.time,
                  style: TextStyle(
                    color: textSecondary.withOpacity(0.7),
                    fontSize: 10,
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