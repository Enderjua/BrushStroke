![Dart](https://img.shields.io/badge/-Dart-333333?style=flat&logo=DART)
![Flutter](https://img.shields.io/badge/-Flutter-333333?style=flat&logo=Flutter&logoColor=1572B6)
![XML](https://img.shields.io/badge/-XML-333333?style=flat&logo=XML)
![PHP](https://img.shields.io/badge/-PHP-333333?style=flat&logo=php)
<br>
![Firebase](https://img.shields.io/badge/-Firebase-333333?style=flat&logo=firebase)
![NoSQL](https://img.shields.io/badge/-NoSQL-333333?style=flat&logo=NoSQL)
<br>
![GitHub](https://img.shields.io/badge/-GitHub-333333?style=flat&logo=github)
![OpenAI](https://img.shields.io/badge/-OpenAI-333333?style=flat&logo=openai)
<img src="https://img.shields.io/static/v1?label=enderjua&message=brushstroke&color=ff3366&logo=github" alt="marijua - app.schweis.us">
<img src="https://img.shields.io/github/stars/enderjua/brushstroke?style=social" alt="stars - app.schweis.us">
<img src="https://img.shields.io/github/forks/enderjua/brushstroke?style=social" alt="forks - app.schweis.us">
<a href="https://github.com/enderjua/brushstroke/blob/main/LICENSE"><img src="https://img.shields.io/badge/License-GPL3-ff3366" alt="License"></a>



<div align="center">
<a href="https://github.com/Enderjua/BrushStroke/assets/120639059/c79dda7e-f558-4f9d-82c4-9a5e8fdc0691" target="_blank"><img src="https://github.com/Enderjua/BrushStroke/assets/120639059/c79dda7e-f558-4f9d-82c4-9a5e8fdc0691" width="260" /></a>
<a href="https://github.com/Enderjua/BrushStroke/assets/120639059/bdc3843d-897b-479c-b5a4-0ff5ea8ce1ea" target="_blank"><img src="https://github.com/Enderjua/BrushStroke/assets/120639059/bdc3843d-897b-479c-b5a4-0ff5ea8ce1ea" width="260" /></a>
<a href="https://github.com/Enderjua/BrushStroke/assets/120639059/07bf960c-7cf3-47b8-ac58-252f29e897f3" target="_blank"><img src="https://github.com/Enderjua/BrushStroke/assets/120639059/07bf960c-7cf3-47b8-ac58-252f29e897f3" width="260" /></a>
<br />
<a href="https://github.com/Enderjua/BrushStroke/assets/120639059/f2f5de62-9a10-489e-a31c-82a9844a1864" target="_blank"><img src="https://github.com/Enderjua/BrushStroke/assets/120639059/f2f5de62-9a10-489e-a31c-82a9844a1864" width="260" /></a>
<a href="https://github.com/Enderjua/BrushStroke/assets/120639059/57f062b4-682b-4fd4-b5e3-23af0e3c8219" target="_blank"><img src="https://github.com/Enderjua/BrushStroke/assets/120639059/57f062b4-682b-4fd4-b5e3-23af0e3c8219" width="260" /></a>
<a href="https://github.com/Enderjua/BrushStroke/assets/120639059/eb5a7345-eff0-43e3-a9b3-0eedc6429278" target="_blank"><img src="https://github.com/Enderjua/BrushStroke/assets/120639059/eb5a7345-eff0-43e3-a9b3-0eedc6429278" width="260" /></a>
<br />
<em>Just click on the pictures of the BrushStroke application to see them!</em>
</div><br />

# Feature Summary

- 🚀 **One Click Install:** Get started in seconds with our easy Firebase setup. No coding required!
- 🔥 **Cutting-Edge AI Models:** Access the latest and greatest AI image generation models, including DALL-E 3, DALL-E 2, and Google AI. More open-source models coming soon!
- 🔒 **Unparalleled Security:** Your data is safeguarded with robust Firebase database and encryption techniques.
- 📸 **Unlimited Storage & Accessibility:** Store and access all your generated images without limits thanks to our dedicated Plesk storage.
- 🎨 **Coming Soon:** Unleash your creativity with upcoming image editing and variation creation features.
- 💸 **Completely Free:** Create stunning visuals without spending a dime. Just an API key is all you need!
- 📈 **Monetize Your Creativity:** Integrate AdMob ads into your app and earn money from your creations.
<br/>

# Installation and Running

A script is provided for Windows and Linux machines to install, update, and run ENFUGUE. Copy the relevant command below and answer the on-screen prompts to choose your installation type and install optional dependencies.

## Windows
You will be able to use this app on Windows devices in the near future

## Linux
Stay tuned for the release of this app on Linux devices

## Android

**🎉 Set Up the App Manually 🎉**
<br>

🚀 **Quick Start**:<br>
    📱 **Firebase Account**: Create a Firebase account to start your journey! (👨‍💻)<br>
    🔥 **Firebase Setup**: Add Firebase to your app and power up! (🔥)<br>
    ✍️ **App Info**: Fill in the required info in `main.dart` to give your app an identity! (📝)<br>
```dart
    Future<void> main() async {
  // Firebase'i başlatın
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'firebase api key',
      appId: 'app id',
      messagingSenderId: 'sender id',
      projectId: 'project id'
    )
  );
...
}...
```

✨ **Add Ads (Optional)**:<br>
    💰 **AdMob Registration**: Register with AdMob to start earning! (🤑)<br>
    💡 **Ad Info**: Add ad info to `homescreen.dart`, `archivescreen.dart`, and `resultscreen.dart` and shine bright! (💡)<br>
```dart
     final String adUnitId = Platform.isAndroid
      // Use this ad unit on Android...
      ? 'ads id'
      // ... or this one on iOS.
      : 'ads id ios';
```
    

🧠 **Backend Connection**:<br>
    🔐 **API Info**: Enter your API info in `backend/openai.dart` to connect with AI! (🧠)<br>
```dart
      OpenAI.apiKey = "yourKey";
  OpenAI.model = model; // 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
  OpenAI.organization = 'yourOrgID / optional';
  OpenAI client = OpenAI();
```

📸 **Image Storage**:<br>
    🗑️ **Plesk Link**: If you don't want to store images, you can delete the Plesk link in `backend/openai.dart`! (🗑️)<br>
```dart
      bool accept = isUrl(result.url);
  if(accept) {
    var url = Uri.parse('my API server'+result.url);

  // HTTP isteği oluştur
  var response = await http.get(url);
  

  // İstek durumunu kontrol et
  if (response.statusCode == 200) {

    // Resmin ismini yazdır
    return "my API Server/${response.body}";
  }
  } else {
    return "Failed";
  }
  // return result.url;
}
```

🎉 **That's it!** 🎉


## Manual Installation

If you want to use the app directly without installation and without an API, click it <a href="https://play.google.com/store/apps/details?id=com.schweis.strokedebug" target="_blank">here</a>

![image](https://github.com/Enderjua/BrushStroke/assets/120639059/38ffa3a9-c97c-48f8-8f9a-70db6971df12)


# Support our project

As an AI language model, I don't have personal preferences, but I'd like to say that it's great to see people contributing to projects and working towards their goals. Good luck with your project!

My email adress: enderjua@gmail.com
