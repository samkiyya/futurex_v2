import 'package:flutter/material.dart';
import 'package:futurex_app/exam/providers/My_Result_provider.dart';
import 'package:futurex_app/widgets/bottomNav.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _selectAll = false;
  final Set<int> _selectedIndexes = {}; // Track selected items by index

  @override
  void initState() {
    super.initState();
    Provider.of<ResultFetchProvider>(
      context,
      listen: false,
    ).fetchResultsBySubject();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pass':
        return Colors.green.shade600;
      case 'fail':
        return Colors.red.shade600;
      case 'completed':
        return Colors.blue.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pass':
        return Icons.check_circle;
      case 'fail':
        return Icons.cancel;
      case 'completed':
        return Icons.check_circle_outline;
      default:
        return Icons.help_outline;
    }
  }

  void _shareSelectedResults() {
    final provider = Provider.of<ResultFetchProvider>(context, listen: false);
    final selectedResults = _selectedIndexes
        .map((index) => provider.results[index])
        .toList();

    if (selectedResults.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No subjects selected to share!')),
      );
      return;
    }

    String shareText = 'My Weekly Exam Results:\n\n';
    for (var result in selectedResults) {
      shareText +=
          '${result.subjectName} (G-${result.subjectYear}): ${result.total}%\n';
    }
    shareText +=
        '\nDownload Futurex Exam App: https://play.google.com/store/apps/details?id=com.inspireethiopia.net.futurexappversion2\n';
    shareText +=
        'Shared via Futurex Exam App at 11:59 PM EAT on Tuesday, July 08, 2025.';

    Share.share(shareText, subject: 'My Weekly Exam Results');
  }

  void _shareAllResults() {
    final provider = Provider.of<ResultFetchProvider>(context, listen: false);
    if (provider.results.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No results to share!')));
      return;
    }

    String shareText = 'My Weekly Exam Results:\n\n';
    for (var result in provider.results) {
      shareText +=
          '${result.subjectName} (G-${result.subjectYear}): ${result.total}%\n';
    }
    shareText +=
        '\nDownload Futurex Exam App: https://play.google.com/store/apps/details?id=com.inspireethiopia.net.futurexappversion2\n';
    shareText +=
        'Shared via Futurex Exam App at 11:59 PM EAT on Tuesday, July 08, 2025.';

    Share.share(shareText, subject: 'My Weekly Exam Results');
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ResultFetchProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("My Weekly Exam Results"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
          ? Center(
              child: Text(
                provider.error!,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : provider.results.isEmpty
          ? const Center(
              child: Text(
                "No results found.",
                style: TextStyle(fontSize: 18, color: Colors.black54),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _selectAll,
                            onChanged: (value) {
                              setState(() {
                                _selectAll = value ?? false;
                                if (_selectAll) {
                                  _selectedIndexes.clear();
                                  _selectedIndexes.addAll(
                                    List.generate(
                                      provider.results.length,
                                      (i) => i,
                                    ),
                                  );
                                } else {
                                  _selectedIndexes.clear();
                                }
                              });
                            },
                          ),
                          Text('All'),
                        ],
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: _shareSelectedResults,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text('Share Selected'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _shareAllResults,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text('Share All'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Subject',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Score',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...provider.results.map((result) {
                    int index = provider.results.indexOf(result);
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Checkbox(
                          value: _selectAll || _selectedIndexes.contains(index),
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                _selectedIndexes.add(index);
                              } else {
                                _selectedIndexes.remove(index);
                                if (_selectedIndexes.isEmpty)
                                  _selectAll = false;
                              }
                            });
                          },
                        ),
                        title: Text(result.subjectName),
                        subtitle: Text('G-${result.subjectYear}'),
                        trailing: Text('${result.total}%'),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
      bottomNavigationBar: BottomNav(
        onTabSelected: (index) {},
        currentSelectedIndex: 3,
      ),
    );
  }
}
