/// Model đại diện cho phản hồi API từ lấy lịch sử giao dịch
class PaymentHistoryResponse {
  /// Mã trạng thái HTTP
  final int status;
  
  /// Thông điệp từ server
  final String message;
  
  /// Danh sách các giao dịch
  final List<PaymentHistoryItem> data;

  PaymentHistoryResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  /// Factory constructor để tạo PaymentHistoryResponse từ JSON
  factory PaymentHistoryResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>;
    
    return PaymentHistoryResponse(
      status: json['status'] as int,
      message: json['message'] as String,
      data: dataList.map((item) => PaymentHistoryItem.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }

  /// Chuyển đổi PaymentHistoryResponse thành Map
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}

/// Model đại diện cho một item giao dịch
class PaymentHistoryItem {
  /// ID của giao dịch thanh toán
  final int paymentId;
  
  /// ID giao dịch
  final String transactionId;
  
  /// Ngày thanh toán
  final DateTime paymentDate;
  
  /// Tổng tiền thanh toán
  final double totalPayment;
  
  /// Phương thức thanh toán
  final String paymentMethod;
  
  /// Loại thanh toán
  final String paymentType;
  
  /// Chi tiết các sản phẩm đã thanh toán
  final List<PaymentDetail> paymentDetails;

  PaymentHistoryItem({
    required this.paymentId,
    required this.transactionId,
    required this.paymentDate,
    required this.totalPayment,
    required this.paymentMethod,
    required this.paymentType,
    required this.paymentDetails,
  });

  /// Factory constructor để tạo PaymentHistoryItem từ JSON
  factory PaymentHistoryItem.fromJson(Map<String, dynamic> json) {
    final detailsList = json['paymentDetails'] as List<dynamic>;
    
    return PaymentHistoryItem(
      paymentId: json['paymentId'] as int,
      transactionId: json['transactionId'] as String,
      paymentDate: DateTime.parse(json['paymentDate'] as String),
      totalPayment: (json['totalPayment'] as num).toDouble(),
      paymentMethod: json['paymentMethod'] as String,
      paymentType: json['paymentType'] as String,
      paymentDetails: detailsList.map((item) => PaymentDetail.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }

  /// Chuyển đổi PaymentHistoryItem thành Map
  Map<String, dynamic> toJson() {
    return {
      'paymentId': paymentId,
      'transactionId': transactionId,
      'paymentDate': paymentDate.toIso8601String(),
      'totalPayment': totalPayment,
      'paymentMethod': paymentMethod,
      'paymentType': paymentType,
      'paymentDetails': paymentDetails.map((item) => item.toJson()).toList(),
    };
  }
  
  /// Kiểm tra xem giao dịch có phải là combo hay không
  bool get isCombo => paymentDetails.length > 1;

  /// Format số tiền với đơn vị đồng
  String get formattedAmount => '${totalPayment.toStringAsFixed(0)}đ';

  /// Format thời gian ngày/tháng/năm
  String get formattedDate => '${paymentDate.day}/${paymentDate.month}/${paymentDate.year}';
  
  /// Format thời gian giờ:phút
  String get formattedTime => '${paymentDate.hour}:${paymentDate.minute.toString().padLeft(2, '0')}';
}

/// Model đại diện cho chi tiết một sản phẩm trong giao dịch
class PaymentDetail {
  /// ID của chi tiết thanh toán
  final int paymentDetailId;
  
  /// Tiêu đề của sản phẩm
  final String title;
  
  /// Giá của sản phẩm
  final double price;
  
  /// Loại sản phẩm (EXAM, COURSE, COMBO)
  final String type;

  PaymentDetail({
    required this.paymentDetailId,
    required this.title,
    required this.price,
    required this.type,
  });

  /// Factory constructor để tạo PaymentDetail từ JSON
  factory PaymentDetail.fromJson(Map<String, dynamic> json) {
    return PaymentDetail(
      paymentDetailId: json['paymentDetailId'] as int,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      type: json['type'] as String,
    );
  }

  /// Chuyển đổi PaymentDetail thành Map
  Map<String, dynamic> toJson() {
    return {
      'paymentDetailId': paymentDetailId,
      'title': title,
      'price': price,
      'type': type,
    };
  }
  
  /// Format số tiền với đơn vị đồng
  String get formattedPrice => '${price.toStringAsFixed(0)}đ';
  
  /// Icon tương ứng với loại sản phẩm
  String get typeIcon {
    switch (type) {
      case 'EXAM':
        return 'assets/icons/exam_icon.png'; // Hoặc tên icon tương ứng trong ứng dụng
      case 'COURSE':
        return 'assets/icons/course_icon.png';
      case 'COMBO':
        return 'assets/icons/combo_icon.png';
      default:
        return 'assets/icons/product_icon.png';
    }
  }
} 