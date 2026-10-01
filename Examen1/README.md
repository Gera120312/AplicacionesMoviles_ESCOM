# Examen 1 — Índice de entrega

**Proyecto:** [PolitecnicoOpenWorld](https://github.com/gabrielhuav/PolitecnicoOpenWorld)  
**Estudiante:** Gerardo Rendón Bibiano  
**Repositorio del fork:** `https://github.com/Gera120312/PolitecnicoOpenWorld`  
**Fecha de entrega:** 1 de octubre de 2026

> Este documento es el índice académico de la entrega. El código Android permanece en el
> repositorio del fork; aquí se conserva la planeación, la matriz QA y la bitácora.

## Objetivo y alcance

- **Problema actual:** En el HUD del modo historia/zombies se muestra `MODO: GOLPE (mantén Y)`,
  aunque el botón Y abre el menú combinado y el botón B ejecuta el ataque.
- **Comportamiento esperado:** El HUD debe mostrar `MODO: GOLPE (pulsa B para atacar)` en
  español y `MODE: MELEE (press B to attack)` en inglés.
- **Usuario afectado:** Personas que juegan el modo historia y necesitan identificar el control
  correcto para atacar.
- **Cambio elegido:** Corregir la indicación textual del botón de ataque en el HUD.
- **Archivos previstos:** `app/src/main/res/values/strings.xml` y
  `app/src/main/res/values-en/strings.xml`.
- **Fuera de alcance:** reescritura de arquitectura, migración de dependencias, servidor nuevo
  y cambios en pantallas no relacionados.

## Criterios de aceptación

1. **Éxito:** En el HUD del modo historia/zombies, el modo cuerpo a cuerpo muestra
   `pulsa B para atacar` y al pulsar B el ataque continúa funcionando.
2. **Alterno o límite:** Al cambiar al idioma inglés, el HUD muestra `press B to attack`;
   mantener Y continúa abriendo el menú combinado y no se presenta como el botón de ataque.

## Seguimiento

| Elemento | Valor |
|---|---|
| Issue del fork | No creada todavía; debe crearse antes de abrir el PR |
| Rama de trabajo | `fix/story-attack-button-label` |
| SHA base | `7ed325393f82872c2be94ff2ada46948efa19152` |
| Draft PR hacia `gabrielhuav/PolitecnicoOpenWorld` | No creado todavía |
| SHA final | `812a945a39f0317813ae05bd15ad47447d2acd90` |

## Evidencia y QA

- Matriz de pruebas: [`docs/pruebas.md`](docs/pruebas.md)
- Bitácora individual: [`bitacora-gerardo.md`](bitacora-gerardo.md)
- Evidencia visual:
  - Antes, español: [`Screenshot_2026-09-30-18-34-15-89...jpg`](docs/Screenshot_2026-09-30-18-34-15-89_6560e573e382345798fb6b82bbbca743.jpg)
  - Antes, español: [`Screenshot_2026-09-30-18-34-25-04...jpg`](docs/Screenshot_2026-09-30-18-34-25-04_6560e573e382345798fb6b82bbbca743.jpg)
  - Después, español: [`Screenshot_20260930_182406.png`](docs/Screenshot_20260930_182406.png)
  - Después, inglés: [`Screenshot_20260930_183131.png`](docs/Screenshot_20260930_183131.png)
  - Secuencia grabada: [`Screen_recording_20260930_182438.webm`](docs/Screen_recording_20260930_182438.webm)
- Logs relevantes: No se utilizaron logs en este caso.
- Checks locales: build, tests, nombres KMP y detekt aprobados en el SHA final
  `812a945a39f0317813ae05bd15ad47447d2acd90`.
- Entorno de pruebas del cambio: emulador `sdk_gphone16k_x86_64`, ID
  `emulator-5554`, Android 17/API 37.
- Versión base observada: aplicación descargada desde Google Play Store y ejecutada
  previamente en un OPPO Find X9 Pro. La API exacta del teléfono no fue registrada.

## Revisión y conclusión

- Revisor: No asignado todavía.
- Comentario técnico de revisión: Pendiente de revisión de otro integrante.
- Respuestas a comentarios: Pendiente de abrir el PR.
- Dictamen de calidad: Los checks automáticos pasan y las capturas confirman el cambio
  visual en español e inglés. QA-01, QA-03 y QA-04 también fueron confirmados manualmente,
  aunque el video no muestra de forma explícita cada pulsación o transición. QA-02 y QA-05
  permanecen parciales; todavía falta la revisión de otro integrante.

## Herramientas de IA

Se utilizó Copilot para entender las instrucciones, organizar la documentación y revisar la
estructura de entrega. La selección del cambio, la ejecución de las pruebas y la explicación de
la contribución deben poder ser defendidas por el estudiante.

## Orden de ejecución

1. Sincronizar el fork y registrar el SHA base. **Completado.**
2. Elegir y reproducir un cambio pequeño. **Completado.**
3. Crear issue y rama. **Rama completada; issue pendiente.**
4. Implementar y documentar. **Completado.**
5. Ejecutar build, pruebas, comprobación KMP y detekt. **Completado.**
6. Publicar la rama y abrir el Draft PR hacia el repositorio original. **Pendiente.**
7. Solicitar revisión, responder comentarios y repetir los casos afectados. **Pendiente.**
8. Completar esta documentación y entregar su enlace en Classroom. **Pendiente de enlaces finales.**
