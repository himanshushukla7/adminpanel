import 'package:flutter/material.dart';

class DashboardTopBar extends StatelessWidget {
  final VoidCallback? onMenuTap;
  final VoidCallback? onLogout;

  const DashboardTopBar({super.key, this.onMenuTap, this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          IconButton(icon: const Icon(Icons.menu_rounded), onPressed: onMenuTap),
          const SizedBox(width: 16),
          // Search Bar
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Search...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
          const Spacer(),
          // Language
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFFF1F5FF), borderRadius: BorderRadius.circular(8)),
            child: Row(children: const [
              Icon(Icons.public, size: 16, color: Color(0xFFF59E0B)),
              SizedBox(width: 6),
              Text('EN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B))),
            ]),
          ),
          const SizedBox(width: 16),
          // User Avatar
          const CircleAvatar(
            backgroundColor: Color(0xFFF59E0B),
            child: Text("A", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}