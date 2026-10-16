import 'package:flutter/material.dart';
import 'package:assignment_2_k230779_hammad/presentation/ui/theme/app_theme.dart';

// Network image with a placeholder for missing or failed images
class PosterImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BorderRadius borderRadius;
  final Alignment alignment;

  const PosterImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.borderRadius = BorderRadius.zero,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        width: width,
        height: height,
        child: url == null
            ? const _Placeholder()
            : Image.network(
                url!,
                fit: BoxFit.cover,
                alignment: alignment,
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : const _Placeholder(),
                errorBuilder: (context, error, stack) => const _Placeholder(),
              ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.card,
      alignment: Alignment.center,
      child: const Icon(Icons.movie_outlined, color: AppTheme.textSecondary),
    );
  }
}