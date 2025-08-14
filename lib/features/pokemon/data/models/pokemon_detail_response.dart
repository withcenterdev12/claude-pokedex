import '../../domain/entities/pokemon.dart';

class PokemonDetailResponse {
  final int id;
  final String name;
  final int height;
  final int weight;
  final List<PokemonTypeResponse> types;
  final List<PokemonStatResponse> stats;
  final List<PokemonAbilityResponse> abilities;
  final PokemonSprites sprites;

  const PokemonDetailResponse({
    required this.id,
    required this.name,
    required this.height,
    required this.weight,
    required this.types,
    required this.stats,
    required this.abilities,
    required this.sprites,
  });

  factory PokemonDetailResponse.fromJson(Map<String, dynamic> json) {
    return PokemonDetailResponse(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      height: json['height'] ?? 0,
      weight: json['weight'] ?? 0,
      types: (json['types'] as List<dynamic>?)
              ?.map((item) => PokemonTypeResponse.fromJson(item))
              .toList() ??
          [],
      stats: (json['stats'] as List<dynamic>?)
              ?.map((item) => PokemonStatResponse.fromJson(item))
              .toList() ??
          [],
      abilities: (json['abilities'] as List<dynamic>?)
              ?.map((item) => PokemonAbilityResponse.fromJson(item))
              .toList() ??
          [],
      sprites: PokemonSprites.fromJson(json['sprites'] ?? {}),
    );
  }

  Pokemon toPokemon() {
    final imageUrl = sprites.other?.officialArtwork?.frontDefault ??
        sprites.frontDefault ??
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

    return Pokemon(
      id: id,
      name: name,
      url: 'https://pokeapi.co/api/v2/pokemon/$id/',
      types: types.map((type) => type.type.name).toList(),
      height: height,
      weight: weight,
      imageUrl: imageUrl,
      stats: stats.map((stat) => PokemonStat(
        name: stat.stat.name,
        baseStat: stat.baseStat,
      )).toList(),
      abilities: abilities.map((ability) => PokemonAbility(
        name: ability.ability.name,
        isHidden: ability.isHidden,
      )).toList(),
    );
  }
}

class PokemonTypeResponse {
  final int slot;
  final PokemonTypeInfo type;

  const PokemonTypeResponse({
    required this.slot,
    required this.type,
  });

  factory PokemonTypeResponse.fromJson(Map<String, dynamic> json) {
    return PokemonTypeResponse(
      slot: json['slot'] ?? 0,
      type: PokemonTypeInfo.fromJson(json['type'] ?? {}),
    );
  }
}

class PokemonTypeInfo {
  final String name;
  final String url;

  const PokemonTypeInfo({
    required this.name,
    required this.url,
  });

  factory PokemonTypeInfo.fromJson(Map<String, dynamic> json) {
    return PokemonTypeInfo(
      name: json['name'] ?? '',
      url: json['url'] ?? '',
    );
  }
}

class PokemonStatResponse {
  final int baseStat;
  final int effort;
  final PokemonStatInfo stat;

  const PokemonStatResponse({
    required this.baseStat,
    required this.effort,
    required this.stat,
  });

  factory PokemonStatResponse.fromJson(Map<String, dynamic> json) {
    return PokemonStatResponse(
      baseStat: json['base_stat'] ?? 0,
      effort: json['effort'] ?? 0,
      stat: PokemonStatInfo.fromJson(json['stat'] ?? {}),
    );
  }
}

class PokemonStatInfo {
  final String name;
  final String url;

  const PokemonStatInfo({
    required this.name,
    required this.url,
  });

  factory PokemonStatInfo.fromJson(Map<String, dynamic> json) {
    return PokemonStatInfo(
      name: json['name'] ?? '',
      url: json['url'] ?? '',
    );
  }
}

class PokemonAbilityResponse {
  final bool isHidden;
  final int slot;
  final PokemonAbilityInfo ability;

  const PokemonAbilityResponse({
    required this.isHidden,
    required this.slot,
    required this.ability,
  });

  factory PokemonAbilityResponse.fromJson(Map<String, dynamic> json) {
    return PokemonAbilityResponse(
      isHidden: json['is_hidden'] ?? false,
      slot: json['slot'] ?? 0,
      ability: PokemonAbilityInfo.fromJson(json['ability'] ?? {}),
    );
  }
}

class PokemonAbilityInfo {
  final String name;
  final String url;

  const PokemonAbilityInfo({
    required this.name,
    required this.url,
  });

  factory PokemonAbilityInfo.fromJson(Map<String, dynamic> json) {
    return PokemonAbilityInfo(
      name: json['name'] ?? '',
      url: json['url'] ?? '',
    );
  }
}

class PokemonSprites {
  final String? frontDefault;
  final String? frontShiny;
  final String? backDefault;
  final String? backShiny;
  final PokemonSpritesOther? other;

  const PokemonSprites({
    this.frontDefault,
    this.frontShiny,
    this.backDefault,
    this.backShiny,
    this.other,
  });

  factory PokemonSprites.fromJson(Map<String, dynamic> json) {
    return PokemonSprites(
      frontDefault: json['front_default'],
      frontShiny: json['front_shiny'],
      backDefault: json['back_default'],
      backShiny: json['back_shiny'],
      other: json['other'] != null 
          ? PokemonSpritesOther.fromJson(json['other'])
          : null,
    );
  }
}

class PokemonSpritesOther {
  final PokemonOfficialArtwork? officialArtwork;

  const PokemonSpritesOther({
    this.officialArtwork,
  });

  factory PokemonSpritesOther.fromJson(Map<String, dynamic> json) {
    return PokemonSpritesOther(
      officialArtwork: json['official-artwork'] != null
          ? PokemonOfficialArtwork.fromJson(json['official-artwork'])
          : null,
    );
  }
}

class PokemonOfficialArtwork {
  final String? frontDefault;
  final String? frontShiny;

  const PokemonOfficialArtwork({
    this.frontDefault,
    this.frontShiny,
  });

  factory PokemonOfficialArtwork.fromJson(Map<String, dynamic> json) {
    return PokemonOfficialArtwork(
      frontDefault: json['front_default'],
      frontShiny: json['front_shiny'],
    );
  }
}