import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/pokemon.dart';
import '../providers/pokemon_provider.dart';
import '../widgets/stat_bar.dart';
import '../widgets/type_chip.dart';
import '../widgets/ability_chip.dart';

class PokemonDetailPage extends StatefulWidget {
  final Pokemon pokemon;

  const PokemonDetailPage({
    super.key,
    required this.pokemon,
  });

  @override
  State<PokemonDetailPage> createState() => _PokemonDetailPageState();
}

class _PokemonDetailPageState extends State<PokemonDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Clear previous Pokemon data to prevent showing old data
      context.read<PokemonProvider>().clearSelectedPokemon();
      context.read<PokemonProvider>().loadPokemonDetail(widget.pokemon.id.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<PokemonProvider>(
        builder: (context, provider, child) {
          // Use selectedPokemon only if it matches the current Pokemon being viewed
          // This prevents showing data from previously viewed Pokemon
          final pokemon = (provider.selectedPokemon?.id == widget.pokemon.id) 
              ? provider.selectedPokemon! 
              : widget.pokemon;
          
          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(pokemon),
              SliverToBoxAdapter(
                child: _buildContent(pokemon, provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(Pokemon pokemon) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: _getTypeColor(pokemon.types.isNotEmpty ? pokemon.types.first : 'normal'),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _getTypeColors(pokemon.types),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),
                Hero(
                  tag: 'pokemon-${pokemon.id}',
                  child: _buildPokemonImage(pokemon),
                ),
                const SizedBox(height: 16),
                Text(
                  '#${pokemon.id.toString().padLeft(3, '0')}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  _capitalize(pokemon.name),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back, color: Colors.white),
      ),
    );
  }

  Widget _buildContent(Pokemon pokemon, PokemonProvider provider) {
    if (provider.detailLoadState == PokemonLoadState.loading) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTypesSection(pokemon),
            const SizedBox(height: 24),
            _buildPhysicalInfoSection(pokemon),
            const SizedBox(height: 24),
            if (pokemon.stats.isNotEmpty) ...[
              _buildStatsSection(pokemon),
              const SizedBox(height: 24),
            ],
            if (pokemon.abilities.isNotEmpty) _buildAbilitiesSection(pokemon),
          ],
        ),
      ),
    );
  }

  Widget _buildPokemonImage(Pokemon pokemon) {
    if (pokemon.imageUrl != null && pokemon.imageUrl!.isNotEmpty) {
      return Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(75),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(75),
          child: Image.network(
            pokemon.imageUrl!,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.catching_pokemon,
                size: 80,
                color: Colors.white,
              );
            },
          ),
        ),
      );
    } else {
      return Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(75),
        ),
        child: const Icon(
          Icons.catching_pokemon,
          size: 80,
          color: Colors.white,
        ),
      );
    }
  }

  Widget _buildTypesSection(Pokemon pokemon) {
    if (pokemon.types.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Type',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: pokemon.types.map((type) {
            return TypeChip(type: type);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPhysicalInfoSection(Pokemon pokemon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Physical Info',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildInfoCard(
                'Height',
                '${(pokemon.height / 10).toStringAsFixed(1)} m',
                Icons.height,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInfoCard(
                'Weight',
                '${(pokemon.weight / 10).toStringAsFixed(1)} kg',
                Icons.monitor_weight,
                Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(Pokemon pokemon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Base Stats',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ...pokemon.stats.map((stat) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: StatBar(
              name: _getStatDisplayName(stat.name),
              value: stat.baseStat,
              maxValue: 255, // Pokemon stats typically max at 255
              color: _getStatColor(stat.name),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildAbilitiesSection(Pokemon pokemon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Abilities',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: pokemon.abilities.map((ability) {
            return AbilityChip(ability: ability);
          }).toList(),
        ),
      ],
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  String _getStatDisplayName(String statName) {
    switch (statName.toLowerCase()) {
      case 'hp':
        return 'HP';
      case 'attack':
        return 'Attack';
      case 'defense':
        return 'Defense';
      case 'special-attack':
        return 'Sp. Attack';
      case 'special-defense':
        return 'Sp. Defense';
      case 'speed':
        return 'Speed';
      default:
        return _capitalize(statName.replaceAll('-', ' '));
    }
  }

  Color _getStatColor(String statName) {
    switch (statName.toLowerCase()) {
      case 'hp':
        return Colors.red;
      case 'attack':
        return Colors.orange;
      case 'defense':
        return Colors.blue;
      case 'special-attack':
        return Colors.purple;
      case 'special-defense':
        return Colors.green;
      case 'speed':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  List<Color> _getTypeColors(List<String> types) {
    if (types.isEmpty) {
      return [Colors.grey[300]!, Colors.grey[400]!];
    }

    final primaryColor = _getTypeColor(types.first);
    final secondaryColor = types.length > 1 
        ? _getTypeColor(types[1])
        : primaryColor.withOpacity(0.7);

    return [primaryColor, secondaryColor];
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'normal':
        return const Color(0xFFA8A878);
      case 'fire':
        return const Color(0xFFF08030);
      case 'water':
        return const Color(0xFF6890F0);
      case 'electric':
        return const Color(0xFFF8D030);
      case 'grass':
        return const Color(0xFF78C850);
      case 'ice':
        return const Color(0xFF98D8D8);
      case 'fighting':
        return const Color(0xFFC03028);
      case 'poison':
        return const Color(0xFFA040A0);
      case 'ground':
        return const Color(0xFFE0C068);
      case 'flying':
        return const Color(0xFFA890F0);
      case 'psychic':
        return const Color(0xFFF85888);
      case 'bug':
        return const Color(0xFFA8B820);
      case 'rock':
        return const Color(0xFFB8A038);
      case 'ghost':
        return const Color(0xFF705898);
      case 'dragon':
        return const Color(0xFF7038F8);
      case 'dark':
        return const Color(0xFF705848);
      case 'steel':
        return const Color(0xFFB8B8D0);
      case 'fairy':
        return const Color(0xFFEE99AC);
      default:
        return Colors.grey[600]!;
    }
  }
}