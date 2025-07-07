import 'recipe_model.dart';

class Favorite {
  final int id;
  final String userId;
  final String dishName;
  final int estimatedTime;
  final List<String> ingredients;
  final List<RecipeStep> steps;
  final DateTime createdAt;

  Favorite({
    required this.id,
    required this.userId,
    required this.dishName,
    required this.estimatedTime,
    required this.ingredients,
    required this.steps,
    required this.createdAt,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'],
      userId: json['user_id'],
      dishName: json['dish_name'],
      estimatedTime: json['estimated_time'],
      ingredients: List<String>.from(json['ingredients']),
      steps: (json['steps'] as List)
          .map((step) => RecipeStep.fromJson(step))
          .toList(),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'dish_name': dishName,
      'estimated_time': estimatedTime,
      'ingredients': ingredients,
      'steps': steps.map((e) => {
            'step': e.step,
            'description': e.description,
            'time': e.time,
        }).toList(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
