// ignore_for_file: file_names, non_constant_identifier_names
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:strokedebug/backend/encrypt.dart';
import 'package:strokedebug/backend/hive.dart';
import 'package:strokedebug/backend/openai.dart';
import 'package:strokedebug/screens/archiveScreen.dart';
import 'package:strokedebug/screens/resultScreen.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'package:google_fonts/google_fonts.dart';

import '../backend/deviceInfo.dart';


class HomeScreen extends StatefulWidget {
  /// The requested size of the banner. Defaults to [AdSize.banner].
  final AdSize adSize;

  const HomeScreen({
    super.key,
    this.adSize = AdSize.banner,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {


  final TextEditingController _prompt = TextEditingController();
  int _selectedIndex =
      -1; // Seçili resmin index'i (-1 başta hiçbiri seçili değil)
  int _selectedIndexSize =
      -1; // Seçili resmin size index'i (-1 başta hiçbiri seçili değil)
  final List<String> _dimensions = ['256x256', '512x512', '1024x1024'];
  final List<String> _dimensions3 = ['1024x1024', '1792x1024', '1024x1792'];

  String? deviceNames;
  String? IPAdress;
  String? deviceModels;
  String? deviceHosts;
  String? deviceIDs;
  bool? isPhysicalDevices;
  bool? banned;
  bool? isPhysicalDevice;

  Encrypting encrypting = Encrypting(vectorKey: "yourkey");

  final List<String> _imagePaths = [
    'assets/img/gemini.jpg',
    'assets/img/dall-e-3.png',
    'assets/img/dall-e-2.png',
  ];

  final List<String> _modelNames = [
    'ImageFX',
    'DALL-E 3',
    'DALL-E 2',
  ];

  final List<String> _modelCreator = [
    'Google AI',
    'OpenAI',
    'OpenAI',
  ];

  final DeviceInfoService deviceinfoService = DeviceInfoService();
  CollectionReference devices =
      FirebaseFirestore.instance.collection('devices');
  CollectionReference images = FirebaseFirestore.instance.collection('images');
  Stream collectionStream =
      FirebaseFirestore.instance.collection('devices').snapshots();
  // Stream documentStream = FirebaseFirestore.instance.collection('users').doc('ABC123').snapshots();

  writeImageData(String prompt, String model, String imagePath) async {
    final ipAdress =
        encrypting.encrypterData(await deviceinfoService.getIpAddress());
    final deviceID =
        encrypting.encrypterData(await deviceinfoService.getDeviceID());

    images.add({
      'prompt': prompt,
      'model': model,
      'imagePath': imagePath,
      'ipAdress': ipAdress,
      'androidID': deviceID
    });
  }

  getImagesInfo() async {
    final deviceID = await deviceinfoService.getDeviceID();
    final androidID = encrypting.encrypterData(deviceID);
    final snapshot = await images.where('androidID', isEqualTo: androidID).get();
    final lenght = snapshot.docs.length;
    return lenght;
  }

  getBannedInfo() async {
    final ipAdress = await deviceinfoService.getIpAddress();
    final deviceName = await deviceinfoService.getDeviceName();
    final deviceModel = await deviceinfoService.getDeviceModel();
    final deviceHost = await deviceinfoService.getDeviceHost();
    final deviceID = await deviceinfoService.getDeviceID();
    final PhysicalDevice = await deviceinfoService.getIsPhysical();

    if (PhysicalDevice == 'true') {
      setState(() {
        isPhysicalDevice = true;
      });
    } else if (PhysicalDevice == 'false') {
      setState(() {
        isPhysicalDevice = false;
      });
    }

    final snapshot = await devices
        .get(); // get() kullanarak tek bir veri çekimi yapabilirsiniz.
    final deviceList = snapshot.docs
        .map((doc) => doc.data())
        .toList(); // her dokümandan veriyi almak için doc.data()
    for (int i = 0; i < deviceList.length; i++) {
      final device = deviceList[
          i]; // Her bir belgeyi daha kolay erişim için "device" değişkenine atayabilirsiniz.
      if (device is Map<String, dynamic>) {
        // print(Uint8List.fromList(device['ipAdress'].cast<int>()));
        setState(() {
          deviceNames = device['androidName'];
          IPAdress = encrypting.decrypterData(Uint8List.fromList(device['ipAdress'].cast<int>()));
          deviceModels = encrypting.decrypterData(Uint8List.fromList(device['androidModel'].cast<int>()));
          deviceHosts = encrypting.decrypterData(Uint8List.fromList(device['androidHost'].cast<int>()));
          deviceIDs = encrypting.decrypterData(Uint8List.fromList(device['androidID'].cast<int>()));
          isPhysicalDevices = device['androidPhysical'];
        });
      } else {}

      if (deviceNames == deviceName &&
          IPAdress == ipAdress &&
          deviceModels == deviceModel &&
          deviceHosts == deviceHost &&
          deviceIDs == deviceID &&
          isPhysicalDevices == isPhysicalDevice) {
        // Eşleşme varsa, istediğiniz işlemleri burada gerçekleştirebilirsiniz.
        if (device is Map<String, dynamic>) {
          setState(() {
            banned = device['banned'];
          });
        }
        setState(() {
          i = deviceList.length;
        });
      } else if (deviceNames == deviceName &&
          deviceModels == deviceModel &&
          deviceHosts == deviceHost &&
          deviceIDs == deviceID &&
          isPhysicalDevices == isPhysicalDevice) {
        // güncelleme işlemi
        final snapshot =
            await devices.where('androidID', isEqualTo: deviceID).get();

        if (snapshot.docs.isNotEmpty) {
          final document = snapshot.docs.first;
          if (device is Map<String, dynamic>) {
            setState(() {
              banned = device['banned'];
            });
            // print(banned);
          }
          document.reference.update({
            'androidName': deviceName,
            'ipAdress': encrypting.encrypterData(ipAdress),
            'androidModel': encrypting.encrypterData(deviceModel),
            'androidHost': encrypting.encrypterData(deviceHost),
            'androidID': encrypting.encrypterData(deviceID),
            'androidPhysical': isPhysicalDevice,
            'banned': banned
          });
          setState(() {
            i = deviceList.length + 1;
          });
          break;
        } else {}
      } else {
        if (i == deviceList.length - 1) {
          devices.add({
            'androidName': deviceName,
            'ipAdress': encrypting.encrypterData(ipAdress),
            'androidModel': encrypting.encrypterData(deviceModel),
            'androidHost': encrypting.encrypterData(deviceHost),
            'androidID': encrypting.encrypterData(deviceID),
            'androidPhysical': isPhysicalDevice,
            'banned': false
          });
          setState(() {
            banned == false;
          });
        }
      }
    }
    if (deviceList.isEmpty) {
      devices.add({
        'androidName': deviceName,
        'ipAdress': encrypting.encrypterData(ipAdress),
        'androidModel': encrypting.encrypterData(deviceModel),
        'androidHost': encrypting.encrypterData(deviceHost),
        'androidID': encrypting.encrypterData(deviceID),
        'androidPhysical': isPhysicalDevice,
        'banned': false
      });
      setState(() {
        banned == false;
      });
    }
  }

  int maxFailedLoadAttempts = 3;


  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;

  static const AdRequest request = AdRequest(
    nonPersonalizedAds: false,
  );


  bool _isClicked = false;

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
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 28, 28, 30),
      resizeToAvoidBottomInset:
          false, // Klavyenin alt kısmındaki padding'i engelle
      body: SingleChildScrollView(
        // Sayfayı kaydırılabilir hale getirin
        child: GestureDetector(
          // Tıklamaları dinleyin
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
            // Tıklandığında klavyeyi kapatın
          },

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Padding(
                padding: EdgeInsets.only(top: height / 30 + 5, left: 10.0),
                child: Text('Prompt',
                    style: GoogleFonts.libreFranklin(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    )),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(top: 8.0, right: 10.0, left: 10.0),
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
                      TextField(
                        controller: _prompt,
                        style: const TextStyle(
                          color: Colors.white, // Yazının rengi
                          fontSize: 16.0, // Yazı boyutu
                          fontWeight: FontWeight.w400, // Yazı kalınlığı
                        ),
                        decoration: const InputDecoration(
                          hintText: 'Hayal ettiğin resmi gir!',
                          hintStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                              fontWeight: FontWeight.w400),
                          border: InputBorder.none,
                        ),
                        cursorColor: const Color.fromARGB(255, 44, 44, 44),
                        keyboardType:
                            TextInputType.multiline, // Çok satırlı metin girişi
                        maxLines: null, // Maksimum satır sayısını kaldırın
                        expands: true, // Gerektiğinde genişlemeye izin ver
                      ),
                      Positioned(
                        top: 8.0,
                        right: 8.0,
                        child: InkWell(
                          onTap: () {
                            _prompt.clear();
                          },
                          child: const CircleAvatar(
                            backgroundColor: Color.fromARGB(255, 192, 192, 192),

                            radius: 12.0, // Gri renk kodu
                            child: Icon(
                              Icons.close,
                            ), // Kürenin yarıçapı
                          ),
                        ), // Çarpı ikonunuz
                      ),
                    ]),
                  ),
                ),
              ),
              Padding(
                padding:
                    EdgeInsets.only(top: height / 30, left: 10.0, right: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Modeli seçiniz',
                        style: GoogleFonts.libreFranklin(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        )),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0, left: 14.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _imagePaths.asMap().entries.map((entry) {
                      final imagePath = entry.value;
                      final modelName = _modelNames[entry.key];
                      final creatorName = _modelCreator[entry.key];
                      final index = entry.key; // Resmin index'ini al

                      return InkWell(
                        // InkWell ile tıklanabilir yap
                        onTap: () {
                          setState(() {
                            _selectedIndex = index; // Seçili index'i güncelle
                          });
                        },
                        child: _buildImageContainer(imagePath, modelName,
                            creatorName, index == _selectedIndex),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: height / 30, left: 10.0),
                child: Text('Boyut',
                    style: GoogleFonts.libreFranklin(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    )),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0, top: 13.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _selectedIndex == 1 ? _dimensions3.asMap().entries.map((entry) {
                    int index = entry.key;
                    String dimension = entry.value;
                    return InkWell(
                      // Tıklanabilir konteynerlar için InkWell kullanın
                      onTap: () {
                        setState(() {
                          _selectedIndexSize = index;
                        });
                      },
                      child: Container(
                        width: width / 5 + 9,
                        height: height / 15,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 44, 44, 44),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(14.0)),
                          border: _selectedIndexSize ==
                                  index // Seçili ise border'ı ekle
                              ? Border.all(
                                  color:
                                      const Color.fromARGB(255, 83, 196, 255),
                                  width: 2.0,
                                )
                              : null, // Seçili değilse border'ı kaldır
                        ),
                        child: Center(
                          child: Text(
                            dimension,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  }).toList() : _dimensions.asMap().entries.map((entry) {
                    int index = entry.key;
                    String dimension = entry.value;
                    return InkWell(
                      // Tıklanabilir konteynerlar için InkWell kullanın
                      onTap: () {
                        setState(() {
                          _selectedIndexSize = index;
                        });
                      },
                      child: Container(
                        width: width / 5 + 9,
                        height: height / 15,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 44, 44, 44),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(14.0)),
                          border: _selectedIndexSize ==
                                  index // Seçili ise border'ı ekle
                              ? Border.all(
                                  color:
                                      const Color.fromARGB(255, 83, 196, 255),
                                  width: 2.0,
                                )
                              : null, // Seçili değilse border'ı kaldır
                        ),
                        child: Center(
                          child: Text(
                            dimension,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Center(
                  child: InkWell(
                    onTap: () async {
                      if (_isClicked) {
                        exit(1);
                      } else {
                        setState(() {
                          // setState ile widget'ın rebuild edilmesi sağlandı
                          _isClicked = true;
                        });

                        if (_selectedIndex == 1 ||
                            _selectedIndex == 2 ||
                            _selectedIndex == 0 &&
                                _prompt.text != '' &&
                                _selectedIndex != -1) {
                          try {
                            String url;
                            if (_selectedIndex == 0) {
                              toastification.show(
                                context: context,
                                title: const Text(
                                    'Bu model şu anda kullanılamamaktadır.'),
                                autoCloseDuration: const Duration(seconds: 5),
                              );
                              return;
                            }

                            if (banned == true) {
                              toastification.show(
                                type: ToastificationType.error,
                                style: ToastificationStyle.fillColored,
                                // ignore: use_build_context_synchronously
                                context: context,
                                title: Text(
                                    'Sistemden uzaklaştırıldınız! Lütfen kullanmaya devam edebilmek için bir yetkili ile görüşünüz veya uygulamayı yeniden başlatın.: $banned'),
                                autoCloseDuration: const Duration(seconds: 5),
                              );

                              return;
                            }
                            if (_selectedIndex == 1) {
                              url = await dallE(_prompt.text,
                                  _dimensions3[_selectedIndexSize], 'dall-e-3');
                              await addRecord(_prompt.text, url);
                              writeImageData(_prompt.text, 'dall-e-3', url);
                            } else {
                              url = await dallE(_prompt.text,
                                  _dimensions[_selectedIndexSize], 'dall-e-2');
                              await addRecord(_prompt.text, url);
                              writeImageData(_prompt.text, 'dall-e-2', url);
                            }

                            int lenghtImage  = await getImagesInfo();
                            if(lenghtImage % 3 == 0) {
                              _showInterstitialAd(url);
                            } else {
                              _showInterstitialAd(url);
                            }
                            
                          } catch (error) {
                            // Hata yönetimi ekleyin (örnek: Hata mesajı göster)
                            // ignore: avoid_print
                            toastification.show(
                              type: ToastificationType.error,
                              style: ToastificationStyle.fillColored,
                              // ignore: use_build_context_synchronously
                              context: context,
                              title: error.toString() == 'Exception: Failed to generate image: 400' ? const Text('İnternet bağlantınızı kontrol edin, müstehcen ve şiddet içeren promptlardan kaçının!') : error.toString() == 'Exception: Failed to generate image: 401' ? const Text('Uygulamanın son sürümünü kullandığından emin ol! Güncellemeleri kontrol et!') : Text(error.toString()) ,
                              autoCloseDuration: const Duration(seconds: 5)
                            );
                          } finally {
                            setState(() {
                              _isClicked =
                                  false; // Görsel oluşturma bitince buton etkinleştirilir
                            });
                          }
                        } else {
                          toastification.show(
                            context: context,
                            title: const Text(
                                'Lütfen tüm zorunlu seçenekleri doldurduğunuza emin olun.'),
                            autoCloseDuration: const Duration(seconds: 5),
                          );
                          setState(() {
                            // setState ile widget'ın rebuild edilmesi sağlandı
                            _isClicked = false;
                          });
                        }
                      }
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
                          child: _isClicked
                              ? const CircularProgressIndicator()
                              : Text(
                                  'Resmini Oluştur!',
                                  style: TextStyle(
                                    color: _textColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: _fontSize,
                                  ),
                                )),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: height / 40 - 5),
                child: const Divider(
                  thickness: 1.0,
                  color: Color.fromARGB(255, 55, 55, 55),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Column(
                    children: [
                      Icon(Icons.create, color: Color.fromARGB(255, 83, 196, 255), size: 30,),
                      Text(
                        'Resim Oluştur',
                        style:
                            TextStyle(color: Color.fromARGB(255, 83, 196, 255)),
                      )
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (builder) => const ArchiveScreen()));
                    },
                    child: const Column(
                      children: [
                        Icon(Icons.photo_camera_back_outlined, color: Color.fromRGBO(142, 142, 147, 1.0), size: 30,),
                        Text('Arşiv',
                            style: TextStyle(
                              color: Color.fromRGBO(142, 142, 147, 1.0),
                            ))
                      ],
                    ),
                  ),
          
                ],
              ),
              const SizedBox(height: 5,),
              
            ],
          ),
        ),
      ),
    );
  }


  @override
  void initState() {
    super.initState();
    getBannedInfo();
    _createInterstitialAd();
    
  }

  Widget _buildImageContainer(
      String imagePath, String modelName, String creatorName, bool isSelected) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Container(
      height: height / 4 + 10,
      width: width / 2 - 15,
      margin: const EdgeInsets.only(right: 10.0),
      decoration: BoxDecoration(
        // Container'a dekorasyon ekle
        image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
        border: isSelected // Seçili ise border'ı ekle
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
          Image.asset(
            imagePath,
            fit: BoxFit.cover,
            height: height / 4 + 10,
            width: width / 2 - 15,
          ),
          // Blur efekti için ClipRect ve BackdropFilter
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
              child: Container(
                color: Colors.black.withOpacity(0.4),
                height: 60.0, // Blurlu alanın yüksekliği
                width: width / 2 - 15, // Blurlu alanın genişliği
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
                    Text(
                      creatorName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.0,
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

      void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: Platform.isAndroid
            ? 'ads id'
            : 'ads id ios',
        request: request,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
              _createInterstitialAd();
            }
          },
        ));
  }


void _showInterstitialAd(String url) {
    if (_interstitialAd == null) {
      return;
    }

    // FullScreenContentCallback'i güncelleyeceğiz
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      // ... onAdShowedFullScreenContent, onAdFailedToShowFullScreenContent aynı kalabilir

      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        _createInterstitialAd();

        // Reklam kapandıktan sonra ResultScreen'e yönlendirme
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
                                  promptText: _prompt.text,
                                  imageUrl: url,
                                ),
          ),
        );
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }
}
