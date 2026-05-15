import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../core/constants/app_constants.dart';

class IapService {
  static final IapService _instance = IapService._();
  factory IapService() => _instance;
  IapService._();

  final _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

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
        onPurchaseComplete?.call(purchase);
        _iap.completePurchase(purchase);
      } else if (purchase.status == PurchaseStatus.error) {
        onPurchaseError?.call(
          purchase.error?.message ?? 'Purchase failed. Please try again.',
        );
      }
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
