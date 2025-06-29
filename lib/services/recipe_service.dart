
import 'dart:convert';

import 'package:chefspeaks/models/recipe_model.dart';
import 'package:chefspeaks/services/api_service.dart';

class RecipeService {
  final ApiService _apiService = ApiService();

  Future<Recipe> getRecipe(String userInput) async {
    final response = await _apiService.post(
      baseUrl: '192.168.214.11:3000',
      path: '/api/generate-recipe',
      body: {
        'userInput': userInput,
      },
    );

    return Recipe.fromJson(response);
  }
}
