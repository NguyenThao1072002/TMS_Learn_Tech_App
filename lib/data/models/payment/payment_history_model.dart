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
    try {
      // Validate and handle status field
      if (!json.containsKey('status')) {
        throw FormatException("Missing required 'status' field in response");
      }
      final status = json['status'] as int;
      
      // Validate and handle message field
      if (!json.containsKey('message')) {
        throw FormatException("Missing required 'message' field in response");
      }
      final message = json['message'] as String;
      
      // Validate and handle data field with careful null handling
      if (!json.containsKey('data')) {
        print("Warning: 'data' field missing in response, using empty list");
        return PaymentHistoryResponse(
          status: status,
          message: message,
          data: [],
        );
      }
      
      final dynamic dataRaw = json['data'];
      
      // Handle null data
      if (dataRaw == null) {
        print("Warning: 'data' field is null, using empty list");
        return PaymentHistoryResponse(
          status: status,
          message: message,
          data: [],
        );
      }
      
      // Handle data that is not a list
      if (!(dataRaw is List)) {
        print("Warning: 'data' is not a List (${dataRaw.runtimeType}), using empty list");
        return PaymentHistoryResponse(
          status: status,
          message: message,
          data: [],
        );
      }
      
      // Now we can safely cast and process the list
      final dataList = dataRaw as List<dynamic>;
      
      // Convert each item with careful error handling
      final items = <PaymentHistoryItem>[];
      for (int i = 0; i < dataList.length; i++) {
        try {
          if (dataList[i] is Map<String, dynamic>) {
            items.add(PaymentHistoryItem.fromJson(dataList[i] as Map<String, dynamic>));
          } else {
            print("Warning: Skipping invalid data item at index $i: not a map");
          }
        } catch (e) {
          print("Error parsing payment item at index $i: $e");
          // Continue with the next item rather than failing completely
        }
      }
      
      return PaymentHistoryResponse(
        status: status,
        message: message,
        data: items,
      );
    } catch (e) {
      print("Error in PaymentHistoryResponse.fromJson: $e");
      // Return a valid object with error information instead of throwing
      return PaymentHistoryResponse(
        status: 500,
        message: "Error parsing response: $e",
        data: [],
      );
    }
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
    try {
      // Extract and validate payment details
      List<PaymentDetail> details = [];
      if (json.containsKey('paymentDetails')) {
        final detailsData = json['paymentDetails'];
        if (detailsData != null && detailsData is List) {
          for (int i = 0; i < detailsData.length; i++) {
            try {
              if (detailsData[i] is Map<String, dynamic>) {
                details.add(PaymentDetail.fromJson(detailsData[i] as Map<String, dynamic>));
              }
            } catch (e) {
              print('Error parsing payment detail at index $i: $e');
              // Continue with next detail
            }
          }
        }
      }
      
      // Safe extraction with null checks and defaults
      final paymentId = json['paymentId'] as int? ?? 0;
      final transactionId = json['transactionId'] as String? ?? 'Unknown';
      
      // Handle date parsing safely
      DateTime paymentDate;
      try {
        final dateStr = json['paymentDate'] as String?;
        paymentDate = dateStr != null ? DateTime.parse(dateStr) : DateTime.now();
      } catch (e) {
        print('Error parsing date: $e');
        paymentDate = DateTime.now();
      }
      
      // Handle number conversions safely
      double totalPayment = 0;
      try {
        final amount = json['totalPayment'];
        if (amount != null) {
          totalPayment = amount is double ? amount : (amount is int ? amount.toDouble() : double.tryParse(amount.toString()) ?? 0);
        }
      } catch (e) {
        print('Error parsing totalPayment: $e');
      }
      
      // Other string fields with null checks
      final paymentMethod = json['paymentMethod'] as String? ?? 'Unknown';
      final paymentType = json['paymentType'] as String? ?? 'Unknown';
      
      return PaymentHistoryItem(
        paymentId: paymentId,
        transactionId: transactionId,
        paymentDate: paymentDate,
        totalPayment: totalPayment,
        paymentMethod: paymentMethod,
        paymentType: paymentType,
        paymentDetails: details,
      );
    } catch (e) {
      print('Error in PaymentHistoryItem.fromJson: $e');
      // Return a default object instead of crashing
      return PaymentHistoryItem(
        paymentId: 0,
        transactionId: 'Error',
        paymentDate: DateTime.now(),
        totalPayment: 0,
        paymentMethod: 'Unknown',
        paymentType: 'Unknown',
        paymentDetails: [],
      );
    }
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
    try {
      // Safe extraction with null checks and defaults
      final paymentDetailId = json['paymentDetailId'] as int? ?? 0;
      final title = json['title'] as String? ?? 'Unknown Product';
      
      // Handle price conversion safely
      double price = 0;
      try {
        final priceValue = json['price'];
        if (priceValue != null) {
          price = priceValue is double ? priceValue : 
                 (priceValue is int ? priceValue.toDouble() : 
                 double.tryParse(priceValue.toString()) ?? 0);
        }
      } catch (e) {
        print('Error parsing price in PaymentDetail: $e');
      }
      
      // Product type with default
      final type = json['type'] as String? ?? 'OTHER';
      
      return PaymentDetail(
        paymentDetailId: paymentDetailId,
        title: title,
        price: price,
        type: type,
      );
    } catch (e) {
      print('Error in PaymentDetail.fromJson: $e');
      // Return default object instead of crashing
      return PaymentDetail(
        paymentDetailId: 0,
        title: 'Error',
        price: 0,
        type: 'OTHER',
      );
    }
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