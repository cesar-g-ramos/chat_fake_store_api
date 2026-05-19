import '../../domain/entities/product.dart';
import '../../domain/repositories/ichat_repository.dart';
import '../datasources/fakestore_remote_data_source.dart';


/// Implementación del contrato IChatRepository. Incorpora el mapeo semántico
/// inteligente del español al vocabulario utilizado por la API FakeStore.
class ChatRepositoryImpl implements IChatRepository {
  final FakeStoreRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({required this.remoteDataSource});

  /// Mapa que relaciona palabras clave en español con las categorías oficiales de FakeStore API.
  static const Map<String, String> _categoryTranslationMap = {
    'ropa': "men's clothing",
    'vestir': "men's clothing",
    'pantalon': "men's clothing",
    'pantalones': "men's clothing",
    'camisa': "men's clothing",
    'camisetas': "men's clothing",
    'chaqueta': "men's clothing",
    'saco': "men's clothing",
    'vestido': "women's clothing",
    'falda': "women's clothing",
    'blusa': "women's clothing",
    'joyeria': 'jewelery',
    'joyas': 'jewelery',
    'anillo': 'jewelery',
    'collar': 'jewelery',
    'aretes': 'jewelery',
    'reloj': 'jewelery',
    'electronica': 'electronics',
    'tecnologia': 'electronics',
    'celular': 'electronics',
    'computadora': 'electronics',
    'laptop': 'electronics',
    'tv': 'electronics',
    'television': 'electronics',
    'audifonos': 'electronics',
  };

  @override
  Future<List<Product>> searchProductsByKeyword(String keyword) async {
    final cleanKeyword = _sanitizeText(keyword);
    
    // 1. Buscamos si la palabra clave coincide de forma directa o aproximada con un mapeo de categoría
    String? matchedCategory;
    for (var entry in _categoryTranslationMap.entries) {
      if (cleanKeyword.contains(entry.key) || entry.key.contains(cleanKeyword)) {
        matchedCategory = entry.value;
        break;
      }
    }

    try {
      List<Product> results = [];

      if (matchedCategory != null) {
        // Consultar productos únicamente de la categoría mapeada para optimizar ancho de banda
        final models = await remoteDataSource.fetchProductsByCategory(matchedCategory);
        results.addAll(models);
      } else {
        // En caso de que no haya coincidencia de categoría directa, descargamos el catálogo completo 
        // para realizar búsquedas textuales en el título/descripción
        final models = await remoteDataSource.fetchAllProducts();
        
        // Mapeamos los sinónimos comunes a español para aumentar la precisión de la búsqueda manual
        results = models.where((product) {
          final title = _sanitizeText(product.title);
          final desc = _sanitizeText(product.description);
          return title.contains(cleanKeyword) || desc.contains(cleanKeyword);
        }).toList();
      }

      return results;
    } catch (e) {
      // Re-lanzar excepciones de infraestructura para ser capturadas en presentación
      rethrow;
    }
  }

  /// Utilidad interna para normalizar cadenas de texto eliminando acentos,
  /// mayúsculas y espacios innecesarios facilitando la comparación léxica.
  String _sanitizeText(String text) {
    var withOutAccents = text.toLowerCase();
    withOutAccents = withOutAccents.replaceAll(RegExp(r'[áàäâ]'), 'a');
    withOutAccents = withOutAccents.replaceAll(RegExp(r'[éèëê]'), 'e');
    withOutAccents = withOutAccents.replaceAll(RegExp(r'[íìïî]'), 'i');
    withOutAccents = withOutAccents.replaceAll(RegExp(r'[óòöô]'), 'o');
    withOutAccents = withOutAccents.replaceAll(RegExp(r'[úùüû]'), 'u');
    withOutAccents = withOutAccents.replaceAll(RegExp(r'[ñ]'), 'n');
    return withOutAccents.trim();
  }
}