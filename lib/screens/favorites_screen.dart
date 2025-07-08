import 'package:chefspeaks/models/favorite_model.dart';
import 'package:chefspeaks/models/recipe_model.dart';
import 'package:chefspeaks/screens/recipe_step_screen.dart';
import 'package:chefspeaks/services/favorites_service.dart';
import 'package:chefspeaks/utils/shared_prefs_keys.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoriteService _favoriteService = FavoriteService();
  late List<Favorite> favorites = [];

  Future<List<Recipe>> getFavoritesAsRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(SharedPrefsKeys.userId);

    if (userId == null) {
      throw Exception("User ID not found in SharedPreferences");
    }

    favorites = await _favoriteService.getFavorites(userId);
    return favorites.map((fav) => Recipe(
      status: "200",
      dishName: fav.dishName,
      estimatedTime: fav.estimatedTime,
      ingredients: fav.ingredients,
      steps: fav.steps,
    )).toList();
  }



  void _removeFavorite(int index) async {
    final confirmed = await _showConfirmation(
      context,
      title: "Remove from Favorites?",
      content: "Are you sure you want to remove this recipe from your favorites?",
      confirmText: "Remove",
      confirmColor: Colors.red,
    );
    if (confirmed == true) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString(SharedPrefsKeys.userId);

        if (userId == null) {
          throw Exception("User ID not found");
        }

        final favToRemove = favorites[index];
        await _favoriteService.removeFavorite(
          userId: userId,
          id: favToRemove.id,
        );

        setState(() {
          favorites.removeAt(index);
        });
      } catch (e) {
        debugPrint("Remove Favorite Error: $e");
      }
    }
  }


  void _cookRecipe(Recipe recipe) async {
    final confirmed = await _showConfirmation(
      context,
      title: "Start Cooking?",
      content: "Do you want to start cooking '${recipe.dishName}'?",
      confirmText: "Cook",
      confirmColor: Colors.green,
    );
    if (confirmed == true) {
      Navigator.push(context, MaterialPageRoute(
        builder: (context) => RecipeStepsScreen(recipe: recipe, isFromFavorites: true),
      ));
    }
  }

  Future<bool?> _showConfirmation(
    BuildContext context, {
    required String title,
    required String content,
    required String confirmText,
    required Color confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => Center(
        child: GlassmorphicContainer(
          width: MediaQuery.of(context).size.width * 0.8,
          height: 200,
          borderRadius: 20,
          blur: 15,
          alignment: Alignment.center,
          border: 1,
          linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.2),
              Colors.white.withValues(alpha: 0.1),
            ],
          ),
          borderGradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.3),
              Colors.white.withValues(alpha: 0.1),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title,
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      )),
                  const SizedBox(height: 12),
                  Text(content,
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Cancel Button
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(46),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.white.withAlpha(127)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(20),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            "Cancel",
                            style: GoogleFonts.manrope(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      // Confirm Button
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(46),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.white.withAlpha(127)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(20),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            confirmText,
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  static String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    final cardHeight = h * 0.11;
    final expandedHeight = cardHeight + 60;
    final trailingWidth = w * 0.18;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Favorites',
          style: GoogleFonts.manrope(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            height: h,
            width: w,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Colors.blue, Colors.green],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              // top: kToolbarHeight + 8,
              left: w * 0.03,
              right: w * 0.03,
              bottom: 12,
            ),
            child: FutureBuilder<List<Recipe>>(
              future: getFavoritesAsRecipes(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 1,));
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No favorites found."));
                }

                final favorites = snapshot.data!;

                return ListView.builder(
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final recipe = favorites[index];
                    return _AnimatedFavoriteCard(
                      delay: Duration(milliseconds: 200 * index),
                      child: _ExpandableFavoriteCard(
                        recipe: recipe,
                        cardHeight: cardHeight,
                        expandedHeight: expandedHeight,
                        trailingWidth: trailingWidth,
                        onCook: () => _cookRecipe(recipe),
                        onRemove: () => _removeFavorite(index)
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


class _AnimatedFavoriteCard extends StatefulWidget {
  final Widget child;
  final Duration delay;
  const _AnimatedFavoriteCard({required this.child, required this.delay});

  @override
  State<_AnimatedFavoriteCard> createState() => _AnimatedFavoriteCardState();
}

class _AnimatedFavoriteCardState extends State<_AnimatedFavoriteCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _offset = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _offset,
        child: widget.child,
      ),
    );
  }
}


class _ExpandableFavoriteCard extends StatefulWidget {
  final Recipe recipe;
  final double cardHeight;
  final double expandedHeight;
  final double trailingWidth;
  final VoidCallback onCook;
  final VoidCallback onRemove;

  const _ExpandableFavoriteCard({
    required this.recipe,
    required this.cardHeight,
    required this.expandedHeight,
    required this.trailingWidth,
    required this.onCook,
    required this.onRemove,
    super.key,
  });

  @override
  State<_ExpandableFavoriteCard> createState() => _ExpandableFavoriteCardState();
}

class _ExpandableFavoriteCardState extends State<_ExpandableFavoriteCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () => setState(() => expanded = !expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: EdgeInsets.symmetric(vertical: h * 0.012),
        width: double.infinity,
        height: expanded ? widget.expandedHeight : widget.cardHeight,
        child: GlassmorphicContainer(
          width: double.infinity,
          height: double.infinity,
          borderRadius: 20,
          blur: 8,
          border: 1.5,
          linearGradient: LinearGradient(
            colors: [
              Colors.white.withAlpha(60),
              Colors.white38.withAlpha(30),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderGradient: const LinearGradient(
            colors: [Colors.white24, Colors.white10],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: w * 0.045,
                  vertical: h * 0.01,
                ),
                child: Row(
                  children: [
                    // Expanded for title and subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.recipe.dishName,
                            style: GoogleFonts.manrope(
                              fontSize: w * 0.045,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          SizedBox(height: h * 0.005),
                          Text(
                            widget.recipe.ingredients.join(', '),
                            style: GoogleFonts.manrope(
                              fontSize: w * 0.035,
                              color: Colors.black54,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                      width: widget.trailingWidth,
                      child: Text(
                        "${widget.recipe.estimatedTime} mins",
                        style: GoogleFonts.manrope(
                          fontSize: w * 0.032,
                          color: Colors.black45,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: expanded
                    ? Padding(
                        padding: EdgeInsets.only(
                          left: w * 0.045,
                          right: w * 0.045,
                          bottom: MediaQuery.of(context).viewInsets.bottom + h * 0.01,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Cook Again
                            GestureDetector(
                              onTap: widget.onCook,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(46),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: Colors.white.withAlpha(127)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(20),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  "Cook Again",
                                  style: GoogleFonts.manrope(
                                    color: Colors.white,
                                    fontSize: w * 0.04,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Remove
                            GestureDetector(
                              onTap: widget.onRemove,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(46),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(color: Colors.white.withAlpha(127)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(20),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.favorite, color: Colors.white, size: 20),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
