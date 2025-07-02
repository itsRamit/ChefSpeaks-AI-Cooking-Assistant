import 'package:chefspeaks/models/recipe_model.dart';
import 'package:chefspeaks/services/api_service.dart';
import 'package:chefspeaks/utils/api_constants.dart';

class RecipeService {
  final ApiService _apiService = ApiService();

  Future<Recipe> getRecipe(String userInput) async {
    final response = await _apiService.post(
      baseUrl: ApiConstants.baseUrl,
      path: ApiConstants.generateRecipe,
      body: {
        'userInput': userInput,
      },
    );

    return Recipe.fromJson(response);
  }
}
