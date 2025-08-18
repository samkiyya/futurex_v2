import 'package:flutter/material.dart';
import 'package:futurex_app/videoApp/provider/blog_provider.dart';
import 'package:futurex_app/videoApp/provider/like_provider.dart';

import 'package:futurex_app/videoApp/screens/Blog/blog_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class BlogHorizontalSection extends StatefulWidget {
  const BlogHorizontalSection({super.key});

  @override
  State<BlogHorizontalSection> createState() => _BlogHorizontalSectionState();
}

class _BlogHorizontalSectionState extends State<BlogHorizontalSection> {
  String? selectedFilter;
  final Map<int, VideoPlayerController> _videoControllers = {};

  @override
  void initState() {
    super.initState();
    _initializeLikes();
  }

  Future<void> _initializeLikes() async {
    final likeProvider = Provider.of<LikeProvider>(context, listen: false);
    await likeProvider.initializeLikes(); // Fetch and initialize likes
  }

  @override
  void dispose() {
    // Dispose all video controllers when the widget is disposed
    for (final controller in _videoControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future<bool> _checkLoginStatus() async {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey('parentId');
    }

    return Consumer<BlogProvider>(
      builder: (context, blogProvider, child) {
        final blogs = blogProvider.blogs;

        // Extract unique notification types from blogs
        final notificationTypes = blogs
            .map((blog) => blog.notificationType)
            .toSet()
            .toList();

        // Filter blogs based on selected filter
        final filteredBlogs = selectedFilter == null
            ? blogs // Show all blogs if no filter is selected
            : blogs
                  .where((blog) => blog.notificationType == selectedFilter)
                  .toList();

        return Padding(
          padding: const EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter Section
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: notificationTypes.length,
                  itemBuilder: (context, index) {
                    final type = notificationTypes[index];
                    final isSelected = type == selectedFilter;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedFilter = isSelected
                              ? null
                              : type; // Toggle selection
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          color: isSelected ? Colors.blue : Colors.grey[200],
                        ),
                        child: Center(
                          child: Text(
                            type,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16.0),

              // Featured Blogs Title
              Text(
                "latest notifications", // "Featured Blogs"
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 16.0),

              // Blogs Section
              SizedBox(
                height: 270,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: filteredBlogs.isNotEmpty
                      ? filteredBlogs.length
                      : 3, // Show 3 static placeholders when loading or no blogs
                  itemBuilder: (context, index) {
                    if (blogProvider.isLoading || filteredBlogs.isEmpty) {
                      // Static Placeholder Card
                      return _buildPlaceholderCard();
                    } else {
                      // Blog Card
                      final blog = filteredBlogs[index];
                      return GestureDetector(
                        onTap: () {
                          // Navigate to the Details Screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  BlogDetailsScreen(blog: blog),
                            ),
                          );
                        },
                        child: _buildBlogCard(blog),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBlogCard(blog) {
    final isVideo = _isVideo(blog.media);

    return Consumer<LikeProvider>(
      builder: (context, likeProvider, child) {
        final isLiked = likeProvider.likedStatus[blog.id] ?? false;
        final likeCount = likeProvider.likeCounts[blog.id] ?? blog.likeCount;

        return Container(
          width: 300,
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display video or image
              blog.media != null
                  ? ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16.0),
                        topRight: Radius.circular(16.0),
                      ),
                      child: isVideo
                          ? _buildVideoWithPlayIcon(blog.media, blog.id)
                          : Image.network(
                              "https://usersservice.futurexapp.net/${blog.media}",
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.broken_image,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                            ),
                    )
                  : Container(
                      height: 150,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.image, size: 50, color: Colors.grey),
                      ),
                    ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  blog.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 8.0,
                  left: 8.0,
                  right: 8.0,
                  bottom: 2.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final isLoggedIn = await SharedPreferences.getInstance()
                            .then((prefs) => prefs.containsKey('parentId'));

                        if (!isLoggedIn) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "login required",
                              ), // "Login required"
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        // Toggle like
                        likeProvider.toggleLike(blog.id);
                      },
                      child: Row(
                        children: [
                          AnimatedScale(
                            scale: isLiked ? 1.2 : 1.0,
                            duration: const Duration(milliseconds: 200),
                            child: Icon(
                              isLiked
                                  ? Icons.thumb_up_alt
                                  : Icons.thumb_up_alt_outlined,
                              color: isLiked ? Colors.blue : Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$likeCount',
                            style: TextStyle(
                              color: isLiked ? Colors.blue : Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "likes", // "likes"
                            style: TextStyle(color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.comment_outlined, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text(
                          '${blog.commentCount}',
                          style: TextStyle(color: Colors.blue),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "comments", // "comments"
                          style: TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isVideo(String? media) {
    if (media == null) return false;
    final lowerMedia = media.toLowerCase();
    return lowerMedia.endsWith('.mp4') ||
        lowerMedia.endsWith('.mov') ||
        lowerMedia.endsWith('.avi') ||
        lowerMedia.endsWith('.mkv');
  }

  Widget _buildVideoWithPlayIcon(String mediaUrl, int blogId) {
    final videoUrl = "https://usersservice.futurexapp.net/$mediaUrl";

    if (!_videoControllers.containsKey(blogId)) {
      _videoControllers[blogId] = VideoPlayerController.network(videoUrl)
        ..initialize().then((_) {
          setState(() {}); // Ensure the video is displayed once initialized
        });
    }

    final videoController = _videoControllers[blogId]!;

    return Stack(
      alignment: Alignment.center,
      children: [
        AspectRatio(
          aspectRatio: videoController.value.isInitialized
              ? videoController.value.aspectRatio
              : 16 / 9, // Default aspect ratio
          child: videoController.value.isInitialized
              ? VideoPlayer(videoController)
              : const Center(child: CircularProgressIndicator()),
        ),
        const Center(
          child: Icon(Icons.play_circle_outline, size: 50, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildPlaceholderCard() {
    return Container(
      width: 300,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Placeholder for the image
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: SizedBox(
              height: 20,
              width: 180,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: SizedBox(
              height: 14,
              width: 240,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.thumb_up_alt_outlined, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Container(height: 12, width: 20, color: Colors.grey[300]),
                    const SizedBox(width: 4),
                    Text(
                      "Likes", // "likes"
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.comment_outlined, color: Colors.grey[400]),
                    const SizedBox(width: 4),
                    Container(height: 12, width: 20, color: Colors.grey[300]),
                    const SizedBox(width: 4),
                    Text(
                      "comments", // "comments"
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
