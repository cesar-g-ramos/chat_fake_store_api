import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Importaciones de las capas DDD de la aplicación
import 'features/chat/infrastructure/datasources/fakestore_remote_data_source.dart';
import 'features/chat/infrastructure/repositories/chat_repository_implement.dart';
import 'features/chat/presentation/screens/chat_screen.dart';
import 'features/chat/presentation/state/chat_notifier.dart';
void main() {
  // Aseguramos la correcta inicialización del Framework de Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Instanciamos los componentes de la capa de Infraestructura
  final httpClient = http.Client();
  final remoteDataSource = FakeStoreRemoteDataSource(client: httpClient);
  
  // 2. Acoplamos con la implementación del repositorio inyectando el datasource
  final chatRepository = ChatRepositoryImpl(remoteDataSource: remoteDataSource);

  // 3. Inicializamos el Notificador de la capa de presentación que gobierna el estado
  final chatNotifier = ChatNotifier(chatRepository: chatRepository);

  runApp(FakeStoreChatApp(chatNotifier: chatNotifier));
}

class FakeStoreChatApp extends StatelessWidget {
  final ChatNotifier chatNotifier;

  const FakeStoreChatApp({super.key, required this.chatNotifier});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FakeStore Bot - DDD',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.indigo,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          primary: Colors.indigo,
          secondary: Colors.pinkAccent,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 1,
        ),
      ),
      home: ChatScreen(notifier: chatNotifier),
    );
  }
}