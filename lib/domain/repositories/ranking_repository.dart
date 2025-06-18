import 'dart:async';
import '../../data/models/ranking/ranking.dart';

abstract class RankingRepository {

  Future<List<Ranking>> getRankings(String periodType, int currentUserId);

  /// Get the current user's ranking details
  Future<int> getCurrentUserRanking(String periodType, int currentUserId);

  /// Get the current user's points
  Future<int> getCurrentUserPoints(String periodType, int currentUserId);
}
