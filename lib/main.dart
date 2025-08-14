import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/pokemon/presentation/providers/pokemon_provider.dart';
import 'features/pokemon/presentation/pages/pokemon_home_page.dart';

void main() {
  runApp(const PokedexApp());
}

class PokedexApp extends StatelessWidget {
  const PokedexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PokemonProvider(),
      child: MaterialApp(
        title: 'Pokedex',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.red,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
          ),
        ),
        home: const PokemonHomePage(),
      ),
    );
  }
}
