import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';
  static const String _apiKey = 'AIzaSyAdhq0m5qD0FGNIJQx56ApoS8wkDQelLYU';

  Future<Map<String, dynamic>> getQuizRecommendation(
      String subject, String studentLevel) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text':
                      '''Generate a quiz recommendation for a student with the following context:
                Subject: $subject
                Student Level: $studentLevel
                
                Please provide:
                - Quiz title
                - Brief description
                - Difficulty level (easy/medium/hard)
                - Number of questions (between 5-20)
                
                Format the response as JSON with these exact keys:
                {
                  "title": "string",
                  "description": "string",
                  "difficulty": "string",
                  "questionCount": number
                }'''
                }
              ]
            }
          ],
          'generationConfig': {'temperature': 0.7, 'topP': 0.8, 'topK': 40}
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['candidates'][0]['content']['parts'][0]['text'];
        // Extract the JSON object from the response text
        final jsonStr = content.substring(
          content.indexOf('{'),
          content.lastIndexOf('}') + 1,
        );
        return jsonDecode(jsonStr);
      } else {
        throw Exception('Failed to get AI recommendation');
      }
    } catch (e) {
      print('Error getting AI recommendation: $e');
      return {
        'title': 'Quiz recommandé',
        'description': 'Un quiz adapté à votre niveau',
        'difficulty': 'medium',
        'questionCount': 10,
      };
    }
  }

  Future<String> getQuestionExplanation(
    String question,
    String correctAnswer,
    String userAnswer,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {
                  'text':
                      '''Je suis un professeur bienveillant qui aide les élèves à comprendre leurs erreurs.
                
                Question: $question
                Réponse correcte: $correctAnswer
                Réponse de l'élève: $userAnswer
                
                Générez une explication pédagogique qui :
                1. Reconnaît les éléments corrects dans la réponse de l'élève
                2. Identifie précisément l'erreur ou la confusion
                3. Explique le raisonnement correct
                4. Donne des conseils pour éviter cette erreur à l'avenir
                5. Encourage l'élève à progresser
                
                Utilisez un ton encourageant et constructif.'''
                }
              ]
            }
          ],
          'generationConfig': {'temperature': 0.7, 'topP': 0.8, 'topK': 40}
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        throw Exception('Failed to get AI explanation');
      }
    } catch (e) {
      print('Error getting AI explanation: $e');
      return 'N\'hésitez pas à revoir cette notion et à réessayer. Vous pouvez le faire !';
    }
  }
}
