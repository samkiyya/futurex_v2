import 'package:flutter/material.dart';
import 'package:futurex_app/forum/provider/testimonial_provider.dart';
import 'package:futurex_app/videoApp/provider/login_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

class CreateTestimonialDialog extends StatefulWidget {
  const CreateTestimonialDialog({super.key, required int userId});

  @override
  State<CreateTestimonialDialog> createState() =>
      _CreateTestimonialDialogState();
}

class _CreateTestimonialDialogState extends State<CreateTestimonialDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  XFile? _pickedImage;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (!mounted) return;

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1000,
      );

      if (pickedFile != null && mounted) {
        setState(() {
          _pickedImage = pickedFile;
        });
      }
    } catch (e) {
      if (e is Exception && e.toString().contains('No file selected')) {
        return; // User canceled picker
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Failed to pick image"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  void _removeImage() {
    if (!mounted) return;
    setState(() {
      _pickedImage = null;
    });
  }

  Future<void> _submitTestimonial() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (description.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "Please enter your testimony about Futurex edication ",
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
      return;
    }

    if (_isSubmitting) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Please log in to submit a testimonial"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final testimonialProvider = Provider.of<TestimonialProvider>(
      context,
      listen: false,
    );
    testimonialProvider.clearError();

    final success = await testimonialProvider.createTestimonial(
      title: title,
      description: description,
      userId: userId,
      imageFiles: _pickedImage != null ? [_pickedImage!] : null,
    );

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });

      if (success) {
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              testimonialProvider.error ?? "Failed to submit testimonial",
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      backgroundColor: Colors.white,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.disabled,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Share Your Testimonial in Futurex Education ",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Tell us about your testimony about Futurex!",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: "Title",
                        labelStyle: TextStyle(color: Colors.grey.shade600),
                        filled: true,
                        fillColor: Colors.blue.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blue.shade100),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.blueAccent.shade700,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.redAccent,
                            width: 1,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.redAccent,
                            width: 2,
                          ),
                        ),
                        prefixIcon: Icon(
                          Icons.title,
                          color: Colors.blueAccent.shade700,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please enter a title";
                        }
                        return null;
                      },
                      enabled: !_isSubmitting,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: "Your testimony ",
                        labelStyle: TextStyle(color: Colors.grey.shade600),
                        filled: true,
                        fillColor: Colors.blue.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blue.shade100),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.blueAccent.shade700,
                            width: 2,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.redAccent,
                            width: 1,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.redAccent,
                            width: 2,
                          ),
                        ),
                        prefixIcon: Icon(
                          Icons.description,
                          color: Colors.blueAccent.shade700,
                        ),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 5,
                      minLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Please enter your testimony";
                        }
                        return null;
                      },
                      enabled: !_isSubmitting,
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: _pickedImage != null || _isSubmitting
                          ? null
                          : _pickImage,
                      icon: Icon(
                        _pickedImage != null
                            ? Icons.image_outlined
                            : Icons.image,
                        color: _pickedImage != null || _isSubmitting
                            ? Colors.grey.shade400
                            : Colors.blueAccent.shade700,
                      ),
                      label: Text(
                        _pickedImage == null
                            ? "upload your  photo"
                            : "Image Selected",
                        style: TextStyle(
                          color: _pickedImage != null || _isSubmitting
                              ? Colors.grey.shade400
                              : Colors.blueAccent.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        side: BorderSide(
                          color: _pickedImage != null || _isSubmitting
                              ? Colors.grey.shade400
                              : Colors.blueAccent.shade700,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    if (_pickedImage != null)
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.shade100.withOpacity(
                                0.3,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(_pickedImage!.path),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        color: Colors.redAccent,
                                        size: 40,
                                      ),
                                    ),
                              ),
                            ),
                            if (!_isSubmitting)
                              Positioned(
                                right: 8,
                                top: 8,
                                child: GestureDetector(
                                  onTap: _removeImage,
                                  child: CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.redAccent
                                        .withOpacity(0.9),
                                    child: const Icon(
                                      Icons.close,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _isSubmitting
                              ? null
                              : () => Navigator.of(context).pop(false),
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              color: _isSubmitting
                                  ? Colors.grey.shade400
                                  : Colors.blueAccent.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitTestimonial,
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
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.send, size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      "Send",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isSubmitting)
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.blueAccent,
                  strokeWidth: 3,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
