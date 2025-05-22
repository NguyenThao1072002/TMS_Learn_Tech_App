class PaymentRequestModel {
  final String? id;
  final String paymentDate;
  final double subTotalPayment;
  final double totalPayment;
  final double totalDiscount;
  final int discountValue;
  final String paymentMethod;
  final String transactionId;
  final int accountId;
  final String paymentType;
  final String status;
  final String note;
  final List<PaymentDetailModel> paymentDetails;
  final String createdAt;
  final String updatedAt;

  PaymentRequestModel({
    this.id,
    required this.paymentDate,
    required this.subTotalPayment,
    required this.totalPayment,
    required this.totalDiscount,
    required this.discountValue,
    required this.paymentMethod,
    required this.transactionId,
    required this.accountId,
    required this.paymentType,
    required this.status,
    required this.note,
    required this.paymentDetails,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'paymentDate': paymentDate,
      'subTotalPayment': subTotalPayment,
      'totalPayment': totalPayment,
      'totalDiscount': totalDiscount,
      'discountValue': discountValue,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'accountId': accountId,
      'paymentType': paymentType,
      'status': status,
      'note': note,
      'paymentDetails':
          paymentDetails.map((detail) => detail.toJson()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class PaymentDetailModel {
  final String? id;
  final int? courseId;
  final int? testId;
  final int? courseBundleId;
  final int? subscriptionId;
  final int? walletId;
  final double price;
  final String type;

  PaymentDetailModel({
    this.id,
    this.courseId,
    this.testId,
    this.courseBundleId,
    this.subscriptionId,
    this.walletId,
    required this.price,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'testId': testId,
      'courseBundleId': courseBundleId,
      'subscriptionId': subscriptionId,
      'walletId': walletId,
      'price': price,
      'type': type,
    };
  }
}
