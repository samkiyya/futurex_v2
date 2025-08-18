import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DeveloperInfoScreen extends StatelessWidget {
  const DeveloperInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Information'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 5.0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Text(
                'FUTUREX Developer Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 20),

              // Developer Information
              _buildInfoCard(
                title: 'Developed by:',
                content: 'Abyssinia Software Technology PLC',
              ),

              const SizedBox(height: 30),
              // Contact ListTiles
              // _buildContactTile(
              //   icon: Icons.phone,
              //   title: 'Call: 0951050364 / 0940637672',
              //   url: 'tel://0951050364',
              //   context: context,
              // ),
              // _buildContactTile(
              //   icon: Icons.telegram,
              //   title: 'Telegram: @abyssiniasoftware',
              //   url: 'https://t.me/abyssiniasoftware',
              //   context: context,
              // ),
              _buildContactTile(
                icon: Icons.web,
                title: 'Website: www.abyssiniasoftware.com',
                url: 'https://www.abyssiniasoftware.com',
                context: context,
              ),
              // Copyright Section at the bottom
              const SizedBox(height: 40),
              Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  '© 2025 FutureX Educational Consultancy. All rights reserved.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Card(
        elevation: 3.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blueAccent,
                size: 28,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      content,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required String title,
    required String url,
    required BuildContext context,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.blueAccent,
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // for rounded corners
        ),
        elevation: 5, // Icon and text color
      ),
      onPressed: () async {
        // Check if the URL can be launched
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch URL')),
          );
        }
      },
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent),
          SizedBox(width: 10), // Add some space between the icon and text
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
        ],
      ),
    );
  }
}
