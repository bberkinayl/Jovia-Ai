import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  final List<String> notifications;

  const NotificationsPage({super.key, required this.notifications});

  @override
  Widget build(BuildContext context) {
    const gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFB892FF),
        Color(0xFF7B61FF),
        Color(0xFFFF85C0),
      ],
      stops: [0.0, 0.55, 1.0],
    );

    return Container(
      decoration: const BoxDecoration(gradient: gradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          title: const Text(
            "Notifications",
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: notifications.isEmpty
            ? const Center(
                child: Text(
                  "Şu anda bildirimin yok ✨",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: notifications.length,
                itemBuilder: (context, i) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      // 0.18 opacity ≈ 0x2E
                      color: const Color(0x2EFFFFFF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      notifications[i],
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  );
                },
              ),
      ),
    );
  }
}