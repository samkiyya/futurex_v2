import 'package:flutter/material.dart';
import 'package:futurex_app/constants/base_urls.dart';
import 'package:futurex_app/constants/networks.dart';
import 'package:futurex_app/forum/models/testimonial.dart';
import 'package:intl/intl.dart';

class TestimonialListItem extends StatelessWidget {
  final Testimonial testimonial;
  final String apiBaseUrl;

  const TestimonialListItem({
    super.key,
    required this.testimonial,
    required this.apiBaseUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final String authorName =
        testimonial.author != null && testimonial.author.name.isNotEmpty
        ? testimonial.author.name
        : "Anonymous";
    final String testimonialTitle = testimonial.title;
    final String testimonialDescription = testimonial.description;
    final List<String> displayImageUrls = testimonial.images;

    return Card(
      key: ValueKey(testimonial.id),
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    authorName.isNotEmpty ? authorName[0].toUpperCase() : "A",
                    style: TextStyle(
                      fontSize: 18,
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    authorName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (displayImageUrls.isNotEmpty)
              SizedBox(
                height: 180,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: displayImageUrls.length,
                  itemBuilder: (context, imgIndex) {
                    final imageUrl = displayImageUrls[imgIndex];
                    final fullImageUrl =
                        imageUrl.startsWith('http') ||
                            imageUrl.startsWith('https')
                        ? imageUrl
                        : "${BaseUrls.forumService}/$imageUrl";

                    return Container(
                      margin: EdgeInsets.only(
                        right: imgIndex == displayImageUrls.length - 1
                            ? 0
                            : 8.0,
                      ),
                      width: 250,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          fullImageUrl,
                          fit: BoxFit.fill,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              height: 180,
                              color: theme.colorScheme.surfaceVariant,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value:
                                      loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                      : null,
                                  strokeWidth: 3,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                height: 180,
                                color: theme.colorScheme.surfaceVariant,
                                child: Center(
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    color: theme.colorScheme.onSurfaceVariant,
                                    size: 40,
                                  ),
                                ),
                              ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            if (displayImageUrls.isNotEmpty) const SizedBox(height: 12),
            Text(
              testimonialTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.secondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              '"$testimonialDescription"',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.onSurface.withOpacity(0.85),
                height: 1.45,
              ),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat.yMMMd().add_jm().format(
                    testimonial.createdAt.toLocal(),
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 10,
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
