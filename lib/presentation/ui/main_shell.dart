import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:assignment_2_k230779_hammad/presentation/management/watchlist/bloc/bloc.dart';
import 'package:assignment_2_k230779_hammad/presentation/ui/home_page.dart';
import 'package:assignment_2_k230779_hammad/presentation/ui/search_page.dart';
import 'package:assignment_2_k230779_hammad/presentation/ui/watchlist_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0; // selected tab (pure UI state)

  void _goTo(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    // Shows the "Added / Removed" SnackBar, also while a details page is open
    return BlocListener<WatchlistBloc, WatchlistState>(
      listenWhen: (prev, curr) => prev.messageId != curr.messageId,
      listener: (context, state) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(state.message),
              duration: const Duration(seconds: 2),
            ),
          );
      },
      child: Scaffold(
        // IndexedStack keeps each tab alive (scroll position, search text)
        body: IndexedStack(
          index: _index,
          children: [
            HomePage(onSearchTap: () => _goTo(1)),
            const SearchPage(),
            WatchlistPage(onExplore: () => _goTo(0)),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _goTo,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_border),
              selectedIcon: Icon(Icons.favorite),
              label: 'Watchlist',
            ),
          ],
        ),
      ),
    );
  }
}