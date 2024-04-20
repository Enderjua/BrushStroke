import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:strokedebug/backend/hive.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:strokedebug/screens/homeScreen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:quickalert/quickalert.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(GeneratedImageAdapter());
  WidgetsFlutterBinding.ensureInitialized();
  unawaited(MobileAds.instance.initialize());
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: 'firebase api key',
          appId: 'app id',
          messagingSenderId: 'anladin',
          projectId: 'anla amk'));
  bool result = await InternetConnection().hasInternetAccess;
  runApp(MyApp(result: result,));
}


class MyApp extends StatelessWidget {
  var result;

   MyApp({super.key,
   required this.result,});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BrushStroke',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: result == true ? HomeScreen() : ConnectionChecker(),
    );
  }
}

class ConnectionChecker extends StatefulWidget {
  const ConnectionChecker({super.key});

  @override
  State<ConnectionChecker> createState() => _ConnectionCheckerState();
}

class _ConnectionCheckerState extends State<ConnectionChecker> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Bağlantı Hatası',
        text: 'Lütfen İnternet Bağlantınızı Kontrol Edin',
        confirmBtnText: 'Tekrar Dene',
        onConfirmBtnTap: () {
          closeApp();
        }
      );
    });
  }

   void closeApp() {
      exit(0);
    }
  @override
  Widget build(BuildContext context) {
   
    return const Scaffold();
  }
}
