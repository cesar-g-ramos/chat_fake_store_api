/// Entidad pura del Dominio que representa un producto del catálogo de la tienda.
/// Es agnóstica de frameworks o formatos de serialización como JSON.
class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
  });
}