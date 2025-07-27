import 'package:flutter/material.dart';
import '../screens/live_chat_page.dart';

class FloatingChatButton extends StatelessWidget {
  const FloatingChatButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 16,
      bottom: 90, // Tránh trùng với BottomNavigationBar
      child: FloatingActionButton(
        heroTag: "chat_button", // Tránh lỗi duplicate hero tag
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LiveChatPage()),
          );
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.chat, color: Colors.white),
      ),
    );
  }
}
