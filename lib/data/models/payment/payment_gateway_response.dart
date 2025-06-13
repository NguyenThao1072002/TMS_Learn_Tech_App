import 'package:flutter/foundation.dart';

class PaymentGatewayResponseDetail {
  final int? id;
  final int? paymentId;
  final int? subscriptionId;
  final int? walletId;
  final String type;
  final double price;

  PaymentGatewayResponseDetail({
    this.id,
    this.paymentId,
    this.subscriptionId,
    this.walletId,
    required this.type,
    required this.price,
  });

  factory PaymentGatewayResponseDetail.fromJson(Map<String, dynamic> json) {
    return PaymentGatewayResponseDetail(
      id: json['id'],
      paymentId: json['paymentId'],
      subscriptionId: json['subscriptionId'],
      walletId: json['walletId'],
      type: json['type'],
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'paymentId': paymentId,
      'subscriptionId': subscriptionId,
      'walletId': walletId,
      'type': type,
      'price': price,
    };
  }
}

class PaymentGatewayResponseData {
  final int id;
  final int? walletId;
  final DateTime paymentDate;
  final double subTotalPayment;
  final double totalPayment;
  final double? totalDiscount;
  final double? discountValue;
  final String paymentMethod;
  final String transactionId;
  final int accountId;
  final String paymentType;
  final String status;
  final String note;
  final List<PaymentGatewayResponseDetail> paymentDetails;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PaymentGatewayResponseData({
    required this.id,
    this.walletId,
    required this.paymentDate,
    required this.subTotalPayment,
    required this.totalPayment,
    this.totalDiscount,
    this.discountValue,
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

  factory PaymentGatewayResponseData.fromJson(Map<String, dynamic> json) {
    return PaymentGatewayResponseData(
      id: json['id'],
      walletId: json['walletId'],
      paymentDate: DateTime.parse(json['paymentDate']),
      subTotalPayment: (json['subTotalPayment'] as num).toDouble(),
      totalPayment: (json['totalPayment'] as num).toDouble(),
      totalDiscount: json['totalDiscount'] != null ? (json['totalDiscount'] as num).toDouble() : null,
      discountValue: json['discountValue'] != null ? (json['discountValue'] as num).toDouble() : null,
      paymentMethod: json['paymentMethod'],
      transactionId: json['transactionId'],
      accountId: json['accountId'],
      paymentType: json['paymentType'],
      status: json['status'],
      note: json['note'],
      paymentDetails: json['paymentDetails'] != null && json['paymentDetails'] is List 
          ? (json['paymentDetails'] as List)
              .map((detail) => PaymentGatewayResponseDetail.fromJson(detail))
              .toList()
          : [],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'walletId': walletId,
      'paymentDate': paymentDate.toIso8601String(),
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
      'paymentDetails': paymentDetails.map((detail) => detail.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class PaymentGatewayResponse {
  final int status;
  final String message;
  final PaymentGatewayResponseData? data;

  PaymentGatewayResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory PaymentGatewayResponse.fromJson(Map<String, dynamic> json) {
    return PaymentGatewayResponse(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null 
          ? PaymentGatewayResponseData.fromJson(json['data']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
    };
  }

  bool get isSuccess => status == 200;
} 