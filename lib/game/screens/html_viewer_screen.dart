import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HtmlViewerScreen extends StatefulWidget {
  final String path; // can be local file path or remote url
  final String title;

  const HtmlViewerScreen({super.key, required this.path, required this.title});

  @override
  State<HtmlViewerScreen> createState() => _HtmlViewerScreenState();
}

class _HtmlViewerScreenState extends State<HtmlViewerScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    // enable hybrid composition on Android is handled by package
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);

    if (widget.path.startsWith('http')) {
      _controller.loadRequest(Uri.parse(widget.path));
    } else {
      final fileUri = Uri.file(widget.path).toString();
      _controller.loadRequest(Uri.parse(fileUri));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: WebViewWidget(controller: _controller),
    );
  }
}
