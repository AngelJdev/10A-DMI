import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/number_formats.dart';
import '../../providers/season_provider.dart';
import '../../providers/video_feed_provider.dart';
import '../../widgets/video_player_item.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback? onBackToFeed;

  const ProfileScreen({super.key, this.onBackToFeed});

  @override
  Widget build(BuildContext context) {
    final feedProvider = context.watch<VideoFeedProvider>();
    final seasonTheme = context.watch<SeasonProvider>().currentTheme;
    final likedVideos = feedProvider.likedVideos;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          '@angeljdev',
          style: seasonTheme.headingStyle.copyWith(fontSize: 18),
        ),
        leading: onBackToFeed != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                onPressed: onBackToFeed,
              )
            : null,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          // Avatar del usuario
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: seasonTheme.primaryColor.withAlpha(150), blurRadius: 15, spreadRadius: 2),
              ],
            ),
            child: CircleAvatar(
              radius: 46,
              backgroundColor: seasonTheme.primaryColor,
              child: const CircleAvatar(
                radius: 43,
                backgroundColor: Color(0xFF1E1E26),
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Nombre de usuario y biografía
          Text(
            'Angel Baños Tellez',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '10A DMI • Flutter Developer',
            style: TextStyle(color: Colors.white.withAlpha(160), fontSize: 13),
          ),
          const SizedBox(height: 16),

          // Contadores de Seguidores, Siguiendo y Me Gustas
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatColumn('Siguiendo', '240'),
              _buildDivider(),
              _buildStatColumn('Seguidores', '14.8K'),
              _buildDivider(),
              _buildStatColumn('Me gusta', NumberFormats.formatCount(likedVideos.length)),
            ],
          ),
          const SizedBox(height: 20),

          // SECCIÓN EXCLUSIVA DE "ME GUSTA" (Requerimiento explícito)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white12, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(seasonTheme.likedIcon, color: seasonTheme.primaryColor, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Me gusta (${likedVideos.length})',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),

          // Grid interactivo con todos los videos que el usuario ha likeado
          Expanded(
            child: likedVideos.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(seasonTheme.likeIcon, size: 60, color: Colors.white24),
                          const SizedBox(height: 12),
                          const Text(
                            'Aún no tienes videos con "Me gusta"',
                            style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Ve a Para Ti o Discover y da click al corazón en tus videos preferidos para guardarlos aquí.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white38, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(4),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 3,
                      mainAxisSpacing: 3,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: likedVideos.length,
                    itemBuilder: (context, index) {
                      final video = likedVideos[index];
                      return GestureDetector(
                        onTap: () {
                          // Abre el video a pantalla completa en el mismo formato
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => Scaffold(
                                extendBodyBehindAppBar: true,
                                appBar: AppBar(
                                  backgroundColor: Colors.transparent,
                                  elevation: 0,
                                  leading: IconButton(
                                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                                    onPressed: () => Navigator.of(context).pop(),
                                  ),
                                ),
                                body: VideoPlayerItem(video: video, isCurrentInFeed: true),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (video.thumbnailUrl != null)
                                Image.network(
                                  video.thumbnailUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Center(
                                    child: Icon(Icons.play_circle_fill, color: Colors.white54, size: 36),
                                  ),
                                )
                              else
                                const Center(
                                  child: Icon(Icons.play_circle_fill, color: Colors.white54, size: 36),
                                ),
                              Positioned(
                                bottom: 6,
                                left: 6,
                                child: Row(
                                  children: [
                                    Icon(seasonTheme.likedIcon, color: seasonTheme.primaryColor, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      NumberFormats.formatCount(video.likes),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        shadows: [
                                          Shadow(color: Colors.black, blurRadius: 4),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 18,
      width: 1,
      color: Colors.white24,
    );
  }
}
