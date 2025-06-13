/// Model đại diện cho phản hồi API từ lấy lịch sử giao dịch ví
class WalletTransactionResponse {
  /// Mã trạng thái HTTP
  final int status;
  
  /// Thông điệp từ server
  final String message;
  
  /// Dữ liệu phân trang
  final WalletTransactionPaginatedData data;

  WalletTransactionResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  /// Factory constructor để tạo WalletTransactionResponse từ JSON
  factory WalletTransactionResponse.fromJson(Map<String, dynamic> json) {
    return WalletTransactionResponse(
      status: json['status'] as int,
      message: json['message'] as String,
      data: WalletTransactionPaginatedData.fromJson(json['data'] as Map<String, dynamic>),
    );
  }

  /// Chuyển đổi WalletTransactionResponse thành Map
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.toJson(),
    };
  }
}

/// Model đại diện cho dữ liệu phân trang của lịch sử giao dịch ví
class WalletTransactionPaginatedData {
  /// Tổng số phần tử
  final int totalElements;
  
  /// Tổng số trang
  final int totalPages;
  
  /// Thông tin phân trang
  final Pageable pageable;
  
  /// Kích thước trang
  final int size;
  
  /// Danh sách các giao dịch
  final List<WalletTransaction> content;

  WalletTransactionPaginatedData({
    required this.totalElements,
    required this.totalPages,
    required this.pageable,
    required this.size,
    required this.content,
  });

  /// Factory constructor để tạo WalletTransactionPaginatedData từ JSON
  factory WalletTransactionPaginatedData.fromJson(Map<String, dynamic> json) {
    final contentList = json['content'] as List<dynamic>;
    
    return WalletTransactionPaginatedData(
      totalElements: json['totalElements'] as int,
      totalPages: json['totalPages'] as int,
      pageable: Pageable.fromJson(json['pageable'] as Map<String, dynamic>),
      size: json['size'] as int,
      content: contentList.map((item) => WalletTransaction.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }

  /// Chuyển đổi WalletTransactionPaginatedData thành Map
  Map<String, dynamic> toJson() {
    return {
      'totalElements': totalElements,
      'totalPages': totalPages,
      'pageable': pageable.toJson(),
      'size': size,
      'content': content.map((item) => item.toJson()).toList(),
    };
  }
}

/// Model đại diện cho thông tin phân trang
class Pageable {
  /// Số trang hiện tại
  final int pageNumber;
  
  /// Kích thước trang
  final int pageSize;
  
  /// Thông tin sắp xếp
  final Sort sort;
  
  /// Vị trí bắt đầu
  final int offset;
  
  /// Đã phân trang
  final bool paged;
  
  /// Chưa phân trang
  final bool unpaged;

  Pageable({
    required this.pageNumber,
    required this.pageSize,
    required this.sort,
    required this.offset,
    required this.paged,
    required this.unpaged,
  });

  /// Factory constructor để tạo Pageable từ JSON
  factory Pageable.fromJson(Map<String, dynamic> json) {
    return Pageable(
      pageNumber: json['pageNumber'] as int,
      pageSize: json['pageSize'] as int,
      sort: Sort.fromJson(json['sort'] as Map<String, dynamic>),
      offset: json['offset'] as int,
      paged: json['paged'] as bool,
      unpaged: json['unpaged'] as bool,
    );
  }

  /// Chuyển đổi Pageable thành Map
  Map<String, dynamic> toJson() {
    return {
      'pageNumber': pageNumber,
      'pageSize': pageSize,
      'sort': sort.toJson(),
      'offset': offset,
      'paged': paged,
      'unpaged': unpaged,
    };
  }
}

/// Model đại diện cho thông tin sắp xếp
class Sort {
  /// Đã sắp xếp
  final bool sorted;
  
  /// Trống
  final bool empty;
  
  /// Chưa sắp xếp
  final bool unsorted;

  Sort({
    required this.sorted,
    required this.empty,
    required this.unsorted,
  });

  /// Factory constructor để tạo Sort từ JSON
  factory Sort.fromJson(Map<String, dynamic> json) {
    return Sort(
      sorted: json['sorted'] as bool,
      empty: json['empty'] as bool,
      unsorted: json['unsorted'] as bool,
    );
  }

  /// Chuyển đổi Sort thành Map
  Map<String, dynamic> toJson() {
    return {
      'sorted': sorted,
      'empty': empty,
      'unsorted': unsorted,
    };
  }
}

/// Model đại diện cho một giao dịch ví
class WalletTransaction {
  /// ID của giao dịch
  final int transactionId;
  
  /// Tên tài khoản
  final String accountName;
  
  /// Tên ví
  final String walletName;
  
  /// Loại giao dịch
  final String transactionType;
  
  /// Số tiền giao dịch
  final double amount;
  
  /// Trạng thái giao dịch
  final String transactionStatus;
  
  /// Thời gian giao dịch
  final DateTime transactionDate;
  
  /// ID giao dịch bên ngoài (nếu có)
  final String? externalTransactionId;
  
  /// Mô tả giao dịch
  final String description;

  WalletTransaction({
    required this.transactionId,
    required this.accountName,
    required this.walletName,
    required this.transactionType,
    required this.amount,
    required this.transactionStatus,
    required this.transactionDate,
    this.externalTransactionId,
    required this.description,
  });

  /// Factory constructor để tạo WalletTransaction từ JSON
  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      transactionId: json['transactionId'] as int,
      accountName: json['accountName'] as String,
      walletName: json['walletName'] as String,
      transactionType: json['transactionType'] as String,
      amount: (json['amount'] as num).toDouble(),
      transactionStatus: json['transactionStatus'] as String,
      transactionDate: DateTime.parse(json['transactionDate'] as String),
      externalTransactionId: json['externalTransactionId'] as String?,
      description: json['description'] as String,
    );
  }

  /// Chuyển đổi WalletTransaction thành Map
  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'accountName': accountName,
      'walletName': walletName,
      'transactionType': transactionType,
      'amount': amount,
      'transactionStatus': transactionStatus,
      'transactionDate': transactionDate.toIso8601String(),
      'externalTransactionId': externalTransactionId,
      'description': description,
    };
  }
  
  /// Format số tiền với đơn vị đồng
  String get formattedAmount => '${amount.toStringAsFixed(0)}đ';

  /// Format thời gian ngày/tháng/năm
  String get formattedDate => '${transactionDate.day}/${transactionDate.month}/${transactionDate.year}';
  
  /// Format thời gian giờ:phút
  String get formattedTime => '${transactionDate.hour}:${transactionDate.minute.toString().padLeft(2, '0')}';
  
  /// Kiểm tra xem giao dịch có phải là nạp tiền không
  bool get isTopUp => transactionType == "TOP_UP";
  
  /// Kiểm tra xem giao dịch có phải là thanh toán không
  bool get isPayment => transactionType == "PAYMENT";
  
  /// Lấy màu hiển thị dựa trên loại giao dịch
  String get typeColor {
    switch (transactionType) {
      case "TOP_UP":
        return "#4CAF50"; // Xanh lá
      case "PAYMENT":
        return "#F44336"; // Đỏ
      default:
        return "#2196F3"; // Xanh dương
    }
  }
  
  /// Lấy icon hiển thị dựa trên loại giao dịch
  String get typeIcon {
    switch (transactionType) {
      case "TOP_UP":
        return "assets/icons/top_up.png";
      case "PAYMENT":
        return "assets/icons/payment.png";
      default:
        return "assets/icons/transaction.png";
    }
  }
} 