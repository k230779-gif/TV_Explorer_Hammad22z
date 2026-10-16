import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:assignment_2_k230779_hammad/data/api_client.dart';
import 'package:assignment_2_k230779_hammad/data/details_api.dart';
import 'package:assignment_2_k230779_hammad/data/search_api.dart';
import 'package:assignment_2_k230779_hammad/data/shows_api.dart';
import 'package:assignment_2_k230779_hammad/data/watchlist_storage.dart';
import 'package:assignment_2_k230779_hammad/presentation/management/home/bloc/bloc.dart';
import 'package:assignment_2_k230779_hammad/presentation/management/search/bloc/bloc.dart';
import 'package:assignment_2_k230779_hammad/presentation/management/watchlist/bloc/bloc.dart';
import 'package:assignment_2_k230779_hammad/presentation/ui/main_shell.dart';
import 'package:assignment_2_k230779_hammad/presentation/ui/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => ApiClient()),
        RepositoryProvider(create: (c) => ShowsApi(c.read<ApiClient>())),
        RepositoryProvider(create: (c) => SearchApi(c.read<ApiClient>())),
        RepositoryProvider(create: (c) => DetailsApi(c.read<ApiClient>())),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (c) => ShowsBloc(c.read<ShowsApi>())),
          BlocProvider(create: (c) => SearchBloc(c.read<SearchApi>())),
          BlocProvider(create: (_) => WatchlistBloc(WatchlistStorage())),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'TV Explorer',
          theme: AppTheme.dark,
          home: const MainShell(),
        ),
      ),
    );
  }
}