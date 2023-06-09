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
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  var pascalCase = false;

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  void togglePascal(){
    pascalCase = !pascalCase;
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else if(worst.contains(current)) {
      worst.remove(current);
      favorites.add(current);
    }
    else{
      favorites.add(current);
    }
    notifyListeners();
  }

  var worst = <WordPair>[];

  void toggleWorst(){
    if(worst.contains(current)){
      worst.remove(current);
    }
    else if(favorites.contains(current)){
      favorites.remove(current);
      worst.add(current);
    }
    else{
      worst.add(current);
    }
    notifyListeners();
  }

  void deleteFavorite(WordPair pair){
    favorites.remove(pair);
    notifyListeners();
  }

  void deleteWorst(WordPair pair){
    worst.remove(pair);
    notifyListeners();
  }
  
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex= 0;

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
        page = WorstPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              extended: false,
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.favorite),
                  label: Text('Favorites'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.gpp_bad_outlined),
                  label: Text('Favorites'),
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
  }
}


class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData iconFavorite;
    if (appState.favorites.contains(pair)) {
      iconFavorite = Icons.favorite;
    } else {
      iconFavorite = Icons.favorite_border;
    }

    IconData iconWorst;
    if (appState.worst.contains(pair)) {
      iconWorst = Icons.gpp_bad;
    } else {
      iconWorst = Icons.gpp_bad_outlined;
    }

    IconData iconPascal;
    if (appState.pascalCase == true){
      iconPascal = Icons.check;
    } else{
      iconPascal = Icons.close;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
                onPressed: () {
                  appState.togglePascal();
                },
                icon: Icon(iconPascal),
                label: Text('PascalCase'),
              ),
          SizedBox(height: 10),
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(iconFavorite),
                label: Text('Like'),
              ),
              SizedBox(width: 10,),
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleWorst();
                },
                icon: Icon(iconWorst),
                label: Text('Dislike'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
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
    var theme = Theme.of(context);
    var appState = context.watch<MyAppState>();
    var word = "";
    if(appState.pascalCase==false){
      word = pair.asLowerCase;
    }
    else{
      word = pair.asPascalCase;
    }
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.bold,
    );
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Text(word, 
        style: style, 
        semanticsLabel: pair.asPascalCase,
        ),
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${appState.favorites.length} favorites:'),
        ),
            for (var pair in appState.favorites)
              ListTile(
                leading:IconButton(
                  onPressed: () {
                    appState.deleteFavorite(pair);
                  }, 
                icon: Icon(Icons.delete),
                ),
                title:Text(pair.asLowerCase),
              ),
        ],
    );    
  }
}

class WorstPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.worst.isEmpty) {
      return Center(
        child: Text('No bad ones yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${appState.worst.length} bad ones:'),
        ),
        for (var pair in appState.worst)
          ListTile(
            leading:IconButton(
              onPressed: () {
                appState.deleteWorst(pair);
              }, 
              icon: Icon(Icons.delete),
            ),
            title:Text(pair.asLowerCase),
            ),
      ],
    );
  }
}