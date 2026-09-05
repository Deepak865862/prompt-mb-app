import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // kIsWeb ke liye
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  // Google ke Test IDs
  static String get bannerAdUnitId {
    // Web par empty string return karo
    if (kIsWeb) {
      return '';
    }
    
    // Mobile (Android/iOS) ke liye
    // Yeh test IDs hain - publish ke time apni real IDs dalna
    return 'ca-app-pub-3940256099942544/6300978111'; // Android Test ID
  }

  static String get interstitialAdUnitId {
    if (kIsWeb) {
      return '';
    }
    return 'ca-app-pub-3940256099942544/1033173712'; // Android Test ID
  }

  // Banner Ad Widget
  static Widget getBannerAdWidget() {
    // Sirf Mobile par ad dikhayega
    if (kIsWeb) {
      return const SizedBox.shrink(); // Web par kuch mat dikhao
    }
    
    return Container(
      alignment: Alignment.center,
      width: 320,
      height: 50,
      child: AdWidget(
        ad: BannerAd(
          size: AdSize.banner,
          adUnitId: bannerAdUnitId,
          listener: BannerAdListener(
            onAdLoaded: (ad) => print('Ad loaded.'),
            onAdFailedToLoad: (ad, error) {
              print('Ad failed to load: $error');
              ad.dispose();
            },
          ),
          request: const AdRequest(),
        )..load(),
      ),
    );
  }
}