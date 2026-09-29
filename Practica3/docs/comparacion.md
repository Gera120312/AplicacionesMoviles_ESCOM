# Comparación: Flutter vs. Kotlin Multiplatform

| Criterio | Flutter | Kotlin Multiplatform |
| --- | --- | --- |
| Lenguaje | Dart | Kotlin y Swift para la interfaz nativa |
| Interfaz | Widgets Material/Cupertino | Compose Multiplatform o interfaz nativa |
| Código compartido | Alto, incluida la interfaz | Principalmente lógica y datos |
| APIs nativas | Plugins y platform channels | `expect/actual` e interoperabilidad nativa |
| Binario | Incluye el motor Flutter | Integra frameworks compartidos por plataforma |
| Curva de aprendizaje | Rápida si se conoce Dart | Menor para Android/Kotlin, mayor por la doble interfaz |
| Ecosistema | Amplio catálogo de paquetes | Ecosistema multiplataforma en crecimiento |
| Ajuste al gestor de archivos | Muy bueno para una interfaz común | Bueno si se prioriza una experiencia nativa |
| Ajuste a cámara/micrófono | Requiere plugins confiables | Acceso directo a APIs nativas |

## Conclusión

Flutter reduce el tiempo de construir una interfaz idéntica en Android e iOS. Kotlin Multiplatform conserva mejor las APIs nativas y permite compartir modelos, persistencia y casos de uso sin renunciar a la experiencia propia de cada plataforma. Para esta práctica se eligió Flutter para el gestor de archivos por su interfaz común y KMP para cámara/micrófono por el acceso directo a AVFoundation y CameraX.

## Referencias

- [Flutter documentation](https://docs.flutter.dev/).
- [Kotlin Multiplatform documentation](https://www.jetbrains.com/help/kotlin-multiplatform-dev/get-started.html).
