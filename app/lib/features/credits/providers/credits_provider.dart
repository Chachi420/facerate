import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../../services/iap_service.dart';

final iapServiceProvider = Provider<IapService>((ref) => IapService());

final selectedProductProvider = StateProvider<String?>((ref) => null);

final iapProductsProvider = FutureProvider<List<ProductDetails>>((ref) async {
  final service = ref.read(iapServiceProvider);
  await service.initialize();
  return service.products;
});
