import 'package:flutter/material.dart';

import '../../../domain/entities/movie.dart';

class MoviesSlideshow extends StatefulWidget {
  const MoviesSlideshow({super.key, required this.movies, this.onMovieTap});

  final List<Movie> movies;
  final ValueChanged<Movie>? onMovieTap;

  @override
  State<MoviesSlideshow> createState() => _MoviesSlideshowState();
}

class _MoviesSlideshowState extends State<MoviesSlideshow> {
  late final PageController _controller = PageController(
    viewportFraction: 0.84,
    initialPage: widget.movies.length > 1 ? widget.movies.length * 1000 : 0,
  );
  int _currentIndex = 0;

  void _goToMovie(int index) {
    if (!_controller.hasClients) return;
    final currentPage = _controller.page!.round();
    final movieCount = widget.movies.length;
    final currentIndex = currentPage % movieCount;
    var pageDelta = (index - currentIndex + movieCount) % movieCount;
    if (pageDelta > movieCount / 2) pageDelta -= movieCount;
    _controller.animateToPage(
      currentPage + pageDelta,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _move(int direction) {
    if (!_controller.hasClients || widget.movies.length < 2) return;
    final page = _controller.page!.round();
    _controller.animateToPage(
      (page + direction).clamp(0, 1 << 30),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _goToEnd({required bool last}) {
    if (!_controller.hasClients || widget.movies.isEmpty) return;
    final page = _controller.page!.round();
    final cycleStart = page - page % widget.movies.length;
    final targetPage = cycleStart + (last ? widget.movies.length - 1 : 0);
    final distance = (targetPage - page).abs();
    _controller.animateToPage(
      targetPage,
      duration: Duration(milliseconds: (420 + distance * 120).clamp(420, 980)),
      curve: Curves.easeInOutCubicEmphasized,
    );
  }

  Widget _arrow({required bool previous}) {
    final label = previous ? 'Anterior' : 'Siguiente';
    final hint = previous
        ? 'Doble toque para ir al inicio'
        : 'Doble toque para ir a la ?ltima pel?cula';
    return Tooltip(
      message: '$label. $hint',
      child: GestureDetector(
        key: ValueKey(previous ? 'carousel-previous' : 'carousel-next'),
        behavior: HitTestBehavior.opaque,
        onTap: () => _move(previous ? -1 : 1),
        onDoubleTap: () => _goToEnd(last: !previous),
        child: Semantics(
          button: true,
          label: label,
          hint: hint,
          child: Container(
            width: 44,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.28),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              previous
                  ? Icons.chevron_left_rounded
                  : Icons.chevron_right_rounded,
              size: 34,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ),
      ),
    );
  }

  Widget _pageIndicator(int index) {
    final selected = index == _currentIndex;
    return Semantics(
      button: true,
      selected: selected,
      label: 'Película ${index + 1} de ${widget.movies.length}',
      child: GestureDetector(
        key: ValueKey('carousel-indicator-$index'),
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onTap: () => _goToMovie(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outlineVariant,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.movies.isEmpty) return const SizedBox.shrink();
    final colors = Theme.of(context).colorScheme;
    final borderRadius = BorderRadius.circular(20);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: (MediaQuery.sizeOf(context).width / 1.8).clamp(
            140.0,
            (MediaQuery.sizeOf(context).height * 0.42).clamp(140.0, 420.0),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: widget.movies.length == 1 ? 1 : null,
                  onPageChanged: (index) {
                    final currentIndex = index % widget.movies.length;
                    if (currentIndex != _currentIndex) {
                      setState(() => _currentIndex = currentIndex);
                    }
                  },
                  itemBuilder: (context, index) {
                    final movie = widget.movies[index % widget.movies.length];

                    return AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        final currentPage =
                            _controller.hasClients &&
                                _controller.position.hasContentDimensions
                            ? (_controller.page ?? index.toDouble())
                            : index.toDouble();
                        final distance = (currentPage - index).abs().clamp(
                          0.0,
                          1.0,
                        );
                        final scale = 1 - (distance * 0.055);
                        return Transform.scale(scale: scale, child: child);
                      },
                      child: GestureDetector(
                        key: ValueKey('carousel-movie-$index'),
                        behavior: HitTestBehavior.opaque,
                        onTap: () => widget.onMovieTap?.call(movie),
                        onDoubleTap: widget.movies.length > 1
                            ? () => _move(1)
                            : null,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 12,
                          ),
                          child: Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerHighest,
                              borderRadius: borderRadius,
                              boxShadow: [
                                BoxShadow(
                                  color: colors.shadow.withValues(alpha: 0.16),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            foregroundDecoration: BoxDecoration(
                              borderRadius: borderRadius,
                              border: Border.all(
                                color: colors.outlineVariant.withValues(
                                  alpha: 0.65,
                                ),
                                width: 1.2,
                              ),
                            ),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Semantics(
                                  label: movie.title,
                                  image: true,
                                  child: Image.network(
                                    movie.backdropPath,
                                    fit: BoxFit.cover,
                                    excludeFromSemantics: true,
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) return child;
                                      return const Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    },
                                    errorBuilder:
                                        (
                                          context,
                                          error,
                                          stackTrace,
                                        ) => Image.network(
                                          movie.posterPath,
                                          fit: BoxFit.cover,
                                          excludeFromSemantics: true,
                                          errorBuilder: (_, _, _) => ColoredBox(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .surfaceContainerHighest,
                                            child: const Center(
                                              child: Icon(
                                                Icons.movie_outlined,
                                                size: 40,
                                              ),
                                            ),
                                          ),
                                        ),
                                  ),
                                ),
                                const DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.center,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black87,
                                      ],
                                      stops: [0.48, 1],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 20,
                                  right: 20,
                                  bottom: 16,
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          movie.title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black54,
                                                blurRadius: 6,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Icon(
                                        Icons.star_rounded,
                                        color: Color(0xffffb11b),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        movie.voteAverage.toStringAsFixed(1),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (widget.movies.length > 1) ...[
                Positioned(
                  left: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(child: _arrow(previous: true)),
                ),
                Positioned(
                  right: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(child: _arrow(previous: false)),
                ),
              ],
            ],
          ),
        ),
        if (widget.movies.length > 1)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(widget.movies.length, _pageIndicator),
              ),
            ),
          ),
      ],
    );
  }
}
