import 'package:flutter/material.dart';
import 'package:futurex_app/forum/provider/discusssion_provider.dart';
import 'package:futurex_app/widgets/bottomNav.dart';
import 'package:provider/provider.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<DiscussionProvider>(context, listen: false);
    final success = await provider.createPost(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post submitted successfully')),
      );
      Navigator.of(context).pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.submitPostError ?? 'Unknown error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DiscussionProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Post')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => v == null || v.isEmpty ? 'Enter title' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 4,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter description' : null,
              ),
              const SizedBox(height: 24),
              provider.isSubmittingPost
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _submitPost,
                      icon: const Icon(Icons.send),
                      label: const Text('Submit Post'),
                    ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNav(
        onTabSelected: (index) {},
        currentSelectedIndex: 3,
      ),
    );
  }
}
