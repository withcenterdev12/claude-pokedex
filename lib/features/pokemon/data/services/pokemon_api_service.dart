import 'package:dio/dio.dart';
import '../models/pokemon_list_response.dart';
import '../models/pokemon_detail_response.dart';

class PokemonApiService {
  static const String _baseUrl = 'https://pokeapi.co/api/v2';
  final Dio _dio;

  PokemonApiService({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
    
    // Add interceptor for logging in debug mode
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (log) => print('[API] $log'),
      ),
    );
  }

  /// Fetch paginated list of Pokemon
  /// [offset] - Number of items to skip
  /// [limit] - Number of items to fetch (default: 20)
  Future<PokemonListResponse> fetchPokemonList({
    int offset = 0,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '/pokemon',
        queryParameters: {
          'offset': offset,
          'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        return PokemonListResponse.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch Pokemon list: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Unexpected error occurred: $e');
    }
  }

  /// Fetch detailed information about a specific Pokemon
  /// [identifier] - Pokemon name or ID
  Future<PokemonDetailResponse> fetchPokemonDetail(String identifier) async {
    try {
      final response = await _dio.get('/pokemon/${identifier.toLowerCase()}');

      if (response.statusCode == 200) {
        return PokemonDetailResponse.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch Pokemon detail: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Unexpected error occurred: $e');
    }
  }

  /// Search for a Pokemon by name
  /// This method attempts to fetch the Pokemon directly by name
  Future<PokemonDetailResponse?> searchPokemonByName(String name) async {
    try {
      return await fetchPokemonDetail(name);
    } catch (e) {
      // Return null if Pokemon not found instead of throwing error
      // This allows for graceful handling in the UI
      return null;
    }
  }

  Exception _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timeout. Please check your internet connection.');
      
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 404) {
          return Exception('Pokemon not found.');
        } else if (statusCode == 500) {
          return Exception('Server error. Please try again later.');
        } else {
          return Exception('HTTP Error: $statusCode');
        }
      
      case DioExceptionType.cancel:
        return Exception('Request was cancelled.');
      
      case DioExceptionType.connectionError:
        return Exception('No internet connection. Please check your network.');
      
      case DioExceptionType.badCertificate:
        return Exception('Security error occurred.');
      
      case DioExceptionType.unknown:
      default:
        return Exception('An unexpected error occurred: ${e.message}');
    }
  }

  /// Dispose resources
  void dispose() {
    _dio.close();
  }
}