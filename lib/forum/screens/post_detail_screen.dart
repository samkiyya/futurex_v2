import 'package:flutter/material.dart';
import 'package:futurex_app/forum/models/comment.dart';
import 'package:futurex_app/forum/provider/comment_provider.dart';
import 'package:futurex_app/forum/provider/postCommnetProvider.dart';
import 'package:futurex_app/widgets/app_bar.dart';
import 'package:futurex_app/widgets/bottomNav.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/post.dart';

class CommentsScreen extends StatefulWidget {
  final Post post;
  const CommentsScreen({super.key, required this.post});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final Set<int> _expandedCommentIds = {};
  final Map<int, TextEditingController> _replyControllers = {};
  final Map<int, bool> _showReplyForm = {};
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<ForumCommentProvider>(
        context,
        listen: false,
      ).fetchComments(widget.post.id),
    );
  }

  void _toggleReplies(int commentId) {
    setState(() {
      _expandedCommentIds.contains(commentId)
          ? _expandedCommentIds.remove(commentId)
          : _expandedCommentIds.add(commentId);
    });
  }

  void _toggleReplyForm(int commentId) {
    setState(() {
      _showReplyForm[commentId] = !(_showReplyForm[commentId] ?? false);
      _replyControllers[commentId] ??= TextEditingController();
    });
  }

  void _submitReply(int commentId) async {
    final content = _replyControllers[commentId]?.text.trim() ?? '';
    if (content.isEmpty) return;

    final prov = Provider.of<PostCommentProvider>(context, listen: false);
    await prov.postReply(
      commentId: commentId,
      content: content,
      context: context,
      onSuccess: () {
        _replyControllers[commentId]?.clear();
        Provider.of<ForumCommentProvider>(
          context,
          listen: false,
        ).fetchComments(widget.post.id);
      },
    );
    FocusScope.of(context).unfocus();
  }

  void _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isNotEmpty) {
      final postCommentProv = Provider.of<PostCommentProvider>(
        context,
        listen: false,
      );
      await postCommentProv.postComment(
        postId: widget.post.id,
        content: content,
        context: context,
        onSuccess: () {
          _commentController.clear();
          Provider.of<ForumCommentProvider>(
            context,
            listen: false,
          ).fetchComments(widget.post.id);
        },
      );
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<ForumCommentProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: GradientAppBar(title: widget.post.title),
      body: Column(
        children: [
          Expanded(
            child: prov.loading
                ? const Center(child: CircularProgressIndicator())
                : prov.error != null
                ? Center(child: Text(prov.error!))
                : RefreshIndicator(
                    onRefresh: () => prov.fetchComments(widget.post.id),
                    child: LayoutBuilder(
                      builder: (ctx, constraints) {
                        final pad = constraints.maxWidth > 600 ? 48.0 : 16.0;
                        return ListView(
                          padding: EdgeInsets.symmetric(
                            horizontal: pad,
                            vertical: 16,
                          ),
                          children: [
                            _PostDetails(post: widget.post),
                            const SizedBox(height: 24),
                            Text(
                              'Comments (${prov.comments.length})',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...prov.comments.map(
                              (c) => _CommentCard(
                                comment: c,
                                isExpanded: _expandedCommentIds.contains(c.id),
                                onToggleReplies: () => _toggleReplies(c.id),
                                showReplyForm: _showReplyForm[c.id] ?? false,
                                replyController: _replyControllers[c.id],
                                onToggleReplyForm: () => _toggleReplyForm(c.id),
                                onSubmitReply: () => _submitReply(c.id),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
          ),
          Container(
            color: Colors.grey.shade100,
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: "Write a comment...",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _submitComment,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNav(
        onTabSelected: (index) {},
        currentSelectedIndex: 3,
      ),
    );
  }
}

class _PostDetails extends StatelessWidget {
  final Post post;
  const _PostDetails({required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = DateFormat.yMMMd().add_jm().format(post.createdAt.toLocal());

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(post.description, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  post.author.name,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
                Text(
                  date,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentCard extends StatelessWidget {
  final Comment comment;
  final bool isExpanded;
  final VoidCallback onToggleReplies;
  final bool showReplyForm;
  final TextEditingController? replyController;
  final VoidCallback onToggleReplyForm;
  final VoidCallback onSubmitReply;

  const _CommentCard({
    required this.comment,
    required this.isExpanded,
    required this.onToggleReplies,
    required this.showReplyForm,
    required this.replyController,
    required this.onToggleReplyForm,
    required this.onSubmitReply,
  });

  @override
  Widget build(BuildContext context) {
    final isSubmitting = Provider.of<PostCommentProvider>(context).isSubmitting;

    final theme = Theme.of(context);
    final date = DateFormat.yMMMd().add_jm().format(
      comment.createdAt.toLocal(),
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              comment.content,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    '- ${comment.author.name}, $date',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    if (comment.replies.isNotEmpty)
                      TextButton.icon(
                        onPressed: onToggleReplies,
                        icon: Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                        ),
                        label: Text(
                          isExpanded ? 'Hide Replies' : 'View Replies',
                        ),
                      ),
                    TextButton.icon(
                      onPressed: onToggleReplyForm,
                      icon: const Icon(Icons.reply),
                      label: const Text('Reply'),
                    ),
                  ],
                ),
              ],
            ),
            if (isExpanded)
              Container(
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: comment.replies
                      .map((r) => _ReplyCard(reply: r))
                      .toList(),
                ),
              ),
            if (showReplyForm)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: replyController,
                        decoration: InputDecoration(
                          hintText: 'Write a reply...',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    IconButton(
                      icon: isSubmitting
                          ? const CircularProgressIndicator(strokeWidth: 2)
                          : Icon(Icons.send, color: theme.colorScheme.primary),
                      onPressed: isSubmitting ? null : onSubmitReply,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ReplyCard extends StatelessWidget {
  final Reply reply;
  const _ReplyCard({required this.reply});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = DateFormat.yMMMd().add_jm().format(reply.createdAt.toLocal());

    return Container(
      margin: const EdgeInsets.only(top: 8, left: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(reply.content, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(
            '@${reply.author.name} • $date',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}
