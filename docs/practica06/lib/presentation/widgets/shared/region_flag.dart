import 'package:flutter/material.dart';

import '../../../domain/entities/region_profile.dart';

class RegionFlag extends StatelessWidget {
  const RegionFlag({
    super.key,
    required this.region,
    this.width = 40,
    this.height = 28,
    this.borderRadius = 6,
  });

  final RegionProfile region;
  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.network(
        region.flagAssetUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        semanticLabel: 'Bandera de ${region.country}',
        errorBuilder: (_, _, _) => Container(
          width: width,
          height: height,
          color: Color(region.accentValue),
          alignment: Alignment.center,
          child: Text(
            region.code,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
