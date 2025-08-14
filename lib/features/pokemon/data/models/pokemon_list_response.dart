import '../../domain/entities/pokemon.dart';

class PokemonListResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<PokemonBasic> results;

  const PokemonListResponse({
    required this.count,
    this.next,
    this.previous,
    required this.results,
  });

  factory PokemonListResponse.fromJson(Map<String, dynamic> json) {
    return PokemonListResponse(
      count: json['count'] ?? 0,
      next: json['next'],
      previous: json['previous'],
      results: (json['results'] as List<dynamic>?)
              ?.map((item) => PokemonBasic.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class PokemonBasic {
  final String name;
  final String url;

  const PokemonBasic({
    required this.name,
    required this.url,
  });

  factory PokemonBasic.fromJson(Map<String, dynamic> json) {
    return PokemonBasic(
      name: json['name'] ?? '',
      url: json['url'] ?? '',
    );
  }

  Pokemon toPokemon() {
    // Extract ID from URL (e.g., "https://pokeapi.co/api/v2/pokemon/1/" -> 1)
    final id = int.tryParse(url.split('/').where((s) => s.isNotEmpty).last) ?? 0;
    final imageUrl = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';
    
    return Pokemon(
      id: id,
      name: name,
      url: url,
      imageUrl: imageUrl,
    );
  }
}