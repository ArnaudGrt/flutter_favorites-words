import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Favorites Words',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.greenAccent),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  // VARIABLES
  var current = WordPair.random();
  var favorites = <WordPair>[];
  var history = <WordPair>[];

  // FUNCTIONS
  void getNext() {
    current = WordPair.random();
    history.insert(0, current);

    notifyListeners();
  }

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }

    notifyListeners();
  }

  void resetFavorites() {
    favorites = [];

    notifyListeners();
  }

  void removeFavorite(pair) {
    favorites.remove(pair);

    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;

    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      case 2:
        page = HistoryPage();
        break;
      default:
        throw UnimplementedError('Pas de page implémentée pour cet index');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Accueil'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favoris'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.history),
                    label: Text('Historique'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;
    var theme = Theme.of(context);

    var titleStyle =
        theme.textTheme.headlineLarge!.copyWith(color: Colors.black);
    var subtitleStyle = theme.textTheme.titleMedium!
        .copyWith(fontStyle: FontStyle.italic, color: Colors.black);

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    SizedBox(height: 16),
                    Text("Faites défiler les mots...", style: titleStyle),
                    Text(
                        "... et ajoutez en favoris ceux qui vous parlent le plus !",
                        style: subtitleStyle),
                  ],
                )
              ],
            )),
        Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Card(
                        child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(children: [
                        BigCard(pair: pair),
                        SizedBox(height: 16),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                appState.toggleFavorite();
                              },
                              style: ElevatedButton.styleFrom(
                                  side: BorderSide(
                                      width: 1,
                                      color: theme.colorScheme.primary)),
                              icon: Icon(icon),
                              label: Text('Favoris'),
                            ),
                            SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                appState.getNext();
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary),
                              child: Text('Suivant',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ]),
                    )),
                  ],
                )
              ],
            ))
      ],
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var favorites = appState.favorites;
    var favoritesLength = favorites.length;
    var widgetsList = <Widget>[];

    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.displaySmall!
        .copyWith(color: theme.colorScheme.onPrimary);

    if (favorites.isEmpty) {
      widgetsList = [
        SizedBox(height: 16),
        Row(children: [
          SizedBox(width: 16),
          Text("La liste des favoris est actuellement vide.")
        ])
      ];
    } else {
      widgetsList = [
        Row(children: [
          Padding(
            padding: const EdgeInsets.all(30),
            child: Text("Vous avez actuellement $favoritesLength favoris !",
                style: TextStyle(fontWeight: FontWeight.w500)),
          ),
        ]),
        Expanded(
          child: ListView.builder(
              shrinkWrap: false,
              scrollDirection: Axis.vertical,
              itemCount: favoritesLength,
              itemBuilder: (BuildContext context, int index) {
                final favorite = favorites[index];

                return Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                            bottom: BorderSide(
                                color: theme.colorScheme.onPrimaryFixed))),
                    child: ListTile(
                      horizontalTitleGap: 16,
                      textColor: Colors.black,
                      minVerticalPadding: 8,
                      leading: IconButton(
                        icon: Icon(Icons.delete, semanticLabel: 'Delete'),
                        color: theme.colorScheme.primary,
                        onPressed: () {
                          appState.removeFavorite(favorite);
                        },
                      ),
                      title: Text(
                        favorite.asLowerCase,
                        semanticsLabel: favorite.asPascalCase,
                      ),
                    ));
              }),
        )
      ];
    }

    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Card(
          color: theme.colorScheme.primary,
          elevation: 8,
          child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                "Mes favoris",
                style: titleStyle,
              )),
        ),
      ]),
      ...widgetsList
    ]);
  }
}

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var favorites = appState.favorites;
    var history = appState.history;
    var widgetsList = <Widget>[];

    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.displaySmall!
        .copyWith(color: theme.colorScheme.onPrimary);

    bool wordIsInHistory(word) {
      bool result;

      favorites.contains(word) ? result = true : result = false;

      return result;
    }

    if (history.isEmpty) {
      widgetsList = [
        Row(children: [
          SizedBox(width: 16),
          Text("Il n'y a pas encore d'entrée dans l'historique.")
        ])
      ];
    } else {
      widgetsList = [
        Expanded(
            child: ListView.builder(
                shrinkWrap: false,
                scrollDirection: Axis.vertical,
                itemCount: history.length,
                itemBuilder: (BuildContext context, int index) {
                  final word = history[index];

                  return Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                              bottom: BorderSide(
                                  color: theme.colorScheme.onPrimaryFixed))),
                      child: ListTile(
                        horizontalTitleGap: 16,
                        textColor: Colors.black,
                        minVerticalPadding: 8,
                        leading: Icon(
                          wordIsInHistory(word) ? Icons.favorite : Icons.circle,
                          color: wordIsInHistory(word)
                              ? Colors.red
                              : theme.colorScheme.primary,
                          size: wordIsInHistory(word) ? 18 : 12,
                        ),
                        title: Text(
                          word.asLowerCase,
                          semanticsLabel: word.asPascalCase,
                        ),
                      ));
                })),
      ];
    }

    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Card(
          color: theme.colorScheme.primary,
          elevation: 8,
          child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                "Mon historique",
                style: titleStyle,
              )),
        ),
      ]),
      SizedBox(height: 16),
      ...widgetsList
    ]);
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final style = theme.textTheme.displayMedium!
        .copyWith(color: theme.colorScheme.onPrimary);

    return Card(
      color: theme.colorScheme.primary,
      elevation: 8,
      child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            pair.asLowerCase,
            style: style,
            semanticsLabel: "${pair.first} ${pair.second}",
          )),
    );
  }
}
