class Pokemon {
  final int id;
  final String name;
  final String url;
  final List<String> types;
  final int height;
  final int weight;
  final String? imageUrl;
  final List<PokemonStat> stats;
  final List<PokemonAbility> abilities;

  const Pokemon({
    required this.id,
    required this.name,
    required this.url,
    this.types = const [],
    this.height = 0,
    this.weight = 0,
    this.imageUrl,
    this.stats = const [],
    this.abilities = const [],
  });

  Pokemon copyWith({
    int? id,
    String? name,
    String? url,
    List<String>? types,
    int? height,
    int? weight,
    String? imageUrl,
    List<PokemonStat>? stats,
    List<PokemonAbility>? abilities,
  }) {
    return Pokemon(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      types: types ?? this.types,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      imageUrl: imageUrl ?? this.imageUrl,
      stats: stats ?? this.stats,
      abilities: abilities ?? this.abilities,
    );
  }
}

class PokemonStat {
  final String name;
  final int baseStat;

  const PokemonStat({
    required this.name,
    required this.baseStat,
  });
}

class PokemonAbility {
  final String name;
  final bool isHidden;

  const PokemonAbility({
    required this.name,
    required this.isHidden,
  });
}