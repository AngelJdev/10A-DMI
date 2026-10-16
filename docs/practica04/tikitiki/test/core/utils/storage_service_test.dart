import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tikitiki/core/utils/storage_service.dart';

void main() {
  test('el like 0 -> 1 permanece en SharedPreferences', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.getInstance();

    expect(storage.getLikes('video_demo', 0), 0);
    expect(storage.isLiked('video_demo'), isFalse);

    await storage.saveLikes('video_demo', 1);
    await storage.setLiked('video_demo', true);

    expect(storage.getLikes('video_demo', 0), 1);
    expect(storage.isLiked('video_demo'), isTrue);
    expect(storage.getLikedVideoIds(), contains('video_demo'));
  });
}
