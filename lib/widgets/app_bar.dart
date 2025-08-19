import 'package:flutter/material.dart';
import 'package:futurex_app/videoApp/screens/Blog/notfi_blog_screen.dart';

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showNotificationIcon;
  final VoidCallback? onNotificationPressed;

  const GradientAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showNotificationIcon = true,
    this.onNotificationPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        if (showNotificationIcon)
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed:
                onNotificationPressed ??
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BlogGridScreenNotification(),
                    ),
                  );
                },
          ),
        ...?actions,
      ],
      backgroundColor: Colors.transparent,
      iconTheme: const IconThemeData(color: Colors.white),
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade700, Colors.blue.shade900],
          ),
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
