import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:futurex_app/constants/networks.dart';
import 'package:futurex_app/videoApp/models/course_model.dart';
import 'package:futurex_app/order_screens/payment_details_screen.dart';

class CategorySelectionScreen extends StatefulWidget {
  final bool isFull;
  final String type;
  const CategorySelectionScreen({
    super.key,
    required this.type,
    required this.isFull,
  });

  @override
  State<CategorySelectionScreen> createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  List<Category> _categories = [];
  final List<int> _selectedCategoryIds = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final dio = Dio();
    final primaryUrl = '${Networks().courseAPI}/catagories';
    final secondaryUrl = '${Networks().courseAPI}/categories';
    Response? response;

    try {
      response = await dio.get(
        primaryUrl,
        options: Options(headers: {'Accept': 'application/json'}),
      );
    } catch (_) {
      try {
        response = await dio.get(
          secondaryUrl,
          options: Options(headers: {'Accept': 'application/json'}),
        );
      } catch (_) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Unable to load categories. Please try again.';
        });
        return;
      }
    }

    try {
      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> list = data is List
            ? data
            : (data is Map<String, dynamic>
                  ? (data['data'] as List?) ??
                        (data['categories'] as List?) ??
                        []
                  : []);

        final parsed = list
            .map(
              (json) => Category.fromJson(
                json is Map<String, dynamic>
                    ? json
                    : Map<String, dynamic>.from(json),
              ),
            )
            .toList();

        setState(() {
          _categories = parsed;
          _isLoading = false;

          if (widget.isFull) {
            _selectedCategoryIds
              ..clear()
              ..addAll(_categories.map((c) => c.id));
          }
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Unable to load categories. Please try again.';
        });
      }
    } catch (_) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to load categories. Please try again.';
      });
    }
  }

  void _toggleCategorySelection(int categoryId) {
    // If isFull is true, don't allow changes to selection
    if (widget.isFull) return;

    setState(() {
      if (_selectedCategoryIds.contains(categoryId)) {
        _selectedCategoryIds.remove(categoryId);
      } else {
        // For single selection, clear previous selection first
        _selectedCategoryIds.clear();
        _selectedCategoryIds.add(categoryId);
      }
    });
  }

  void _handleNext() {
    if (_selectedCategoryIds.isEmpty && !widget.isFull) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one category')),
      );
      return;
    }

    final selectedCategories = widget.isFull
        ? _categories // All categories if isFull
        : _categories
              .where((category) => _selectedCategoryIds.contains(category.id))
              .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentDetailsScreen(
          type: widget.type,
          selectedCategories: selectedCategories,
        ),
      ),
    );
  }

  Widget _buildGradeChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? (widget.isFull ? Colors.blue : Colors.blue)
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(25),
          border: widget.isFull && isSelected
              ? Border.all(color: Colors.blue.shade800, width: 2)
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.isFull ? 'All Grades Included' : 'Select Grade',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: screenHeight - 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    widget.isFull
                        ? 'Your premium plan includes all grade levels'
                        : 'Choose the grade level for your enrollment',
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_errorMessage != null)
                  Center(
                    child: Column(
                      children: [
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _isLoading = true;
                              _errorMessage = null;
                            });
                            _fetchCategories();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                else
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: _categories.map((category) {
                      return _buildGradeChip(
                        label: category.catagory,
                        isSelected: _selectedCategoryIds.contains(category.id),
                        onTap: () => _toggleCategorySelection(category.id),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _handleNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.isFull
                          ? Colors.blue
                          : Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      widget.isFull ? 'Continue with All Grades' : 'Continue',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                if (widget.isFull)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text(
                      'All grade levels are included in your premium plan',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
