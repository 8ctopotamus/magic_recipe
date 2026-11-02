import 'package:flutter/material.dart';

import '../client.dart';
import 'greetings_screen.dart';

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({super.key});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  String? _resultMessage;
  String? _errorMessage;

  final _textEditingController = TextEditingController();

  bool _loading = false;

  void _callGenerateRecipe() async {
    try {
      setState(() {
        _errorMessage = null;
        _resultMessage = null;
        _loading = true;
      });

      final result = await client.recipes.generatedRecipe(
        _textEditingController.text,
      );

      setState(() {
        _resultMessage = result;
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
    return Padding(
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
                resultMessage: _resultMessage,
                errorMessage: _errorMessage,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
