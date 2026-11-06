# Formatos de guardado

## Esquema común

Todos los formatos representan el mismo `GameSnapshot` con `schemaVersion: 1`
y `app: ruta_de_sumas`. Los campos principales son `id`, `name`, `level`,
`round`, `totalRounds`, `score`, `elapsedSeconds`, `remainingSeconds`,
`status`, `createdAt`, `modifiedAt`, `hints`, `attempts`, `category`, `tags`,
`board`, `selectedPath`, `settings` y `moveHistory`.

El tablero incluye `size`, `target`, `solution` y `tiles`; cada casilla contiene
`index`, `value` y `blocked`. La configuración incluye `accent`, `brightness`,
`sounds` y `animations`.

## JSON

Se genera con `JsonEncoder.withIndent('  ')`:

```json
{
  "schemaVersion": 1,
  "app": "ruta_de_sumas",
  "id": "game-123",
  "name": "Partida de práctica",
  "level": "basic",
  "round": 1,
  "totalRounds": 5,
  "score": 0,
  "elapsedSeconds": 12,
  "remainingSeconds": 108,
  "status": "paused",
  "board": {
    "size": 4,
    "target": 10,
    "solution": [0, 1],
    "tiles": [{"index": 0, "value": 4, "blocked": false}]
  },
  "selectedPath": [0],
  "settings": {},
  "moveHistory": []
}
```

El ejemplo abreviado omite elementos del tablero por espacio; un archivo real
contiene todas las casillas y todos los campos obligatorios.

## XML

XML es un documento real con raíz `gameSave`, atributos `version` y `app`,
elementos anidados para `board`, `settings` y `moveHistory`, y elementos
`tile`, `index`, `tag` y `move`. El paquete `xml` realiza el escapado.

## TXT

TXT no es JSON renombrado. Usa el encabezado `RUTA_DE_SUMAS_SAVE`, pares
`CLAVE=VALOR` y secciones `[BOARD]`, `[SELECTED_PATH]`, `[SETTINGS]` y
`[MOVE_HISTORY]`. Los nombres y etiquetas se escapan con Base64 URL para
evitar ambigüedad con separadores, saltos de línea o símbolos.

```text
RUTA_DE_SUMAS_SAVE
VERSION=1
ID=game-123
NAME=UGFydGlkYSBkZSBwcsOhY3RpY2E=
LEVEL=basic
ROUND=1
TOTAL_ROUNDS=5
SCORE=0

[BOARD]
SIZE=4
TARGET=10
SOLUTION=0,1
TILES
0|4|false
1|6|false

[SELECTED_PATH]
0

[SETTINGS]
ACCENT=guinda
BRIGHTNESS=system
SOUNDS=true
ANIMATIONS=true

[MOVE_HISTORY]
select|0|0|
```

## Flujo y validación

```text
Estado del juego -> GameSnapshot -> serialización -> archivo
-> detección/deserialización -> GameSaveValidator -> GameController restaurado
```

Un archivo vacío, mal formado, con versión distinta, aplicación incorrecta,
tipos inválidos, índices fuera del tablero, solución bloqueada, objetivo
incorrecto o ruta no adyacente se rechaza con `FormatException`. Una partida
válida no se elimina porque otro archivo sea corrupto.

JSON es cómodo para interoperabilidad; XML es explícito y estructurado; TXT
es legible y sencillo de inspeccionar. JSON suele ser más compacto y fácil de
consumir, mientras que TXT requiere mantener reglas de escape y XML es más
verboso.
