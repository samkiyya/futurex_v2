import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class GoogleFormWebView extends StatefulWidget {
  final String url;

  const GoogleFormWebView({super.key, required this.url});

  @override
  _GoogleFormWebViewState createState() => _GoogleFormWebViewState();
}

class _GoogleFormWebViewState extends State<GoogleFormWebView> {
  bool isLoading = true; // Track loading state
  String errorMessage = ""; // To display errors if any

  @override
  void initState() {
    super.initState();
  }

  // Error handling function for WebView
  void handleError(
      InAppWebViewController controller, String url, int code, String message) {
    setState(() {
      isLoading = false; // Stop loading on error
      errorMessage = "Error loading page: $message";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Entrance Exams'),
      ),
      body: Stack(
        children: [
          InAppWebView(
            //initialUrlRequest: URLRequest(url: Uri.parse(widget.url)),
            initialOptions: InAppWebViewGroupOptions(
              crossPlatform: InAppWebViewOptions(
                javaScriptEnabled: true,
                cacheEnabled: true,
              ),
            ),
            // Correct event handler for page start
            onLoadStart: (controller, url) {
              setState(() {
                isLoading = true; // Show loading while page is loading
              });
            },
            // Correct event handler for page load finish
            onLoadStop: (controller, url) {
              setState(() {
                isLoading =
                    false; // Hide loading indicator when the page is loaded
              });
            },
            // Handle resource loading errors
          ),
          isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : SizedBox.shrink(),
          // Show error message if there is any
          if (errorMessage.isNotEmpty)
            Center(
              child: Text(
                errorMessage,
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
        ],
      ),
    );
  }
}