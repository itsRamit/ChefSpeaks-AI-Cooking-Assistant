import 'dart:convert';

import 'package:chefspeaks/models/favorite_model.dart';
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
        'steps': recipe.steps.map((e) => {
            'step': e.step,
            'description': e.description,
            'time': e.time,
        }).toList(),

      },
    );
  }

  Future<List<Favorite>> getFavorites(String userId) async {
    final response = await _apiService.get(
      baseUrl: ApiConstants.baseUrl,
      path: ApiConstants.favorites,
      queryParams: {'user_id': userId},
    );

    List<Favorite> favorites = (response as List)
        .map((json) => Favorite.fromJson(json))
        .toList();

    return favorites;
  }

  Future<void> removeFavorite({
    required String userId,
    required int id,
  }) async {
    await _apiService.delete(
      baseUrl: ApiConstants.baseUrl,
      path: ApiConstants.favorites,
      body: {
        'user_id': userId,
        'id': id,
      },
    );
  }


}
