# El Servidor de Sistema de Archivos (Filesystem)

## "FS" no es el protocolo, es una implementación

Al estudiar el Model Context Protocol, es importante hacer una distinción fundamental: **el Sistema de Archivos (FS) no forma parte de la especificación del protocolo MCP**.

MCP es únicamente un estándar de comunicación (las reglas sobre cómo se envían y reciben los mensajes JSON-RPC). Por su parte, el servidor de "Filesystem" es simplemente uno de los servidores MCP de referencia creados por la comunidad para demostrar cómo funciona la tecnología. Así como existe un servidor FS, existen mas de otros servidores MCP diseñados para interactuar con bases de datos (PostgreSQL), plataformas en la nube (AWS), herramientas de comunicación (Slack) o repositorios (GitHub).

## Herramientas expuestas y delimitación de alcance

Cuando un cliente MCP se conecta al servidor de sistema de archivos, este último expone un catálogo de herramientas específicas que el modelo de lenguaje puede invocar para interactuar con el entorno local. Las principales herramientas que expone son:

* **Listar un directorio:** Permite al modelo ver qué archivos y carpetas existen en una ruta específica para entender la estructura del proyecto.
* **Leer archivos:** Permite extraer el contenido de texto de un archivo para que el modelo lo procese como contexto.
* **Crear y escribir archivos:** Permite al modelo generar nuevo código o texto y guardarlo directamente en el disco.
* **Mover archivos:** Útil para refactorizar proyectos o reorganizar carpetas.
* **Buscar archivos:** Permite realizar búsquedas por nombre o contenido dentro de un directorio.

Para que el servidor sepa dónde puede operar, su alcance se delimita estrictamente mediante la configuración inicial. Cuando el Host arranca el proceso del servidor FS, se le deben pasar como argumentos las rutas absolutas de los directorios permitidos (por ejemplo, `C:\Usuarios\Gerardo\Proyectos\Tarea1`). El servidor evaluará cada petición del modelo y rechazará cualquier intento de interactuar con una ruta que no esté explícitamente dentro de esos directorios autorizados.

## El límite de seguridad: ¿Por qué existe y qué pasaría sin él?

Este límite geográfico dentro del disco duro no es una simple sugerencia de diseño, es un mecanismo de seguridad crítico conocido como *sandboxing* o enjaulamiento.

Si el servidor de sistema de archivos no estuviera limitado y se ejecutara con acceso global a la raíz del disco duro (por ejemplo, `C:\` en Windows o `/` en Linux), las consecuencias de un error o un ataque serían muy grandes:

1. **Destrucción accidental:** Debido a la naturaleza probabilística de los LLM (alucinaciones), el modelo podría interpretar mal una instrucción de limpieza y terminar borrando archivos críticos del sistema operativo, dejando la computadora inutilizable.
2. **Filtración de datos:** Si un usuario pega en el chat un texto descargado de internet que contenga un ataque de *Prompt Injection*, el texto malicioso podría ordenarle al modelo buscar y leer archivos sensibles, como bases de datos de contraseñas, llaves privadas SSH, o tokens de sesión de navegadores, y enviarlos en su respuesta.
3. **Compromiso del sistema:** El modelo podría ser manipulado para escribir scripts maliciosos en las carpetas de inicio automático de Windows, instalando malware de forma persistente sin que el usuario se dé cuenta.

El límite de directorios permitidos garantiza que, incluso si el modelo falla o es engañado, el daño o la exposición de información quede confinado única y exclusivamente a la carpeta del proyecto en cuestión.
