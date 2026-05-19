import 'dart:math';
import 'package:flutter/material.dart';
//import '../../domain/entities/product.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/ichat_repository.dart';


/// Gestor de estado ligero basado en ChangeNotifier. Controla la lista
/// de mensajes, estados de carga y maneja la lógica de respuesta automática del bot.
class ChatNotifier extends ChangeNotifier {
  final IChatRepository chatRepository;

  final List<Message> _messages = [];
  bool _isLoading = false;
  
  // Nodo de foco para el input de texto del chat.
  final FocusNode inputFocusNode = FocusNode();

  ChatNotifier({required this.chatRepository}) {
    // Añadimos un mensaje de bienvenida de manera inicial
    _messages.add(
      Message.create(
        text: '¡Hola! Soy tu asistente de FakeStore 🛒🤖. Pregúntame sobre cualquier producto usando palabras como: "Ropa", "Joyas", "Tecnología", o "Zapatos". ¿En qué te puedo ayudar hoy?',
        sender: MessageSender.bot,
      ),
    );
  }

  List<Message> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;

  /// Procesa el mensaje enviado por el usuario y ejecuta la lógica del Chat Bot.
  Future<void> handleUserMessage(String text) async {
    if (text.trim().isEmpty) return;

    // 1. Agregar el mensaje del usuario a la lista inmediatamente
    final userMessage = Message.create(
      text: text.trim(),
      sender: MessageSender.user,
    );
    _messages.add(userMessage);
    _isLoading = true;
    notifyListeners();

    // Mantener explícitamente el foco del teclado después de enviar el mensaje
    inputFocusNode.requestFocus();

    // 2. Simular un delay de "escribiendo..." de 1 a 1.5 segundos para mejorar el UX
    await Future.delayed(Duration(milliseconds: 1000 + Random().nextInt(500)));

    try {
      // 3. Consultar productos mediante el repositorio de dominio
      final results = await chatRepository.searchProductsByKeyword(text);

      if (results.isEmpty) {
        _messages.add(
          Message.create(
            text: 'Lo siento, no pude encontrar ningún producto que coincida con tu búsqueda de "$text". Intenta con términos como "reloj", "camisa", "celular" o "abrigo".',
            sender: MessageSender.bot,
          ),
        );
      } else {
        // Seleccionamos un producto al azar de los resultados encontrados
        final randomProduct = results[Random().nextInt(results.length)];
        
        // Generamos la respuesta con los datos de dominio correspondientes
        _messages.add(
          Message.create(
            text: '¡Claro que sí! He encontrado un excelente producto para ti:\n\n*${randomProduct.title}*\n\n_Descripción:_ ${randomProduct.description}\n\n_Categoría:_ ${randomProduct.category}',
            sender: MessageSender.bot,
            imageUrl: randomProduct.image,
            productTitle: randomProduct.title,
            productPrice: '\$${randomProduct.price.toStringAsFixed(2)}',
          ),
        );
      }
    } catch (e) {
      // Capturamos cualquier falla del servidor de forma elegante en la UI
      _messages.add(
        Message.create(
          text: 'Oops! Ocurrió un problema de conexión al buscar tus productos. Por favor intenta de nuevo.',
          sender: MessageSender.bot,
        ),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
      // Volvemos a asegurar el foco
      inputFocusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    inputFocusNode.dispose();
    super.dispose();
  }
}