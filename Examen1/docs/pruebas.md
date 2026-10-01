# Matriz de pruebas del Examen 1

Esta matriz registra la evidencia disponible al 30 de septiembre de 2026. La versión base fue
la aplicación descargada desde Google Play Store y ejecutada en un OPPO Find X9 Pro. La versión
modificada fue el APK debug construido desde la rama `fix/story-attack-button-label` y probado
en el emulador indicado abajo. Un caso sin evidencia suficiente se conserva como pendiente y
no se presenta como aprobado.

## Objetivo del cambio

Corregir la indicación del HUD del modo historia/zombies. La versión base mostraba
`MODO: GOLPE (mantén Y)`, aunque B ejecuta el ataque y Y abre el menú combinado. La versión
corregida muestra `MODO: GOLPE (pulsa B para atacar)` y, en inglés,
`MODE: MELEE (press B to attack)`.

## Datos comunes del entorno

| Dato | Valor |
|---|---|
| SHA probado | `812a945a39f0317813ae05bd15ad47447d2acd90` |
| Sistema operativo | Windows 11 |
| Android Studio | 2026.1.3 |
| Gradle | 9.5.0 |
| Android Gradle Plugin | 9.3.0 |
| Kotlin | 2.3.21 |
| JDK | Amazon Corretto 25.0.4.1; daemon compatible con Java 21 |
| Android SDK | `C:\Users\gerar\AppData\Local\Android\Sdk` |
| Dispositivo de la versión base | OPPO Find X9 Pro; API no registrada |
| Dispositivo del cambio | `sdk_gphone16k_x86_64` (`emulator-5554`) |
| API / versión Android | API 37 / Android 17 |
| APK probado | `app-debug.apk` construido desde la rama |

## Casos manuales

| ID | Categoría | Criterio o riesgo cubierto | Precondiciones y pasos | Resultado esperado | Resultado registrado | Evidencia |
|---|---|---|---|---|---|---|
| QA-01 | Ruta feliz | El HUD identifica B como ataque | Abrir el modo historia, entrar a una zona de zombies, observar el HUD y pulsar B. | Aparece `MODO: GOLPE (pulsa B para atacar)` y B ejecuta el ataque. | **Aprobado.** La pulsación de B y la ejecución del ataque fueron confirmadas manualmente durante la prueba. La captura y el video sirven como evidencia de contexto, aunque no muestran de forma explícita el instante de la pulsación. | [Después, español](Screenshot_20260930_182406.png) · [video](Screen_recording_20260930_182438.webm) |
| QA-02 | Alterna / límite | Y conserva su función de menú | Mantener Y en una zona de zombies, observar el menú y soltar Y. | Y abre el menú combinado y no se presenta como botón de ataque. | **Parcial.** La captura demuestra el menú `MODO DE COMBATE` y el botón Y; falta registrar por escrito el resultado de mantener y soltar. | [Menú de combate](Screenshot_2026-09-30-18-34-25-04_6560e573e382345798fb6b82bbbca743.jpg) · [video](Screen_recording_20260930_182438.webm) |
| QA-03 | Regresión | Movimiento y combate no se rompen | Entrar a una zona jugable, mover al personaje y atacar con B. | Movimiento, ataque, HUD y objetivo cercano continúan funcionando. | **Aprobado.** Se ejecutó manualmente el recorrido de movimiento y combate; el cambio de texto no alteró el ataque ni el funcionamiento del HUD. La evidencia visual no permite identificar cada pulsación por separado. | [video](Screen_recording_20260930_182438.webm) |
| QA-04 | Navegación / estado | El flujo conserva navegación y estado | Entrar al flujo, usar Atrás, volver a entrar y recrear la actividad si aplica. | La pantalla vuelve a abrirse correctamente y el HUD conserva el estado esperado. | **Aprobado.** Se comprobó manualmente la salida con Atrás, el regreso al flujo y la conservación del estado esperado. La evidencia adjunta no muestra de forma explícita cada transición. | [video](Screen_recording_20260930_182438.webm) |
| QA-05 | Accesibilidad | El texto sigue siendo legible y usable | Activar texto ampliado y, si está disponible, recorrer el HUD con TalkBack. | El mensaje permanece legible y puede identificarse; las limitaciones quedan documentadas. | **Parcial.** Las capturas muestran legibilidad; no demuestran una ejecución con TalkBack. | [Después, español](Screenshot_20260930_182406.png) · [Después, inglés](Screenshot_20260930_183131.png) |
| QA-06 | Compatibilidad | La traducción funciona en inglés | Cambiar el idioma del dispositivo a inglés y repetir el recorrido. | Aparece `MODE: MELEE (press B to attack)` sin error de recursos. | **Aprobado visualmente.** La captura en inglés muestra exactamente la cadena corregida. | [Después, inglés](Screenshot_20260930_183131.png) |

