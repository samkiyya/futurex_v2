import 'package:dio/dio.dart';

class OpenAPIService {
  final dio = Dio();
  // ignore: non_constant_identifier_names
  final String GEMINI_API_KEY = "AIzaSyDE6Qle-BHtFijBIrDJbwScez-ITJw3z18";
  final String apiUrl = "https://api.openai.com/v1/completions";
  //request gpt model
  Future<String> generateResponse(String prompt) async {
    try {
      var response = await dio.post(
          "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$GEMINI_API_KEY",
          options: Options(headers: {
            'Content-Type': 'application/json',
          }),
          data: {
            "contents": [
              {
                "parts": [
                  {"text": prompt}
                ]
              }
            ]
          });
      final String geminiResponse =
          response.data['candidates'][0]['content']['parts'][0]["text"];
      return geminiResponse;
    } catch (e) {
      if (e is DioException) {
        return "Network Error!!";
      } else {
        return "Error Generating Response";
      }
    }
  }
}
