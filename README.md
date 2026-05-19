# chat_fake_store_api

## Arquitectura del proyecto:

````bash
lib/
├── core/                      # Utilidades, constantes y componentes compartidos
│   ├── theme/                 # Temas y estilos visuales de la aplicación
│   └── errors/                # Manejo global de excepciones y fallas (Failures)
└── features/
    └── chat/
        ├── domain/            # Capa de Dominio (lógica de negocio)
        │   ├── entities/      # Entidades del negocio (Message, Product, User)
        │   ├── value_objects/ # Objetos de valor inmutables (ej. SenderType)
        │   └── repositories/  # Contratos/Interfaces del Repositorio (IChatRepository)
        │
        ├── infrastructure/    # Capa de Infraestructura (Implementaciones tecnológicas)
        │   ├── datasources/   # Clientes HTTP / APIs externas (FakeStoreRemoteDataSource)
        │   ├── models/        # DTOs (Data Transfer Objects) para serialización JSON
        │   └── repositories/  # Implementación concreta del IChatRepository
        │
        └── presentation/      # Capa de Presentación (UI y Control de Estado)
            ├── state/         # Gestores de estado (Bloc / Cubit / ChangeNotifier)
            ├── screens/       # Pantallas principales (ChatScreen)
            └── widgets/       # Componentes visuales atómicos (ChatBubble, InputField)

```