import 'package:serverpod/serverpod.dart';
import 'package:dartantic_ai/dartantic_ai.dart';
import '../../src/generated/protocol.dart';

class RecipesEndpoint extends Endpoint {
  Future<Recipe> generatedRecipe(Session session, String ingredients) async {
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

    final recipe = Recipe(
      author: 'Gemini',
      text: responseText,
      date: DateTime.now(),
      ingredients: ingredients,
    );

    return Recipe.db.insertRow(session, recipe);
  }

  Future<List<Recipe>> getRecipes(Session session) async {
    return Recipe.db.find(session, orderBy: (t) => t.date.desc());
  }
}
