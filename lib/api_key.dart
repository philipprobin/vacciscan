import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiKey {
  static String get openAiKey => dotenv.env['OPENAI_API_KEY'] ?? '';
}
