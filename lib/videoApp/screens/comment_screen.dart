import 'package:flutter/material.dart';
import 'package:futurex_app/videoApp/provider/comment_provider.dart';
import 'package:futurex_app/widgets/appBar.dart';
import 'package:futurex_app/widgets/comment_widgets/comment_header.dart';
import 'package:futurex_app/widgets/comment_widgets/comment_input.dart';
import 'package:futurex_app/widgets/comment_widgets/comment_list.dart';
import 'package:futurex_app/widgets/comment_widgets/rating_section.dart';
import 'package:provider/provider.dart';

class CommentScreen extends StatelessWidget {
  final String courseId;
  final String thumbnail;
  final String title;
  final int likes;
  final int comment;

  const CommentScreen({
    super.key,
    required this.courseId,
    required this.thumbnail,
    required this.title,
    required this.likes,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CommentProvider(courseId, likes)..setContext(context),
      child: Scaffold(
        appBar: GradientAppBar(title: "Comments for $title'"),
        body: Consumer<CommentProvider>(
          builder: (context, provider, child) {
            return provider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommentHeader(
                          thumbnail: thumbnail,
                          likesCount: provider.likesCount,
                          commentsCount: provider.comments.length,
                          onLikePressed: () => provider.toggleLike(context),
                        ),
                        const SizedBox(height: 16),
                        RatingSection(
                          initialRating: provider.rating,
                          onRatingChanged: provider.updateRating,
                        ),
                        const SizedBox(height: 16),
                        CommentInput(
                          controller: provider.commentTextController,
                          onSubmit: () => provider.submitComment(context),
                        ),
                        const SizedBox(height: 16),
                        CommentList(comments: provider.comments),
                      ],
                    ),
                  );
          },
        ),
      ),
    );
  }
}
