# MCP frente a una API Tradicional

Para comprender el impacto del Model Context Protocol (MCP), hay que entender la forma en que se comunican los sistemas de software.

## ¿Qué es una API tradicional?

Una API (Interfaz de Programación de Aplicaciones) es, en esencia, un contrato estricto entre dos programas. En el desarrollo tradicional con APIs, el proceso es completamente determinista y manual:
1. El programador, sabiendo las reglas de negocio que quiere implementar, analiza la información que le llega.
2. Con base en esa lectura, el desarrollador decide exactamente qué *endpoint* llamar para cumplir una función específica.
3. Se escribe el código fuente para armar la petición HTTP, inyectar las credenciales y capturar la respuesta.
4. Finalmente, se programa la lógica para interpretar la estructura del JSON devuelto.

En este paradigma, **la decisión de qué se llama, cuándo se llama y con qué parámetros se llama está escrita de antemano de forma rígida en el código fuente**. Si la API cambia o se agrega un endpoint nuevo, el cliente debe ser reprogramado.

## ¿Qué es el Model Context Protocol (MCP)?

El Model Context Protocol (MCP) no es una API, sino un **protocolo abierto y estandarizado basado en JSON-RPC 2.0** que resuelve el problema de conectar modelos de inteligencia artificial con fuentes de datos y herramientas externas de manera dinámica.

En lugar de requerir que un humano programe cada llamada, un servidor MCP funciona publicando un catálogo de sus capacidades. Este catálogo incluye el nombre de las herramientas disponibles, una descripción en lenguaje natural de para qué sirven y el esquema exacto de los parámetros que requieren. 

La diferencia fundamental ocurre en tiempo de ejecución: el modelo de lenguaje (el LLM) se conecta al servidor, lee este catálogo autodescriptivo, comprende qué herramientas existen y, dependiendo de lo que el usuario haya solicitado en su *prompt*, **el modelo decide de forma autónoma cuál herramienta invocar** y cómo estructurar los parámetros para usarla.

## Tabla Comparativa

| Característica | API Tradicional | Model Context Protocol (MCP) |
| :--- | :--- | :--- |
| **Quién decide qué se invoca** | El desarrollador humano. La decisión está fuertemente acoplada en el código fuente del cliente. | El Modelo de Lenguaje (LLM). Decide dinámicamente en tiempo de ejecución basándose en la petición del usuario. |
| **Descubrimiento de capacidades** | Manual y externo. El desarrollador lee documentación estática o archivos de definición. | Automático e integrado. El servidor expone un catálogo descriptivo y sus esquemas directamente al modelo. |
| **Nivel de acoplamiento cliente/servicio** | Alto. El cliente se debe programar específicamente para conocer las rutas, métodos y respuestas de cada API individual. | Bajo. El cliente (Host) es agnóstico a la lógica de negocio; solo necesita saber "hablar" el protocolo MCP estándar. |
| **Formato de los mensajes** | JSON o XML con estructuras arbitrarias definidas por el creador de la API. | Estandarizado bajo **JSON-RPC 2.0**, con tipos de mensajes estrictamente definidos por la especificación MCP. |
| **Manejo de autenticación y consentimiento** | Manejado programáticamente y en segundo plano (tokens, headers, API keys). No requiere confirmación por cada acción. | El protocolo delega el consentimiento al cliente, permitiendo implementar aprobaciones humanas antes de ejecutar herramientas destructivas. |
| **Reutilización entre aplicaciones** | Baja. Consumir una nueva API requiere escribir nuevo código de integración en cada aplicación cliente. | Alta. Un servidor MCP desarrollado una sola vez puede ser utilizado inmediatamente por cualquier cliente compatible. |

## Aclaración crítica: MCP no sustituye a las APIs

Es un error conceptual frecuente afirmar que MCP viene a reemplazar o a volver obsoletas a las APIs tradicionales. **MCP no sustituye a las APIs, las envuelve.**

Un servidor MCP rara vez implementa la lógica de negocio desde cero. En la inmensa mayoría de los casos, actúa como una capa de abstracción o intermediario por encima de una API REST existente, una base de datos o un recurso local. Su única función es traducir esa API tradicional a un formato estandarizado que un modelo de lenguaje pueda descubrir, entender y utilizar sin necesidad de que un desarrollador escriba código para cada integración.