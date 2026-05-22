# FakeStore Chat Bot 🛒

Chatbot conversacional construido en Flutter con arquitectura **DDD (Domain-Driven Design)** que consume la [FakeStore API](https://fakestoreapi.com/) para recomendar productos al usuario de forma natural, sin que éste necesite conocer IDs, categorías ni nombres técnicos.

---

## Características

- Búsqueda de productos por palabras clave en **español** (`"ropa"`, `"joyas"`, `"tecnología"`)
- Mapeo semántico automático del español a las categorías de la API
- Imagen del producto diferente en cada interacción (sin repetir hasta agotar el catálogo)
- Indicador de escritura animado mientras el bot procesa
- UI de chat fluida con scroll automático y foco persistente en el input

---

## Arquitectura

El proyecto sigue una separación estricta en tres capas:

```bash
lib/
└── features/
    └── chat/
        ├── domain/
        │   ├── entities/
        │   │   ├── message.dart        # Entidad Message (id, text, sender, imageUrl…)
        │   │   └── product.dart        # Entidad Product (id, title, price, category…)
        │   └── repositories/
        │       └── ichat_repository.dart   # Contrato abstracto del repositorio
        │
        ├── infrastructure/
        │   ├── datasources/
        │   │   └── fakestore_remote_data_source.dart  # Llamadas HTTP a la API
        │   ├── models/
        │   │   └── product_model_dto.dart  # DTO con deserialización JSON
        │   └── repositories/
        │       └── chat_repository_implement.dart  # Implementación + mapeo ES→API
        │
        └── presentation/
            ├── screens/
            │   └── chat_screen.dart    # UI: burbujas, input, scroll
            └── state/
                └── chat_notifier.dart  # ChangeNotifier: lógica de estado del chat
```

### Flujo de una interacción

```
Usuario escribe → ChatNotifier → IChatRepository
                                       ↓
                              ChatRepositoryImpl
                              (mapeo ES → categoría)
                                       ↓
                         FakeStoreRemoteDataSource
                         (HTTP GET /products/category)
                                       ↓
                              Lista de productos
                                       ↓
                         _pickUniqueProduct()  ← excluye ya mostrados
                                       ↓
                         Mensaje con imagen del bot
```

---

## Selección de producto sin repetición

Cada `ChatNotifier` mantiene un `Set<int>` con los IDs de productos ya mostrados en la sesión. Al recibir resultados de la API:

1. Filtra los productos que el usuario **aún no ha visto**.
2. Si ya los vio todos (catálogo agotado para esa búsqueda), **reinicia solo ese subconjunto** y empieza un nuevo ciclo.
3. Registra el ID del producto elegido antes de mostrarlo.

El usuario nunca interactúa con IDs, nombres exactos ni categorías — la lógica es completamente transparente.

```dart
Product _pickUniqueProduct(List<Product> candidates) {
  final unseen = candidates.where((p) => !_shownProductIds.contains(p.id)).toList();
  final pool = unseen.isNotEmpty ? unseen : candidates;
  if (unseen.isEmpty) _shownProductIds.removeAll(candidates.map((p) => p.id));
  pool.shuffle(Random());
  final chosen = pool.first;
  _shownProductIds.add(chosen.id);
  return chosen;
}
```

---

## Dependencias

| Paquete | Versión | Uso |
|---|---|---|
| `http` | ^1.6.0 | Peticiones HTTP a FakeStore API |
| `uuid` | ^4.5.3 | Generación de IDs únicos para mensajes |
| `equatable` | ^2.0.8 | Comparación de entidades de dominio |
| `get_it` | ^9.2.1 | Inyección de dependencias |

---

## Primeros pasos

### Requisitos

- Flutter SDK `^3.11.1`
- Dart SDK `^3.11.1`
- Conexión a internet (consume API externa)

### Instalación

```bash
git clone <url-del-repositorio>
cd chat_fake_store_api
flutter pub get
flutter run
```

---

## Palabras clave reconocidas

El repositorio traduce automáticamente términos en español a las categorías de la API:

| Español | Categoría API |
|---|---|
| ropa, camisa, chaqueta, pantalón | `men's clothing` |
| vestido, falda, blusa | `women's clothing` |
| joyas, reloj, collar, aretes | `jewelery` |
| tecnología, celular, laptop, tv | `electronics` |

Si ninguna clave coincide, se descarga el catálogo completo y se filtra por título o descripción.

---

## API externa

[FakeStore API](https://fakestoreapi.com/) — API REST pública, sin autenticación, con 20 productos en 4 categorías. No requiere API key.

```
GET https://fakestoreapi.com/products
GET https://fakestoreapi.com/products/category/{category}
```