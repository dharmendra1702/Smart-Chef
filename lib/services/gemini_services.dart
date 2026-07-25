import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

class GeminiServices {
  final Gemini gemini;

  GeminiServices({required this.gemini});

  // Safely extracts the actual text from the last response Part.
  // (value?.output usually works too, but this is a safe fallback that
  // avoids accidentally printing "Instance of 'TextPart'".)
  String _extractText(dynamic candidates) {
    final part = candidates?.content?.parts?.last;
    if (part is TextPart) return part.text;
    return candidates?.output?.toString() ?? '';
  }

  // Shared language/style directive so every recipe reads consistently.
  static const String _indianEnglishStyle = '''
Write entirely in Indian English:
- Use Indian English spellings (colour, flavour, favourite, gramme is fine as gram) and phrasing.
- Prefer Indian names for ingredients where applicable: capsicum (not bell pepper), brinjal (not eggplant), curd (not yogurt), coriander leaves/dhania (not cilantro), spring onion, maida, besan, atta, ghee, jeera, haldi, etc. — use the Indian term first.
- Use Indian-familiar measurements where natural: katori, cup, tsp/tbsp, grams — you may mention a katori/cup equivalent alongside grams for staples like rice or dal.
- Keep instructions clear and simply worded, in the tone of a friendly Indian home cook.''';

  String _strictnessRule(bool allowSuggestions) => allowSuggestions
      ? '''
- Build the recipe primarily around the identified ingredients.
- You MAY suggest up to 3 additional common ingredients that would meaningfully improve the dish, but they must NEVER appear in the main "Ingredients" list. List them separately under a final section titled "Suggested Additions (Optional)", each with a one-line reason why it helps. Do not assume the user has them.'''
      : '''
- Use ONLY the ingredients you identify. Do not introduce any ingredient beyond what's identified.
- Exception: you may assume basic pantry staples are available even if not listed — water, salt, pepper, and cooking oil — since virtually every kitchen has these. Do not use anything beyond the identified ingredients plus these staples.
- Do NOT include a "Suggested Additions" section in strict mode.''';

  String _sectionHeaders(String peopleText, bool allowSuggestions) => '''
Respond in well-structured markdown using EXACTLY these level-2 headers (## ), in this order, and nothing else at that heading level. Be concise and efficient — no filler, no repetition, no restating the question:
## Recipe Name
(just the dish name, nothing else)
## Ingredients
(precise quantities for $peopleText people, as a bullet list — one line per ingredient)
## Detailed Instructions
(numbered steps, at most 8 steps — combine minor steps together rather than over-splitting)
## Nutritional Information
(approximate, per serving, at most 5 short bullet points)
${allowSuggestions ? '## Suggested Additions (Optional)\n(at most 3 bullet points, each one line, only if genuinely useful — omit the whole section otherwise)' : ''}''';


  Future<String> masterAgentForIngredientsToRecipe(
    String? ingredients,
    String numberOfPeople,
    String? diet,
    Uint8List? image, {
    bool allowSuggestions = true,
  }) async {
    debugPrint(
        'Ingredients: $ingredients | Number of People: $numberOfPeople | Diet: $diet | Allow Suggestions: $allowSuggestions');

    // If an image was provided, reason directly from the image in ONE call
    // instead of first describing it as text and then generating from that
    // text — the two-step version was the source of accuracy issues (a
    // slightly-off description would produce a completely different dish).
    if (image != null) {
      String recipe = await agentForGenerateRecipeFromIngredientsImage(
          image, numberOfPeople, diet, allowSuggestions);
      debugPrint('Recipe: $recipe');
      return recipe;
    }

    String recipe = await agentForGenerateRecipeFromIngredients(
        ingredients, numberOfPeople, diet, allowSuggestions);
    debugPrint('Recipe: $recipe');
    return recipe;
  }

  // MASTER AGENT FOR FOOD TO RECIPE
  Future<String> masterAgentForFoodToRecipe(
      String numberOfPeople, String? diet, Uint8List? image) async {
    // Single multimodal call: identify the dish/ingredient AND build the
    // recipe from the actual image in one shot — see
    // agentForGenerateRecipeFromFoodImage for why this replaced the old
    // two-step "extract name as text, then generate from that text" flow.
    String recipe = await agentForGenerateRecipeFromFoodImage(
        image!, numberOfPeople, diet);
    debugPrint('Recipe: $recipe');
    return recipe;
  }

