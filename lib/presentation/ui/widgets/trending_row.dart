// ignore_for_file: unnecessary_underscores

import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:assignment_2_k230779_hammad/domain/show.dart';
import 'package:assignment_2_k230779_hammad/presentation/ui/widgets/show_poster_card.dart';

class TrendingRow extends StatefulWidget {
  final List<Show> shows;
  final void Function(Show show) onTap;

  const TrendingRow({super.key, required this.shows, required this.onTap});

  @override
  State<TrendingRow> createState() => _TrendingRowState();
}

class _TrendingRowState extends State<TrendingRow> {
  final ScrollController _controller = ScrollController();
  bool _showLeft = false;
  bool _showRight = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateArrows);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Shows an arrow only when there is more content in that direction
  void _updateArrows() {
    if (!mounted || !_controller.hasClients) return;
    final position = _controller.position;
    if (!position.hasContentDimensions) return;

    final left = position.pixels > 4;
    final right = position.pixels < position.maxScrollExtent - 4;

    if (left != _showLeft || right != _showRight) {
      setState(() {
        _showLeft = left;
        _showRight = right;
      });
    }
  }

  // Scrolls by about 80% of the visible width
  void _scroll(int direction) {
    if (!_controller.hasClients) return;
    final position = _controller.position;
    final step = position.viewportDimension * 0.8;
    final target = (position.pixels + direction * step)
        .clamp(0.0, position.maxScrollExtent)
        .toDouble();

    _controller.animateTo(
      target,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Re-check after every layout (also when the window is resized)
    MediaQuery.sizeOf(context);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateArrows());

    return SizedBox(
      height: 250,
      child: Stack(
        children: [
          ListView.separated(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: widget.shows.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final show = widget.shows[index];
              return SizedBox(
                width: 140,
                child: ShowPosterCard(
                  show: show,
                  onTap: () => widget.onTap(show),
                ),
              );
            },
          ),
          _arrow(left: true, visible: _showLeft),
          _arrow(left: false, visible: _showRight),
        ],
      ),
    );
  }

  // Positioned over the poster area, at the left or right corner
  Widget _arrow({required bool left, required bool visible}) {
    return Positioned(
      left: left ? 6 : null,
      right: left ? null : 6,
      top: 85,
      child: IgnorePointer(
        ignoring: !visible,
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          child: _ArrowButton(
            icon: left ? Icons.chevron_left : Icons.chevron_right,
            onTap: () => _scroll(left ? -1 : 1),
          ),
        ),
      ),
    );
  }
}

// Translucent, slightly blurred round button
class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ArrowButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Material(
          color: Colors.black.withValues(alpha: 0.4),
          child: InkWell(
            onTap: onTap,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24),
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
          ),
        ),
      ),
    );
  }
}