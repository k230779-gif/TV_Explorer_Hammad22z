// ignore_for_file: unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:assignment_2_k230779_hammad/data/details_api.dart';
import 'package:assignment_2_k230779_hammad/domain/cast_member.dart';
import 'package:assignment_2_k230779_hammad/domain/episode.dart';
import 'package:assignment_2_k230779_hammad/domain/show.dart';
import 'package:assignment_2_k230779_hammad/presentation/management/details/bloc/bloc.dart';
import 'package:assignment_2_k230779_hammad/presentation/management/watchlist/bloc/bloc.dart';
import 'package:assignment_2_k230779_hammad/presentation/ui/theme/app_theme.dart';
import 'package:assignment_2_k230779_hammad/presentation/ui/widgets/content_width.dart';
import 'package:assignment_2_k230779_hammad/presentation/ui/widgets/poster_image.dart';
import 'package:assignment_2_k230779_hammad/presentation/ui/widgets/state_views.dart';

class DetailsPage extends StatefulWidget {
  const DetailsPage({super.key});

  // Opens the page with its own DetailsBloc for this show
  static Future<void> open(BuildContext context, Show show) {
    final api = context.read<DetailsApi>();
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => DetailsBloc(api, show)
            ..add(const DetailsEvent(DetailsAction.load)),
          child: const DetailsPage(),
        ),
      ),
    );
  }

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    // Rebuild when the selected tab changes (pure UI state)
    _tabs.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ContentWidth(
        maxWidth: 760,
        child: BlocBuilder<DetailsBloc, DetailsState>(
          builder: (context, state) {
            // One scroll view: header, button, tabs and content scroll together
            return CustomScrollView(
              slivers: [
                _buildAppBar(context, state),
                SliverToBoxAdapter(child: _WatchlistButton(show: state.show)),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabBarDelegate(_tabs),
                ),
                ..._buildContent(context, state),
              ],
            );
          },
        ),
      ),
    );
  }

  // ---------- Collapsing header ----------
  Widget _buildAppBar(BuildContext context, DetailsState state) {
    final height = (MediaQuery.sizeOf(context).height * 0.42)
        .clamp(260.0, 380.0)
        .toDouble();

    return SliverAppBar(
      pinned: true,
      expandedHeight: height,
      backgroundColor: AppTheme.surface,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      leadingWidth: 64,
      leading: Center(
        child: _CircleButton(
          icon: Icons.arrow_back,
          onTap: () => Navigator.of(context).pop(),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Center(child: _HeartButton(show: state.show)),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: _HeaderBackground(
          show: state.show,
          seasons: state.episodesBySeason.length,
        ),
      ),
    );
  }

  // ---------- Content of the selected tab ----------
  List<Widget> _buildContent(BuildContext context, DetailsState state) {
    switch (_tabs.index) {
      case 0:
        return [
          SliverToBoxAdapter(child: _OverviewTab(show: state.show)),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ];
      case 1:
        return _episodeSlivers(context, state);
      default:
        return _castSlivers(context, state);
    }
  }

  // Loading / error view shared by the Episodes and Cast tabs
  Widget? _statusSliver(BuildContext context, DetailsState state) {
    if (state.status == DetailsStatus.loading) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: LoadingView(),
      );
    }
    if (state.status == DetailsStatus.failure) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: ErrorView(
          message: state.errorMessage,
          onRetry: () => context
              .read<DetailsBloc>()
              .add(const DetailsEvent(DetailsAction.load)),
        ),
      );
    }
    return null;
  }

  List<Widget> _episodeSlivers(BuildContext context, DetailsState state) {
    final status = _statusSliver(context, state);
    if (status != null) return [status];

    if (state.episodesBySeason.isEmpty) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyView(
            icon: Icons.tv_off,
            title: 'No episodes yet',
            subtitle: 'Episodes for this show are not available.',
          ),
        ),
      ];
    }

    final episodes = state.episodesBySeason[state.selectedSeason] ?? [];

    return [
      SliverToBoxAdapter(child: _SeasonDropdown(state: state)),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        sliver: SliverList.separated(
          itemCount: episodes.length,
          itemBuilder: (_, index) => _EpisodeTile(episode: episodes[index]),
          separatorBuilder: (_, __) => const SizedBox(height: 8),
        ),
      ),
    ];
  }

  List<Widget> _castSlivers(BuildContext context, DetailsState state) {
    final status = _statusSliver(context, state);
    if (status != null) return [status];

    if (state.cast.isEmpty) {
      return const [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyView(
            icon: Icons.people_outline,
            title: 'No cast information',
            subtitle: 'Cast details are not available for this show.',
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.all(20),
        sliver: SliverList.separated(
          itemCount: state.cast.length,
          itemBuilder: (_, index) => _CastTile(member: state.cast[index]),
          separatorBuilder: (_, __) => const SizedBox(height: 12),
        ),
      ),
    ];
  }
}

// ---------- Pinned tab bar ----------
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabController controller;

  const _TabBarDelegate(this.controller);

  @override
  double get minExtent => 48;

  @override
  double get maxExtent => 48;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppTheme.background,
      child: TabBar(
        controller: controller,
        indicatorColor: AppTheme.primary,
        labelColor: AppTheme.primary,
        unselectedLabelColor: AppTheme.textSecondary,
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Episodes'),
          Tab(text: 'Cast'),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) =>
      controller != oldDelegate.controller;
}

