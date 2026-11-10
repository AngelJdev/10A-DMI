import '../../../app_theme.dart';
import '../../widgets/shared/media_selector.dart';
import '../../widgets/shared/region_loading_overlay.dart';
import '../../views/popular_view.dart';

import 'package:go_router/go_router.dart';

import '../../views/favorites_grid.dart';

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../domain/entities/movie.dart';
import '../../../domain/entities/region_profile.dart';
import '../../localization/app_copy.dart';
import '../../providers/providers.dart';
import '../../widgets/widgets.dart';

class HomeScreen extends ConsumerStatefulWidget {
  static const name = 'home-screen';
  const HomeScreen({
    super.key,
    this.child,
    this.selectedIndex,
    this.navigationShell,
  });
  final StatefulNavigationShell? navigationShell;
  final Widget? child;
  final int? selectedIndex;
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int _localIndex = 0;
  int get _selectedIndex => widget.selectedIndex ?? _localIndex;
  int _regionRequest = 0;
  bool _isChangingRegion = false;
  RegionProfile? _loadingRegion;
  late Future<void> _initialLoad;
  @override
  void initState() {
    super.initState();
    _initialLoad = _loadInitialCatalog();
  }

  Future<void> _loadInitialCatalog() =>
      Future.wait([_load(nowPlayingMoviesProvider), _loadAdditionalMovies()]);

  Future<void> _loadAdditionalMovies() async {
    for (final provider in [
      upcomingMoviesProvider,
      popularMoviesProvider,
      topRatedMoviesProvider,
    ]) {
      try {
        await _load(provider);
      } catch (_) {
        // The home experience remains usable if an optional section fails.
      }
    }
  }