### Evidencia de referencia y resultado

Las capturas JPG documentan la versión base, mientras que las PNG documentan la versión
corregida:

- [Estado anterior 1](Screenshot_2026-09-30-18-34-15-89_6560e573e382345798fb6b82bbbca743.jpg)
- [Estado anterior 2](Screenshot_2026-09-30-18-34-25-04_6560e573e382345798fb6b82bbbca743.jpg)
- [Estado corregido en español](Screenshot_20260930_182406.png)
- [Estado corregido en inglés](Screenshot_20260930_183131.png)
- [Video de la ejecución](Screen_recording_20260930_182438.webm)

## Riesgos

| Riesgo | Impacto | Casos que lo cubren | Mitigación o decisión |
|---|---|---|---|
| La corrección textual se contradice con el control real. | Alto | QA-01, QA-02 | Verificar B como ataque y Y como menú combinado. |
| El cambio rompe una función cercana de combate. | Alto | QA-03 | Repetir movimiento y ataque en una zona jugable. |
| El texto no es legible con fuente grande o TalkBack. | Medio | QA-05 | Probar texto ampliado y registrar TalkBack. |
| La traducción inglesa falta o produce un recurso inválido. | Medio | QA-06 | Repetir el flujo con el dispositivo en inglés. |
| La navegación pierde el estado del HUD. | Medio | QA-04 | Probar Atrás, regreso y recreación de actividad. |

## Verificaciones automáticas

Ejecutadas el 30 de septiembre de 2026 con el SHA
`812a945a39f0317813ae05bd15ad47447d2acd90`.

| Check | Estado | Cobertura | Limitaciones |
|---|---|---|---|
| `:app:assembleDebug` | **Aprobado** (`BUILD SUCCESSFUL`) | Compila el APK debug y valida recursos Android. | No prueba interacción manual. |
| `:app:testDebugUnitTest` | **Aprobado** | Ejecuta pruebas unitarias de `app`. | No prueba el dispositivo ni el HUD visual. |
| `:shared:testAndroidHostTest` | **Aprobado** | Ejecuta pruebas host de `shared`. | No prueba controles táctiles. |
| `tools/check_kmp_test_names.sh` | **Aprobado** | Comprueba nombres compatibles con Kotlin/Native. | No valida comportamiento. |
| Detekt 1.23.8 | **Aprobado** | Analiza las fuentes configuradas. | No sustituye QA manual. |

No existe todavía una URL de GitHub Actions porque el Draft PR aún no ha sido creado. Estas
verificaciones tampoco cubren por completo sprites, audio, TalkBack, navegación manual,
interacciones táctiles reales, rendimiento visual ni servicios externos.

## Registro detallado pendiente

Los casos QA-01, QA-03 y QA-04 fueron reproducidos manualmente. La ausencia de una imagen que
muestre cada pulsación o transición no significa que el caso no se haya ejecutado; por eso se
describe expresamente la confirmación manual y se conserva la limitación de la evidencia visual.
QA-02 y QA-05 permanecen parciales porque no se documentaron de forma completa el ciclo de Y ni
TalkBack.
