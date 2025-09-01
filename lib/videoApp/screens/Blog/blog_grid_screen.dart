import 'package:flutter/material.dart';
import 'package:futurex_app/constants/networks.dart';
import 'package:futurex_app/videoApp/provider/blog_provider.dart';
import 'package:futurex_app/videoApp/provider/like_provider.dart';
import 'package:futurex_app/videoApp/screens/Blog/blog_detail_screen.dart';
import 'package:futurex_app/videoApp/screens/home_screen/home_screen.dart';

import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class BlogGridScreen extends StatefulWidget {
  const BlogGridScreen({super.key});

  @override
  State<BlogGridScreen> createState() => _BlogGridScreenState();
}

class _BlogGridScreenState extends State<BlogGridScreen> {
  final Map<int, VideoPlayerController> _videoControllers = {};
  int _currentIndex = 2; // Initialize to 2, as this is the BlogGridScreen

  @override
  void initState() {
    super.initState();
    _initializeLikes();
  }

  void _onNavBarTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Handle navigation based on the selected index
    switch (index) {
      case 0:
        // Navigator.of(context).pushReplacement(
        //   MaterialPageRoute(builder: (context) => const MyStudentScreenHome()),
        // );
        break;
      case 1:
        // Navigate to the Home screen
        // Navigator.of(context).pushReplacement(
        //   MaterialPageRoute(builder: (context) => HomeScreen()),
        // );
        break;
      case 2:
        // Navigate to the Blogs screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const BlogGridScreen()),
        );
        break;
      case 3:
        // Navigator.of(context).pushReplacement(
        //   MaterialPageRoute(
        //       builder: (context) => const MyStudentResultScreen()),
        // );
        break;
    }
  }

  Future<void> _initializeLikes() async {
    final likeProvider = Provider.of<LikeProvider>(context, listen: false);
    await likeProvider.initializeLikes(); // Fetch and initialize likes
  }

  // Refresh function to reload blogs
  Future<void> _refreshBlogs() async {
    final blogProvider = Provider.of<BlogProvider>(context, listen: false);
    await blogProvider
        .fetchBlogs(); // Assuming fetchBlogs is the method to reload blogs
    await _initializeLikes(); // Re-initialize likes after refreshing blogs
  }

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
  void dispose() {
    // Dispose all video controllers when the widget is disposed
    for (final controller in _videoControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Blogs',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshBlogs,
        child: Consumer2<BlogProvider, LikeProvider>(
          builder: (context, blogProvider, likeProvider, child) {
            if (blogProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (blogProvider.blogs.isEmpty) {
              return const Center(child: Text("No blogs available"));
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 3 / 4, // Aspect ratio for responsive design
                ),
                itemCount: blogProvider.blogs.length,
                itemBuilder: (context, index) {
                  final blog = blogProvider.blogs[index];
                  final isLiked = likeProvider.likedStatus[blog.id] ?? false;
                  final likeCount =
                      likeProvider.likeCounts[blog.id] ?? blog.likeCount;

                  return GestureDetector(
                    onTap: () {
                      // Navigate to the BlogDetailsScreen with the selected blog
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
                          // Media (Image or Video)
                          if (blog.media != null)
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16.0),
                                topRight: Radius.circular(16.0),
                              ),
                              child: _isVideo(blog.media)
                                  ? _buildVideoWithPlayIcon(blog.media, blog.id)
                                  : Image.network(
                                      "${Networks().userPath}/${blog.media}",
                                      height: 100,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          Container(), // Display empty container if image loading fails
                                    ),
                            )
                          else
                            Container(
                              height: 100,
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 40,
                                  color: Colors.grey,
                                ),
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
                              maxLines: 1, // Truncate to one line
                              overflow: TextOverflow
                                  .ellipsis, // Add ellipsis for long text
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8.0,
                            ),
                            child: Text(
                              blog.body,
                              style: const TextStyle(fontSize: 14),
                              maxLines: 1, // Truncate to one line
                              overflow: TextOverflow
                                  .ellipsis, // Add ellipsis for long text
                            ),
                          ),
                          const Spacer(), // Push the icons row to the bottom
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Like Section
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        isLiked
                                            ? Icons.thumb_up_alt
                                            : Icons.thumb_up_alt_outlined,
                                        color: isLiked
                                            ? Colors.blue
                                            : Colors.blue,
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
                                // Comment Section
                                Row(
                                  children: [
                                    Icon(
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
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildVideoWithPlayIcon(String? mediaUrl, int blogId) {
    final videoUrl = Networks().userPath + "/${mediaUrl ?? ''}";

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
}