  Future<void> _reloadRegionalCatalog(RegionProfile region) async {
    ref.read(searchQueryProvider.notifier).state = '';
    ref.read(searchedMoviesProvider.notifier).state = [];
    final request = ++_regionRequest;
    final minimumTransition = Future<void>.delayed(
      const Duration(milliseconds: 650),
    );
    setState(() {
      _isChangingRegion = true;
      _loadingRegion = region;
    });
    try {
      // Rebuild even providers retained by hot reload or an earlier selection.
      final providers = [
        nowPlayingMoviesProvider,
        upcomingMoviesProvider,
        popularMoviesProvider,
        topRatedMoviesProvider,
      ];
      for (final provider in providers) {
        ref.invalidate(provider);
      }
      await Future.wait(
        providers.map((provider) => ref.read(provider.notifier).loadNextPage()),
      ).timeout(const Duration(seconds: 20));
    } catch (_) {
      if (mounted && request == _regionRequest) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No se pudo actualizar el catálogo de ${region.country}.',
            ),
          ),
        );
      }
    } finally {
      await minimumTransition;
      if (mounted && request == _regionRequest) {
        setState(() {
          _isChangingRegion = false;
        });
      }
    }
  }

  Future<void> _load(
    StateNotifierProvider<MoviesNotifier, List<Movie>> provider,
  ) async {
    if (ref.read(provider).isEmpty) {
      await ref.read(provider.notifier).loadNextPage();
    }
  }

  void _openMovie(Movie movie) => context.push(movie.location, extra: movie);
  void _openSearch() {
    if (!mounted) return;
    final previous = ref.read(searchedMoviesProvider);
    showSearch<void>(
      context: context,
      query: ref.read(searchQueryProvider),
      delegate: MovieSearchDelegate(
        searchLabel: AppCopy.of(context).text(
          ref.read(selectedMediaProvider) == MediaType.series
              ? 'searchSeries'
              : 'search',
        ),
        initialMovies: previous.isNotEmpty
            ? previous
            : ref.read(nowPlayingMoviesProvider),
        onMovieTap: _openMovie,
        searchMovies: ref.read(activeRepositoryProvider).searchMovies,
        onResults: (query, movies) {
          if (!mounted) return;
          ref.read(searchQueryProvider.notifier).state = query;
          ref.read(searchedMoviesProvider.notifier).state = movies;
        },
      ),
    );
  }

  void _selectSection(int index) {
    _scaffoldKey.currentState?.closeDrawer();
    if (widget.navigationShell != null) {
      widget.navigationShell!.goBranch(index);
    } else if (widget.child != null) {
      context.go(['/home', '/categories', '/favorites'][index]);
    } else {
      setState(() => _localIndex = index);
    }
  }

  void _chooseRegion() {
    _scaffoldKey.currentState?.closeDrawer();
    Future<void>.delayed(const Duration(milliseconds: 220), () {
      if (!mounted) return;
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        isScrollControlled: true,
        builder: (context) => Consumer(
          builder: (context, ref, _) {
            final selected = ref.watch(selectedRegionProvider);
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selected.locale.startsWith('es')
                          ? 'Región e idioma'
                          : 'Region & language',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      selected.locale.startsWith('es')
                          ? 'Al elegir un país también cambiará el idioma de la app y del catálogo.'
                          : 'Choosing a country also changes the app and catalog language.',
                    ),
                    const SizedBox(height: 18),
                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        children: regionProfiles
                            .map(
                              (region) => ListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                selected: selected.code == region.code,
                                selectedTileColor: AppTheme.brandColor
                                    .withValues(alpha: 0.10),
                                leading: RegionFlag(region: region),
                                title: Text(
                                  region.country,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  '${region.continent} · ${region.ratingSystem} · ${region.language}',
                                ),
                                trailing: selected.code == region.code
                                    ? Icon(
                                        Icons.check_circle_rounded,
                                        color: AppTheme.brandColor,
                                      )
                                    : null,
                                onTap: () {
                                  ref
                                          .read(selectedRegionProvider.notifier)
                                          .state =
                                      region;
                                  Navigator.pop(context);
                                },
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final region = ref.watch(selectedRegionProvider);
    const accent = AppTheme.brandColor;
    final copy = AppCopy(region.locale);
    ref.listen<RegionProfile>(selectedRegionProvider, (previous, next) {
      if (previous?.code != next.code) {
        _reloadRegionalCatalog(next);
      }
    });
    ref.listen<MediaType>(selectedMediaProvider, (previous, next) {
      if (previous == next) return;
      ref.read(searchQueryProvider.notifier).state = '';
      ref.read(searchedMoviesProvider.notifier).state = [];
      setState(() {
        _initialLoad = _loadInitialCatalog();
      });
    });
    return Stack(
      children: [
        Scaffold(
          key: _scaffoldKey,
          drawerEnableOpenDragGesture: true,
          drawerEdgeDragWidth: 42,
          drawer: NavigationDrawer(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _selectSection,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 20, 22),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.asset(
                        'assets/branding/cinemapedia.png',
                        width: 52,
                        height: 52,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cinemapedia',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          copy.text('tagline'),
                          style: TextStyle(color: Color(0xff747986)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(indent: 20, endIndent: 20),
              const SizedBox(height: 8),
              Consumer(
                builder: (context, ref, _) {
                  final region = ref.watch(selectedRegionProvider);
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 28),
                    leading: RegionFlag(region: region, width: 36, height: 24),
                    title: Text(copy.text('country')),
                    subtitle: Text(
                      '${region.country} · ${region.ratingSystem}',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: _chooseRegion,
                  );
                },
              ),
              NavigationDrawerDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home_rounded),
                label: Text(copy.text('home')),
              ),
              NavigationDrawerDestination(
                icon: const Icon(Icons.category_outlined),
                selectedIcon: const Icon(Icons.category_rounded),
                label: Text(copy.text('categories')),
              ),
              NavigationDrawerDestination(
                icon: const Icon(Icons.favorite_border_rounded),
                selectedIcon: const Icon(Icons.favorite_rounded),
                label: Text(copy.text('favorites')),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 28, 28, 8),
                child: Text(
                  copy.text('discover'),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: Color(0xff8c919e),
                  ),
                ),
              ),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 28),
                leading: const Icon(Icons.search_rounded),
                title: Text(copy.text('search')),
                onTap: () {
                  _scaffoldKey.currentState?.closeDrawer();
                  Future<void>.delayed(
                    const Duration(milliseconds: 250),
                    _openSearch,
                  );
                },
              ),
            ],
          ),
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight + 64),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomAppBar(
                  onMenu: () => _scaffoldKey.currentState?.openDrawer(),
                  onSearch: _openSearch,
                  accentColor: accent,
                ),
                const MediaSelector(),
              ],
            ),
          ),
          bottomNavigationBar: CustomBottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _selectSection,
            activeColor: accent,
          ),
          body: FutureBuilder<void>(
            future: _initialLoad,
            builder: (context, snapshot) => Stack(
              fit: StackFit.expand,
              children: [
                widget.child ??
                    IndexedStack(
                      index: _selectedIndex,
                      children: [
                        HomeView(onMovieTap: _openMovie),
                        CategoriesView(onMovieTap: _openMovie),
                        FavoritesView(onMovieTap: _openMovie),
                      ],
                    ),
                if (_selectedIndex != 2 &&
                    snapshot.connectionState != ConnectionState.done)
                  const ColoredBox(
                    color: Colors.white,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (_selectedIndex != 2 && snapshot.hasError)
                  ColoredBox(
                    color: Colors.white,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(copy.text('loadError')),
                          TextButton.icon(
                            onPressed: () => setState(() {
                              _initialLoad = _loadInitialCatalog();
                            }),
                            icon: const Icon(Icons.refresh),
                            label: Text(copy.text('retry')),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !_isChangingRegion,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              child: _isChangingRegion && _loadingRegion != null
                  ? RegionLoadingOverlay(
                      key: ValueKey(_loadingRegion!.code),
                      region: _loadingRegion!,
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ],
    );
  }
}

class HomeView extends ConsumerWidget {
  const HomeView({super.key, required this.onMovieTap});
  final ValueChanged<Movie> onMovieTap;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final copy = AppCopy.of(context);
    final type = ref.watch(selectedMediaProvider);
    final isSeries = type == MediaType.series;
    final now = ref.watch(nowPlayingMoviesProvider),
        upcoming = ref.watch(upcomingMoviesProvider);
    if (now.isEmpty) {
      return Center(
        child: Text(copy.text(isSeries ? 'emptySeries' : 'emptyRegion')),
      );
    }
    final featured = now.take(6).toList();
    final featuredIds = featured.map((movie) => movie.id).toSet();
    final inTheaters = now
        .where((movie) => !featuredIds.contains(movie.id))
        .toList();
    final usedIds = {...featuredIds, ...inTheaters.map((movie) => movie.id)};
    final comingSoon = upcoming
        .where((movie) => !usedIds.contains(movie.id))
        .toList();
    return CustomScrollView(
      key: PageStorageKey(
        'home-feed-${type.name}-${ref.watch(selectedRegionProvider).code}',
      ),
      slivers: [
        SliverToBoxAdapter(
          child: MoviesSlideshow(
            key: ValueKey('featured-${type.name}'),
            movies: featured,
            onMovieTap: onMovieTap,
          ),
        ),
        SliverToBoxAdapter(
          child: MovieSection(
            title: copy.text(isSeries ? 'onAir' : 'localCinema'),
            badge: isSeries
                ? copy.text('thisWeek')
                : ref.watch(selectedRegionProvider).country,
            movies: inTheaters,
            loadNextPage: ref
                .read(nowPlayingMoviesProvider.notifier)
                .loadNextPage,
            onMovieTap: onMovieTap,
          ),
        ),
        SliverToBoxAdapter(
          child: MovieSection(
            title: copy.text(isSeries ? 'airingToday' : 'comingSoon'),
            badge: copy.text(isSeries ? 'today' : 'thisMonth'),
            movies: comingSoon,
            loadNextPage: ref
                .read(upcomingMoviesProvider.notifier)
                .loadNextPage,
            onMovieTap: onMovieTap,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        if (ref.watch(selectedRegionProvider).code == 'JP')
          SliverToBoxAdapter(
            child: ref
                .watch(animeMoviesProvider)
                .when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(24),
                    child: LinearProgressIndicator(),
                  ),
                  error: (_, _) => TextButton(
                    onPressed: () => ref.invalidate(animeMoviesProvider),
                    child: const Text('Reintentar cargar anime'),
                  ),
                  data: (movies) => MovieSection(
                    title: 'Anime japonés',
                    movies: movies,
                    onMovieTap: onMovieTap,
                  ),
                ),
          ),
      ],
    );
  }
}

class CategoriesView extends ConsumerWidget {
  const CategoriesView({super.key, required this.onMovieTap});
  final ValueChanged<Movie> onMovieTap;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopularView(onMovieTap: onMovieTap);
  }
}

class FavoritesView extends ConsumerWidget {
  const FavoritesView({super.key, required this.onMovieTap});
  final ValueChanged<Movie> onMovieTap;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FavoritesGrid(onMovieTap: onMovieTap);
  }
}

