import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_core/theme.dart';

class PdfReaderScreenOffline extends StatefulWidget {
  final String documentPath;
  final String title;
  // final int bookId;
  // final String filePath; // Local or network URL of the PDF
  // final String bookTitle;

  const PdfReaderScreenOffline(
      {required this.documentPath, required this.title});
  // required this.filePath,
  // required this.bookTitle,
  // required this.bookId,
  @override
  State<PdfReaderScreenOffline> createState() => _PdfReaderScreenState();
}

class _PdfReaderScreenState extends State<PdfReaderScreenOffline> {
  String? _localFilePath;
  bool _isLoading = true;
  late SharedPreferences _prefs;
  String _theme = 'light';
  bool _isAppBarVisible = true;
  bool _isBottomNavVisible = true;
  late PdfViewerController _pdfViewerController;
  String _scrollDirection = 'vertical';
  final GlobalKey<SfPdfViewerState> _pdfViewerStateKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _loadPreferences();
    _loadPdf(widget.documentPath);
  }

  @override
  void dispose() {
    // Stop tracking when the user leaves the screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // final userActivityProvider =
        //     Provider.of<UserActivityProvider>(context, listen: false);
        // userActivityProvider.stopTracking(widget.bookId);
      }
    });
    super.dispose();
  }

  // Increment pages read when user progresses in the book
  void _incrementPagesRead() {
    // final userActivityProvider =
    //     Provider.of<UserActivityProvider>(context, listen: false);
    // userActivityProvider.incrementPagesRead();
  }

  void _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _theme = _prefs.getString('theme') ?? 'light';
      _scrollDirection = _prefs.getString('scrollDirection') ?? 'vertical';
    });
  }

  void _savePreferences() {
    _prefs.setString('theme', _theme);
    _prefs.setString('scrollDirection', _scrollDirection);
  }

  // Load the PDF (local or from network URL)
  Future<void> _loadPdf(String path) async {
    setState(() {
      _localFilePath = path;
      _isLoading = false;
    });
  }

  Color _getOverlayColor() {
    switch (_theme) {
      case 'dark':
        return Colors.black.withOpacity(0.5); // Semi-transparent dark overlay
      case 'sepia':
        return const Color(0xFF704214).withOpacity(0.3); // Sepia overlay
      default:
        return Colors.transparent; // No overlay for light theme
    }
  }

  Color _getTextColor() {
    return _theme == 'dark' ? Colors.white : Colors.black;
  }

  void _toggleAppBarVisibility() {
    setState(() {
      _isAppBarVisible = !_isAppBarVisible;
      _isBottomNavVisible = !_isBottomNavVisible;
      print(
          '_isAppBarVisible: $_isAppBarVisible, _isBottomNavVisible: $_isBottomNavVisible');
    });
  }

  @override
  Widget build(BuildContext context) {
    // final userActivityProvider = Provider.of<UserActivityProvider>(context);

    double width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Theme(
        data: ThemeData(
          brightness: _theme == 'dark' ? Brightness.dark : Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: _getOverlayColor(),
          appBar: _isAppBarVisible
              ? AppBar(
                  title: Text("Check Book"),
                  actions: <Widget>[
                    IconButton(
                      onPressed: () {
                        if (_pdfViewerController.zoomLevel > 1) {
                          _pdfViewerController.zoomLevel =
                              _pdfViewerController.zoomLevel - 0.5;
                        }
                      },
                      icon: const Icon(Icons.zoom_out),
                    ),
                    IconButton(
                      onPressed: () {
                        double newZoomLevel =
                            _pdfViewerController.zoomLevel + 0.5;
                        if (newZoomLevel <= 4) {
                          _pdfViewerController.zoomLevel = newZoomLevel;
                        }
                      },
                      icon: const Icon(Icons.zoom_in),
                    ),
                    if (!_isLoading)
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          setState(() {
                            if (value == 'Light Theme') {
                              _theme = 'light';
                            } else if (value == 'Dark Theme') {
                              _theme = 'dark';
                            } else if (value == 'Sepia Theme') {
                              _theme = 'sepia';
                            } else if (value == 'Vertical Scroll') {
                              _scrollDirection = 'vertical';
                            } else if (value == 'Horizontal Scroll') {
                              _scrollDirection = 'horizontal';
                            }
                            _savePreferences();
                          });
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                              value: 'Light Theme', child: Text('Light Theme')),
                          const PopupMenuItem(
                              value: 'Dark Theme', child: Text('Dark Theme')),
                          const PopupMenuItem(
                              value: 'Sepia Theme', child: Text('Sepia Theme')),
                          const PopupMenuItem(
                              value: 'Vertical Scroll',
                              child: Text('Vertical Scroll')),
                          const PopupMenuItem(
                              value: 'Horizontal Scroll',
                              child: Text('Horizontal Scroll')),
                        ],
                      ),
                  ],
                )
              : null,
          body: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ))
              : _localFilePath == null
                  ? const Center(child: Text('Failed to load PDF'))
                  : Stack(
                      children: [
                        // PDF Viewer
                        SfPdfViewerTheme(
                          data: SfPdfViewerThemeData(
                            backgroundColor: _theme == 'dark'
                                ? Colors.black
                                : _theme == 'sepia'
                                    ? const Color(0xFFE6D4B4)
                                    : Colors.white,
                          ),
                          child: SfPdfViewer.file(
                            File(_localFilePath!),
                            controller: _pdfViewerController,
                            scrollDirection: _scrollDirection == 'vertical'
                                ? PdfScrollDirection.vertical
                                : PdfScrollDirection.horizontal,
                            key: _pdfViewerStateKey,
                            canShowPageLoadingIndicator: true,
                            pageLayoutMode: _scrollDirection == 'vertical'
                                ? PdfPageLayoutMode.continuous
                                : PdfPageLayoutMode.single,
                            onTap: (details) async {
                              _toggleAppBarVisibility();
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setInt('last_interaction',
                                  DateTime.now().millisecondsSinceEpoch);
                              print('Tapped on page: ${details.pageNumber}');
                            },
                            interactionMode: PdfInteractionMode.pan,
                          ),
                        ),
                      ],
                    ),
          bottomNavigationBar: _isBottomNavVisible && !_isLoading
              ? BottomAppBar(
                  child: Padding(
                    padding: EdgeInsets.all(width * 0.0074),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_back,
                                  color: _getTextColor()),
                              onPressed: () async {
                                _pdfViewerController.previousPage();
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.arrow_forward,
                                  color: _getTextColor()),
                              onPressed: () async {
                                _pdfViewerController.nextPage();
                                _incrementPagesRead();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:flutter_pdfview/flutter_pdfview.dart';

// class OfflinePdfReader extends StatelessWidget {
  // final String documentPath;
  // final String title;

//   const OfflinePdfReader({required this.documentPath, required this.title});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text(
//             title,
//             style: TextStyle(color: Colors.white),
//           ),
//           backgroundColor: Colors.blue,
//           foregroundColor: Colors.white,
//           leading: IconButton(
//             icon: Icon(Icons.arrow_back),
//             onPressed: () {
//               Navigator.pop(context);
//             },
//           ),
//         ),
//         body: PDFView(
//           filePath: documentPath, // Use the result of getFile() here
//         ),
//       ),
//     );
//   }
// }
