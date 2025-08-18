import 'package:flutter/material.dart';

class OfflineAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onOnlineTap;
  final VoidCallback onOfflineTap;

  const OfflineAppBar(
      {super.key, required this.onOnlineTap, required this.onOfflineTap});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text("Courses",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade700, Colors.blue.shade900],
          ),
          borderRadius:
              const BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      // actions: [
      //   Padding(
      //     padding: const EdgeInsets.symmetric(horizontal: 8.0),
      //     child: Row(
      //       children: [
      //         _buildActionButton(label: 'Online', onTap: onOnlineTap),
      //         const SizedBox(width: 8),
      //         _buildActionButton(label: 'Offline', onTap: onOfflineTap),
      //       ],
      //     ),
      //   ),
      // ],
    );
  }

  Widget _buildActionButton(
      {required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2))
          ],
        ),
        child: Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
