import '../../domain/entities/region_profile.dart';

import 'package:flutter_riverpod/legacy.dart';

import '../../domain/entities/movie.dart';

final selectedMediaProvider = StateProvider<MediaType>(
  (ref) => MediaType.movie,
);

final selectedRegionProvider = StateProvider<RegionProfile>(
  (ref) => regionProfiles.first,
);
