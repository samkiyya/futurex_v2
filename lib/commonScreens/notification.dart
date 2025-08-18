import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: getNotifications(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          List<String> notifications = snapshot.data ?? [];
          return Scaffold(
            appBar: AppBar(
              title: Text('ማሳወቂያዎች'),
            ),
            body: ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                String notification = notifications[index];

                List<String> parts = notification.split(':');
                String title =
                    parts.length > 0 ? parts[0].trim() : "Default Title";
                String message =
                    parts.length > 1 ? parts[1].trim() : "Default Message";

                return Card(
                  elevation: 3.0,
                  color: Colors.white,
                  margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          message,
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ],
                    ),
                    contentPadding: EdgeInsets.all(16.0),
                  ),
                );
              },
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: Text('Notifications'),
            ),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  // Function to get stored notifications
  Future<List<String>> getNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('notifications') ?? [];
  }
}
