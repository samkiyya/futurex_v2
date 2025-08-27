import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:futurex_app/constants/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

class OnlinePdfViewer extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const OnlinePdfViewer({super.key, required this.pdfUrl, required this.title});

  @override
  State<OnlinePdfViewer> createState() => _OnlinePdfViewerState();
}

class _OnlinePdfViewerState extends State<OnlinePdfViewer> {
  late String fullUrl;
  String? pdfPath;
  bool isLoading = true;
  String? error;
  bool isDownloaded = false;
  double downloadProgress = 0.0;
  bool isOnline = false;

  @override
  void initState() {
    super.initState();
    fullUrl = '${Networks().lessonPath}${widget.pdfUrl}';
    _initialize();
  }

  Future<void> _initialize() async {
    final connectivity = await Connectivity().checkConnectivity();
    isOnline = connectivity != ConnectivityResult.none;
    await _checkIfDownloadedOrLoadOnline();
  }

  Future<void> _checkIfDownloadedOrLoadOnline() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final hash = md5.convert(utf8.encode(fullUrl)).toString();
      final fileName = '${widget.title.replaceAll(" ", "_")}_$hash.pdf';
      final filePath = '${dir.path}/$fileName';
      final file = File(filePath);

      if (await file.exists()) {
        setState(() {
          pdfPath = file.path;
          isDownloaded = true;
          isLoading = false;
        });
      } else if (isOnline) {
        final tempPath = '${dir.path}/temp_$hash.pdf';
        final response = await http.get(Uri.parse(fullUrl));
        final tempFile = File(tempPath);
        await tempFile.writeAsBytes(response.bodyBytes);
        setState(() {
          pdfPath = tempFile.path;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Failed to load PDF: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _downloadPDF() async {
    try {
      final request = http.Request('GET', Uri.parse(fullUrl));
      final response = await request.send();

      final dir = await getApplicationDocumentsDirectory();
      final hash = md5.convert(utf8.encode(fullUrl)).toString();
      final fileName = '${widget.title.replaceAll(" ", "_")}_$hash.pdf';
      final filePath = '${dir.path}/$fileName';
      final file = File(filePath);

      int received = 0;
      final total = response.contentLength ?? 1;

      setState(() {
        downloadProgress = 0.01;
      });

      final sink = file.openWrite();

      response.stream.listen(
        (chunk) {
          received += chunk.length;
          sink.add(chunk);
          setState(() {
            downloadProgress = received / total;
          });
        },
        onDone: () async {
          await sink.close();
          setState(() {
            isDownloaded = true;
            pdfPath = file.path;
            downloadProgress = 0.0;
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Download complete!')));
        },
        onError: (e) {
          setState(() {
            downloadProgress = 0.0;
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Download error: $e')));
        },
        cancelOnError: true,
      );
    } catch (e) {
      setState(() {
        downloadProgress = 0.0;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Download failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (!isDownloaded && !isLoading && isOnline)
            ElevatedButton(onPressed: _downloadPDF, child: Text("Download")),

          if (isDownloaded)
            IconButton(
              icon: const Icon(Icons.folder_open),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opened from local device')),
                );
              },
              tooltip: 'Open from device',
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                if (pdfPath != null)
                  PDFView(
                    filePath: pdfPath!,
                    enableSwipe: true,
                    autoSpacing: true,
                    pageFling: true,
                    onError: (err) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('please check your connection')),
                      );
                    },
                  )
                else
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.wifi_off,
                          size: 60,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'You are offline.\nPlease connect to the internet to download or read online.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.download),
                          label: const Text('Download'),
                          onPressed: isOnline ? _downloadPDF : null,
                        ),
                      ],
                    ),
                  ),

                if (downloadProgress > 0 && downloadProgress < 1)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 10),
                          Text(
                            'Downloading ${(downloadProgress * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
