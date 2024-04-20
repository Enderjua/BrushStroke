// ignore_for_file: file_names, avoid_print

import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:strokedebug/backend/deviceInfo.dart';
import 'package:strokedebug/backend/hive.dart';
import 'package:strokedebug/screens/homeScreen.dart';
import 'package:strokedebug/screens/resultScreen.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'package:strokedebug/backend/encrypt.dart';


class ArchiveScreen extends StatefulWidget {
  const ArchiveScreen({super.key});

  @override
  State<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends State<ArchiveScreen> {
  @override

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchData();
     _createRewardedInterstitialAd();
  }

  int _selectedIndex =
      -1; // Seçili resmin index'i (-1 başta hiçbiri seçili değil)
// Seçili resmin index'i (-1 başta hiçbiri seçili değil)

  int maxFailedLoadAttempts = 3;

  RewardedInterstitialAd? _rewardedInterstitialAd;
  int _numRewardedInterstitialLoadAttempts = 0;

  static const AdRequest request = AdRequest(
    nonPersonalizedAds: false,
  );

  int click = 0;

  Encrypting encrypting = Encrypting(vectorKey: "yourKey");
  final DeviceInfoService deviceinfoService = DeviceInfoService();
 
  final List<String> _images = [];
  final List<String> _prompt = [];

  CollectionReference images = FirebaseFirestore.instance.collection('images');


  getImagesInfo() async {
    final deviceID = await deviceinfoService.getDeviceID();
    final androidID = encrypting.encrypterData(deviceID);
    final snapshot = await images.where('androidID', isEqualTo: androidID).get();
    final imageValue = snapshot.docs.map((e) => e.data()).toList();
    for(int j = 0; j < imageValue.length; j++ ) {
      final images = imageValue[j];
      if(images is Map<String, dynamic>) {
        setState(() {
          _images.add(images['imagePath']);
        _prompt.add(images['prompt']);
        });
      }
    }
  }

