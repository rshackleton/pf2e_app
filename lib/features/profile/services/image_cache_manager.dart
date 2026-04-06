import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ImageCacheManager extends CacheManager {
  static const key = 'pf2e_avatar';

  ImageCacheManager()
    : super(
        Config(
          key,
          stalePeriod: const Duration(hours: 24),
          maxNrOfCacheObjects: 100,
        ),
      );
}
