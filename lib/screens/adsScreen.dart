import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:quickalert/quickalert.dart';


class AdsScreen extends StatefulWidget {
  const AdsScreen({super.key});

  @override
  State<AdsScreen> createState() => _AdsScreenState();
}

class _AdsScreenState extends State<AdsScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _createRewardedInterstitialAd();
    Future.delayed(const Duration(milliseconds: 500), () {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.loading,
        title: 'Yükleniyor',
        text: 'Size uygun bir reklam yükleniyor',
      );
    });

     Future.delayed(const Duration(seconds: 5), () {
      _showRewardedInterstitialAd();
    });
  }


    int maxFailedLoadAttempts = 3;

  RewardedInterstitialAd? _rewardedInterstitialAd;
  int _numRewardedInterstitialLoadAttempts = 0;

  static final AdRequest request = AdRequest(
    nonPersonalizedAds: false,
  );



  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 28, 28, 30),
      body: Container(
        child: Column(
          children: [
            
   ],
        ),
      ),
      
    );
  }
  void _createRewardedInterstitialAd() {
    if (_rewardedInterstitialAd != null) return; //
    RewardedInterstitialAd.load(
        adUnitId: Platform.isAndroid
            ? 'banner id'
            : 'banner id ios',
        request: request,
        rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
          onAdLoaded: (RewardedInterstitialAd ad) {
            print('$ad loaded.');
            _rewardedInterstitialAd = ad;
            _numRewardedInterstitialLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('RewardedInterstitialAd failed to load: $error');
            _rewardedInterstitialAd = null;
            _numRewardedInterstitialLoadAttempts += 1;
            if (_numRewardedInterstitialLoadAttempts < maxFailedLoadAttempts) {
              _createRewardedInterstitialAd();
            }
          },
        ));
  }

   void _showRewardedInterstitialAd() {
    if (_rewardedInterstitialAd == null) {
      
      return;
    }
    _rewardedInterstitialAd!.fullScreenContentCallback =
        FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedInterstitialAd ad) {
        Future.delayed(const Duration(seconds: 30), () { // Increased duration
          ad.dispose(); 
          // print('KAPAN ULAN REKLAM');
        });
      },
      onAdDismissedFullScreenContent: (RewardedInterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        // print('bitti');

        _createRewardedInterstitialAd();

         Future.delayed(const Duration(seconds: 5), () {
            _showRewardedInterstitialAd();
            // print('GÖSTERMELİ!');
          });
      },
      onAdFailedToShowFullScreenContent:
          (RewardedInterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createRewardedInterstitialAd();
      },
    );

    _rewardedInterstitialAd!.setImmersiveMode(true);
    _rewardedInterstitialAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      print('$ad with reward $RewardItem(${reward.amount}, ${reward.type})');
    });
    _rewardedInterstitialAd = null;
  }

  Card buildButton({
    required onTap,
    required title,
    required text,
    required leadingImage,
  }) {
    return Card(
      shape: const StadiumBorder(),
      margin: const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundImage: AssetImage(
            leadingImage,
          ),
        ),
        title: Text(title ?? ""),
        subtitle: Text(text ?? ""),
        trailing: const Icon(
          Icons.keyboard_arrow_right_rounded,
        ),
      ),
    );
  }
}