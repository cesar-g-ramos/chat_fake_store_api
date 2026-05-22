import 'dart:math';
import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/ichat_repository.dart';


/// Gestor de estado ligero basado en ChangeNotifier. Controla la lista
/// de mensajes, estados de carga y maneja la lógica de respuesta automática del bot.
class ChatNotifier extends ChangeNotifier {
   final IChatRepository chatRepository;

  final List<Message> _messages = [];
  bool _isLoading = false;
  final FocusNode inputFocusNode = FocusNode();

  // ── NUEVO: registro de IDs ya mostrados ──────────────────────────────────
  final Set<int> _shownProductIds = {};
  // ─────────────────────────────────────────────────────────────────────────

  ChatNotifier({required this.chatRepository}) {
    _messages.add(
      Message.create(
        text: '¡Hola! Soy tu asistente de FakeStore 🛒🤖. Pregúntame sobre cualquier producto usando palabras como: "Ropa", "Joyas", "Tecnología", o "Zapatos". ¿En qué te puedo ayudar hoy?',
        sender: MessageSender.bot,
      ),
    );
  }

  List<Message> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;

  Future<void> handleUserMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = Message.create(
      text: text.trim(),
      sender: MessageSender.user,
    );
    _messages.add(userMessage);
    _isLoading = true;
    notifyListeners();

    inputFocusNode.requestFocus();
    await Future.delayed(Duration(milliseconds: 1000 + Random().nextInt(500)));

    try {
      final results = await chatRepository.searchProductsByKeyword(text);

      if (results.isEmpty) {
        _messages.add(
          Message.create(
            text: 'Lo siento, no pude encontrar ningún producto que coincida con tu búsqueda de "$text".',
            sender: MessageSender.bot,
          ),
        );
      } else {
        // ── NUEVO: selección con exclusión de ya mostrados ─────────────────
        final product = _pickUniqueProduct(results);
        // ──────────────────────────────────────────────────────────────────

        _messages.add(
          Message.create(
            text: '¡Claro que sí! He encontrado un excelente producto para ti:\n\n*${product.title}*\n\n_Descripción:_ ${product.description}\n\n_Categoría:_ ${product.category}',
            sender: MessageSender.bot,
            imageUrl: product.image,
            productTitle: product.title,
            productPrice: '\$${product.price.toStringAsFixed(2)}',
          ),
        );
      }
    } catch (e) {
      _messages.add(
        Message.create(
          text: 'Oops! Ocurrió un problema de conexión al buscar tus productos. Por favor intenta de nuevo.',
          sender: MessageSender.bot,
        ),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
      inputFocusNode.requestFocus();
    }
  }

  // ── NUEVO MÉTODO ──────────────────────────────────────────────────────────
  /// Devuelve un producto no visto aún. Si todos ya fueron mostrados,
  /// reinicia el historial y comienza un nuevo ciclo (nunca se queda sin productos).
  Product _pickUniqueProduct(List<Product> candidates) {
    // Filtramos los que el usuario NO ha visto todavía
    final unseen = candidates.where((p) => !_shownProductIds.contains(p.id)).toList();

    // Si ya vio todos los de esta búsqueda, reiniciamos solo los de esta lista
    final pool = unseen.isNotEmpty ? unseen : candidates;
    if (unseen.isEmpty) {
      _shownProductIds.removeAll(candidates.map((p) => p.id));
    }

    pool.shuffle(Random());
    final chosen = pool.first;
    _shownProductIds.add(chosen.id); // registramos como visto
    return chosen;
  }
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void dispose() {
    inputFocusNode.dispose();
    super.dispose();
  }
  
}