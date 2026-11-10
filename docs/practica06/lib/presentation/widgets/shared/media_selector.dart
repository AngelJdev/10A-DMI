import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/movie.dart';
import '../../localization/app_copy.dart';
import '../../providers/catalog_preferences.dart';

class MediaSelector extends ConsumerWidget {
  const MediaSelector({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedMediaProvider);
    final theme = Theme.of(context);
    final copy = AppCopy.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
      child: Container(
        height: 46,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xfff0f3f8),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: MediaType.values.map((type) {
            final active = type == selected;
            return Expanded(
              child: Semantics(
                selected: active,
                button: true,
                child: InkWell(
                  key: ValueKey('media-${type.name}'),
                  borderRadius: BorderRadius.circular(10),
                  onTap: () =>
                      ref.read(selectedMediaProvider.notifier).state = type,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      color: active ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: active
                          ? const [
                              BoxShadow(
                                color: Color(0x0d172b4d),
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          type == MediaType.movie
                              ? Icons.movie_outlined
                              : Icons.tv_rounded,
                          size: 18,
                          color: active
                              ? theme.colorScheme.primary
                              : const Color(0xff737b8a),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          copy.text(
                            type == MediaType.movie ? 'movies' : 'series',
                          ),
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: active
                                ? theme.colorScheme.primary
                                : const Color(0xff737b8a),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
