import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:practica06/infrastructure/repositories/local_reviews_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'Reseñas se recuperan en otra instancia y no se mezclan entre películas',
    () async {
      SharedPreferences.setMockInitialValues({});
      final created = DateTime(2026, 11, 4, 12);
      await LocalReviewsRepository().save(2048, [
        LocalReview(
          text: 'Me gustó la historia y el reparto.',
          stars: 5,
          created: created,
        ),
      ]);
      final freshRepository = LocalReviewsRepository();
      final reviews = await freshRepository.load(2048);
      expect(reviews.single.text, 'Me gustó la historia y el reparto.');
      expect(reviews.single.stars, 5);
      expect(reviews.single.created, created);
      expect(await freshRepository.load(4096), isEmpty);
    },
  );
}
