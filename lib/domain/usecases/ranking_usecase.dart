import 'dart:async';
import '../../data/models/ranking/ranking.dart';
import '../repositories/ranking_repository.dart';

class GetRankingsUseCase {
  final RankingRepository repository;

  GetRankingsUseCase(this.repository);

  Future<List<Ranking>> execute(String periodType, int currentUserId) {
    return repository.getRankings(periodType, currentUserId);
  }
}

class GetCurrentUserRankingUseCase {
  final RankingRepository repository;

  GetCurrentUserRankingUseCase(this.repository);

  Future<int> execute(String periodType, int currentUserId) {
    return repository.getCurrentUserRanking(periodType, currentUserId);
  }
}

class GetCurrentUserPointsUseCase {
  final RankingRepository repository;

  GetCurrentUserPointsUseCase(this.repository);

  Future<int> execute(String periodType, int currentUserId) {
    return repository.getCurrentUserPoints(periodType, currentUserId);
  }
}
