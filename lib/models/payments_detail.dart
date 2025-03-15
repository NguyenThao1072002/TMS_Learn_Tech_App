class PaymentsDetail {
  final int id;
  final String courseTitle;
  final double price;
  final int courseId;
  final int paymentId;
  final int subscriptionId;
  final String type;

  PaymentsDetail({
    required this.id,
    required this.courseTitle,
    required this.price,
    required this.courseId,
    required this.paymentId,
    required this.subscriptionId,
    required this.type,
  });

  factory PaymentsDetail.fromJson(Map<String, dynamic> json) {
    return PaymentsDetail(
      id: json['id'],
      courseTitle: json['course_title'],
      price: json['price'],
      courseId: json['course_id'],
      paymentId: json['payment_id'],
      subscriptionId: json['subscription_id'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'course_title': courseTitle,
      'price': price,
      'course_id': courseId,
      'payment_id': paymentId,
      'subscription_id': subscriptionId,
      'type': type,
    };
  }
}