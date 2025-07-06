import 'package:chefspeaks/models/recipe_model.dart';
import 'package:chefspeaks/services/api_service.dart';
import 'package:chefspeaks/utils/api_constants.dart';

class FavoriteService {
  final ApiService _apiService = ApiService();

  // Add a recipe to favorites
  Future<void> addFavorite(Recipe recipe, String userId) async {
    await _apiService.post(
      baseUrl: ApiConstants.baseUrl,
      path: ApiConstants.favorites,
      body: {
        'user_id': userId,
        'dish_name': recipe.dishName,
        'estimated_time': recipe.estimatedTime,
        'ingredients': recipe.ingredients,
        'steps': recipe.steps,
      },
    );
  }

  Future<List<Recipe>> getFavorites(String userId) async {
    final response = await _apiService.get(
      baseUrl: ApiConstants.baseUrl,
      path: '${ApiConstants.favorites}/$userId',
    );

    return (response as List).map((json) => Recipe.fromJson(json)).toList();
  }
}
