# Práctica 1: Model Context Protocol y acceso a archivos locales

## Datos de identificación

| Dato | Información |
| --- | --- |
| Nombre completo | **Gerardo Rendón Bibiano** |
| Número de boleta | **2022630011** |
| Grupo | **7CV4** |
| Fecha | 20 de septiembre de 2026 |

## Objetivo

Comprender cómo un modelo de lenguaje puede pasar de una interacción aislada en un navegador a trabajar con herramientas externas mediante el Model Context Protocol (MCP). En esta práctica se instaló y verificó un servidor MCP de sistema de archivos usando Roo Code dentro de Visual Studio Code.

El servidor permitió listar, leer, crear, modificar y buscar archivos dentro de un directorio controlado. También se comprobó que una petición hacia una ruta externa es rechazada por el límite de seguridad del servidor.

## Índice

- [Investigación](#investigación)
- [Implementación](#implementación)
- [Operaciones demostradas](#operaciones-demostradas)
- [Prueba del límite de seguridad](#prueba-del-límite-de-seguridad)
- [Evidencias](#evidencias)
- [Conclusiones](#conclusiones)
- [Referencias](#referencias)

## Investigación

La investigación completa se encuentra separada en los documentos solicitados:

1. [Evolución de los modelos](docs/1_evolucion.md)
2. [El problema del aislamiento](docs/2_aislamiento.md)
3. [MCP frente a una API tradicional](docs/3_mcp_vs_api.md)
4. [Arquitectura de MCP](docs/4_arquitectura.md)
5. [Servidor de sistema de archivos](docs/5_servidor_fs.md)
6. [Seguridad en MCP](docs/6_seguridad.md)
7. [Casos de uso](docs/7_casos_de_uso.md)

### Resumen: LM, LLM y razonamiento

Un modelo de lenguaje (LM) predice la continuación más probable de una secuencia de tokens. Un modelo de lenguaje grande (LLM) mantiene esta idea fundamental, pero utiliza muchos más parámetros, datos de entrenamiento y capacidad de cómputo. La evolución de LM a LLM permitió realizar tareas como traducción, resumen y generación de código.

El razonamiento explícito no aparece automáticamente por aumentar el tamaño del modelo. Depende de técnicas de entrenamiento, como aprendizaje por refuerzo, y de cómputo adicional durante la inferencia para analizar problemas de varios pasos antes de producir la respuesta.

### Resumen: aislamiento del modelo

Un LLM recibe texto y produce texto; por sí mismo no puede abrir, modificar o borrar archivos porque no ejecuta llamadas al sistema operativo. Además, los modelos comerciales suelen ejecutarse en servidores remotos que no tienen un canal directo hacia el disco local.

El aislamiento también es una medida de seguridad: evita modificaciones accidentales, limita el acceso a información privada y reduce el impacto de instrucciones maliciosas incluidas en archivos externos.

### MCP frente a una API

Una API es un contrato entre programas. En una integración tradicional, el desarrollador consulta la documentación, decide qué endpoint utilizar, construye la petición, agrega la autenticación y programa la interpretación de la respuesta. La decisión está escrita previamente en el código.

MCP es un protocolo abierto basado en JSON-RPC 2.0. Un servidor MCP publica un catálogo de capacidades con nombres de herramientas, descripciones y esquemas de parámetros. El cliente descubre ese catálogo y el modelo puede decidir en tiempo de ejecución qué herramienta invocar según la petición del usuario.

| Característica | API tradicional | MCP |
| --- | --- | --- |
| Quién decide qué se invoca | El desarrollador mediante código predefinido. | El modelo propone una herramienta según el catálogo y la petición. |
| Descubrimiento de capacidades | Manual: documentación, endpoints o archivos de definición. | Dinámico: el servidor publica tools, recursos y prompts. |
| Acoplamiento | Alto: el cliente conoce rutas, parámetros y respuestas concretas. | Menor: el cliente necesita implementar el protocolo y el servidor describe sus capacidades. |
| Mensajes | JSON, XML u otro formato definido por cada API. | JSON-RPC 2.0 con mensajes definidos por MCP. |
| Autenticación y consentimiento | Normalmente se programa con tokens, headers o API keys. | El cliente puede aplicar permisos y pedir aprobación humana antes de acciones sensibles. |
| Reutilización | Cada aplicación debe programar su integración. | Un servidor puede conectarse a distintos clientes compatibles. |
| Relación con APIs | Es la interfaz que se consume directamente. | Puede envolver APIs, bases de datos, sistemas de archivos u otros recursos. |

MCP no sustituye a las APIs ni las vuelve obsoletas. En muchos casos, un servidor MCP es una capa por encima de una API o recurso existente: lo describe de forma estandarizada para que un modelo pueda descubrirlo y utilizarlo.

## Implementación

### Cliente elegido

Se eligió **Roo Code dentro de Visual Studio Code** porque integra un cliente MCP en el entorno de desarrollo y permite revisar las herramientas publicadas por un servidor desde la interfaz de configuración. El host es VS Code/Roo Code, el cliente MCP es el componente interno de Roo Code y el servidor es el proceso Node.js del paquete filesystem.

### Entorno utilizado

- Sistema operativo: Windows.
- Visual Studio Code: `1.138.0`.
- Roo Code: `3.54.0`.
- Node.js: `v24.20.0`.
- npm: `11.19.0`.
- Paquete del servidor: `@modelcontextprotocol/server-filesystem`.
- Versión reportada por el servidor: `0.2.0`.
- Transporte: `stdio`.
- Especificación MCP consultada: `2024-11-05`.
- Fecha de consulta y ejecución: 20 de septiembre de 2026.

### Directorio de trabajo autorizado

Se creó y utilizó exclusivamente el directorio:

```text
C:\Users\gerar\Downloads\Repositorios\AplicacionesMoviles_ESCOM\Tarea1\entorno_mcp
```

No se autorizó la raíz del disco ni la carpeta completa del usuario.

### Instalación y configuración

1. Instalar Node.js y npm en Windows.
2. Instalar la extensión Roo Code en Visual Studio Code.
3. Crear el directorio `Tarea1/entorno_mcp`.
4. Abrir Roo Code y entrar a la configuración de **MCP Servers**.
5. Agregar el servidor filesystem con la siguiente configuración. El mismo contenido se conserva como referencia en [config/mcp_settings.json](config/mcp_settings.json).

```json
{
	"mcpServers": {
		"filesystem": {
			"command": "npx.cmd",
			"args": [
				"-y",
				"@modelcontextprotocol/server-filesystem",
				"C:/Users/gerar/Downloads/Repositorios/AplicacionesMoviles_ESCOM/Tarea1/entorno_mcp"
			],
			"disabled": false,
			"alwaysAllow": [],
			"disabledTools": []
		}
	}
}
```

6. Guardar la configuración y seleccionar **Refresh MCP Servers**.
7. Verificar que Roo Code muestre el servidor `filesystem` conectado y sus herramientas. En esta instalación se observaron 14 herramientas, entre ellas `read_text_file`, `write_file`, `edit_file`, `list_directory`, `move_file` y `search_files`.

El comando `npx.cmd` descarga o utiliza el paquete y ejecuta el servidor como proceso hijo. La comunicación MCP se realiza mediante entrada y salida estándar (`stdio`), sin abrir un puerto de red.

### Arquitectura y primitivas

El servidor puede publicar herramientas (acciones ejecutables), recursos (fuentes de información identificadas por URI) y plantillas de prompt (instrucciones parametrizadas). En la práctica se utilizaron principalmente herramientas de archivo.

El cliente también puede participar mediante primitivas como **roots**, que delimitan las rutas permitidas, y **elicitation/sampling**, que permiten solicitudes controladas al cliente para obtener información o apoyo del modelo. El transporte local utilizado fue `stdio`; para servidores remotos MCP también define **Streamable HTTP**.

## Operaciones demostradas

Las operaciones se ejecutaron dentro de `Tarea1/entorno_mcp`.

### 1. Listar el directorio autorizado

La primera consulta listó el contenido del directorio. Inicialmente la carpeta estaba vacía; después se agregaron los archivos utilizados en las pruebas.

### 2. Leer un archivo existente

Se leyó `a.txt`, cuyo contenido fue:

```text
Este es un archivo de prueba
```

### 3. Crear un archivo y escribir contenido

Se creó `nuevo.txt` con el siguiente contenido:

```text
Este archivo fue creado mediante una operación MCP.
Contenido de prueba para la práctica.
```

### 4. Modificar un archivo existente

Se agregó una línea al final de `nuevo.txt`:

```text
Esta línea fue agregada al modificar el archivo existente.
```

### 5. Buscar un archivo por contenido

Se buscó la frase `operación MCP` dentro del directorio autorizado. El servidor encontró la coincidencia en `nuevo.txt`.

## Prueba del límite de seguridad

Se solicitó leer `Tarea1/README.md`, que se encuentra fuera de `Tarea1/entorno_mcp`. El servidor rechazó la solicitud con el resultado:

```text
Access denied - path outside allowed directories:
C:\Users\gerar\Downloads\Repositorios\AplicacionesMoviles_ESCOM\Tarea1\README.md
not in
C:\Users\gerar\Downloads\Repositorios\AplicacionesMoviles_ESCOM\Tarea1\entorno_mcp
```

La operación fue bloqueada porque el servidor valida cada ruta contra la lista de directorios permitidos que recibe al iniciarse. Este mecanismo funciona como un sandbox: aunque el modelo solicite una ruta externa, el servidor no la procesa.

## Evidencias

Las capturas se encuentran en [`img/`](img/):

| Evidencia | Captura |
| --- | --- |
| Pantalla inicial de Roo Code | [191426](img/Captura%20de%20pantalla%202026-09-20%20191426.png) |
| Herramientas `read_file` y `read_text_file` | [191448](img/Captura%20de%20pantalla%202026-09-20%20191448.png) |
| Herramientas `read_media_file`, `read_multiple_files` y `write_file` | [191455](img/Captura%20de%20pantalla%202026-09-20%20191455.png) |
| Herramientas `edit_file` y `list_directory` | [191502](img/Captura%20de%20pantalla%202026-09-20%20191502.png) |
| Herramienta `search_files` y directorio permitido | [191516](img/Captura%20de%20pantalla%202026-09-20%20191516.png) |
| Configuración y actualización de servidores MCP | [192855](img/Captura%20de%20pantalla%202026-09-20%20192855.png) |
| Lectura de `a.txt` | [193113](img/Captura%20de%20pantalla%202026-09-20%20193113.png) |
| Creación y escritura de `nuevo.txt` | [193214](img/Captura%20de%20pantalla%202026-09-20%20193214.png) |
| Modificación de `nuevo.txt` | [193315](img/Captura%20de%20pantalla%202026-09-20%20193315.png) |
| Búsqueda por contenido | [193526](img/Captura%20de%20pantalla%202026-09-20%20193526.png) |
| Rechazo de acceso fuera del directorio | [image.png](img/image.png) |


## Seguridad

Los riesgos principales son la inyección de instrucciones escondidas en archivos, el acceso a rutas fuera del alcance, y la escritura o eliminación no deseada. Las mitigaciones usadas en esta práctica son:

- limitar el servidor a `entorno_mcp`;
- revisar las herramientas que expone el servidor;
- mantener vacías las listas `alwaysAllow` y `disabledTools` para conservar la aprobación interactiva del cliente;
- solicitar aprobación humana para operaciones que modifiquen archivos;
- no incluir credenciales, tokens o llaves en el repositorio;
- preferir un servidor de solo lectura cuando el flujo no necesite escritura.

## Casos de uso

Tres clientes o herramientas que implementan MCP son:

1. **Claude Desktop**, que conecta el modelo con servidores de archivos, bases de datos y repositorios mediante configuración JSON.
2. **Google Antigravity**, un entorno de desarrollo agéntico que puede coordinar tareas y herramientas durante el ciclo de desarrollo.
3. **Zed**, un editor que integra un asistente capaz de conectarse a servidores MCP y consultar fuentes de contexto locales o remotas.

En estos flujos el modelo no recibe necesariamente un archivo comprimido. El cliente le permite descubrir el árbol del repositorio, leer solo los archivos relevantes, proponer cambios y escribirlos mediante herramientas autorizadas. La persona conserva el control mediante permisos, confirmaciones y el alcance configurado.

## Conclusiones

MCP establece una forma común para conectar modelos con herramientas y fuentes de datos. La diferencia más importante frente a una API tradicional es el descubrimiento dinámico del catálogo y la posibilidad de que el modelo proponga la herramienta adecuada en tiempo de ejecución.

La práctica también mostró que el servidor filesystem no otorga acceso ilimitado al equipo. Solo habilita las operaciones que publica y dentro de las rutas autorizadas. El rechazo de `README.md` comprobó que el límite se aplica en el servidor y no depende únicamente de que el modelo siga instrucciones.

Finalmente, MCP no reemplaza las APIs: las complementa. Un servidor MCP puede envolver una API, base de datos o sistema de archivos para hacerlo descubrible por clientes compatibles, manteniendo mecanismos de consentimiento y control de alcance.

## Referencias

- Anthropic. (2024). *Model Context Protocol documentation*. https://modelcontextprotocol.io/
- Anthropic. (2024). *Model Context Protocol specification, version 2024-11-05*. https://spec.modelcontextprotocol.io/specification/2024-11-05/
- Model Context Protocol. (s. f.). *Filesystem server*. npm. https://www.npmjs.com/package/@modelcontextprotocol/server-filesystem
- Roo Code. (s. f.). *Roo Code documentation*. https://docs.roocode.com/
- Visual Studio Code. (s. f.). *Visual Studio Code documentation*. https://code.visualstudio.com/docs
