import 'package:chef_buddy/constants/assets.dart';
import 'package:chef_buddy/constants/colors.dart';
import 'package:chef_buddy/views/chat/chat_view.dart';
import 'package:chef_buddy/views/info/info_screen.dart';
import 'package:chef_buddy/views/recipe_generate/recipe_generate_view.dart';
import 'package:chef_buddy/widgets/suggestions_widget.dart';
import 'package:chef_buddy/widgets/tools_widget.dart';
import 'package:flutter/material.dart';

class WebHomeView extends StatelessWidget {
  const WebHomeView({super.key});

  static const _suggestionPrompts = [
    'What to cook today?',
    'How to cook Alfredo pasta?',
    'How to make a cheese cake?',
    'Suggest delicious recipes',
  ];

  void _openChat(BuildContext context, String message) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          message: message,
          // chat_view.dart indexes preQuestions[0..3] unconditionally, so
          // this must always be the full list of 4 — filtering out the
          // tapped one here caused a RangeError crash.
          preQuestions: _suggestionPrompts,
        ),
      ),
    );
  }

  void _openRecipeView(BuildContext context, bool isIngredient) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeGenerateView(isIngredient: isIngredient),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Scale paddings/gaps/logo down gracefully on shorter viewports
          // (typical laptop screens at 100% browser zoom) instead of relying
          // on a huge fixed canvas that only looked right when zoomed out.
          final viewportHeight = constraints.maxHeight;
          final isCompactHeight = viewportHeight < 760;
          final horizontalPadding = isCompactHeight ? 28.0 : 40.0;
          final logoSize =
              (constraints.maxWidth * 0.5 * 0.15).clamp(90.0, 160.0).toDouble();

          return Row(
            children: [
              // LEFT PANEL — brand + quick suggestions
              Expanded(
                child: Container(
                  height: viewportHeight,
                  color: kPrimaryColor,
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: viewportHeight),
                      child: Padding(
                        padding: EdgeInsets.all(horizontalPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: logoSize,
                              height: logoSize,
                              decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                                border: Border.fromBorderSide(
                                  BorderSide(
                                    color: Color(0xFFED7F45),
                                    width: 4,
                                  ),
                                ),
                                image: DecorationImage(
                                  image: AssetImage(kLogo),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            SizedBox(height: isCompactHeight ? 28 : 44),
                            ..._suggestionPrompts.expand((prompt) => [
                                  SuggestionWidget(
                                    text: prompt,
                                    isWeb: true,
                                    onTap: () => _openChat(context, prompt),
                                  ),
                                  const SizedBox(height: 10),
                                ]),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // RIGHT PANEL — welcome header + tool cards
              Expanded(
                child: Container(
                  height: viewportHeight,
                  color: kPrimaryColor.withOpacity(0.15),
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: viewportHeight),
                      child: Padding(
                        padding: EdgeInsets.all(horizontalPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Welcome to,',
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 18,
                                        ),
                                      ),
                                      Text(
                                        'Smart Chef',
                                        style: TextStyle(
                                          color: kPrimaryColor,
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const InfoScreen(),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.info,
                                    color: kPrimaryColor,
                                    size: 42,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: isCompactHeight ? 40 : 60),
                            LayoutBuilder(
                              builder: (context, cardConstraints) {
                                final maxWidth = cardConstraints.maxWidth;
                                // Card size scales with available width
                                // instead of a fixed 220px, so it always
                                // fits without needing to zoom out.
                                final cardSize =
                                    (maxWidth / 2 - 30).clamp(130.0, 220.0).toDouble();

                                if (maxWidth < 460) {
                                  return Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      ToolWidget(
                                        size: cardSize,
                                        image: kChatbot,
                                        title: 'Chef Buddy',
                                        description: 'Chat with Chef Buddy',
                                        onTap: () => _openChat(context, ""),
                                      ),
                                      const SizedBox(height: 20),
                                      ToolWidget(
                                        size: cardSize,
                                        image: kIngredients,
                                        title: 'Ingredients to Recipe',
                                        description:
                                            'Get Recipe from Ingredients',
                                        onTap: () =>
                                            _openRecipeView(context, true),
                                      ),
                                      const SizedBox(height: 20),
                                      ToolWidget(
                                        size: cardSize,
                                        image: kFood,
                                        title: 'Food to Recipe',
                                        description: 'Chat with Chef Buddy',
                                        onTap: () =>
                                            _openRecipeView(context, false),
                                      ),
                                    ],
                                  );
                                }

                                return Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        ToolWidget(
                                          size: cardSize,
                                          image: kChatbot,
                                          title: 'Chef Buddy',
                                          description: 'Chat with Chef Buddy',
                                          onTap: () => _openChat(context, ""),
                                        ),
                                        ToolWidget(
                                          size: cardSize,
                                          image: kIngredients,
                                          title: 'Ingredients to Recipe',
                                          description:
                                              'Get Recipe from Ingredients',
                                          onTap: () =>
                                              _openRecipeView(context, true),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: isCompactHeight ? 24 : 40),
                                    ToolWidget(
                                      size: cardSize,
                                      image: kFood,
                                      title: 'Food to Recipe',
                                      description: 'Chat with Chef Buddy',
                                      onTap: () =>
                                          _openRecipeView(context, false),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