class MovieSearchDelegate extends SearchDelegate<void> {
  MovieSearchDelegate({
    required this.initialMovies,
    required this.onMovieTap,
    required this.searchMovies,
    this.onResults,
    this.searchLabel,
  });
  final String? searchLabel;
  final List<Movie> initialMovies;
  final ValueChanged<Movie> onMovieTap;
  final Future<List<Movie>> Function(String query) searchMovies;
  final Map<String, Future<List<Movie>>> _searches = {};
  final void Function(String query, List<Movie> movies)? onResults;

  @override
  String get searchFieldLabel => searchLabel ?? 'Buscar películas';
  @override
  List<Widget> buildActions(BuildContext context) => [
    IconButton(onPressed: () => query = '', icon: const Icon(Icons.clear)),
  ];
  @override
  Widget buildLeading(BuildContext context) =>
      BackButton(onPressed: () => close(context, null));
  @override
  PreferredSizeWidget? buildBottom(BuildContext context) {
    final currentQuery = query.trim().toLowerCase();
    return PreferredSize(
      preferredSize: const Size.fromHeight(3),
      child: currentQuery.isEmpty
          ? const SizedBox(height: 3)
          : FutureBuilder<List<Movie>>(
              future: _searches.putIfAbsent(
                currentQuery,
                () => _findMovies(currentQuery),
              ),
              builder: (context, snapshot) =>
                  snapshot.connectionState != ConnectionState.done
                  ? const _SearchLoadingLine()
                  : const SizedBox(height: 3),
            ),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _results();
  @override
  Widget buildSuggestions(BuildContext context) => _results();
  Widget _results() {
    final currentQuery = query.trim().toLowerCase();
    final search = _searches.putIfAbsent(
      currentQuery,
      () => _findMovies(currentQuery),
    );

    return FutureBuilder<List<Movie>>(
      future: search,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _SearchLoadingMessage();
        }

        if (snapshot.hasError) {
          return _SearchErrorView(
            onRetry: () {
              _searches.remove(currentQuery);
              query = '$query ';
            },
          );
        }

        final matches = snapshot.data ?? const <Movie>[];
        if (matches.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.search_off_rounded,
                    size: 68,
                    color: Color(0xff9da1aa),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No encontramos resultados',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'No hay resultados para “${query.trim()}”.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Color(0xff777982)),
                  ),
                ],
              ),
            ),
          );
        }

        return _movieList(matches);
      },
    );
  }

  Future<List<Movie>> _findMovies(String currentQuery) async {
    if (currentQuery.isEmpty) return initialMovies;
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (query.trim().toLowerCase() != currentQuery) {
      _searches.remove(currentQuery);
      return const [];
    }
    final results = await searchMovies(currentQuery)
        .timeout(const Duration(seconds: 20));
    if (query.trim().toLowerCase() == currentQuery) {
      onResults?.call(currentQuery, results);
    }
    return results;
  }

  Widget _movieList(List<Movie> matches) {
    return ListView.builder(
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final movie = matches[index];
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              movie.posterPath,
              width: 45,
              height: 64,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                final expected = progress.expectedTotalBytes;
                return SizedBox(
                  width: 45,
                  height: 64,
                  child: ColoredBox(
                    color: const Color(0xffeef0f4),
                    child: Center(
                      child: SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          value: expected == null
                              ? null
                              : progress.cumulativeBytesLoaded / expected,
                        ),
                      ),
                    ),
                  ),
                );
              },
              errorBuilder: (_, _, _) => const SizedBox(
                width: 45,
                height: 64,
                child: ColoredBox(
                  color: Color(0xffeef0f4),
                  child: Icon(Icons.movie_outlined),
                ),
              ),
            ),
          ),
          title: Text(movie.title),
          subtitle: Row(
            children: [
              Text(movie.releaseDate?.year.toString() ?? 'Próximamente'),
              const SizedBox(width: 12),
              const Icon(
                Icons.star_rounded,
                size: 17,
                color: Color(0xffffad1f),
              ),
              const SizedBox(width: 3),
              Text(
                movie.voteAverage.toStringAsFixed(1),
                style: const TextStyle(color: Color(0xffd18a00)),
              ),
            ],
          ),
          onTap: () {
            close(context, null);
            onMovieTap(movie);
          },
        );
      },
    );
  }
}

