import 'package:flutter/foundation.dart';

class PaymentDetail {
  final int? paymentId;
  final int? subscriptionId;
  final int? walletId;
  final String type;
  final double price;

  PaymentDetail({
    this.paymentId,
    this.subscriptionId,
    this.walletId,
    required this.type,
    required this.price,
  });

  Map<String, dynamic> toJson() {
    return {
      'paymentId': paymentId,
      'subscriptionId': subscriptionId,
      'walletId': walletId,
      'type': type,
      'price': price,
    };
  }
  
  factory PaymentDetail.fromJson(Map<String, dynamic> json) {
    return PaymentDetail(
      paymentId: json['paymentId'],
      subscriptionId: json['subscriptionId'],
      walletId: json['walletId'],
      type: json['type'],
      price: (json['price'] as num).toDouble(),
    );
  }
}

class PaymentGatewayRequest {
  final DateTime paymentDate;
  final double subTotalPayment;
  final double totalPayment;
  final double? totalDiscount;
  final double? discountValue;
  final String paymentMethod;
  final String transactionId;
  final int accountId;
  final String paymentType; // WALLET | SUBSCRIPTION | PRODUCT
  final String note;
  final List<PaymentDetail> paymentDetails;
  final DateTime createdAt;
  final DateTime updatedAt;

  PaymentGatewayRequest({
    required this.paymentDate,
    required this.subTotalPayment,
    required this.totalPayment,
    this.totalDiscount,
    this.discountValue,
    required this.paymentMethod,
    required this.transactionId,
    required this.accountId,
    required this.paymentType,
    required this.note,
    required this.paymentDetails,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'paymentDate': paymentDate.toIso8601String(),
      'subTotalPayment': subTotalPayment,
      'totalPayment': totalPayment,
      'totalDiscount': totalDiscount ?? 0,
      'discountValue': discountValue ?? 0,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'accountId': accountId,
      'paymentType': paymentType,
      'note': note,
      'paymentDetails': paymentDetails.map((detail) => detail.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PaymentGatewayRequest.fromJson(Map<String, dynamic> json) {
    return PaymentGatewayRequest(
      paymentDate: DateTime.parse(json['paymentDate']),
      subTotalPayment: (json['subTotalPayment'] as num).toDouble(),
      totalPayment: (json['totalPayment'] as num).toDouble(),
      totalDiscount: json['totalDiscount'] != null ? (json['totalDiscount'] as num).toDouble() : null,
      discountValue: json['discountValue'] != null ? (json['discountValue'] as num).toDouble() : null,
      paymentMethod: json['paymentMethod'],
      transactionId: json['transactionId'],
      accountId: json['accountId'],
      paymentType: json['paymentType'],
      note: json['note'],
      paymentDetails: (json['paymentDetails'] as List)
          .map((detail) => PaymentDetail.fromJson(detail))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  /// Helper factory to create a wallet deposit request
  factory PaymentGatewayRequest.createWalletDeposit({
    required String transactionId,
    required int accountId,
    required double amount,
    required int walletId,
    String paymentMethod = 'Zalo Pay',
  }) {
    final now = DateTime.now();
    return PaymentGatewayRequest(
      paymentDate: now,
      subTotalPayment: amount,
      totalPayment: amount,
      totalDiscount: 0,
      discountValue: 0,
      paymentMethod: paymentMethod,
      transactionId: transactionId,
      accountId: accountId,
      paymentType: 'WALLET',
      note: 'Thanh toán thành công cho đơn hàng #$transactionId',
      paymentDetails: [
        PaymentDetail(
          paymentId: null,
          subscriptionId: null,
          walletId: walletId,
          type: 'WALLET',
          price: amount,
        ),
      ],
      createdAt: now,
      updatedAt: now,
    );
  }
} 