  // AGENT FOR GENERATING RECIPE FROM INGREDIENTS (text input, no image)
  Future<String> agentForGenerateRecipeFromIngredients(
    String? ingredients,
    String numberOfPeople,
    String? diet,
    bool allowSuggestions,
  ) async {
    final peopleText = numberOfPeople.trim().isEmpty ? '1' : numberOfPeople;
    final dietText = (diet != null && diet.trim().isNotEmpty)
        ? ' The dish must be $diet.'
        : '';

    final prompt = '''
You are a precise, expert chef. Create ONE accurate, realistic recipe using the ingredients provided.

Ingredients available: $ingredients
Servings: $peopleText people.$dietText

Rules for accuracy:
- Every ingredient quantity must be realistically scaled for $peopleText people — do not guess arbitrary amounts.
- Do not invent ingredients, steps, or nutritional numbers that aren't reasonably derived from the dish. If the ingredients are insufficient for a complete traditional dish, adapt honestly (e.g. a simple stir-fry or one-pot dish) rather than inventing what isn't there.
${_strictnessRule(allowSuggestions)}

$_indianEnglishStyle

${_sectionHeaders(peopleText, allowSuggestions)}
''';

    try {
      return gemini.text(prompt).then((value) {
        String recipe = _extractText(value);
        debugPrint('Recipe: $recipe');
        return recipe;
      }).catchError((e) {
        return 'Error: $e';
      });
    } catch (e) {
      return 'Error: $e';
    }
  }

  // AGENT FOR GENERATING RECIPE DIRECTLY FROM AN INGREDIENTS IMAGE
  //
  // Single multimodal call — the model looks at the actual photo and builds
  // the recipe in the same pass, instead of first writing a text summary of
  // what it sees and then generating from that (lossy) summary.
  Future<String> agentForGenerateRecipeFromIngredientsImage(
    Uint8List image,
    String numberOfPeople,
    String? diet,
    bool allowSuggestions,
  ) async {
    final peopleText = numberOfPeople.trim().isEmpty ? '1' : numberOfPeople;
    final dietText = (diet != null && diet.trim().isNotEmpty)
        ? ' The dish must be $diet.'
        : '';

    final prompt = '''
You are a precise, expert chef with excellent vision. Silently identify every ingredient visible in the attached image (accurately — don't guess ones that aren't there, don't miss ones that are), then go straight to building ONE accurate, realistic recipe from what you identified. Do not narrate your identification step — output only the formatted recipe below.

Servings: $peopleText people.$dietText

Rules for accuracy:
- Every ingredient quantity must be realistically scaled for $peopleText people.
- Do not invent ingredients, steps, or nutritional numbers that weren't identified.
${_strictnessRule(allowSuggestions)}

$_indianEnglishStyle

${_sectionHeaders(peopleText, allowSuggestions)}
''';

    try {
      return gemini.textAndImage(text: prompt, images: [image]).then((value) {
        String recipe = _extractText(value);
        debugPrint('Recipe: $recipe');
        return recipe;
      }).catchError((e) {
        return 'Error: $e';
      });
    } catch (e) {
      return 'Error: $e';
    }
  }

  // AGENT FOR GENERATING RECIPE DIRECTLY FROM A FOOD IMAGE
  //
  // Single multimodal call — identifies exactly what's shown (a prepared
  // dish vs. a raw/uncooked ingredient) and builds the recipe from that same
  // image in one pass. This replaced a two-step "extract dish name as text,
  // then generate from that text" flow, which was the root cause of
  // inaccurate results (e.g. uploading a raw cauliflower/gobi image could
  // return a completely unrelated dish, because the intermediate text
  // description lost the visual detail the second call needed).
  Future<String> agentForGenerateRecipeFromFoodImage(
    Uint8List image,
    String numberOfPeople,
    String? diet,
  ) async {
    final peopleText = numberOfPeople.trim().isEmpty ? '1' : numberOfPeople;
    final dietText = (diet != null && diet.trim().isNotEmpty)
        ? ' The dish must be $diet.'
        : '';

    final prompt = '''
You are a precise, expert chef with excellent vision. Look at the attached image and silently identify precisely what is shown:
- Fully prepared/cooked dish → identify that exact dish. Don't confuse it with a similar-looking but different dish.
- Raw/uncooked ingredient (vegetable, fruit, meat, grain) → recognise it as raw, and build the recipe AROUND that ingredient — don't invent an unrelated finished dish (e.g. raw cauliflower/gobi → a gobi dish like Gobi Manchurian or Gobi Sabzi, not something else).
- Multiple items visible → identify all and pick the most sensible single dish combining them.

Then go straight to building ONE accurate, authentic recipe from that. Do not narrate your identification — output only the formatted recipe below.

Servings: $peopleText people.$dietText

Rules for accuracy:
- Every ingredient quantity must be realistically scaled for $peopleText people.
- Stay faithful to what you actually identified — don't invent ingredients, steps, or nutrition numbers ungrounded in it.

$_indianEnglishStyle

${_sectionHeaders(peopleText, false)}
''';

    try {
      return gemini.textAndImage(text: prompt, images: [image]).then((value) {
        String recipe = _extractText(value);
        debugPrint('Recipe: $recipe');
        return recipe;
      }).catchError((e) {
        return 'Error: $e';
      });
    } catch (e) {
      return 'Error: $e';
    }
  }
}