class _SearchErrorView extends StatelessWidget {
  const _SearchErrorView({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: const BoxDecoration(
              color: Color(0xfffff0f0),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.cloud_off_rounded,
              size: 38,
              color: Color(0xffe35454),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'No pudimos consultar TMDB',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 7),
          const Text(
            'Comprueba tu conexión e inténtalo nuevamente.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xff777982)),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    ),
  );
}

class _SearchLoadingLine extends StatefulWidget {
  const _SearchLoadingLine();
  @override
  State<_SearchLoadingLine> createState() => _SearchLoadingLineState();
}

class _SearchLoadingLineState extends State<_SearchLoadingLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 3,
    width: double.infinity,
    child: AnimatedBuilder(
      animation: _controller,
      builder: (_, _) =>
          CustomPaint(painter: _LoadingLinePainter(_controller.value)),
    ),
  );
}

class _LoadingLinePainter extends CustomPainter {
  const _LoadingLinePainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final track = Paint()..color = const Color(0xffe8edfa);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0.5, size.width, 2),
        const Radius.circular(2),
      ),
      track,
    );
    const segmentWidth = 110.0;
    final left = (size.width + segmentWidth) * progress - segmentWidth;
    final glow = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0x00246bfd),
          Color(0xff246bfd),
          Color(0xff7b5cff),
          Color(0x007b5cff),
        ],
      ).createShader(Rect.fromLTWH(left, 0, segmentWidth, 3));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(left, 0, segmentWidth, 3),
        const Radius.circular(4),
      ),
      glow,
    );
  }

  @override
  bool shouldRepaint(covariant _LoadingLinePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _SearchLoadingMessage extends StatefulWidget {
  const _SearchLoadingMessage();
  @override
  State<_SearchLoadingMessage> createState() => _SearchLoadingMessageState();
}

class _SearchLoadingMessageState extends State<_SearchLoadingMessage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1700),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Center(
    child: AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Transform.scale(
            scale: 0.98 + (_controller.value * 0.04),
            child: Container(
              width: 126,
              height: 126,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xff246bfd)
                        .withValues(alpha: 0.12 + _controller.value * 0.12),
                    blurRadius: 24 + _controller.value * 18,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: CustomPaint(
                painter: _CinemapediaMarkPainter(_controller.value),
              ),
            ),
          ),
          const SizedBox(height: 27),
          const Text(
            'Buscando en Cinemapedia',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            _controller.value < 0.5
                ? 'Consultando el catálogo de TMDB'
                : 'Comparando títulos y estrenos',
            style: const TextStyle(color: Color(0xff7c8190)),
          ),
        ],
      ),
    ),
  );
}

