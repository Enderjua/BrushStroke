// ignore_for_file: file_names
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:strokedebug/backend/hive.dart';
import 'package:strokedebug/backend/shareImage.dart';
import 'package:strokedebug/screens/homeScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:toastification/toastification.dart';

class ResultScreen extends StatefulWidget {
  /// The requested size of the banner. Defaults to [AdSize.banner].
  final AdSize adSize;
   final String promptText; // Prompt metni için değişken
  final String imageUrl; // Resim URL'si için değişken

  /// The AdMob ad unit to show.
  ///
  /// TODO: replace this test ad unit with your own ad unit
  final String adUnitId = Platform.isAndroid
      // Use this ad unit on Android...
      ? 'ads id'
      // ... or this one on iOS.
      : 'ads id ios';

  ResultScreen({
    super.key,
    this.adSize = AdSize.banner,
    required this.promptText,
    required this.imageUrl
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  /// The banner ad to show. This is `null` until the ad is actually loaded.
  BannerAd? _bannerAd;



  // Butonun genişliği
  final double _buttonWidth = 300.0;

// Butonun yüksekliği
  final double _buttonHeight = 70.0;

// Butonun kenarlık yarıçapı
  final double _borderRadius = 10.0;

// Butonun arka plan rengi

// Butonun metin rengi
  final Color _textColor = Colors.black;

// Butonun yazı tipi boyutu
  final double _fontSize = 20.0;
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 28, 28, 30),
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
                        builder: (builder) => HomeScreen()));
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
                  'Sonuç',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        actions: [
          InkWell(
            onTap: () async {
              final box = Hive.box<GeneratedImage>(
                  'images'); // Gerekirse 'GeneratedImage' kısmını model sınıfınızla değiştirin.
              final itemsToDelete = box.values
                  .where((record) =>
                      record.prompt == widget.promptText &&
                      record.imagePath == widget.imageUrl)
                  .toList();
              for (var item in itemsToDelete) {
                box.delete(item.key);
              }

              // Silme işlemi tamamlandıktan sonra ana ekrana yönlendirme
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => HomeScreen()),
              );
            },
            child: const CircleAvatar(
              backgroundColor: Color.fromARGB(255, 192, 192, 192),
              radius: 16.0, // Gri renk kodu
              child: Icon(Icons.delete),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: InkWell(
              onTap: () async {
                // Dio nesnesi oluşturun
                var dio = Dio();

                // Resmi indir
                var response = await dio.get(widget.imageUrl,
                    options: Options(responseType: ResponseType.bytes));

                // İndirilen resmin bytes'ını alın
                var bytes = response.data;

                final result = await ImageGallerySaver.saveImage(bytes);

                if (result.toString() != '') {
                  toastification.show(
                    type: ToastificationType.success,
                    style: ToastificationStyle.fillColored,
                    // ignore: use_build_context_synchronously
                    context: context,
                    title: const Text('Resim başarıyla galerinize kaydedildi!'),
                    autoCloseDuration: const Duration(seconds: 5),
                  );
                } else {
                  toastification.show(
                    type: ToastificationType.error,
                    style: ToastificationStyle.fillColored,
                    // ignore: use_build_context_synchronously
                    context: context,
                    title: const Text('Resim indirilirken bir sorun yaşandı.'),
                    autoCloseDuration: const Duration(seconds: 5),
                  );
                }
              },
              child: const CircleAvatar(
                backgroundColor: Color.fromARGB(255, 192, 192, 192),
                radius: 16.0, // Gri renk kodu
                child: Icon(Icons.download),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              Padding(
              padding:  EdgeInsets.only(left: MediaQuery.of(context).size.width / 17, bottom: 8.0),
              child: SizedBox(
  
  width: _bannerAd != null ? widget.adSize.width.toDouble() : 1,
  height: _bannerAd != null ? widget.adSize.height.toDouble() : 1,                        child: _bannerAd == null
                // Nothing to render yet.
                ? Text('')
                // The actual ad.
                : AdWidget(ad: _bannerAd!),
                      ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 20.0),
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                child: SizedBox(
                  height: height / 2,
                  width: double.infinity,
                  child: FadeInImage(
                    placeholder: const AssetImage(
                        'assets/img/yükleniyor.jpg'), // Yüklenirken gösterilecek resim
                    image: NetworkImage(
                      widget.imageUrl,
                    ),
                    fit: BoxFit.cover, // Resmi container'a sığdırır
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: height / 50, left: 10.0),
              child: Text('Prompt',
                  style: GoogleFonts.libreFranklin(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  )),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, right: 10.0, left: 10.0),
              child: Container(
                height: height / 6 + 30,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 44, 44, 44),
                  borderRadius: const BorderRadius.all(Radius.circular(14.0)),
                  border: Border.all(
                    color: const Color.fromARGB(
                        255, 83, 196, 255), // İstediğiniz rengi buraya yazın
                    width: 2.0, // Kenarlık kalınlığı
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Stack(children: [
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: widget.promptText));
        
                  // Kopyalama işlemini bildiren bir SnackBar göster
                  toastification.show(
                      type: ToastificationType.success,
                      style: ToastificationStyle.fillColored,
                      // ignore: use_build_context_synchronously
                      context: context,
                      title: const Text('Prompt kopyalandı!'),
                      autoCloseDuration: const Duration(seconds: 5),
                    );
        
                      },
                      child: TextField(
                        readOnly: true,
                        enabled: false,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          hintText: widget.promptText, // Satır sonlarına \n eklendi
                          hintStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w400),
                          border: InputBorder.none,
                        ),
                        cursorColor: const Color.fromARGB(255, 44, 44, 44),
                        keyboardType: TextInputType.multiline,
                        maxLines: null, // Maksimum satır sayısı ayarlandı
                        expands: true, // Gerektiğinde genişlemeye izin ver
                      ),
                    ),
                  ]),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 10.0,
              ),
              child: Center(
                child: InkWell(
                  onTap: () {
                    shareImage(widget.promptText, widget.imageUrl);
                  },
                  child: Container(
                    width: _buttonWidth,
                    height: _buttonHeight,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [
                          Color(0xFF1991FF),
                          Color(0xFF5ECCFF),
                        ],
                        stops: [0.0, 1.0], // Renklerin geçiş noktaları
                      ),
                      borderRadius: BorderRadius.circular(_borderRadius),
                    ),
                    child: Center(
                      child: Text(
                        'Paylaş!',
                        style: TextStyle(
                          color: _textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: _fontSize,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 5,),
      
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadAd();
    
  }

    @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadAd() {
    final bannerAd = BannerAd(
      size: widget.adSize,
      adUnitId: widget.adUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          ad.dispose();
        },
      ),
    );

    // Start loading.
    bannerAd.load();
  }


  
}
