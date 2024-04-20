// ignore_for_file: prefer_interpolation_to_compose_strings, implementation_imports

import 'package:openai_package/openai_package.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:openai_package/src/openai/import/importAi.dart';

Future dallE(String prompt, String size, String model) async {
  OpenAI.apiKey = "yourKey";
  OpenAI.model = model; // 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
  OpenAI.organization = 'yourOrgID / optional';
  OpenAI client = OpenAI();
  OpenAIGenerateImage result =
      await client.generateImage(prompt: prompt, n: 1, size: size,);

  bool isUrl(String str) {
    try {
      Uri.parse(str);
      return true;
    } catch (e) {
      return false;
    }
  }

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
