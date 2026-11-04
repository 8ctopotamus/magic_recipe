import 'package:flutter/material.dart';
import 'package:magic_recipe_client/magic_recipe_client.dart';
import '../client.dart';
import 'greetings_screen.dart';

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({super.key});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  Recipe? _recipe;
  List<Recipe> _recipeHistory = [];

  String? _errorMessage;

  final _textEditingController = TextEditingController();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    client.recipes.getRecipes().then((recipes) {
      setState(() => _recipeHistory = recipes);
    });
  }

  void _callGenerateRecipe() async {
    try {
      setState(() {
        _errorMessage = null;
        _recipe = null;
        _loading = true;
      });

      final result = await client.recipes.generatedRecipe(
        _textEditingController.text,
      );

      setState(() {
        _recipe = result;
        _recipeHistory = [result, ..._recipeHistory];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '$e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _recipeHistory.length,
            itemBuilder: (context, index) {
              final recipe = _recipeHistory[index];
              return ListTile(
                title: Text(recipe.text.split('\n').first),
                subtitle: Text('${recipe.author} - ${recipe.date}'),
                onTap: () => setState(() => _recipe = recipe),
              );
            },
          ),
        ),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _textEditingController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your ingredients',
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loading ? null : _callGenerateRecipe,
                  child: _loading
                      ? const Text('Loading...')
                      : const Text('Generate Recipe'),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: ResultDisplay(
                      resultMessage: _recipe != null
                          ? '${_recipe!.author} on ${_recipe!.date}:\n${_recipe!.text}'
                          : null,
                      errorMessage: _errorMessage,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
