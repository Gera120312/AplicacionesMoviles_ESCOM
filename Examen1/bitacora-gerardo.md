# Bitácora individual — Gerardo

## Identificación

- Repositorio del fork: `https://github.com/Gera120312/PolitecnicoOpenWorld`
- Repositorio destino del PR: `https://github.com/gabrielhuav/PolitecnicoOpenWorld`
- Issue: Pendiente de crear en el fork
- Rama: `fix/story-attack-button-label`
- SHA base: `7ed325393f82872c2be94ff2ada46948efa19152`
- SHA final probado: `812a945a39f0317813ae05bd15ad47447d2acd90`

## Registro de actividades

| Fecha | Actividad | Evidencia o enlace | Resultado |
|---|---|---|---|
| 2026-09-30 | Revisión de instrucciones y estructura de repositorios | [Índice](README.md) | Completado |
| 2026-09-30 | Sincronización con `upstream/main` | SHA `7ed325393f82872c2be94ff2ada46948efa19152` | Completado |
| 2026-09-30 | Reproducción de la versión base desde Google Play Store | OPPO Find X9 Pro; [capturas anteriores](docs/pruebas.md) | Se observó `MODO: GOLPE (mantén Y)` |
| 2026-09-30 | Creación de la rama de trabajo | `fix/story-attack-button-label` | Completado |
| 2026-09-30 | Implementación de la corrección | Commit `812a945a39f0317813ae05bd15ad47447d2acd90` | Completado |
| 2026-09-30 | Build, pruebas unitarias, host tests, nombres KMP y detekt | SHA `812a945a39f0317813ae05bd15ad47447d2acd90` | Aprobado |
| 2026-09-30 | Pruebas manuales QA-01, QA-03 y QA-04 | [Matriz QA](docs/pruebas.md) | B, combate, navegación y conservación de estado confirmados manualmente |
| Pendiente | Crear issue, publicar la rama y abrir Draft PR | Pendiente | Pendiente |
| Pendiente | Revisión de otro integrante y respuesta a comentarios | Pendiente | Pendiente |

## Contribución sustantiva

- Cambio implementado: corregir `mantén Y` por `pulsa B para atacar` y su traducción inglesa.
- Archivos modificados en el fork:
  - `PolitecnicoOpenWorld/app/src/main/res/values/strings.xml`
  - `PolitecnicoOpenWorld/app/src/main/res/values-en/strings.xml`
- Commit: `812a945a39f0317813ae05bd15ad47447d2acd90` —
  `fix: clarify story attack control`.
- Casos ejecutados: QA-01, QA-03 y QA-04 aprobados manualmente; QA-02 y QA-05 parciales; QA-06 aprobado visualmente.
- Revisión realizada a otro integrante: Pendiente de realizar.

## Evidencia manual

- [Estado anterior 1](docs/Screenshot_2026-09-30-18-34-15-89_6560e573e382345798fb6b82bbbca743.jpg)
- [Estado anterior 2](docs/Screenshot_2026-09-30-18-34-25-04_6560e573e382345798fb6b82bbbca743.jpg)
- [Estado corregido en español](docs/Screenshot_20260930_182406.png)
- [Estado corregido en inglés](docs/Screenshot_20260930_183131.png)
- [Video de la ejecución](docs/Screen_recording_20260930_182438.webm)

Las evidencias visuales confirman el cambio de `MODO: GOLPE (mantén Y)` a
`MODO: GOLPE (pulsa B para atacar)` y la traducción `MODE: MELEE (press B to attack)`.
La pulsación de B, el recorrido de combate, Atrás y la conservación del estado se confirmaron
manualmente. El video y las capturas no hacen visible de forma explícita cada pulsación o
transición, por lo que esa limitación queda registrada en la matriz. TalkBack no fue demostrado.

## Hallazgos

| Hallazgo | Pasos reproducibles | Estado | Evidencia o decisión |
|---|---|---|---|
| El HUD indicaba Y aunque el ataque se ejecuta con B. | Entrar a una zona de zombies en la versión base y observar el HUD. | Corregido | [Antes y después](docs/pruebas.md); commit `812a945a39f0317813ae05bd15ad47447d2acd90`. |

## Entorno

- Sistema operativo: Windows 11.
- Android Studio: 2026.1.3.
- Gradle: 9.5.0.
- Android Gradle Plugin: 9.3.0.
- Kotlin: 2.3.21.
- JDK: Amazon Corretto 25.0.4.1; daemon compatible con Java 21.
- Android SDK: `android-35`, `android-36` y `android-37.0`.
- Dispositivo del cambio: AVD `sdk_gphone16k_x86_64`, ID `emulator-5554`, Android 17/API 37.
- Dispositivo de la versión base: OPPO Find X9 Pro; API no registrada.

## Herramientas de IA

Se utilizó Copilot para analizar la estructura, localizar la cadena incorrecta, organizar la
matriz y revisar la documentación. La implementación y la evidencia deben ser explicables por
el estudiante.
