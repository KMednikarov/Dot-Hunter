import 'dart:async';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple shop page allowing the player to buy extra lives and power-ups.
/// Extra lives can only be purchased up to three times while power-ups have no
/// such limit and are bought in pairs. Purchases persist across sessions using
/// [SharedPreferences].
class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  // In-app purchase configuration
  static const String _lifeProductId = 'extra_life';
  static const String _powerupProductId = 'power_up';

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late final StreamSubscription<List<PurchaseDetails>> _subscription;
  final Set<String> _kIds = {_lifeProductId, _powerupProductId};
  List<ProductDetails> _products = <ProductDetails>[];

  int _extraLives = 0;
  int _extraPowerups = 0;

  @override
  void initState() {
    super.initState();
    _load();

    final purchaseStream = _inAppPurchase.purchaseStream;
    _subscription = purchaseStream.listen(
      _onPurchaseUpdated,
      onDone: () => _subscription.cancel(),
      onError: (_) {},
    );
    _initializeStoreInfo();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _extraLives = prefs.getInt('extraLives') ?? 0;
      _extraPowerups = prefs.getInt('extraPowerups') ?? 0;
    });
  }

  Future<void> _initializeStoreInfo() async {
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) return;
    final ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails(_kIds);
    if (response.error != null || response.productDetails.isEmpty) {
      return;
    }
    setState(() {
      _products = response.productDetails;
    });
  }

  Future<void> _buyLife() async {
    if (_extraLives >= 3) return;
    final ProductDetails product =
        _products.firstWhere((e) => e.id == _lifeProductId);
    final PurchaseParam param = PurchaseParam(productDetails: product);
    await _inAppPurchase.buyConsumable(purchaseParam: param);
  }

  Future<void> _buyPowerup() async {
    final ProductDetails product =
        _products.firstWhere((e) => e.id == _powerupProductId);
    final PurchaseParam param = PurchaseParam(productDetails: product);
    await _inAppPurchase.buyConsumable(purchaseParam: param);
  }

  Future<void> _onPurchaseUpdated(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        final bool valid = await _verifyPurchase(purchaseDetails);
        if (valid) {
          await _deliverProduct(purchaseDetails.productID);
        }
      }
      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // TODO: Send purchaseDetails to backend server for verification and
    // return whether the purchase is valid.
    return true;
  }

  Future<void> _deliverProduct(String productId) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (productId == _lifeProductId && _extraLives < 3) {
        _extraLives++;
      } else if (productId == _powerupProductId) {
        _extraPowerups += 2;
      }
    });
    await prefs.setInt('extraLives', _extraLives);
    await prefs.setInt('extraPowerups', _extraPowerups);
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Extra Lives: $_extraLives/3'),
            ElevatedButton(
              onPressed: _extraLives >= 3 ? null : _buyLife,
              child: const Text('Buy +1 Life'),
            ),
            const SizedBox(height: 20),
            Text('Extra Powerups: $_extraPowerups'),
            ElevatedButton(
              onPressed: _buyPowerup,
              child: const Text('Buy +2 Power Ups'),
            ),
          ],
        ),
      ),
    );
  }
}