class _CinemapediaMarkPainter extends CustomPainter {
  const _CinemapediaMarkPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 100;
    final scaleY = size.height / 100;
    canvas.save();
    canvas.scale(scaleX, scaleY);

    final body = RRect.fromRectAndRadius(
      const Rect.fromLTWH(17, 30, 66, 54),
      const Radius.circular(13),
    );
    final clapper = Path()
      ..moveTo(19, 30)
      ..lineTo(27, 13)
      ..lineTo(85, 13)
      ..lineTo(78, 30)
      ..close();
    final play = Path()
      ..moveTo(43, 45)
      ..lineTo(43, 70)
      ..lineTo(65, 57.5)
      ..close();

    final outline = Paint()
      ..color = const Color(0xffb8c2d9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeJoin = StrokeJoin.round;
    canvas.drawRRect(body, outline);
    canvas.drawPath(clapper, outline);
    canvas.drawPath(play, outline);
    for (final x in [34.0, 54.0, 74.0]) {
      canvas.drawLine(Offset(x, 15), Offset(x - 7, 29), outline);
    }

    final fill = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [Color(0xff246bfd), Color(0xff6f55e8), Color(0xff29b6e8)],
      ).createShader(const Rect.fromLTWH(10, 10, 80, 78))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final top = 88 - (progress * 80);
    canvas.clipRect(Rect.fromLTRB(5, top, 95, 92));
    canvas.drawRRect(body, fill);
    canvas.drawPath(clapper, fill);
    canvas.drawPath(play, fill);
    for (final x in [34.0, 54.0, 74.0]) {
      canvas.drawLine(Offset(x, 15), Offset(x - 7, 29), fill);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CinemapediaMarkPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _LegacySearchLoadingMessage extends StatefulWidget {
  const _LegacySearchLoadingMessage();
  @override
  State<_LegacySearchLoadingMessage> createState() =>
      _LegacySearchLoadingMessageState();
}

class _LegacySearchLoadingMessageState
    extends State<_LegacySearchLoadingMessage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Center(
    child: AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 224,
            height: 142,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xff101a3b),
                  Color(0xff263d83),
                  Color(0xff6c4ad3),
                ],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33246bfd),
                  blurRadius: 30,
                  offset: Offset(0, 14),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: -20,
                  top: -30,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      color: Color(0x167ea2ff),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Transform.rotate(
                  angle: math.sin(_controller.value * math.pi * 2) * 0.06,
                  child: const Icon(
                    Icons.movie_filter_rounded,
                    size: 58,
                    color: Colors.white,
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 8 + (_controller.value * 126),
                  child: Container(
                    height: 3,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0x00ffffff),
                          Color(0xffffffff),
                          Color(0x00ffffff),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(color: Color(0xaa88c7ff), blurRadius: 12),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Explorando TMDB',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 7),
              for (var index = 0; index < 3; index++)
                Transform.translate(
                  offset: Offset(
                    0,
                    -math.max(
                          0,
                          math.sin(
                            (_controller.value * math.pi * 2) - index * 0.8,
                          ),
                        ) *
                        8,
                  ),
                  child: Container(
                    width: 7,
                    height: 7,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: const BoxDecoration(
                      color: Color(0xff5b55d9),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Buscando coincidencias en el catálogo real',
            style: TextStyle(color: Color(0xff7c8190)),
          ),
        ],
      ),
    ),
  );
}
