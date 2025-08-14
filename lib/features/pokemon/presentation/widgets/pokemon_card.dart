import 'package:flutter/material.dart';
import '../../domain/entities/pokemon.dart';

class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;
  final VoidCallback? onTap;

  const PokemonCard({
    super.key,
    required this.pokemon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _getTypeColors(pokemon.types),
            ),
          ),
          child: Column(
            children: [
              // Pokemon Image
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Hero(
                    tag: 'pokemon-${pokemon.id}',
                    child: _buildPokemonImage(),
                  ),
                ),
              ),
              
              // Pokemon Info
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pokemon ID
                      Text(
                        '#${pokemon.id.toString().padLeft(3, '0')}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Pokemon Name
                      Text(
                        _capitalize(pokemon.name),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Pokemon Types
                      if (pokemon.types.isNotEmpty)
                        Wrap(
                          spacing: 4,
                          children: pokemon.types.take(2).map((type) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getTypeColor(type).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _getTypeColor(type),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                _capitalize(type),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: _getTypeColor(type),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPokemonImage() {
    if (pokemon.imageUrl != null && pokemon.imageUrl!.isNotEmpty) {
      return Image.network(
        pokemon.imageUrl!,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 2,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackImage();
        },
      );
    } else {
      return _buildFallbackImage();
    }
  }

  Widget _buildFallbackImage() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.catching_pokemon,
        size: 48,
        color: Colors.white,
      ),
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
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