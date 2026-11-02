import 'package:serverpod/serverpod.dart';
import 'package:dartantic_ai/dartantic_ai.dart';

class RecipesEndpoint extends Endpoint {
  Future<String> generatedRecipe(Session session, String ingredients) async {
    final geminiApiKey = session.passwords['geminiApiKey'];
    if (geminiApiKey == null) {
      throw Exception('Gemini API key not found');
    }

    final agent = Agent.forProvider(
      GoogleProvider(apiKey: geminiApiKey),
      chatModelName: 'gemini-3.5-flash-lite',
    );

    final prompt =
        'Generate a recipe using the following ingredients: $ingredients. '
        'Always put the title of the recipe in the first line, and then the instructions. '
        'The recipe should be easy to follow and include all necessary steps. '
        'Please provide a detailed recipe.';

    final response = await agent.send(prompt);

    final responseText = response.output;

    if (responseText.isEmpty) {
      throw Exception('No response from Gemini API');
    }

    return responseText;
  }
}
