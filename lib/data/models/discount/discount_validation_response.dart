class ApiResponse<T> {
  final int status;
  final String message;
  final T data;

  ApiResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ApiResponse.fromJson(
      Map<String, dynamic> json, T Function(dynamic) fromJsonT) {
    return ApiResponse(
      status: json['status'],
      message: json['message'],
      data: fromJsonT(json['data']),
    );
  }
}

class DiscountValidationResponse {
  final String voucherCode;
  final int id;
  final double discountValue;
  final String format;
  final String startDate;
  final String endDate;

  DiscountValidationResponse({
    required this.voucherCode,
    required this.id,
    required this.discountValue,
    required this.format,
    required this.startDate,
    required this.endDate,
  });

  factory DiscountValidationResponse.fromJson(Map<String, dynamic> json) {
    return DiscountValidationResponse(
      voucherCode: json['voucherCode'],
      id: json['id'],
      discountValue: json['discountValue'] is int
          ? (json['discountValue'] as int).toDouble()
          : json['discountValue'],
      format: json['format'],
      startDate: json['startDate'],
      endDate: json['endDate'],
    );
  }
}
