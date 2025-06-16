import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:tms_app/core/utils/constants.dart';
import '../../models/ranking/ranking.dart';


class RankingService {
  final String baseUrl = "${Constants.BASE_URL}/api";
  final Dio dio;

  RankingService(this.dio); 


  Future<List<Ranking>> fetchRankings(
      {required String periodType, required int currentUserId}) async {
    final response = await dio.get('$baseUrl/rankings/$periodType');

    if (response.statusCode != 200) {
      throw Exception('Failed to load rankings: ${response.statusCode}');
    }

    final Map<String, dynamic> jsonResponse = json.decode(response.data);
    final rankingApiResponse = RankingApiResponse.fromJson(jsonResponse);

    return rankingApiResponse.data.content.map((model) {
      return Ranking(
        id: model.id,
        avatar: model.avatar,
        accountId: model.accountId,
        accountName: model.accountName,
        periodType: model.periodType,
        totalPoints: model.totalPoints,
        ranking: model.ranking,
        status: model.status,
        createdAt: model.createdAt,
        updatedAt: model.updatedAt,
        isCurrentUser: model.accountId == currentUserId,
        // Since the API currently doesn't expose level/completedCourses, we use defaults.
        level: 1,
        completedCourses: 0,
      );
    }).toList();
  }

  /// Convenience method to obtain current user's rank.
  Future<int> fetchCurrentUserRank(
      {required String periodType, required int currentUserId}) async {
    final rankings = await fetchRankings(
        periodType: periodType, currentUserId: currentUserId);
    return rankings
        .firstWhere(
          (r) => r.accountId == currentUserId,
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
        )
        .ranking;
  }

  /// Convenience method to obtain current user's points.
  Future<int> fetchCurrentUserPoints(
      {required String periodType, required int currentUserId}) async {
    final rankings = await fetchRankings(
        periodType: periodType, currentUserId: currentUserId);
    return rankings
        .firstWhere(
          (r) => r.accountId == currentUserId,
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
        )
        .totalPoints;
  }
}
