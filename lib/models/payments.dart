class Payments {
  final int id;
  final String paymentMethod;
  final DateTime paymentDate;
  final double totalPayment;
  final int accountId;
  final String paymentType;

  Payments({
    required this.id,
    required this.paymentMethod,
    required this.paymentDate,
    required this.totalPayment,
    required this.accountId,
    required this.paymentType,
  });

  factory Payments.fromJson(Map<String, dynamic> json) {
    return Payments(
      id: json['id'],
      paymentMethod: json['payment_method'],
      paymentDate: DateTime.parse(json['payment_date']),
      totalPayment: json['total_payment'],
      accountId: json['account_id'],
      paymentType: json['payment_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'payment_method': paymentMethod,
      'payment_date': paymentDate.toIso8601String(),
      'total_payment': totalPayment,
      'account_id': accountId,
      'payment_type': paymentType,
    };
  }
}