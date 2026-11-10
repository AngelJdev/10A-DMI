import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../domain/entities/region_profile.dart';
import '../../localization/app_copy.dart';
import 'region_flag.dart';

class RegionLoadingOverlay extends StatelessWidget {
  const RegionLoadingOverlay({super.key, required this.region});
  final RegionProfile region;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final copy = AppCopy(region.locale);
    return Semantics(
      liveRegion: true,
      label: copy.text('updatingLanguage'),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: ColoredBox(
            color: const Color(0xfff5f7fb).withValues(alpha: 0.82),
            child: Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) => Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 12 * (1 - value)),
                    child: child,
                  ),
                ),
                child: Container(
                  width: 340,
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xffe7ecf4)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0c182e57),
                        blurRadius: 40,
                        offset: Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.07,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.translate_rounded,
                              color: theme.colorScheme.primary,
                              size: 24,
                            ),
                          ),
                          const Spacer(),
                          RegionFlag(
                            region: region,
                            width: 38,
                            height: 26,
                            borderRadius: 6,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        copy.text('updatingLanguage'),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xff17233b),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${region.country} · ${region.language}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xff737b8a),
                        ),
                      ),
                      const SizedBox(height: 24),
                      LinearProgressIndicator(
                        minHeight: 3,
                        borderRadius: BorderRadius.circular(4),
                        color: theme.colorScheme.primary,
                        backgroundColor: const Color(0xffedf1f8),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
