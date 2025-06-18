import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tms_app/data/models/ranking/ranking.dart';
import 'package:tms_app/data/services/ranking/ranking_service.dart';
import 'package:tms_app/domain/repositories/ranking_repository.dart';

class RankingRepositoryImpl implements RankingRepository {
  final RankingService rankingService;

  RankingRepositoryImpl({
    required this.rankingService,
  });

  @override
  Future<List<Ranking>> getRankings(String periodType, int currentUserId) async {
    return await rankingService.fetchRankings(
        periodType: periodType, currentUserId: currentUserId);
  }

  @override
  Future<int> getCurrentUserRanking(String periodType, int currentUserId) async {
    try {
      final rankings = await getRankings(periodType, currentUserId);
      final currentUserRanking = rankings.firstWhere(
        (ranking) => ranking.accountId == currentUserId,
        orElse: () => Ranking(
          id: 0,
          accountId: currentUserId,
          accountName: '',
          periodType: periodType,
          totalPoints: 0,
          ranking: 0,
          status: false,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
          isCurrentUser: true,
        ),
      );
      return currentUserRanking.ranking;
    } catch (e) {
      return 0; // Default ranking if not found
    }
  }

  @override
  Future<int> getCurrentUserPoints(String periodType, int currentUserId) async {
    try {
      final rankings = await getRankings(periodType, currentUserId);
      final currentUserRanking = rankings.firstWhere(
        (ranking) => ranking.accountId == currentUserId,
        orElse: () => Ranking(
          id: 0,
          accountId: currentUserId,
          accountName: '',
          periodType: periodType,
          totalPoints: 0,
          ranking: 0,
          status: false,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
          isCurrentUser: true,
        ),
      );
      return currentUserRanking.totalPoints;
    } catch (e) {
      return 0; // Default points if not found
    }
  }
}
