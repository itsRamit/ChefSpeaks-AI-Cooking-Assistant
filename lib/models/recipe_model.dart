class Recipe {
  final String status;
  final String dishName;
  final int estimatedTime;
  final List<String> ingredients;
  final List<RecipeStep> steps;

  Recipe({
    required this.status,
    required this.dishName,
    required this.estimatedTime,
    required this.ingredients,
    required this.steps,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      status: json['status'] ?? '',
      dishName: json['dish_name'] ?? '',
      estimatedTime: json['estimated_time'] ?? '',
      ingredients: List<String>.from(json['ingredients'] ?? []),
      steps: (json['steps'] as List)
          .map((stepJson) => RecipeStep.fromJson(stepJson))
          .toList(),
    );
  }
}

class RecipeStep {
  final String step;
  final String description;
  final int time;

  RecipeStep({
    required this.step,
    required this.description,
    required this.time,
  });

  factory RecipeStep.fromJson(Map<String, dynamic> json) {
    return RecipeStep(
      step: json['step'] ?? '',
      description: json['description'] ?? '',
      time: json['time'] ?? 0,
    );
  }
}
