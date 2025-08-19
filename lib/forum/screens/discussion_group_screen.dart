import 'package:flutter/material.dart';
import 'package:futurex_app/forum/models/post.dart';
import 'package:futurex_app/forum/provider/post_provider.dart';
import 'package:futurex_app/forum/screens/create_forum.dart';
import 'package:futurex_app/forum/screens/post_detail_screen.dart';
import 'package:futurex_app/widgets/app_bar.dart';
import 'package:futurex_app/widgets/bottomNav.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PostsScreen extends StatefulWidget {
  const PostsScreen({super.key});

  @override
  State<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends State<PostsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<PostProvider>(context, listen: false).fetchPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<PostProvider>(context);

    Widget bodyContent;

    if (prov.isLoading && prov.posts.isEmpty) {
      bodyContent = const Center(child: CircularProgressIndicator());
    } else if (prov.error != null) {
      bodyContent = Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                prov.error!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: prov.fetchPosts,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    } else if (prov.posts.isEmpty) {
      bodyContent = const Center(
        child: Text('No posts found', style: TextStyle(fontSize: 18)),
      );
    } else {
      bodyContent = RefreshIndicator(
        onRefresh: prov.fetchPosts,
        child: LayoutBuilder(
          builder: (ctx, constraints) {
            final isWide = constraints.maxWidth > 600;
            final crossAxisCount = isWide ? 2 : 1;

            return GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: isWide ? 3 : 1.8,
              ),
              itemCount: prov.posts.length,
              itemBuilder: (ctx, i) {
                final post = prov.posts[i];
                return _PostCard(post: post);
              },
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: GradientAppBar(title: "Discussion"),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => CreatePostScreen()));
        },
        child: Text("ASk Question"),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: bodyContent,
      ),
      bottomNavigationBar: BottomNav(
        onTabSelected: (index) {},
        currentSelectedIndex: 3,
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final Post post;
  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat.yMMMd().add_jm().format(post.createdAt.toLocal());

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              post.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  post.author.name,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  date,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CommentsScreen(post: post),
                    ),
                  );
                },
                icon: const Icon(Icons.comment_outlined),
                label: const Text("View Details"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
