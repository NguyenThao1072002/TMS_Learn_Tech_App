class RefreshTokens {
  final int id;
  final DateTime expiryDate;
  final String token;
  final int accountId;

  RefreshTokens({
    required this.id,
    required this.expiryDate,
    required this.token,
    required this.accountId,
  });

  factory RefreshTokens.fromJson(Map<String, dynamic> json) {
    return RefreshTokens(
      id: json['id'],
      expiryDate: DateTime.parse(json['expiry_date']),
      token: json['token'],
      accountId: json['account_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'expiry_date': expiryDate.toIso8601String(),
      'token': token,
      'account_id': accountId,
    };
  }
}