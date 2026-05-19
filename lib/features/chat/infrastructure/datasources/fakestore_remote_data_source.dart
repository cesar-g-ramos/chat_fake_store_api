import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model_dto.dart';


/// Origen de datos encargado exclusivamente de realizar la petición HTTP
/// sobre el endpoint remoto de la API fakestoreapi.com.
class FakeStoreRemoteDataSource {
  final http.Client client;

  FakeStoreRemoteDataSource({required this.client});

  /// Consulta la lista completa de productos desde el servidor remoto.
  Future<List<ProductModel>> fetchAllProducts() async {
    final url = Uri.parse('https://fakestoreapi.com/products');
    
    try {
      final response = await client.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> decodedJson = json.decode(response.body);
        return decodedJson
            .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Error al comunicarse con la API de FakeStore. Código: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Excepción de red al obtener productos: $e');
    }
  }

  /// Consulta productos filtrados por una categoría específica admitida por la API.
  Future<List<ProductModel>> fetchProductsByCategory(String category) async {
    final url = Uri.parse('https://fakestoreapi.com/products/category/$category');
    
    try {
      final response = await client.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> decodedJson = json.decode(response.body);
        return decodedJson
            .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Error al obtener productos de la categoría "$category".');
      }
    } catch (e) {
      throw Exception('Excepción de red al obtener categoría: $e');
    }
  }
}