  // ignore: unused_element
  Future<void> _fetchData() async {
    var records = await getRecords();
    setState(() {
      for (var record in records) {
        _images.add(record.imagePath);
        _prompt.add(record.prompt);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 28, 28, 30),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center, // Başlığı ortalar
          children: [
            InkWell(
              onTap: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (builder) => const HomeScreen()));
              },
              child: const CircleAvatar(
                backgroundColor: Color.fromARGB(255, 192, 192, 192),
                radius: 16.0,
                child: Icon(
                  Icons.arrow_back,
                  size: 25,
                ),
              ),
            ),
            const Expanded(
              // Başlığı olabildiğince genişletir
              child: Center(
                // Başlığı Expanded içine aldık ve ortalamak için Center kullandık
                child: Text(
                  'Arşiv Sayfası',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 28, 28, 30),
      resizeToAvoidBottomInset:
          false, // Klavyenin alt kısmındaki padding'i engelle
      body: SingleChildScrollView(
        // Tıklamaları dinleyin
       
      
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          
            Padding(
              padding: const EdgeInsets.only(top: 20.0, left: 14.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  children: [
                    if (_images.isEmpty)
                      const Center(child: CircularProgressIndicator())
                    else
                      for (var i = 0; i < _images.length; i++)
                        InkWell(
                          // InkWell ile tıklanabilir yap
                          onTap: () {
                            setState(() {
                              _selectedIndex = i; // Seçili index'i güncelle
                            });
                            _showRewardedInterstitialAd(i);
                          },
                          child: _buildImageContainer(
                            _images[i], // Hive'dan gelen imagePath
                            _prompt[
                                i], // Hive'dan gelen modelName yerine kullanılacak prompt
                            i == _selectedIndex,
                          ),
                        ),
                  ],
                ),
              ),
            ),
         
            const Divider(
              thickness: 1.0,
              color: Color.fromARGB(255, 55, 55, 55),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom:  10.0, top: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (builder) => const HomeScreen()));
                    },
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.create, color: Color.fromRGBO(142, 142, 147, 1.0), size: 30,),
                        Text(
                          'Resim Oluştur',
                          style: TextStyle(
                              color: Color.fromRGBO(142, 142, 147, 1.0)),
                        )
                      ],
                    ),
                  ),
                  const Column(
                    children: [
                      Icon(Icons.photo_camera_back_outlined, color: Color.fromARGB(255, 83, 196, 255), size: 30,),
                      Text('Arşiv',
                          style: TextStyle(
                            color: Color.fromARGB(255, 83, 196, 255),
                          ))
                    ],
                  ),
       
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildImageContainer(
      String imagePath, String modelName, bool isSelected) {
    // Ekran boyutlarını al
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    // Resim genişliğini ve yüksekliğini hesapla
    double imageWidth = width / 1.1;
    double imageHeight = height / 4;

    // Container'ı oluştur
    return Container(
      height: imageHeight,
      width: imageWidth,
      margin: const EdgeInsets.only(right: 10.0, bottom: 10.0),
      decoration: BoxDecoration(
        // Container'a dekorasyon ekle
        image: DecorationImage(
            image: NetworkImage(imagePath),
            onError: (exception, stackTrace) {
              // Hata oluşursa yerel resim kullan
              toastification.show(
                type: ToastificationType.error,
                style: ToastificationStyle.fillColored,
                // ignore: use_build_context_synchronously
                context: context,
                title: const Text(
                    'API kaynaklı bir sorun oluştu! Lütfen internet bağlantınızı kontrol edin.'),
                autoCloseDuration: const Duration(seconds: 5),
              );
            },
            fit: BoxFit.cover),
        border: isSelected
            ? Border.all(
                color: const Color.fromARGB(255, 83, 196, 255),
                width: 2.0,
              )
            : null,
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Resmi gösterme

          // Blur efekti için ClipRect ve BackdropFilter
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
              child: Container(
                color: Colors.black.withOpacity(0.4),
                height: 60.0, // Blurlu alanın yüksekliği
                width: imageWidth, // Blurlu alanın genişliği
              ),
            ),
          ),
          // Başlık
          Positioned(
            bottom: 5.0,
            left: 8.0,
            height: 50.0,
            child: Container(
              color: Colors.transparent,
              child: Center(
                child: Column(
                  children: [
                    Text(
                      modelName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  void _createRewardedInterstitialAd() {
    if (_rewardedInterstitialAd != null) return; //
    RewardedInterstitialAd.load(
        adUnitId: Platform.isAndroid
            ? 'adsid'
            : 'adsid ios',
        request: request,
        rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
          onAdLoaded: (RewardedInterstitialAd ad) {
            _rewardedInterstitialAd = ad;
            _numRewardedInterstitialLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            _rewardedInterstitialAd = null;
            _numRewardedInterstitialLoadAttempts += 1;
            if (_numRewardedInterstitialLoadAttempts < maxFailedLoadAttempts) {
              _createRewardedInterstitialAd();
            }
          },
        ));
  }

   void _showRewardedInterstitialAd(int i) {
    if (_rewardedInterstitialAd == null) {
       if(click == 3) {
        Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (builder) => ResultScreen(
                                          promptText: _prompt[i],
                                          imageUrl: _images[i],
                                        )));
       } else {
        toastification.show(
                type: ToastificationType.warning,
                style: ToastificationStyle.fillColored,
                // ignore: use_build_context_synchronously
                context: context,
                title: const Text(
                    'Veriler yükleniyor! Lütfen biraz bekledikten sonra tekrar deneyin.'),
                autoCloseDuration: const Duration(seconds: 5),
              );
      setState(() {
        click = click + 1;
      });
       }
      return;
    }
    _rewardedInterstitialAd!.fullScreenContentCallback =
        FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedInterstitialAd ad) =>
          print('$ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedInterstitialAd ad) {
        ad.dispose();
        _createRewardedInterstitialAd();
        Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (builder) => ResultScreen(
                                          promptText: _prompt[i],
                                          imageUrl: _images[i],
                                        )));
        //geçiş
      },
      onAdFailedToShowFullScreenContent:
          (RewardedInterstitialAd ad, AdError error) {
        ad.dispose();
        _createRewardedInterstitialAd();
      },
    );

    _rewardedInterstitialAd!.setImmersiveMode(true);
    _rewardedInterstitialAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
    });
    _rewardedInterstitialAd = null;
  }
}
