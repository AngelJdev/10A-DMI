import 'package:flutter/material.dart';
import '../../domain/entities/recommendation.dart';
import '../../domain/repositories/recommendation_repository.dart';

class RecommendationProvider extends ChangeNotifier {
  final RecommendationRepository repository;

  bool isLoading = false;
  VideoSource currentSource = VideoSource.youtube;
  List<Recommendation> recommendations = [];

  RecommendationProvider(this.repository) {
    loadRecommendations(VideoSource.youtube);
  }

  Future<void> loadRecommendations(VideoSource source) async {
    currentSource = source;
    isLoading = true;
    notifyListeners();

    try {
      recommendations = await repository.getRecommendations(source);
    } catch (_) {
      recommendations = [];
    }

    isLoading = false;
    notifyListeners();
  }
}
