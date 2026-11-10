import '../../../domain/entities/video.dart';
import '../../../domain/entities/movie.dart';
import '../../providers/catalog_preferences.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../infrastructure/repositories/movies_repository_provider.dart';
import '../../../infrastructure/repositories/local_reviews_repository.dart';
import '../../localization/app_copy.dart';

final videosFromMovieProvider = FutureProvider.family<List<Video>, int>(
  (ref, id) => ref.watch(movieRepositoryProvider).getYoutubeVideosById(id),
);
final movieTrailerProvider = FutureProvider.family<Video?, int>((
  ref,
  id,
) async {
  final videos = await ref.watch(videosFromMovieProvider(id).future);
  return videos.isEmpty ? null : videos.first;
});

final contentTrailerProvider =
    FutureProvider.family<Video?, ({int id, MediaType type})>((
      ref,
      request,
    ) async {
      if (request.type == MediaType.movie) {
        return ref.watch(movieTrailerProvider(request.id).future);
      }
      final locale = ref.watch(selectedRegionProvider).locale;
      final videos = await ref
          .watch(seriesRepositoryProvider(locale))
          .getYoutubeVideosById(request.id);
      return videos.isEmpty ? null : videos.first;
    });

class MovieTrailer extends ConsumerWidget {
  const MovieTrailer({
    super.key,
    required this.movieId,
    this.mediaType = MediaType.movie,
  });
  final int movieId;
  final MediaType mediaType;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final copy = AppCopy.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          copy.text('trailer'),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ref
            .watch(contentTrailerProvider((id: movieId, type: mediaType)))
            .when(
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => TextButton(
                onPressed: () {
                  ref.invalidate(videosFromMovieProvider(movieId));
                  ref.invalidate(movieTrailerProvider(movieId));
                  ref.invalidate(
                    contentTrailerProvider((id: movieId, type: mediaType)),
                  );
                },
                child: Text(copy.text('retry')),
              ),
              data: (video) => video == null
                  ? const Text('No hay tráiler disponible para esta película.')
                  : _InlineTrailer(
                      key: ValueKey(video.youtubeKey),
                      video: video,
                    ),
            ),
      ],
    );
  }
}

class _InlineTrailer extends StatefulWidget {
  const _InlineTrailer({super.key, required this.video});
  final Video video;
  @override
  State<_InlineTrailer> createState() => _InlineTrailerState();
}

class _InlineTrailerState extends State<_InlineTrailer>
    with WidgetsBindingObserver {
  late final YoutubePlayerController _controller;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.video.youtubeKey,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        interfaceLanguage: 'es',
        captionLanguage: 'es',
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) _controller.pauseVideo();
  }

  Future<void> _openYouTube() async {
    await _controller.pauseVideo();
    try {
      final opened = await launchUrl(
        Uri.https('www.youtube.com', '/watch', {'v': widget.video.youtubeKey}),
        mode: LaunchMode.externalApplication,
      );
      if (!opened) throw StateError('No se pudo abrir');
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir YouTube. Inténtalo de nuevo.'),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    margin: EdgeInsets.zero,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        YoutubePlayer(
          controller: _controller,
          aspectRatio: 16 / 9,
          autoFullScreen: false,
        ),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.video.name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                widget.video.language == 'es' ? 'Español' : 'Otro idioma',
                style: const TextStyle(color: Color(0xff666e7a)),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _openYouTube,
                icon: const Icon(Icons.open_in_new_rounded, size: 18),
                label: Text(AppCopy.of(context).text('goYoutube')),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class MovieReviews extends StatefulWidget {
  const MovieReviews({
    super.key,
    required this.movieId,
    this.mediaType = MediaType.movie,
  });
  final int movieId;
  final MediaType mediaType;
  @override
  State<MovieReviews> createState() => _MovieReviewsState();
}

class _MovieReviewsState extends State<MovieReviews> {
  final _repository = LocalReviewsRepository();
  final _text = TextEditingController();
  List<LocalReview> _reviews = [];
  int _stars = 4;
  bool _loading = true, _saving = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final reviews = await _repository.load(
        widget.movieId,
        type: widget.mediaType,
      );
      if (mounted) {
        setState(() {
          _reviews = reviews;
          _loading = false;
          _error = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'No se pudieron leer tus reseñas.';
        });
      }
    }
  }

  Future<void> _save() async {
    final text = _text.text.trim();
    if (text.isEmpty) return;
    setState(() => _saving = true);
    final next = [
      LocalReview(text: text, stars: _stars, created: DateTime.now()),
      ..._reviews,
    ];
    try {
      await _repository.save(widget.movieId, next, type: widget.mediaType);
      if (!mounted) return;
      setState(() {
        _reviews = next;
        _text.clear();
        _saving = false;
      });
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Reseña guardada')));
    } catch (_) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No se pudo guardar. Tu comentario sigue en el formulario.',
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final copy = AppCopy.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          copy.text('reviews'),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text(
          'Tus comentarios se guardan en este dispositivo para cada título.',
          style: TextStyle(color: Color(0xff666e7a)),
        ),
        const SizedBox(height: 12),
        if (_loading)
          const LinearProgressIndicator()
        else if (_error != null)
          TextButton(onPressed: _load, child: Text('$_error Reintentar'))
        else ...[
          Wrap(
            children: List.generate(
              5,
              (i) => IconButton(
                tooltip: '${i + 1} estrellas',
                onPressed: _saving
                    ? null
                    : () => setState(() => _stars = i + 1),
                icon: Icon(
                  i < _stars ? Icons.star_rounded : Icons.star_border_rounded,
                  color: const Color(0xffffad1f),
                ),
              ),
            ),
          ),
          TextField(
            controller: _text,
            minLines: 3,
            maxLines: 6,
            maxLength: 2000,
            enabled: !_saving,
            decoration: InputDecoration(
              hintText: copy.text('reviewHint'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: const Icon(Icons.rate_review_outlined),
            label: Text(
              _saving ? copy.text('saving') : copy.text('saveReview'),
            ),
          ),
          const SizedBox(height: 18),
          ..._reviews.map(
            (r) => _ReviewCard(
              author:
                  'Tú · ${r.created.day}/${r.created.month}/${r.created.year}',
              text: r.text,
              stars: r.stars,
            ),
          ),
        ],
        const SizedBox(height: 18),
        const Text(
          'Ejemplos de reseñas',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        const Text(
          'Demostración: estos comentarios son ficticios.',
          style: TextStyle(color: Color(0xff666e7a), fontSize: 12),
        ),
        const SizedBox(height: 10),
        const _ReviewCard(
          author: 'Ana · Ejemplo',
          text: 'Me gustó la fotografía y cómo acompaña la historia.',
          stars: 5,
        ),
        const _ReviewCard(
          author: 'Luis · Ejemplo',
          text: 'Una propuesta entretenida, aunque algunas escenas se sienten largas.',
          stars: 3,
        ),
        const _ReviewCard(
          author: 'Sofía · Ejemplo',
          text: 'La música y los personajes fueron lo que más disfruté.',
          stars: 4,
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.author,
    required this.text,
    required this.stars,
  });
  final String author, text;
  final int stars;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xfff4f6fa),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(author, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Row(
          children: List.generate(
            5,
            (i) => Icon(
              i < stars ? Icons.star_rounded : Icons.star_border_rounded,
              color: const Color(0xffffad1f),
              size: 18,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(text),
      ],
    ),
  );
}
