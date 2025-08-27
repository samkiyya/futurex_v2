import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:futurex_app/constants/networks.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HtmlViewer extends StatefulWidget {
  final String url;
  final String title;

  const HtmlViewer({super.key, required this.url, required this.title});

  @override
  State<HtmlViewer> createState() => _HtmlViewerState();
}

class _HtmlViewerState extends State<HtmlViewer> {
  WebViewController? _controller;
  bool _isLoading = true;
  bool _hasConnection = false;
  bool _isDownloaded = false;
  bool _isDownloading = false;
  String? _errorMessage;
  String? _localFilePath;

  static String baseUrl = Networks().lessonPath;

  @override
  void initState() {
    super.initState();
    _initHtmlViewer();
  }

  Future<void> _initHtmlViewer() async {
    final connection = await Connectivity().checkConnectivity();
    _hasConnection = connection != ConnectivityResult.none;

    final fullUrl = widget.url.startsWith('http')
        ? widget.url
        : '${baseUrl}uploads/html/${widget.url}';
    final hash = md5.convert(utf8.encode(fullUrl)).toString();
    final fileName = '${widget.title.replaceAll(" ", "_")}_$hash.html';

    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/$fileName';
    final file = File(filePath);
    final exists = await file.exists();

    if (exists) {
      _isDownloaded = true;
      _localFilePath = filePath;
    }

    if (_hasConnection) {
      print("Loading online HTML: $fullUrl");
      _loadOnlineHtml(fullUrl);
    } else {
      if (_isDownloaded) {
        _loadLocalHtml(_localFilePath!);
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage =
              "No internet connection.\nPlease connect to download, or try again later.";
        });
      }
    }
  }

  void _loadOnlineHtml(String url) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onWebResourceError: (_) => setState(() {
            _isLoading = false;
            _errorMessage = "Failed to load the online HTML.";
          }),
        ),
      )
      ..loadRequest(Uri.parse(url));

    setState(() {
      _controller = controller;
      _isLoading = true;
    });
  }

  void _loadLocalHtml(String path) {
    final fileUri = Uri.file(path).toString();

    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(fileUri))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onWebResourceError: (_) => setState(() {
            _isLoading = false;
            _errorMessage = "Failed to load the local HTML.";
          }),
        ),
      );

    setState(() {
      _controller = controller;
      _isLoading = true;
    });
  }

  Future<void> _downloadHtml() async {
    setState(() {
      _isDownloading = true;
    });

    final fullUrl = widget.url.startsWith('http')
        ? widget.url
        : '$baseUrl${widget.url}';
    final hash = md5.convert(utf8.encode(fullUrl)).toString();
    final fileName = '${widget.title.replaceAll(" ", "_")}_$hash.html';

    try {
      final response = await http.get(Uri.parse(fullUrl));
      if (response.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/$fileName');
        await file.writeAsString(response.body);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Download complete!')));

        setState(() {
          _isDownloaded = true;
          _localFilePath = file.path;
        });

        if (!_hasConnection) {
          _loadLocalHtml(file.path);
        }
      } else {
        throw Exception(
          "Failed to fetch HTML (Status: ${response.statusCode})",
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Download failed: $e')));
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (_hasConnection && !_isDownloaded)
            ElevatedButton(
              onPressed: _isDownloading ? null : _downloadHtml,
              child: Text("Download"),
            ),
        ],
      ),
      body: Stack(
        children: [
          if (_errorMessage != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _isDownloading ? null : _downloadHtml,
                    icon: const Icon(Icons.download),
                    label: const Text("Download HTML"),
                  ),
                ],
              ),
            ),
          if (_controller != null && _errorMessage == null)
            WebViewWidget(controller: _controller!),
          if (_isLoading || _isDownloading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
