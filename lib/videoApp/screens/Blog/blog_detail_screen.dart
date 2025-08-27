import 'package:flutter/material.dart';
import 'package:futurex_app/constants/networks.dart';
import 'package:futurex_app/videoApp/provider/blog_comment_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:futurex_app/videoApp/models/blog_model.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

class BlogDetailsScreen extends StatefulWidget {
  final Blog blog;
  const BlogDetailsScreen({required this.blog, super.key});

  @override
  State<BlogDetailsScreen> createState() => _BlogDetailsScreenState();
}

class _BlogDetailsScreenState extends State<BlogDetailsScreen> {
  final Map<int, bool> _expandedComments = {};
  final Map<int, TextEditingController> _replyControllers = {};
  final TextEditingController _commentController = TextEditingController();

  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    if (widget.blog.media != null &&
        widget.blog.media!.toLowerCase().endsWith('.mp4')) {
      _initializeVideoPlayer();
    }
  }

  void _initializeVideoPlayer() {
    final media = widget.blog.media ?? '';
    final videoUrl = media.startsWith('http')
        ? media
        : (() {
            final base = Networks().coursePath;
            final needsSlash = !(base.endsWith('/') || media.startsWith('/'));
            return needsSlash ? "$base/$media" : "$base$media";
          })();
    _videoPlayerController = VideoPlayerController.network(videoUrl)
      ..initialize()
          .then((_) {
            _chewieController = ChewieController(
              videoPlayerController: _videoPlayerController!,
              autoPlay: false,
              looping: false,
            );
            setState(() {}); // Trigger rebuild after initialization
          })
          .catchError((error) {
            // Handle initialization errors
            debugPrint("Video initialization error: $error");
          });
  }

  @override
  void dispose() {
    _commentController.dispose();
    for (var controller in _replyControllers.values) {
      controller.dispose();
    }
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  String _safeTimeago(String input) {
    try {
      if (input.isEmpty) return '';
      final dt = DateTime.parse(input);
      return timeago.format(dt);
    } catch (_) {
      return '';
    }
  }

  void _openImageViewer(String url) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(ctx).pop(),
              child: Container(color: Colors.black.withOpacity(0.95)),
            ),
            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 5,
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(strokeWidth: 3),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.broken_image, color: Colors.white);
                  },
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(ctx).padding.top + 8,
              right: 8,
              child: IconButton(
                onPressed: () => Navigator.of(ctx).pop(),
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                splashRadius: 20,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _refreshComments(CommentProvider commentProvider) async {
    await commentProvider.fetchComments(widget.blog.id);
  }

  Future<bool> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('userId');
  }

  void _handleAddComment(
    CommentProvider commentProvider,
    String commentText,
  ) async {
    if (await _checkLoginStatus()) {
      await commentProvider.addComment(widget.blog.id, commentText);
      _commentController.clear();
      await _refreshComments(commentProvider);
    } else {
      // LoginPromptModal.show(context);
    }
  }

  void _handleAddReply(
    CommentProvider commentProvider,
    int commentId,
    String replyText,
  ) async {
    if (await _checkLoginStatus()) {
      await commentProvider.addReply(commentId, replyText);
      _replyControllers[commentId]?.clear();
      await commentProvider.fetchReplies(
        commentId,
      ); // Re-fetch replies for this comment
    } else {
      //LoginPromptModal.show(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          widget.blog.title,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: ChangeNotifierProvider(
        create: (_) => CommentProvider()..fetchComments(widget.blog.id),
        child: Consumer<CommentProvider>(
          builder: (context, commentProvider, child) {
            return Column(
              children: [
                // Media Section
                if (widget.blog.media != null &&
                    widget.blog.media!.trim().isNotEmpty &&
                    widget.blog.media!.trim().toLowerCase() != 'null') ...[
                  widget.blog.media!.toLowerCase().endsWith('.mp4')
                      ? _videoPlayerController != null &&
                                _videoPlayerController!.value.isInitialized
                            ? AspectRatio(
                                aspectRatio:
                                    _videoPlayerController!.value.aspectRatio,
                                child: Chewie(controller: _chewieController!),
                              )
                            : const Center(child: CircularProgressIndicator())
                      : Builder(
                          builder: (context) {
                            final media = widget.blog.media!.trim();
                            final url = media.startsWith('http')
                                ? media
                                : () {
                                    final base = Networks().coursePath;
                                    final needsSlash =
                                        !(base.endsWith('/') ||
                                            media.startsWith('/'));
                                    return needsSlash
                                        ? "$base/$media"
                                        : "$base$media";
                                  }();

                            return GestureDetector(
                              onTap: () => _openImageViewer(url),
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16.0),
                                  topRight: Radius.circular(16.0),
                                ),
                                child: Stack(
                                  children: [
                                    SizedBox(
                                      width: double.infinity,
                                      height: 220,
                                      child: Image.network(
                                        url,
                                        fit: BoxFit.cover,
                                        loadingBuilder:
                                            (context, child, progress) {
                                              if (progress == null)
                                                return child;
                                              return const Center(
                                                child: SizedBox(
                                                  width: 28,
                                                  height: 28,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2.5,
                                                      ),
                                                ),
                                              );
                                            },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return const Center(
                                                child: Icon(
                                                  Icons.broken_image,
                                                  color: Colors.grey,
                                                ),
                                              );
                                            },
                                      ),
                                    ),
                                    Positioned(
                                      right: 8,
                                      bottom: 8,
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.zoom_in,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ],
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    widget.blog.body,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => _refreshComments(commentProvider),
                    child: commentProvider.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            itemCount: commentProvider.comments.length,
                            itemBuilder: (context, index) {
                              final comment = commentProvider.comments[index];
                              final isExpanded =
                                  _expandedComments[comment.id] ?? false;

                              _replyControllers.putIfAbsent(
                                comment.id,
                                () => TextEditingController(),
                              );

                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 12,
                                ),
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              comment.comment,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              isExpanded
                                                  ? Icons.expand_less
                                                  : Icons.expand_more,
                                              color: Colors.blue,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _expandedComments[comment.id] =
                                                    !isExpanded;
                                                if (!commentProvider.repliesMap
                                                    .containsKey(comment.id)) {
                                                  commentProvider.fetchReplies(
                                                    comment.id,
                                                  );
                                                }
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const SizedBox(width: 8),
                                          Text(
                                            " ${comment.user?.fullName ?? 'Unknown User'}",
                                            style: const TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        _safeTimeago(comment.createdAt),
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      if (isExpanded) ...[
                                        const Divider(),
                                        if (commentProvider
                                                .repliesMap[comment.id]
                                                ?.isEmpty ??
                                            true)
                                          Text("no replay"),
                                        ...?commentProvider
                                            .repliesMap[comment.id]
                                            ?.map(
                                              (reply) => Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 16.0,
                                                  top: 4.0,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "↳ ${reply.reply}",
                                                      style: const TextStyle(
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                    Text(
                                                      _safeTimeago(
                                                        reply.createdAt,
                                                      ),
                                                      style: const TextStyle(
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                controller:
                                                    _replyControllers[comment
                                                        .id],
                                                decoration: InputDecoration(
                                                  hintText:
                                                      "write replay", // "Write a reply..."
                                                  enabled: !context
                                                      .watch<CommentProvider>()
                                                      .isAddingReply, // Disable input while loading
                                                ),
                                                onSubmitted: (replyText) {
                                                  if (replyText.isNotEmpty) {
                                                    _handleAddReply(
                                                      context
                                                          .read<
                                                            CommentProvider
                                                          >(),
                                                      comment.id,
                                                      replyText,
                                                    );
                                                  }
                                                },
                                              ),
                                            ),
                                            context
                                                    .watch<CommentProvider>()
                                                    .isAddingReply
                                                ? const CircularProgressIndicator() // Show loading indicator
                                                : IconButton(
                                                    icon: const Icon(
                                                      Icons.send,
                                                      color: Colors.blue,
                                                    ),
                                                    onPressed: () {
                                                      final replyText =
                                                          _replyControllers[comment
                                                                  .id]
                                                              ?.text ??
                                                          "";
                                                      if (replyText
                                                          .isNotEmpty) {
                                                        _handleAddReply(
                                                          context
                                                              .read<
                                                                CommentProvider
                                                              >(),
                                                          comment.id,
                                                          replyText,
                                                        );
                                                      }
                                                    },
                                                  ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: "Add comment", // "Add a comment..."
                            enabled: !context
                                .watch<CommentProvider>()
                                .isAddingComment, // Disable input while loading
                          ),
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              _handleAddComment(
                                context.read<CommentProvider>(),
                                value,
                              );
                            }
                          },
                        ),
                      ),
                      context.watch<CommentProvider>().isAddingComment
                          ? const CircularProgressIndicator() // Show loading indicator
                          : IconButton(
                              icon: const Icon(Icons.send, color: Colors.blue),
                              onPressed: () {
                                final commentText = _commentController.text;
                                if (commentText.isNotEmpty) {
                                  _handleAddComment(
                                    context.read<CommentProvider>(),
                                    commentText,
                                  );
                                }
                              },
                            ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
