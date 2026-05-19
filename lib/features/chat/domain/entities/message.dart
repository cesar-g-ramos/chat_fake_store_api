import 'package:uuid/uuid.dart';

/// Define quién envía el mensaje en el ecosistema del chat.
enum MessageSender {
  user,
  bot,
}

/// Entidad pura del Dominio que representa un mensaje individual dentro de la conversación.
class Message {
  final String id;
  final String text;
  final String? imageUrl;
  final MessageSender sender;
  final DateTime timestamp;
  final String? productTitle;
  final String? productPrice;

  Message({
    required this.id,
    required this.text,
    this.imageUrl,
    required this.sender,
    required this.timestamp,
    this.productTitle,
    this.productPrice,
  });

  /// Factory helper para instanciar un mensaje nuevo asegurando la generación del ID único.
  factory Message.create({
    required String text,
    required MessageSender sender,
    String? imageUrl,
    String? productTitle,
    String? productPrice,
  }) {
    return Message(
      id: const Uuid().v4(),
      text: text,
      imageUrl: imageUrl,
      sender: sender,
      timestamp: DateTime.now(),
      productTitle: productTitle,
      productPrice: productPrice,
    );
  }
}