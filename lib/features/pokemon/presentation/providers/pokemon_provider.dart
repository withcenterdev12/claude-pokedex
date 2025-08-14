import 'package:flutter/foundation.dart';
import '../../domain/entities/pokemon.dart';
import '../../data/services/pokemon_api_service.dart';

enum PokemonLoadState { initial, loading, loaded, error }

class PokemonProvider extends ChangeNotifier {
  final PokemonApiService _apiService;

  // State variables
  PokemonLoadState _loadState = PokemonLoadState.initial;
  final List<Pokemon> _allPokemon = []; // Paginated Pokemon from API
  final List<Pokemon> _apiSearchedPokemon = []; // Pokemon found via API search
  List<Pokemon> _filteredPokemon = [];
  String _searchQuery = '';
  String? _errorMessage;
  bool _hasMoreData = true;
  int _currentOffset = 0;
  static const int _pageSize = 20;
  final Set<int> _loadedPages = {}; // Track which pages have been loaded
  bool _isLoadingPage = false; // Prevent concurrent page loads

  // Detailed Pokemon state
  Pokemon? _selectedPokemon;
  PokemonLoadState _detailLoadState = PokemonLoadState.initial;
  String? _detailErrorMessage;

  PokemonProvider({PokemonApiService? apiService})
    : _apiService = apiService ?? PokemonApiService();

  // Getters
  PokemonLoadState get loadState => _loadState;
  List<Pokemon> get allPokemon => List.unmodifiable(_allPokemon);
  List<Pokemon> get filteredPokemon => List.unmodifiable(_filteredPokemon);
  String get searchQuery => _searchQuery;
  String? get errorMessage => _errorMessage;
  bool get hasMoreData => _hasMoreData;

  Pokemon? get selectedPokemon => _selectedPokemon;
  PokemonLoadState get detailLoadState => _detailLoadState;
  String? get detailErrorMessage => _detailErrorMessage;

  bool get isLoading => _loadState == PokemonLoadState.loading;
  bool get isDetailLoading => _detailLoadState == PokemonLoadState.loading;
  int get pageSize => _pageSize;

  /// Load Pokemon data for a specific page
  /// [pageKey] - Page number (0-based)
  Future<List<Pokemon>> loadPokemonPage(int pageKey) async {
    // Prevent duplicate requests for the same page
    if (_loadedPages.contains(pageKey) || _isLoadingPage) {
      return [];
    }

    _isLoadingPage = true;

    if (pageKey == 0) {
      // Use Future.microtask to avoid calling notifyListeners during build
      Future.microtask(() => _setLoadState(PokemonLoadState.loading));
    }

    try {
      final offset = pageKey * _pageSize;
      final response = await _apiService.fetchPokemonList(
        offset: offset,
        limit: _pageSize,
      );

      final newPokemon = response.results
          .map((basic) => basic.toPokemon())
          .toList();

      // Add new Pokemon to the list
      _allPokemon.addAll(newPokemon);
      _loadedPages.add(pageKey);
      _hasMoreData = response.next != null;

      // Update filtered list if we're not searching
      if (_searchQuery.isEmpty) {
        _filteredPokemon = List.from(_allPokemon);
      }

      if (pageKey == 0) {
        Future.microtask(() => _setLoadState(PokemonLoadState.loaded));
      } else {
        Future.microtask(() => notifyListeners());
      }

      return newPokemon;
    } catch (e) {
      if (pageKey == 0) {
        Future.microtask(() => _setError(e.toString()));
      }
      rethrow;
    } finally {
      _isLoadingPage = false;
    }
  }

  /// Load initial Pokemon data (kept for compatibility)
  Future<void> loadInitialPokemon() async {
    if (_loadState == PokemonLoadState.loading) return;
    await loadPokemonPage(0);
  }

  /// Search Pokemon with hybrid approach
  Future<void> searchPokemon(String query) async {
    _searchQuery = query.trim().toLowerCase();

    if (_searchQuery.isEmpty) {
      _filterPokemon();
      return;
    }

    // First, search in already loaded Pokemon (client-side)
    _filterPokemon();

    // If no results found in loaded data and query looks like a specific Pokemon name
    if (_filteredPokemon.isEmpty && _searchQuery.isNotEmpty) {
      await _searchViApi(_searchQuery);
    }
  }

