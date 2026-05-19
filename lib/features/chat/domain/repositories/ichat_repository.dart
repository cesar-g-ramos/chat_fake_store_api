import '../entities/product.dart';

/// Contrato abstracto que expone los comportamientos del dominio para interactuar
/// con los productos y simular la lógica de negocio del chat bot.
abstract class IChatRepository {
  /// Busca productos utilizando términos o palabras clave (generalmente en español).
  /// Retorna una lista filtrada de productos que coinciden con los criterios de búsqueda.
  Future<List<Product>> searchProductsByKeyword(String keyword);
}
