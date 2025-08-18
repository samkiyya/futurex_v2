// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class PdfViewer extends StatefulWidget {
  final String documentPath;
  final String title;

  const PdfViewer({super.key, required this.documentPath, required this.title});

  @override
  State<PdfViewer> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  String? _localFilePath;
  bool _isLoading = true;
  late SharedPreferences _prefs;
  String _theme = 'light';
  final bool _isAppBarVisible = true;
  final bool _isBottomNavVisible = true;
  late PdfViewerController _pdfViewerController;
  String _scrollDirection = 'vertical';
  final GlobalKey<SfPdfViewerState> _pdfViewerStateKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _loadPreferences();
    _preparePdf();
  }

  Future<void> _preparePdf() async {
    try {
      String processedUrl = processPdfUrl(widget.documentPath);
      String filePath = await downloadPdf(processedUrl);
      setState(() {
        _localFilePath = filePath;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError("Failed to load PDF. Please try again.");
    }
  }

  String processPdfUrl(String pdfName) {
    String baseUrl = 'https://111.21.27.29.futurex.et/uploads/lesson_files/';
    if (!pdfName.startsWith(baseUrl)) {
      pdfName = baseUrl + pdfName;
    }
    if (pdfName.endsWith('.1')) {
      pdfName = '${pdfName.substring(0, pdfName.length - 2)}.pdf';
    }
    return pdfName;
  }

  Future<String> downloadPdf(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/downloaded_pdf.pdf';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      return filePath;
    } else {
      throw Exception("Failed to download PDF");
    }
  }

  Future<void> _loadPreferences() async {
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

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Color _getOverlayColor() {
    switch (_theme) {
      case 'dark':
        return Colors.black.withOpacity(0.5);
      case 'sepia':
        return const Color(0xFF704214).withOpacity(0.3);
      default:
        return Colors.transparent;
    }
  }

  Color _getTextColor() {
    return _theme == 'dark' ? Colors.white : Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Theme(
        data: ThemeData(
          brightness: _theme == 'dark' ? Brightness.dark : Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: _getOverlayColor(),
          appBar: _isAppBarVisible
              ? AppBar(
                  title: Text(widget.title),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.zoom_out),
                      onPressed: () {
                        if (_pdfViewerController.zoomLevel > 1) {
                          _pdfViewerController.zoomLevel -= 0.5;
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.zoom_in),
                      onPressed: () {
                        if (_pdfViewerController.zoomLevel < 4) {
                          _pdfViewerController.zoomLevel += 0.5;
                        }
                      },
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        setState(() {
                          if (value == 'Light Theme') _theme = 'light';
                          if (value == 'Dark Theme') _theme = 'dark';
                          if (value == 'Sepia Theme') _theme = 'sepia';
                          if (value == 'Vertical Scroll') {
                            _scrollDirection = 'vertical';
                          }
                          if (value == 'Horizontal Scroll') {
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
              ?  Center(child: Text(widget.documentPath,style:TextStyle(color:Colors.red)))
              : _localFilePath == null
                  ? const Center(child: Text('Failed to load PDF'))
                  : Stack(
                      children: [
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
                          ),
                        ),
                      ],
                    ),
          bottomNavigationBar: _isBottomNavVisible && !_isLoading
              ? BottomAppBar(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: _getTextColor()),
                        onPressed: () {
                          _pdfViewerController.previousPage();
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_forward, color: _getTextColor()),
                        onPressed: () {
                          _pdfViewerController.nextPage();
                        },
                      ),
                    ],
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
