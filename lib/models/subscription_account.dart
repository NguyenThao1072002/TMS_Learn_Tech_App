class SubscriptionAccount {
  final int id;
  final DateTime endDate;
  final DateTime startDate;
  final String status;
  final int accountId;
  final int subscriptionId;

  SubscriptionAccount({
    required this.id,
    required this.endDate,
    required this.startDate,
    required this.status,
    required this.accountId,
    required this.subscriptionId,
  });

  factory SubscriptionAccount.fromJson(Map<String, dynamic> json) {
    return SubscriptionAccount(
      id: json['id'],
      endDate: DateTime.parse(json['end_date']),
      startDate: DateTime.parse(json['start_date']),
      status: json['status'],
      accountId: json['account_id'],
      subscriptionId: json['subscription_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'end_date': endDate.toIso8601String(),
      'start_date': startDate.toIso8601String(),
      'status': status,
      'account_id': accountId,
      'subscription_id': subscriptionId,
    };
  }
}