// ---------- Header background (poster, title, rating, genres) ----------
class _HeaderBackground extends StatelessWidget {
  final Show show;
  final int seasons;

  const _HeaderBackground({required this.show, required this.seasons});

  @override
  Widget build(BuildContext context) {
    final info = <String>[
      if (show.years.isNotEmpty) show.years,
      if (seasons > 0) '$seasons Season${seasons == 1 ? '' : 's'}',
    ];

    return Stack(
      fit: StackFit.expand,
      children: [
        PosterImage(
          url: show.posterOriginal ?? show.posterMedium,
          alignment: Alignment.topCenter,
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black26,
                Colors.transparent,
                AppTheme.background
              ],
              stops: [0, 0.4, 1],
            ),
          ),
        ),
        Positioned(
          left: 20,
          right: 20,
          bottom: 12,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                show.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Flexible(
                    child: Text(
                      info.join('  •  '),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                  if (show.rating != null) ...[
                    const SizedBox(width: 12),
                    const Icon(Icons.star, size: 16, color: AppTheme.star),
                    const SizedBox(width: 4),
                    Text('${show.rating}/10',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: show.genres
                    .take(4)
                    .map(
                      (g) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(g, style: const TextStyle(fontSize: 12)),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black45,
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }
}

// Heart in the header: filled when the show is in the watchlist
class _HeartButton extends StatelessWidget {
  final Show show;

  const _HeartButton({required this.show});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WatchlistBloc, WatchlistState>(
      builder: (context, state) {
        final saved = state.savedIds.contains(show.id);
        return _CircleButton(
          icon: saved ? Icons.favorite : Icons.favorite_border,
          color: saved ? AppTheme.danger : Colors.white,
          onTap: () => context
              .read<WatchlistBloc>()
              .add(WatchlistEvent(WatchlistAction.toggle, show: show)),
        );
      },
    );
  }
}

// ---------- Add / remove watchlist button ----------
class _WatchlistButton extends StatelessWidget {
  final Show show;

  const _WatchlistButton({required this.show});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WatchlistBloc, WatchlistState>(
      builder: (context, state) {
        final saved = state.savedIds.contains(show.id);

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton.icon(
              onPressed: () => context
                  .read<WatchlistBloc>()
                  .add(WatchlistEvent(WatchlistAction.toggle, show: show)),
              style: FilledButton.styleFrom(
                backgroundColor: saved ? AppTheme.card : AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: Icon(saved ? Icons.check : Icons.add),
              label: Text(saved ? 'Remove from Watchlist' : 'Add to Watchlist'),
            ),
          ),
        );
      },
    );
  }
}

// ---------- Overview tab ----------
class _OverviewTab extends StatelessWidget {
  final Show show;

  const _OverviewTab({required this.show});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            show.summary.isEmpty ? 'No summary available.' : show.summary,
            style: const TextStyle(height: 1.5, color: Colors.white70),
          ),
          const SizedBox(height: 20),
          const Text('Quick Info',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          _InfoRow(label: 'Status', value: show.status),
          _InfoRow(label: 'Network', value: show.network),
          _InfoRow(
            label: 'Genres',
            value: show.genres.isEmpty ? null : show.genres.join(', '),
          ),
          _InfoRow(label: 'Language', value: show.language),
          _InfoRow(
            label: 'Runtime',
            value: show.runtime == null ? null : '${show.runtime} min',
          ),
          _InfoRow(label: 'Premiered', value: show.premiered),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              (value == null || value!.isEmpty) ? 'N/A' : value!,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- Season dropdown (Episodes tab) ----------
class _SeasonDropdown extends StatelessWidget {
  final DetailsState state;

  const _SeasonDropdown({required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: state.selectedSeason,
            isExpanded: true,
            dropdownColor: AppTheme.card,
            items: state.episodesBySeason.entries
                .map(
                  (e) => DropdownMenuItem<int>(
                    value: e.key,
                    child: Text('Season ${e.key} (${e.value.length} episodes)'),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                context.read<DetailsBloc>().add(DetailsEvent(
                    DetailsAction.selectSeason,
                    season: value));
              }
            },
          ),
        ),
      ),
    );
  }
}

class _EpisodeTile extends StatelessWidget {
  final Episode episode;

  const _EpisodeTile({required this.episode});

  @override
  Widget build(BuildContext context) {
    final subtitle = <String>[
      if (episode.airdate != null && episode.airdate!.isNotEmpty)
        episode.airdate!,
      if (episode.runtime != null) '${episode.runtime} min',
    ].join('  •  ');

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              episode.number?.toString() ?? '•',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontWeight: FontWeight.w700, color: AppTheme.primary),
            ),
          ),
          const SizedBox(width: 8),
          PosterImage(
            url: episode.imageUrl,
            width: 80,
            height: 52,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  episode.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CastTile extends StatelessWidget {
  final CastMember member;

  const _CastTile({required this.member});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PosterImage(
          url: member.imageUrl,
          width: 52,
          height: 52,
          borderRadius: BorderRadius.circular(26),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(member.name,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              if (member.character.isNotEmpty)
                Text(member.character,
                    style: const TextStyle(color: AppTheme.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }
}