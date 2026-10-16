import 'package:flutter/material.dart';
import 'package:assignment_2_k230779_hammad/domain/show.dart';
import 'package:assignment_2_k230779_hammad/presentation/ui/theme/app_theme.dart';
import 'package:assignment_2_k230779_hammad/presentation/ui/widgets/poster_image.dart';

// Poster + rating badge + title + genres (used in the home grid and trending row)
class ShowPosterCard extends StatelessWidget {
  final Show show;
  final VoidCallback onTap;

  const ShowPosterCard({super.key, required this.show, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final genres = show.genres.take(2).join(', ');

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                PosterImage(
                  url: show.posterMedium,
                  borderRadius: BorderRadius.circular(14),
                ),
                if (show.rating != null)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: _RatingBadge(rating: show.rating!),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            show.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          Text(
            genres.isEmpty ? ' ' : genres,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:
                const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  final double rating;

  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 12, color: AppTheme.star),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}