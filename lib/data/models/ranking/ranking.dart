class RankingApiResponse {
  final int status;
  final String message;
  final RankingData data;

  RankingApiResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory RankingApiResponse.fromJson(Map<String, dynamic> json) {
    return RankingApiResponse(
      status: json['status'] as int,
      message: json['message'] as String,
      data: RankingData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'data': data.toJson(),
      };
}

class RankingData {
  final int totalElements;
  final int totalPages;
  final int size;
  final List<Ranking> content;

  RankingData({
    required this.totalElements,
    required this.totalPages,
    required this.size,
    required this.content,
  });

  factory RankingData.fromJson(Map<String, dynamic> json) {
    return RankingData(
      totalElements: json['totalElements'] as int,
      totalPages: json['totalPages'] as int,
      size: json['size'] as int,
      content: (json['content'] as List<dynamic>)
          .map((e) => Ranking.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'totalElements': totalElements,
        'totalPages': totalPages,
        'size': size,
        'content': content.map((e) => e.toJson()).toList(),
      };
}

class Ranking {
  final int id;
  final String? avatar;
  final int accountId;
  final String accountName;
  final String periodType;
  final int totalPoints;
  final int ranking;
  final bool status;
  final String createdAt;
  final String updatedAt;
  final bool isCurrentUser;
  final int level;
  final int completedCourses;

  Ranking({
    required this.id,
    this.avatar,
    required this.accountId,
    required this.accountName,
    required this.periodType,
    required this.totalPoints,
    required this.ranking,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.isCurrentUser = false,
    this.level = 1,
    this.completedCourses = 0,
  });

  factory Ranking.fromJson(Map<String, dynamic> json) {
    return Ranking(
      id: json['id'] as int,
      avatar: json['avatar'] as String?,
      accountId: json['accountId'] as int,
      accountName: json['accountName'] as String,
      periodType: json['periodType'] as String,
      totalPoints: json['totalPoints'] as int,
      ranking: json['ranking'] as int,
      status: json['status'] as bool,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      // These fields aren't in the API, so we provide defaults
      isCurrentUser: false,
      level: 1,
      completedCourses: 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'avatar': avatar,
        'accountId': accountId,
        'accountName': accountName,
        'periodType': periodType,
        'totalPoints': totalPoints,
        'ranking': ranking,
        'status': status,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}