  /// Search Pokemon via API when not found in loaded data
  Future<void> _searchViApi(String query) async {
    try {
      final detailResponse = await _apiService.searchPokemonByName(query);

      if (detailResponse != null) {
        final pokemon = detailResponse.toPokemon();

        // Check if Pokemon is already in the paginated list
        final existingIndex = _allPokemon.indexWhere((p) => p.id == pokemon.id);
        final existingSearchIndex = _apiSearchedPokemon.indexWhere((p) => p.id == pokemon.id);

        if (existingIndex == -1 && existingSearchIndex == -1) {
          // Add to API searched Pokemon list
          _apiSearchedPokemon.add(pokemon);
        } else if (existingIndex != -1) {
          // Update existing Pokemon in paginated list with detailed info
          _allPokemon[existingIndex] = pokemon;
        } else if (existingSearchIndex != -1) {
          // Update existing Pokemon in API searched list
          _apiSearchedPokemon[existingSearchIndex] = pokemon;
        }

        _filterPokemon();
      }
    } catch (e) {
      // Silently handle API search errors to not disrupt UI
      debugPrint('API search error: $e');
    }
  }

  /// Filter Pokemon based on search query
  void _filterPokemon() {
    if (_searchQuery.isEmpty) {
      // When not searching, only show paginated Pokemon
      _filteredPokemon = List.from(_allPokemon);
    } else {
      // When searching, include both paginated and API-searched Pokemon
      final combinedPokemon = [..._allPokemon, ..._apiSearchedPokemon];
      _filteredPokemon = combinedPokemon
          .where((pokemon) => pokemon.name.toLowerCase().contains(_searchQuery))
          .toList();
    }
    notifyListeners();
  }

  /// Load detailed Pokemon information
  Future<void> loadPokemonDetail(String identifier) async {
    if (_detailLoadState == PokemonLoadState.loading) return;

    _setDetailLoadState(PokemonLoadState.loading);

    try {
      final response = await _apiService.fetchPokemonDetail(identifier);
      _selectedPokemon = response.toPokemon();

      // Update the Pokemon in the appropriate list with detailed info
      final paginatedIndex = _allPokemon.indexWhere((p) => p.id == _selectedPokemon!.id);
      final searchedIndex = _apiSearchedPokemon.indexWhere((p) => p.id == _selectedPokemon!.id);
      
      if (paginatedIndex != -1) {
        _allPokemon[paginatedIndex] = _selectedPokemon!;
      } else if (searchedIndex != -1) {
        _apiSearchedPokemon[searchedIndex] = _selectedPokemon!;
      }
      _filterPokemon();

      _setDetailLoadState(PokemonLoadState.loaded);
    } catch (e) {
      _setDetailError(e.toString());
    }
  }

  /// Clear selected Pokemon
  void clearSelectedPokemon() {
    _selectedPokemon = null;
    _detailLoadState = PokemonLoadState.initial;
    _detailErrorMessage = null;
    notifyListeners();
  }

  /// Refresh all data
  Future<void> refresh() async {
    _allPokemon.clear();
    _apiSearchedPokemon.clear();
    _filteredPokemon.clear();
    _searchQuery = '';
    _selectedPokemon = null;
    _loadedPages.clear();
    _currentOffset = 0;
    _hasMoreData = true;
    _isLoadingPage = false;
    await loadInitialPokemon();
  }

  // Private helper methods
  void _setLoadState(PokemonLoadState state) {
    _loadState = state;
    if (state != PokemonLoadState.error) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  void _setDetailLoadState(PokemonLoadState state) {
    _detailLoadState = state;
    if (state != PokemonLoadState.error) {
      _detailErrorMessage = null;
    }
    notifyListeners();
  }

  void _setError(String message) {
    _loadState = PokemonLoadState.error;
    _errorMessage = message;
    notifyListeners();
  }

  void _setDetailError(String message) {
    _detailLoadState = PokemonLoadState.error;
    _detailErrorMessage = message;
    notifyListeners();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}
