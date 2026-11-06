import 'package:flutter/material.dart';

/// Centers short titles and scrolls overflowing titles at a constant speed.
class ScrollingMovieTitle extends StatefulWidget {
  const ScrollingMovieTitle({
    super.key,
    required this.title,
    required this.style,
  });
  final String title;
  final TextStyle style;

  @override
  State<ScrollingMovieTitle> createState() => _ScrollingMovieTitleState();
}

class _ScrollingMovieTitleState extends State<ScrollingMovieTitle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animation = AnimationController(vsync: this);
  double _distance = 0;
  static const _gap = 48.0;
  static const _pauseMs = 1400;

  void _configure(double distance) {
    if (_distance == distance) return;
    _distance = distance;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _distance != distance) return;
      _animation.stop();
      _animation.value = 0;
      if (distance > 0) {
        _animation.duration = Duration(
          milliseconds: _pauseMs + (distance / 30 * 1000).round(),
        );
        _animation.repeat();
      }
    });
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final scaler = MediaQuery.textScalerOf(context);
      final direction = Directionality.of(context);
      final painter = TextPainter(
        text: TextSpan(text: widget.title, style: widget.style),
        textDirection: direction,
        textScaler: scaler,
        maxLines: 1,
      )..layout();
      final width = painter.width;
      final height = painter.height;
      painter.dispose();
      final overflows = width > constraints.maxWidth;
      final reducedMotion = MediaQuery.disableAnimationsOf(context);
      _configure(overflows && !reducedMotion ? width + _gap : 0);
      final label = Text(
        widget.title,
        style: widget.style,
        maxLines: 1,
        softWrap: false,
      );
      if (!overflows) {
        return SizedBox(
          height: height + 4,
          child: Center(child: label),
        );
      }
      if (reducedMotion) {
        return SizedBox(
          height: height + 4,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: label,
          ),
        );
      }
      return Semantics(
        label: widget.title,
        child: ExcludeSemantics(
          child: SizedBox(
            height: height + 4,
            child: ClipRect(
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, _) {
                  final duration = _pauseMs + ((width + _gap) / 30 * 1000);
                  final elapsed = _animation.value * duration;
                  final offset =
                      ((elapsed - _pauseMs) / (duration - _pauseMs)).clamp(
                        0.0,
                        1.0,
                      ) *
                      (width + _gap);
                  return OverflowBox(
                    alignment: Alignment.centerLeft,
                    minWidth: 2 * (width + _gap),
                    maxWidth: 2 * (width + _gap),
                    child: Transform.translate(
                      offset: Offset(-offset, 0),
                      child: Row(
                        children: [
                          SizedBox(width: width, child: label),
                          const SizedBox(width: _gap),
                          SizedBox(width: width, child: label),
                          const SizedBox(width: _gap),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
    },
  );
}
