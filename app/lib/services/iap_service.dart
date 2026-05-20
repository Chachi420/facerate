import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../core/constants/app_constants.dart';

class IapService {
  static final IapService _instance = IapService._();
  factory IapService() => _instance;
  IapService._();

  final _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  final _dio = Dio(BaseOptions(
    baseUrl: AppConstants.apiBaseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  List<ProductDetails> _products = [];
  List<ProductDetails> get products => _products;

  void Function(PurchaseDetails)? onPurchaseComplete;
  void Function(String)? onPurchaseError;

  static const _productIds = {
    AppConstants.creditsProduct10,
    AppConstants.creditsProduct30,
    AppConstants.creditsProduct100,
    AppConstants.proMonthly,
  };

  Future<void> initialize() async {
    final available = await _iap.isAvailable();
    if (!available) return;

    _subscription = _iap.purchaseStream.listen(_handlePurchaseUpdates);

    final response = await _iap.queryProductDetails(_productIds);
    _products = response.productDetails;
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        _verifyAndComplete(purchase);
      } else if (purchase.status == PurchaseStatus.error) {
        onPurchaseError?.call(
          purchase.error?.message ?? 'Purchase failed. Please try again.',
        );
      }
    }
  }

  Future<void> _verifyAndComplete(PurchaseDetails purchase) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        onPurchaseError?.call('You must be signed in to complete a purchase.');
        return;
      }

      final idToken = await user.getIdToken();
      final purchaseToken = purchase.verificationData.serverVerificationData;

      final response = await _dio.post(
        '/api/iap/verify',
        data: jsonEncode({
          'product_id': purchase.productID,
          'purchase_token': purchaseToken,
        }),
        options: Options(
          headers: {
            'Authorization': 'Bearer $idToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        await _iap.completePurchase(purchase);
        onPurchaseComplete?.call(purchase);
      } else {
        onPurchaseError?.call('Verification failed. Please contact support.');
      }
    } on DioException catch (e) {
      final status = e.response?.statusCode;

      if (status == 409) {
        // Already processed on a previous attempt — still safe to complete.
        await _iap.completePurchase(purchase);
        onPurchaseComplete?.call(purchase);
        return;
      }

      final detail = (e.response?.data is Map)
          ? (e.response?.data['detail'] ?? 'Verification failed.')
          : 'Verification failed.';
      onPurchaseError?.call(detail.toString());
    } catch (e) {
      // Network error — the purchase is valid but we couldn't reach the backend.
      // Let the user restore purchases later; do NOT complete here.
      onPurchaseError?.call(
        'Network error. Your purchase will appear after restoring purchases.',
      );
    }
  }

  Future<void> purchaseProduct(ProductDetails product) async {
    final param = PurchaseParam(productDetails: product);
    if (product.id == AppConstants.proMonthly) {
      await _iap.buyNonConsumable(purchaseParam: param);
    } else {
      await _iap.buyConsumable(purchaseParam: param);
    }
  }

  Future<void> restorePurchases() async {
    await _iap.restorePurchases();
  }

  void dispose() {
    _subscription?.cancel();
  }
}
