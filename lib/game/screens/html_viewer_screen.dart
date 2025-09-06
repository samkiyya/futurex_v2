import 'dart:io';
import 'package:flutter/material.dart';
import 'package:futurex_app/widgets/app_bar.dart';
import 'package:futurex_app/widgets/bottomNav.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class HtmlViewerScreen extends StatefulWidget {
  final String path;
  final String title;
  final bool isOnline;

  const HtmlViewerScreen({
    super.key,
    required this.path,
    required this.title,
    required this.isOnline,
  });

  @override
  State<HtmlViewerScreen> createState() => _HtmlViewerScreenState();
}

class _HtmlViewerScreenState extends State<HtmlViewerScreen> {
  WebViewController? _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    if (!widget.isOnline) {
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Storage permission denied. Cannot access local files.',
              ),
            ),
          );
        }
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = !widget.isOnline; // Only show for offline
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            final bool? isMain = error.isForMainFrame;
            final String? url = error.url;

            if (isMain == true) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Error loading ${widget.title}: ${error.description}',
                    ),
                  ),
                );
                setState(() {
                  _isLoading = false;
                });
              }
            } else {
              debugPrint(
                '[HtmlViewerScreen] Ignored subresource error: ${url ?? 'unknown'} – ${error.description}',
              );
            }
          },
        ),
      );

    try {
      if (widget.isOnline) {
        await _controller!.loadRequest(Uri.parse(widget.path));
      } else {
        final file = File(widget.path);
        if (await file.exists()) {
          await _controller!.loadFile(file.path);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Local file not found: ${widget.path}')),
            );
            setState(() {
              _isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      print('[HtmlViewerScreen] Error loading WebView: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load ${widget.title}: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(title: widget.title),
      body: Stack(
        children: [
          if (_controller != null)
            WebViewWidget(controller: _controller!)
          else
            const Center(child: Text('Failed to initialize WebView')),
          if (_isLoading && !widget.isOnline)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
      bottomNavigationBar: BottomNav(
        currentSelectedIndex: 2,
        onTabSelected: (index) {},
      ),
    );
  }
}
