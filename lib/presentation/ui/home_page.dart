import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:assignment_2_k230779_hammad/presentation/management/home/bloc/bloc.dart';
import 'package:assignment_2_k230779_hammad/presentation/ui/details_page.dart';
import 'package:assignment_2_k230779_hammad/presentation/ui/theme/app_theme.dart';
import 'package:assignment_2_k230779_hammad/presentation/ui/widgets/content_width.dart';
import 'package:assignment_2_k230779_hammad/presentation/ui/widgets/show_poster_card.dart';
import 'package:assignment_2_k230779_hammad/presentation/ui/widgets/state_views.dart';
import 'package:assignment_2_k230779_hammad/presentation/ui/widgets/trending_row.dart';

class HomePage extends StatefulWidget {
  final VoidCallback onSearchTap;

  const HomePage({super.key, required this.onSearchTap});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onScroll);
  }

  // Near the bottom -> ask the bloc for the next page
  void _onScroll() {
    if (_controller.position.pixels >=
        _controller.position.maxScrollExtent - 400) {
      context.read<ShowsBloc>().add(const ShowsEvent(ShowsAction.loadMore));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ContentWidth(
        maxWidth: 1100,
        child: BlocBuilder<ShowsBloc, ShowsState>(
          builder: (context, state) {
            if (state.status == ShowsStatus.loading) {
              return const LoadingView();
            }
            if (state.status == ShowsStatus.failure) {
              return ErrorView(
                message: state.errorMessage,
                onRetry: () => context
                    .read<ShowsBloc>()
                    .add(const ShowsEvent(ShowsAction.load)),
              );
            }
            if (state.shows.isEmpty) {
              return const EmptyView(
                icon: Icons.tv_off,
                title: 'No shows found',
                subtitle: 'Please check back later.',
              );
            }

            return CustomScrollView(
              controller: _controller,
              slivers: [
                SliverToBoxAdapter(child: _buildHeader()),
                if (state.trending.isNotEmpty) ...[
                  SliverToBoxAdapter(child: _sectionTitle('Trending Now')),
                  SliverToBoxAdapter(
                    child: TrendingRow(
                      shows: state.trending,
                      onTap: (show) => DetailsPage.open(context, show),
                    ),
                  ),
                ],
                SliverToBoxAdapter(child: _sectionTitle('Popular Shows')),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverGrid(
                    // Adds more columns as the window gets wider
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 170,
                      childAspectRatio: 0.54,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 18,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final show = state.shows[index];
                        return ShowPosterCard(
                          show: show,
                          onTap: () => DetailsPage.open(context, show),
                        );
                      },
                      childCount: state.shows.length,
                    ),
                  ),
                ),
                SliverToBoxAdapter(child: _buildFooter(context, state)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Hello,',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          const Text('TV Explorer! 👋',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          // Tapping the fake search bar jumps to the Search tab
          GestureDetector(
            onTap: widget.onSearchTap,
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: AppTheme.textSecondary),
                  SizedBox(width: 10),
                  Text('Search shows...',
                      style: TextStyle(color: AppTheme.textSecondary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Text(text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildFooter(BuildContext context, ShowsState state) {
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }
    if (state.loadMoreFailed) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: TextButton.icon(
            onPressed: () => context
                .read<ShowsBloc>()
                .add(const ShowsEvent(ShowsAction.retryLoadMore)),
            icon: const Icon(Icons.refresh),
            label: const Text("Couldn't load more. Tap to retry"),
          ),
        ),
      );
    }
    if (state.hasReachedMax) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Text("You've reached the end",
              style: TextStyle(color: AppTheme.textSecondary)),
        ),
      );
    }
    return const SizedBox(height: 24);
  }
}