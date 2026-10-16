import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:assignment_2_k230779_hammad/presentation/management/search/bloc/bloc.dart';
import 'package:assignment_2_k230779_hammad/presentation/ui/details_page.dart';
import 'package:assignment_2_k230779_hammad/presentation/ui/theme/app_theme.dart';
import 'package:assignment_2_k230779_hammad/presentation/ui/widgets/content_width.dart';
import 'package:assignment_2_k230779_hammad/presentation/ui/widgets/show_list_tile.dart';
import 'package:assignment_2_k230779_hammad/presentation/ui/widgets/state_views.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ContentWidth(
        maxWidth: 800,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: _controller,
                builder: (context, value, _) => TextField(
                  controller: _controller,
                  onChanged: (text) => context
                      .read<SearchBloc>()
                      .add(SearchEvent(SearchAction.query, query: text)),
                  decoration: InputDecoration(
                    hintText: 'Search shows...',
                    hintStyle: const TextStyle(color: AppTheme.textSecondary),
                    prefixIcon: const Icon(Icons.search,
                        color: AppTheme.textSecondary),
                    suffixIcon: value.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _controller.clear();
                              context
                                  .read<SearchBloc>()
                                  .add(const SearchEvent(SearchAction.clear));
                            },
                          ),
                    filled: true,
                    fillColor: AppTheme.card,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  switch (state.status) {
                    case SearchStatus.initial:
                      return const EmptyView(
                        icon: Icons.search,
                        title: 'Search for TV shows',
                        subtitle: 'Type a show name to get started.',
                      );
                    case SearchStatus.loading:
                      return const LoadingView();
                    case SearchStatus.failure:
                      return ErrorView(
                        message: state.errorMessage,
                        onRetry: () => context.read<SearchBloc>().add(
                            SearchEvent(SearchAction.query,
                                query: state.query)),
                      );
                    case SearchStatus.empty:
                      return EmptyView(
                        icon: Icons.search_off,
                        title: 'No results found',
                        subtitle:
                            'We could not find any shows for "${state.query}".',
                      );
                    case SearchStatus.success:
                      return ListView.builder(
                        itemCount: state.results.length,
                        itemBuilder: (context, index) {
                          final show = state.results[index];
                          return ShowListTile(
                            show: show,
                            onTap: () {
                              FocusScope.of(context).unfocus();
                              DetailsPage.open(context, show);
                            },
                          );
                        },
                      );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}