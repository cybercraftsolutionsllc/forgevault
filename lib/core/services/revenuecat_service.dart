import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// RevenueCat subscription service — manages Pro entitlements via native
/// App Store / Play Store / macOS subscriptions.
///
/// Platform Guard:
///   - iOS, Android, macOS → full RevenueCat SDK (paywalls, customer center)
///   - Windows, Web → unsupported (Pro status synced via `.forge` backup)
///
/// Reactive State:
///   - [isProNotifier] is a [ValueNotifier] that any widget can listen to
///     via [ValueListenableBuilder]. Updated on RC events and manual bypass.
class RevenueCatService {
  RevenueCatService._();
  static final RevenueCatService _instance = RevenueCatService._();
  factory RevenueCatService() => _instance;

  static const String _apiKey = 'test_GfUdTTEWewFMayHdBUCPceONGpg';
  static const String _entitlementId = 'Cyber Craft Solutions, LLC Pro';

  /// Reactive Pro status — drives UI via ValueListenableBuilder.
  final ValueNotifier<bool> isProNotifier = ValueNotifier<bool>(false);

  /// Whether RevenueCat is supported on this platform.
  bool get isSupported =>
      !kIsWeb && (Platform.isIOS || Platform.isAndroid || Platform.isMacOS);

  /// Initialize RevenueCat SDK and fetch initial Pro status.
  ///
  /// Safe to call on unsupported platforms — loads cached status only.
  Future<void> init() async {
    // Always load cached Pro status from SharedPreferences (supports
    // manual bypass and cross-platform .forge sync on Windows/Web).
    final prefs = await SharedPreferences.getInstance();
    isProNotifier.value = prefs.getBool('isPro') ?? false;

    if (!isSupported) return;

    await Purchases.setLogLevel(LogLevel.debug);
    await Purchases.configure(PurchasesConfiguration(_apiKey));

    // Listen for background renewals / subscription changes.
    Purchases.addCustomerInfoUpdateListener((info) => _syncProStatus(info));

    // Fetch initial entitlement status.
    try {
      final info = await Purchases.getCustomerInfo();
      await _syncProStatus(info);
    } catch (_) {
      // Sandbox / test_store deserialization may fail — fall back to cache.
    }
  }

  /// Sync RevenueCat entitlement → SharedPreferences + ValueNotifier.
  Future<void> _syncProStatus(CustomerInfo info) async {
    try {
      final isPro = info.entitlements.all[_entitlementId]?.isActive == true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isPro', isPro);
      isProNotifier.value = isPro;
    } catch (_) {
      // Serialization or network error — retain current cached value.
    }
  }

  /// Present the RevenueCat paywall (native modal).
  ///
  /// Throws on failure — caller is responsible for catching and
  /// displaying errors to the user.
  Future<void> presentPaywall() async {
    if (!isSupported) return;
    await RevenueCatUI.presentPaywallIfNeeded(
      _entitlementId,
      displayCloseButton: true,
    );
    // Forcefully re-fetch status after paywall closes.
    await init();
  }

  /// Present the RevenueCat Customer Center (manage/cancel subscription).
  ///
  /// Throws on failure — caller handles UI error display.
  Future<void> showCustomerCenter() async {
    if (!isSupported) return;
    await RevenueCatUI.presentCustomerCenter();
  }

  /// Restore previous purchases (e.g., after reinstall).
  ///
  /// Throws on failure — caller handles UI error display.
  Future<void> restorePurchases() async {
    if (!isSupported) return;
    await Purchases.restorePurchases();
    await init();
  }
}
