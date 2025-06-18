import 'package:flutter/foundation.dart';
import 'package:tms_app/data/models/payment/payment_gateway_request.dart';
import 'package:tms_app/data/models/payment/payment_gateway_response.dart';
import 'package:tms_app/data/models/payment/payment_request_model.dart';
import 'package:tms_app/data/models/payment/payment_response_model.dart';
import 'package:tms_app/data/models/payment/payment_resquest_modal_wallet.dart';
import '../../domain/usecases/payment_usecase.dart';

class PaymentController extends ChangeNotifier {
  final PaymentUseCase paymentUseCase;
  PaymentController({required this.paymentUseCase});

  // Value notifiers for UI state
  final ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier<String?>(null);
  final ValueNotifier<ApiResponseWrapper<PaymentResponseModel>?> paymentResult =
      ValueNotifier<ApiResponseWrapper<PaymentResponseModel>?>(null);

  Future<Map<String, dynamic>> getZaloPayToken(
      Map<String, dynamic> amount) async {
    return await paymentUseCase.createOrderUseCase(amount);
  }

  // Khởi tạo zalo pay cho mobile để nạp tiền vào ví
  Future<Map<String, dynamic>> getZaloPayTokenMobile(
      Map<String, dynamic> amount) async {
    return await paymentUseCase.createOrderUseCaseMobile(amount);
  }

  Future<Map<String, dynamic>> getQueryPayment(String appTransId) async {
    return await paymentUseCase.getQueryPaymentUseCase(appTransId);
  }

  Future<ApiResponseWrapper<PaymentResponseModel>> savePaymentRecord(
      PaymentRequestModel request) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final result = await paymentUseCase.savePayment(request);
      isLoading.value = false;
      paymentResult.value = result;
      return result;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
      throw e;
    }
  }

  Future<PaymentGatewayResponse> savePaymentRecordMobile(
      PaymentRequestModelWallet request) async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final result = await paymentUseCase.processPaymentGatewayMobile(request);
      isLoading.value = false;
      return result;
    } catch (e) {
      isLoading.value = false;
      errorMessage.value = e.toString();
      throw e;
    }
  }

  @override
  void dispose() {
    isLoading.dispose();
    errorMessage.dispose();
    paymentResult.dispose();
    super.dispose();
  }
}
