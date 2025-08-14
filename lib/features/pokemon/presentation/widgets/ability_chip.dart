import 'package:flutter/material.dart';
import '../../domain/entities/pokemon.dart';

class AbilityChip extends StatelessWidget {
  final PokemonAbility ability;

  const AbilityChip({
    super.key,
    required this.ability,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: ability.isHidden ? Colors.purple[100] : Colors.blue[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ability.isHidden ? Colors.purple[300]! : Colors.blue[300]!,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (ability.isHidden)
            Icon(
              Icons.visibility_off,
              size: 14,
              color: Colors.purple[600],
            ),
          if (ability.isHidden) const SizedBox(width: 4),
          Text(
            _capitalize(ability.name.replaceAll('-', ' ')),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: ability.isHidden ? Colors.purple[600] : Colors.blue[600],
            ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}