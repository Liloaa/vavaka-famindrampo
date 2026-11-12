import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CacheImages {
  static final CacheManager manager = CacheManager(
    Config(
      'vavaka_images',
      stalePeriod: const Duration(days: 365),
      maxNrOfCacheObjects: 500,
    ),
  );
}