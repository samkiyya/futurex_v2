import 'package:flutter/material.dart';
import 'package:futurex_app/videoApp/provider/blog_provider.dart';
import 'package:futurex_app/videoApp/provider/like_provider.dart';
import 'package:futurex_app/videoApp/screens/Blog/blog_detail_screen.dart';
import 'package:futurex_app/widgets/app_bar.dart';
import 'package:provider/provider.dart';
import 'package:futurex_app/constants/networks.dart';
import 'package:video_player/video_player.dart';
import 'dart:developer' as developer; // For logging

class BlogGridScreenNotification extends StatefulWidget {
  const BlogGridScreenNotification({super.key});

  @override
  State<BlogGridScreenNotification> createState() =>
      _BlogGridScreenNotificationState();
}

class _BlogGridScreenNotificationState
    extends State<BlogGridScreenNotification> {
  final Map<int, VideoPlayerController> _videoControllers = {};

  // Detects if the media is a video based on the file extension
  bool _isVideo(String? media) {
    if (media == null) return false;
    final lowerMedia = media.toLowerCase();
    return lowerMedia.endsWith('.mp4') ||
        lowerMedia.endsWith('.mov') ||
        lowerMedia.endsWith('.avi') ||
        lowerMedia.endsWith('.mkv');
  }

  @override
  void initState() {
    super.initState();
    // Fetch blogs when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BlogProvider>(context, listen: false).loadBlogs();
    });
  }

  @override
  void dispose() {
    // Dispose all video controllers
    for (final controller in _videoControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(title: "Notifications"),
      backgroundColor: Colors.white,
      body: Consumer2<BlogProvider, LikeProvider>(
        builder: (context, blogProvider, likeProvider, child) {
          // Log the state for debugging
          developer.log('BlogProvider isLoading: ${blogProvider.isLoading}');
          developer.log('Blog count: ${blogProvider.blogs.length}');

          if (blogProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (blogProvider.blogs.isEmpty) {
            return const Center(
              child: Text(
                'No blogs available.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await blogProvider.loadBlogs();
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: blogProvider.blogs.length,
                itemBuilder: (context, index) {
                  final blog = blogProvider.blogs[index];
                  final isLiked = likeProvider.likedStatus[blog.id] ?? false;
                  final likeCount =
                      likeProvider.likeCounts[blog.id] ?? blog.likeCount;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BlogDetailsScreen(blog: blog),
                          ),
                        );
                      },
                      child: Container(
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
                            // Media section
                            _buildMediaWidget(blog.media, blog.id),
                            // Title
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                blog.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Body
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: Text(
                                blog.body,
                                style: const TextStyle(fontSize: 14),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Like and Comment section
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 8.0,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(16.0),
                                  bottomRight: Radius.circular(16.0),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // Like section
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          isLiked
                                              ? Icons.thumb_up_alt
                                              : Icons.thumb_up_alt_outlined,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () {
                                          likeProvider.toggleLike(blog.id);
                                        },
                                      ),
                                      Text(
                                        '$likeCount',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Comment section
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.comment_outlined,
                                        color: Colors.blue,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${blog.commentCount}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMediaWidget(String? mediaUrl, int blogId) {
    if (mediaUrl == null) {
      return Container(
        height: 100,
        color: Colors.grey[200],
        child: const Center(
          child: Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
        ),
      );
    }

    final fullUrl = mediaUrl.startsWith('https://')
        ? mediaUrl
        : "${Networks().coursePath}/$mediaUrl";

    if (_isVideo(mediaUrl)) {
      return _buildVideoWithPlayIcon(fullUrl, blogId);
    } else {
      return ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
        child: fullUrl.isNotEmpty
            ? Image.network(
                fullUrl,
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  developer.log('Image load error for $fullUrl: $error');
                  return Container(
                    height: 100,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              )
            : null,
      );
    }
  }

  Widget _buildVideoWithPlayIcon(String videoUrl, int blogId) {
    // Initialize controller only when needed
    if (!_videoControllers.containsKey(blogId)) {
      _videoControllers[blogId] =
          VideoPlayerController.networkUrl(Uri.parse(videoUrl))
            ..initialize()
                .then((_) {
                  if (mounted) {
                    setState(
                      () {},
                    ); // Update UI only if widget is still mounted
                  }
                })
                .catchError((error) {
                  developer.log(
                    'Video initialization error for $videoUrl: $error',
                  );
                });
    }

    final videoController = _videoControllers[blogId]!;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16.0),
        topRight: Radius.circular(16.0),
      ),
      child: SizedBox(
        height: 100,
        child: Stack(
          alignment: Alignment.center,
          children: [
            videoController.value.isInitialized
                ? AspectRatio(
                    aspectRatio: videoController.value.aspectRatio,
                    child: VideoPlayer(videoController),
                  )
                : Container(
                    height: 100,
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
            const Center(
              child: Icon(
                Icons.play_circle_outline,
                size: 50,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
