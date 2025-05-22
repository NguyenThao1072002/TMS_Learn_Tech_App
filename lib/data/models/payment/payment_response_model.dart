class ApiResponseWrapper<T> {
  final int status;
  final String message;
  final T data;

  ApiResponseWrapper({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ApiResponseWrapper.fromJson(
      Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    return ApiResponseWrapper(
      status: json['status'],
      message: json['message'],
      data: fromJsonT(json['data']),
    );
  }
}

class PaymentResponseModel {
  final int id;
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
  final List<PaymentDetailResponseModel> paymentDetails;
  final String? createdAt;
  final String? updatedAt;

  PaymentResponseModel({
    required this.id,
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
    this.createdAt,
    this.updatedAt,
  });

  factory PaymentResponseModel.fromJson(Map<String, dynamic> json) {
    return PaymentResponseModel(
      id: json['id'],
      paymentDate: json['paymentDate'],
      subTotalPayment: json['subTotalPayment'].toDouble(),
      totalPayment: json['totalPayment'].toDouble(),
      totalDiscount: json['totalDiscount'].toDouble(),
      discountValue: json['discountValue'],
      paymentMethod: json['paymentMethod'],
      transactionId: json['transactionId'],
      accountId: json['accountId'],
      paymentType: json['paymentType'],
      status: json['status'],
      note: json['note'],
      paymentDetails: (json['paymentDetails'] as List)
          .map((detail) => PaymentDetailResponseModel.fromJson(detail))
          .toList(),
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}

class PaymentDetailResponseModel {
  final int id;
  final int? paymentId;
  final int? courseId;
  final int? testId;
  final int? courseBundleId;
  final int? subscriptionId;
  final int? walletId;
  final double price;
  final String type;
  final String? createdAt;
  final String? updatedAt;

  PaymentDetailResponseModel({
    required this.id,
    this.paymentId,
    this.courseId,
    this.testId,
    this.courseBundleId,
    this.subscriptionId,
    this.walletId,
    required this.price,
    required this.type,
    this.createdAt,
    this.updatedAt,
  });

  factory PaymentDetailResponseModel.fromJson(Map<String, dynamic> json) {
    return PaymentDetailResponseModel(
      id: json['id'],
      paymentId: json['paymentId'],
      courseId: json['courseId'],
      testId: json['testId'],
      courseBundleId: json['courseBundleId'],
      subscriptionId: json['subscriptionId'],
      walletId: json['walletId'],
      price: json['price'].toDouble(),
      type: json['type'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}
