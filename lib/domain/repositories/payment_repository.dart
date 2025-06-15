import 'package:tms_app/data/models/payment/payment_request_model.dart';
import 'package:tms_app/data/models/payment/payment_response_model.dart';
import 'package:tms_app/data/models/payment/payment_gateway_request.dart';
import 'package:tms_app/data/models/payment/payment_gateway_response.dart';
import 'package:tms_app/data/models/payment/payment_resquest_modal_wallet.dart';

abstract class PaymentRepository {
  Future<Map<String, dynamic>> createZaloPayOrder(Map<String, dynamic> amount);
  Future<Map<String, dynamic>> createZaloPayOrderMobile(
      Map<String, dynamic> amount);
  Future<bool> verifyPayment(String paymentId);
  Future<void> cancelPayment(String paymentId);
  Future<Map<String, dynamic>> getQueryPayment(String appTransId);
  Future<ApiResponseWrapper<PaymentResponseModel>> createPayment(
      PaymentRequestModel request);

  /// Process a successful payment from payment gateway (like ZaloPay) and deposit into wallet
  ///
  /// [request]: The payment gateway request object with all transaction details
  Future<PaymentGatewayResponse> processPaymentGateway(
      PaymentGatewayRequest request);

  Future<PaymentGatewayResponse> processPaymentGatewayMobile(
      PaymentRequestModelWallet request);
}
