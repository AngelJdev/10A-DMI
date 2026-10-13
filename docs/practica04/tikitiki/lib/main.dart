import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/utils/storage_service.dart';
import 'data/datasources/local_video_datasource.dart';
import 'data/datasources/youtube_video_datasource.dart';
import 'data/datasources/online_stream_datasource.dart';
import 'data/repositories/video_repository_impl.dart';
import 'domain/usecases/get_videos.dart';
import 'presentation/providers/season_provider.dart';
import 'presentation/providers/video_feed_provider.dart';
import 'presentation/screens/discover/discover_screen.dart';
import 'presentation/screens/favorites/favorites_screen.dart';
import 'presentation/screens/profile/profile_screen.dart';
import 'presentation/screens/video_feed_screen.dart';
import 'presentation/widgets/bottom_navigation_bar_widget.dart';
import 'presentation/widgets/top_navigation_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar almacenamiento local (SharedPreferences)
  final storageService = await StorageService.getInstance();

  // Inicializar fuentes de datos (Clean Architecture: 3 datasources)
  final localDatasource = LocalVideoDatasourceImpl();
  final ytDatasource = YouTubeVideoDatasourceImpl();
  final onlineStreamDatasource = OnlineStreamDatasourceImpl();

  // Inicializar repositorio unificado con almacenamiento persistente
  final videoRepository = VideoRepositoryImpl(
    localDatasource: localDatasource,
    youtubeDatasource: ytDatasource,
    onlineStreamDatasource: onlineStreamDatasource,
    storageService: storageService,
  );

  // Inicializar caso de uso
  final getVideosUseCase = GetVideos(videoRepository);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SeasonProvider()),
        ChangeNotifierProvider(
          create: (_) => VideoFeedProvider(
            repository: videoRepository,
            getVideosUseCase: getVideosUseCase,
          ),
        ),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final seasonTheme = context.watch<SeasonProvider>().currentTheme;

    return MaterialApp(
      title: 'TikiTiki - TikTok Clean Architecture',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: seasonTheme.backgroundColor,
        primaryColor: seasonTheme.primaryColor,
        colorScheme: ColorScheme.dark(
          primary: seasonTheme.primaryColor,
          secondary: seasonTheme.secondaryColor,
          surface: seasonTheme.backgroundColor,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // 1 = 'For You' por defecto al inicio
  int _currentIndex = 1;
  bool _showProfile = false;
  late final PageController _horizontalPageController;

  @override
  void initState() {
    super.initState();
    _horizontalPageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _horizontalPageController.dispose();
    super.dispose();
  }

  void _onTopTabChanged(int index) {
    setState(() {
      _showProfile = false;
      _currentIndex = index;
    });
    _horizontalPageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: _showProfile
          ? ProfileScreen(
              onBackToFeed: () {
                setState(() {
                  _showProfile = false;
                });
              },
            )
          : Stack(
              children: [
                // DESPLAZAMIENTO LATERAL (PageView Horizontal) entre Discover / For You / Favorites
                PageView(
                  controller: _horizontalPageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  children: const [
                    DiscoverScreen(), // Página 0: Discover / Recomendaciones en formato vertical completo
                    VideoFeedScreen(), // Página 1: For You (Para ti)
                    FavoritesScreen(), // Página 2: Favorites (Favoritos)
                  ],
                ),

                // BARRA SUPERIOR DE NAVEGACIÓN Y SELECTOR DE TEMPORADAS
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: TopNavigationBar(
                    currentIndex: _currentIndex,
                    onTabChanged: _onTopTabChanged,
                  ),
                ),
              ],
            ),
      bottomNavigationBar: BottomNavigationBarWidget(
        selectedIndex: _showProfile
            ? 4
            : (_currentIndex == 1 ? 0 : (_currentIndex == 0 ? 1 : 3)),
        onTap: (navIndex) {
          if (navIndex == 0) {
            _onTopTabChanged(1); // Inicio -> For You
          } else if (navIndex == 1) {
            _onTopTabChanged(0); // Tendencias -> Discover
          } else if (navIndex == 4) {
            setState(() {
              _showProfile = true; // Perfil -> Sección de Me gusta
            });
          }
        },
      ),
    );
  }
}
