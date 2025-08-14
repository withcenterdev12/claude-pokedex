import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../providers/pokemon_provider.dart';
import '../../domain/entities/pokemon.dart';
import '../widgets/pokemon_card.dart';
import '../widgets/pokemon_search_bar.dart';
import 'pokemon_detail_page.dart';

class PokemonHomePage extends StatefulWidget {
  const PokemonHomePage({super.key});

  @override
  State<PokemonHomePage> createState() => _PokemonHomePageState();
}

class _PokemonHomePageState extends State<PokemonHomePage> {
  final PagingController<int, Pokemon> _pagingController = PagingController(
    firstPageKey: 0,
  );

  PokemonProvider? _pokemonProvider;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_pokemonProvider == null) {
      _pokemonProvider = context.read<PokemonProvider>();
      _initializeData();
    }
  }

  Future<void> _initializeData() async {
    // Don't pre-load data - let the paging controller handle it
    // This prevents duplicate initial requests
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      // If we're searching, show filtered results
      if (_isSearching) {
        final pokemon = _pokemonProvider!.filteredPokemon;
        _pagingController.appendLastPage(pokemon);
        return;
      }

      // For normal pagination mode
      if (pageKey == 0) {
        // First page - show all currently loaded Pokemon
        final allLoaded = _pokemonProvider!.allPokemon;
        if (allLoaded.isNotEmpty) {
          // Calculate how many "pages" worth of Pokemon we already have
          final loadedPageCount = (allLoaded.length / 20).ceil();
          final hasMoreData = _pokemonProvider!.hasMoreData;
          
          if (!hasMoreData && allLoaded.length <= 20) {
            _pagingController.appendLastPage(allLoaded);
          } else {
            _pagingController.appendPage(allLoaded, loadedPageCount);
          }
          return;
        }
      }

      // Load the specific page from the provider
      final newPokemon = await _pokemonProvider!.loadPokemonPage(pageKey);

      // Check if there's more data available
      final hasMoreData = _pokemonProvider!.hasMoreData;
      final isLastPage = !hasMoreData || newPokemon.isEmpty;

      if (isLastPage) {
        _pagingController.appendLastPage(newPokemon);
      } else {
        _pagingController.appendPage(newPokemon, pageKey + 1);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  // Removed _updatePagingController method - no longer needed
  // The _fetchPage method now handles pagination directly

  void _onSearchChanged(String query) async {
    final wasSearching = _isSearching;
    setState(() {
      _isSearching = query.isNotEmpty;
    });

    await _pokemonProvider!.searchPokemon(query);
    
    // If we were searching and now we're not, reset to show paginated results
    if (wasSearching && !_isSearching) {
      // Reset pagination to show all loaded Pokemon
      _pagingController.refresh();
    } else if (_isSearching) {
      // For active search, refresh to show filtered results
      _pagingController.refresh();
    }
  }

  void _onPokemonTap(Pokemon pokemon) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PokemonDetailPage(pokemon: pokemon),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Pokedex',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.red[400],
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar Section
          Container(
            color: Colors.red[400],
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: PokemonSearchBar(onSearchChanged: _onSearchChanged),
          ),

          // Pokemon List Section
          Expanded(
            child: Consumer<PokemonProvider>(
              builder: (context, provider, child) {
                if (provider.loadState == PokemonLoadState.loading &&
                    provider.allPokemon.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Loading Pokemon...',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.loadState == PokemonLoadState.error) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Oops! Something went wrong',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          provider.errorMessage ?? 'Unknown error occurred',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            _pagingController.refresh();
                            provider.refresh();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[400],
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.filteredPokemon.isEmpty && _isSearching) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No Pokemon found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try searching for a different Pokemon name',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    _pagingController.refresh();
                    await provider.refresh();
                  },
                  child: PagedGridView<int, Pokemon>(
                    pagingController: _pagingController,
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    builderDelegate: PagedChildBuilderDelegate<Pokemon>(
                      itemBuilder: (context, pokemon, index) {
                        return PokemonCard(
                          pokemon: pokemon,
                          onTap: () => _onPokemonTap(pokemon),
                        );
                      },
                      firstPageProgressIndicatorBuilder: (_) =>
                          const SizedBox.shrink(),
                      newPageProgressIndicatorBuilder: (_) => Container(
                        padding: const EdgeInsets.all(16),
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.red,
                            ),
                          ),
                        ),
                      ),
                      noItemsFoundIndicatorBuilder: (_) => Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.catching_pokemon,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No Pokemon found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                      firstPageErrorIndicatorBuilder: (_) =>
                          const SizedBox.shrink(),
                      newPageErrorIndicatorBuilder: (_) => Container(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(height: 8),
                            const Text('Failed to load more Pokemon'),
                            TextButton(
                              onPressed: () =>
                                  _pagingController.retryLastFailedRequest(),
                              child: const Text('Try Again'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}
