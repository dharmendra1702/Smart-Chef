import 'dart:typed_data';

import 'package:chef_buddy/constants/assets.dart';
import 'package:chef_buddy/constants/colors.dart';
import 'package:chef_buddy/services/gemini_services.dart';
import 'package:chef_buddy/widgets/cooking_loading_animation.dart';
import 'package:chef_buddy/widgets/custom_textfield.dart';
import 'package:chef_buddy/widgets/recipe_result_view.dart';
import 'package:chef_buddy/widgets/typewriter_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:image_picker/image_picker.dart';

class RecipeGenerateView extends StatefulWidget {
  final bool isIngredient;
  const RecipeGenerateView({super.key, required this.isIngredient});

  @override
  State<RecipeGenerateView> createState() => _RecipeGenerateViewState();
}

class _RecipeGenerateViewState extends State<RecipeGenerateView>
    with SingleTickerProviderStateMixin {
  final _ingredientController = TextEditingController();
  final _numberOfPeopleController = TextEditingController();
  final _dietController = TextEditingController();
  String recipeResult = "";
  bool isLoading = false;
  final gemini = Gemini.instance;
  Uint8List? selectedImage;
  final ImagePicker picker = ImagePicker();
  bool isImageOn = false;
  // When ON, the AI may suggest a few extra ingredients (kept separate from
  // the main list). When OFF, the recipe strictly uses only what the user
  // listed (plus basic staples like salt/oil/water).
  bool allowSuggestions = true;
  bool isTypingPhase = false;
  bool _isButtonPressed = false;

  late final AnimationController _resultAnimController;
  late final Animation<double> _resultFade;
  late final Animation<Offset> _resultSlide;

  @override
  void initState() {
    super.initState();
    _resultAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _resultFade = CurvedAnimation(
      parent: _resultAnimController,
      curve: Curves.easeOut,
    );
    _resultSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _resultAnimController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _resultAnimController.dispose();
    _ingredientController.dispose();
    _numberOfPeopleController.dispose();
    _dietController.dispose();
    super.dispose();
  }

  void pickImage() async {
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        selectedImage = bytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        leading: const BackButton(color: Colors.white),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage(
                widget.isIngredient ? kIngredients : kFood,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isIngredient
                      ? "Ingredients to Recipe"
                      : "Food to Recipe",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.5,
                  child: Text(
                    widget.isIngredient
                        ? "Generate recipe from ingredients"
                        : "Generate recipe from food",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 8),
            child: Column(
              children: [
                Visibility(
                  visible: widget.isIngredient,
                  child: Row(
                    children: [
                      Text(
                        widget.isIngredient
                            ? "Upload image of ingredients"
                            : "Upload image of food",
                        style: const TextStyle(
                          color: kPrimaryColor,
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Switch(
                        value: isImageOn,
                        onChanged: (value) {
                          setState(() {
                            isImageOn = value;
                          });
                        },
                        activeColor: kPrimaryColor,
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: !isImageOn && widget.isIngredient,
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _ingredientController,
                        keyboardType: TextInputType.multiline,
                        text: "What ingredients do you have?",
                        hintText: "Chicken, Rice, Salt, etc.",
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: widget.isIngredient,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.only(top: 16),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: allowSuggestions
                          ? kPrimaryColor.withOpacity(0.08)
                          : Colors.grey.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: allowSuggestions
                            ? kPrimaryColor.withOpacity(0.4)
                            : Colors.grey.withOpacity(0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          transitionBuilder: (child, anim) =>
                              ScaleTransition(scale: anim, child: child),
                          child: Icon(
                            allowSuggestions
                                ? Icons.lightbulb
                                : Icons.lock_outline,
                            key: ValueKey(allowSuggestions),
                            color: kPrimaryColor,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Suggest extra ingredients",
                                style: TextStyle(
                                  color: kPrimaryColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                allowSuggestions
                                    ? "AI may suggest a few optional add-ons to improve the dish"
                                    : "Recipe will use only what you listed above",
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: allowSuggestions,
                          onChanged: (value) {
                            setState(() {
                              allowSuggestions = value;
                            });
                          },
                          activeColor: kPrimaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 600) {
                      return Column(
                        children: [
                          CustomTextField(
                            controller: _numberOfPeopleController,
                            keyboardType: TextInputType.number,
                            text: "Number of people",
                            hintText: "1, 2, 3, etc.",
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _dietController,
                            keyboardType: TextInputType.multiline,
                            text: "Diet",
                            hintText: "Vegan, Vegetarian, etc.",
                          ),
                        ],
                      );
                    } else {
                      return Row(
                        children: [
                          Expanded(
                            child: CustomTextField(
                              controller: _numberOfPeopleController,
                              keyboardType: TextInputType.number,
                              text: "Number of people",
                              hintText: "1, 2, 3, etc.",
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CustomTextField(
                              controller: _dietController,
                              keyboardType: TextInputType.multiline,
                              text: "Diet",
                              hintText: "Vegan, Vegetarian, etc.",
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),
                Visibility(
                  visible: isImageOn || !widget.isIngredient,
                  child: Column(
                    children: [
                      Text(
                        widget.isIngredient
                            ? "Upload image of ingredients"
                            : "Upload image of food",
                        style: const TextStyle(
                          color: kPrimaryColor,
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 7),
                      InkWell(
                        onTap: () {
                          pickImage();
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          height: 250,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: kPrimaryColor,
                              width: 2,
                            ),
                          ),
                          child: selectedImage == null
                              ? const Center(
                                  child: Icon(
                                    Icons.add_photo_alternate_outlined,
                                    color: kPrimaryColor,
                                    size: 100,
                                  ),
                                )
                              : Image.memory(
                                  selectedImage!,
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTapDown: (_) => setState(() => _isButtonPressed = true),
                  onTapUp: (_) => setState(() => _isButtonPressed = false),
                  onTapCancel: () => setState(() => _isButtonPressed = false),
                  onTap: () async {
                    if (selectedImage == null &&
                        _ingredientController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Please enter ingredients or upload image",
                          ),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      isLoading = true;
                      recipeResult = "";
                      isTypingPhase = false;
                    });

                    widget.isIngredient
                        ? GeminiServices(gemini: gemini)
                            .masterAgentForIngredientsToRecipe(
                            isImageOn ? "" : _ingredientController.text,
                            _numberOfPeopleController.text,
                            _dietController.text,
                            isImageOn ? selectedImage : null,
                            allowSuggestions: allowSuggestions,
                          )
                            .then((result) {
                            setState(() {
                              recipeResult = result;
                              isLoading = false;
                              isTypingPhase = true;
                            });
                          })
                        : GeminiServices(gemini: gemini)
                            .masterAgentForFoodToRecipe(
                            _numberOfPeopleController.text,
                            _dietController.text,
                            selectedImage,
                          )
                            .then((result) {
                            setState(() {
                              recipeResult = result;
                              isLoading = false;
                              isTypingPhase = true;
                            });
                          });
                  },
                  child: AnimatedScale(
                    scale: _isButtonPressed ? 0.97 : 1.0,
                    duration: const Duration(milliseconds: 120),
                    curve: Curves.easeOut,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: kPrimaryColor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: kPrimaryColor.withOpacity(0.35),
                            blurRadius: _isButtonPressed ? 4 : 12,
                            offset: Offset(0, _isButtonPressed ? 1 : 5),
                          ),
                        ],
                      ),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          transitionBuilder: (child, anim) => FadeTransition(
                            opacity: anim,
                            child: ScaleTransition(scale: anim, child: child),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  key: ValueKey('loading'),
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  "Generate Recipe",
                                  key: ValueKey('label'),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Visibility(
                  visible: isLoading,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Center(
                      child: CookingLoadingAnimation(size: 90),
                    ),
                  ),
                ),
                // Phase 1: word-by-word "typing" reveal, ChatGPT/Claude-style,
                // of the already-fetched recipe text.
                Visibility(
                  visible: recipeResult.isNotEmpty && isTypingPhase,
                  child: Column(
                    children: [
                      const Text(
                        "Here is your recipe",
                        style: TextStyle(
                          color: kPrimaryColor,
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: kPrimaryColor.withOpacity(0.4)),
                        ),
                        child: isTypingPhase
                            ? TypewriterText(
                                key: ValueKey(recipeResult),
                                text: recipeResult,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                                onComplete: () {
                                  if (!mounted) return;
                                  setState(() {
                                    isTypingPhase = false;
                                  });
                                  _resultAnimController.forward(from: 0);
                                },
                              )
                            : const SizedBox(),
                      ),
                    ],
                  ),
                ),
                // Phase 2: final, nicely structured card view once typing
                // has finished.
                Visibility(
                  visible: recipeResult.isNotEmpty && !isTypingPhase,
                  child: FadeTransition(
                    opacity: _resultFade,
                    child: SlideTransition(
                      position: _resultSlide,
                      child: Column(
                        children: [
                          const Text(
                            "Here is your recipe",
                            style: TextStyle(
                              color: kPrimaryColor,
                              fontSize: 17,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),
                          RecipeResultView(markdown: recipeResult),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
