import 'package:flutter/material.dart';
import 'package:futurex_app/videoApp/services/api_service.dart';

class ComingSoonList extends StatefulWidget {
  const ComingSoonList({super.key});

  @override
  _ComingSoonListState createState() => _ComingSoonListState();
}

class _ComingSoonListState extends State<ComingSoonList> {
  List<Map<String, String>> comingSoonData = [];

  @override
  void initState() {
    super.initState();
    _fetchComingSoon();
  }

  Future<void> _fetchComingSoon() async {
    comingSoonData = await ApiService().fetchComingSoon();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (comingSoonData.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "Coming Soon Courses",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        SizedBox(
          height: 220,
          width: double.infinity,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: comingSoonData.length,
            itemBuilder: (context, index) =>
                _buildImageCard(context, comingSoonData[index]),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildImageCard(BuildContext context, Map<String, String> data) {
    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Coming Soon!"),
          content: const Text("Stay tuned for exciting new courses!"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        width: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color.fromARGB(255, 251, 251, 251),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                data['image']!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 140,
                  height: 110,
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.broken_image,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Text(
                data['course']!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
