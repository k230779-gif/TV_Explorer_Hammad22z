import 'package:flutter/material.dart';
import 'package:assignment_2_k230779_hammad/domain/show.dart';
import 'package:assignment_2_k230779_hammad/presentation/ui/theme/app_theme.dart';
import 'package:assignment_2_k230779_hammad/presentation/ui/widgets/poster_image.dart';

// Row used by search results and the watchlist
class ShowListTile extends StatelessWidget {
  final Show show;
  final VoidCallback onTap;
  final Widget? trailing;

  const ShowListTile({
    super.key,
    required this.show,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            PosterImage(
              url: show.posterMedium,
              width: 56,
              height: 80,
              borderRadius: BorderRadius.circular(8),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    show.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  if (show.years.isNotEmpty)
                    Text(
                      show.years,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  if (show.genres.isNotEmpty)
                    Text(
                      show.genres.take(3).join(', '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  if (show.rating != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        children: [
                          const Icon(Icons.star,
                              size: 14, color: AppTheme.star),
                          const SizedBox(width: 4),
                          Text(show.rating!.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            trailing ??
                const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}