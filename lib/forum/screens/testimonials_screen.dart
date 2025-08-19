import 'package:flutter/material.dart';
import 'package:futurex_app/videoApp/provider/login_provider.dart';
import 'package:futurex_app/widgets/app_bar.dart';
import 'package:futurex_app/widgets/bottomNav.dart';
import 'package:provider/provider.dart';
import 'package:futurex_app/forum/provider/testimonial_provider.dart';
import 'package:futurex_app/forum/models/testimonial.dart';
import 'package:futurex_app/forum/widgets/testimonials/create_testimonial_dialog.dart';
import 'package:futurex_app/forum/widgets/testimonials/testimonial_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TestimonialsScreen extends StatefulWidget {
  static const routeName = '/testimonials';
  const TestimonialsScreen({super.key});

  @override
  State<TestimonialsScreen> createState() => _TestimonialsScreenState();
}

class _TestimonialsScreenState extends State<TestimonialsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchInitialData();
    });
  }

  Future<void> _fetchInitialData() async {
    final provider = Provider.of<TestimonialProvider>(context, listen: false);
    provider.clearError();
    await provider.fetchTestimonials(forceRefresh: true);
  }

  Future<void> _handleRefresh() async {
    final provider = Provider.of<TestimonialProvider>(context, listen: false);
    provider.clearError();
    await provider.fetchTestimonials(forceRefresh: true);
  }

  void _showCreateTestimonialDialog() async {
    final theme = Theme.of(context);
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Please login or register first to send testimony',
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    final success = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return CreateTestimonialDialog(userId: int.parse(userId));
      },
    );

    if (success == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Testimonial submitted successfully!'),
          backgroundColor: Colors.blueAccent.shade700,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Widget _buildCenteredFeedback({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String message,
    required VoidCallback onRetry,
    bool isLoading = false,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.8),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        color: Colors.blueAccent.shade700.withOpacity(0.8),
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh, size: 20),
                        label: const Text('Refresh'),
                        onPressed: isLoading ? null : onRetry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          shadowColor: Colors.blueAccent.withOpacity(0.4),
                        ),
                      ),
                      const SizedBox.shrink(), // Shrink when no additional content
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, TestimonialProvider provider) {
    final testimonials = provider.testimonials;
    final isLoading = provider.isLoading;
    final error = provider.error;

    if (isLoading && testimonials.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.blueAccent.shade700,
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading Testimonials...',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
            const SizedBox.shrink(), // Shrink when no additional content
          ],
        ),
      );
    }

    if (error != null && testimonials.isEmpty) {
      return _buildCenteredFeedback(
        context: context,
        icon: Icons.error_outline,
        title: "Failed to connect!",
        message: error,
        onRetry: _handleRefresh,
        isLoading: isLoading,
      );
    }

    if (testimonials.isEmpty && !isLoading) {
      return _buildCenteredFeedback(
        context: context,
        icon: Icons.rate_review_outlined,
        title: "No  students Testimonials ",
        message: "Be the first to share your testimony!",
        onRetry: _handleRefresh,
        isLoading: isLoading,
      );
    }

    return TestimonialList(
      testimonials: testimonials,
      apiBaseUrl: Testimonial.imageBaseUrl,
      onRefresh: _handleRefresh,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Testimonials',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blueAccent.shade700,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent.shade700, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Consumer<TestimonialProvider>(
          builder: (context, provider, _) => _buildContent(context, provider),
        ),
      ),
      floatingActionButton: Consumer<TestimonialProvider>(
        builder: (context, provider, _) {
          return AnimatedScale(
            scale: provider.isLoading ? 0.9 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: FloatingActionButton.extended(
              onPressed: provider.isLoading
                  ? null
                  : _showCreateTestimonialDialog,
              icon: const Icon(Icons.add_comment_outlined, size: 20),
              label: const Text(
                'Add Testimonial',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              backgroundColor: Colors.blueAccent.shade700,
              foregroundColor: Colors.white,
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNav(
        onTabSelected: (index) {},
        currentSelectedIndex: 3,
      ),
    );
  }
}
