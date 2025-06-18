class PaymentRequestModelWallet {
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
  final List<PaymentDetailModelWallet> paymentDetails;
  final String createdAt;
  final String updatedAt;

  PaymentRequestModelWallet({
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

class PaymentDetailModelWallet {
  final int? itemid;
  final String? itemname;
  final double? itemprice;
  final String? itemtype;

  PaymentDetailModelWallet({
    this.itemid,
    this.itemname,
    this.itemprice,
    this.itemtype,
  });

  Map<String, dynamic> toJson() {
    return {
      'itemid': itemid,
      'itemname': itemname,
      'itemprice': itemprice,
      'itemtype': itemtype,
    };
  }
}
