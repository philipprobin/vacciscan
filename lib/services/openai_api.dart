import 'dart:convert';
import 'package:http/http.dart' as http;
import '../api_key.dart';

class OpenAIApi {
  final String apiKey = ApiKey.openAiKey;
  final String apiUrl = 'https://api.openai.com/v1/chat/completions';


  Future<Map<String, dynamic>> extractVaccineInfo(String imageBase64) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        "model": "gpt-4-turbo",
        "messages": [
          {
            "role": "system",
            "content": [
              {
                "type": "text",
                "text": "You are a tool that extracts structured data from vaccine certificates. Your goal is to output data in strict JSON format according to the provided schema."
              }
            ]
          },
          {
            "role": "user",
            "content": [
              {
                "type": "image_url",
                "image_url": {
                  "url": "data:image/png;base64,$imageBase64"
                }
              }
            ]
          }
        ],
        "temperature": 0,
        "max_tokens": 256,
        "top_p": 1,
        "frequency_penalty": 0,
        "presence_penalty": 0,
        "tools": [
          {
            "type": "function",
            "function": {
              "name": "extract_vaccine_info",
              "description": "Extracts information from a vaccine certificate image",
              "parameters": {
                "type": "object",
                "properties": {
                  "vaccinations": {
                    "type": "array",
                    "items": {
                      "type": "object",
                      "properties": {
                        "date": {
                          "type": "string",
                          "description": "The date when the vaccination was administered."
                        },
                        "name_of_vaccine": {
                          "type": "string",
                          "description": "The name or brand of the vaccine administered."
                        },
                        "vaccination_against": {
                          "type": "string",
                          "enum": [
                            "COVID-19",
                            "Denguefieber",
                            "Diphtherie",
                            "Ebola",
                            "FSME",
                            "Gelbfieber",
                            "Gürtelrose",
                            "Haemophilus Influenzae-Typ-B",
                            "Hepatitis-A",
                            "Hepatitis-B",
                            "HPV",
                            "Influenza",
                            "Japanische Enzephalitis",
                            "Masern",
                            "Meningokokken",
                            "Milzbrand (Anthrax)",
                            "Mumps",
                            "Pertussis (Keuchhusten)",
                            "Pneumokokken",
                            "Pocken",
                            "Poliomyelitis (Kinderlähmung)",
                            "Röteln",
                            "Rotavirus",
                            "RSV",
                            "Tetanus (Wundstarrkrampf)",
                            "Tollwut",
                            "Typhus",
                            "Varizellen (Windpocken)"
                          ],
                          "description": "The illness or condition that the vaccine is intended to protect against."
                        }
                      },
                      "required": [
                        "date",
                        "name_of_vaccine",
                        "vaccination_against"
                      ],
                      "additionalProperties": false
                    }
                  }
                },
                "required": [
                  "vaccinations"
                ],
                "additionalProperties": false
              },
              "strict": true
            }
          }
        ],
        "response_format": {
          "type": "json_object"
        }
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to extract vaccine information');
    }
  }
}