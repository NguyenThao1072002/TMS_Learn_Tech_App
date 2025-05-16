class AccountOverviewModel {
  final int accountId;
  final String accountName;
  final String email;
  final int totalPoints;
  final int dayStreak;
  final int countCourse;
  final int countDocument;
  final double balanceWallet;
  final int? walletId;

  AccountOverviewModel({
    required this.accountId,
    required this.accountName,
    required this.email,
    required this.totalPoints,
    required this.dayStreak,
    required this.countCourse,
    required this.countDocument,
    required this.balanceWallet,
    this.walletId,
  });

  factory AccountOverviewModel.fromJson(Map<String, dynamic> json) {
    return AccountOverviewModel(
      accountId: json['accountId'] ?? 0,
      accountName: json['accountName'] ?? '',
      email: json['email'] ?? '',
      totalPoints: json['totalPoints'] ?? 0,
      dayStreak: json['dayStreak'] ?? 0,
      countCourse: json['countCourse'] ?? 0,
      countDocument: json['countDocument'] ?? 0,
      balanceWallet: (json['balanceWallet'] ?? 0).toDouble(),
      walletId: json['walletId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accountId': accountId,
      'accountName': accountName,
      'email': email,
      'totalPoints': totalPoints,
      'dayStreak': dayStreak,
      'countCourse': countCourse,
      'countDocument': countDocument,
      'balanceWallet': balanceWallet,
      'walletId': walletId,
    };
  }
}
