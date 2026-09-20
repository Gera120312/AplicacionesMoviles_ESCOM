# Arquitectura del Model Context Protocol (MCP)

La arquitectura de MCP está diseñada para ser modular, segura y altamente escalable, separando claramente las responsabilidades entre la interfaz que usa el humano, el modelo de inteligencia artificial y las fuentes de datos.

## El modelo de roles: Host, Cliente y Servidor

El ecosistema MCP opera bajo una topología donde intervienen tres roles fundamentales:

1. **Host:** Es la aplicación principal con la que interactúa el usuario final. Se encarga de gestionar la interfaz gráfica (UI), mantener la comunicación con el Modelo de Lenguaje (LLM) y administrar las conexiones con uno o varios servidores MCP.
2. **Cliente (Client):** Es un componente interno que vive dentro del Host. Su función es establecer y mantener una conexión 1:1 con un servidor MCP específico, traduciendo las intenciones del modelo al protocolo estándar.
3. **Servidor (Server):** Es un programa ligero e independiente que expone capacidades específicas, datos o herramientas. No tiene conexión directa con el LLM ni con el usuario; solo responde a las peticiones del Cliente usando el protocolo JSON-RPC.

**Aplicación en mi implementación:**
En el ejercicio práctico de esta actividad, el **Host** es la aplicación que elegimos utilizar (VS Code). El **Cliente** es el subsistema interno de esa aplicación que maneja las conexiones MCP. Finalmente, el **Servidor** es el proceso de Node.js o Python (`@modelcontextprotocol/server-filesystem`) que ejecutamos en nuestra máquina para exponer los archivos locales.

## Primitivas del lado del Servidor

Un servidor MCP puede exponer tres tipos de capacidades fundamentales (primitivas) para que el modelo las descubra:

* **Herramientas (Tools):** Son funciones ejecutables que el modelo puede invocar para realizar acciones con efectos secundarios en el mundo real. Ejemplos incluyen escribir en un archivo, consultar una API externa o ejecutar un script. El modelo recibe la lista de herramientas y decide de forma autónoma cuándo y cómo usarlas.
* **Recursos (Resources):** Son fuentes de datos (estáticas o dinámicas) que el servidor expone para que el modelo lea y obtenga contexto. Funcionan de manera similar a un sistema de archivos virtual y se identifican mediante URIs (por ejemplo, `file:///logs/app.log` o `postgres://database/schema`).
* **Plantillas de Prompt (Prompts):** Son instrucciones predefinidas y parametrizadas que el servidor ofrece para ayudar a los usuarios a estructurar mejores peticiones. Por ejemplo, un servidor de código podría exponer un prompt llamado `explicar_clase` que tome como parámetro el nombre de un archivo.

## Primitivas del lado del Cliente

El cliente no es solo un receptor pasivo; también expone primitivas hacia el servidor para garantizar la seguridad y ampliar las capacidades:

* **Roots (Raíces):** Son los límites o fronteras que el cliente define para indicar al servidor qué partes del sistema local están permitidas. Por ejemplo, el cliente puede pasar un *root* que limite al servidor a operar únicamente dentro de la carpeta `C:\Proyectos\TareaMCP`, impidiendo que acceda al resto del disco duro.
* **Elicitation / Sampling (Muestreo):** Es una capacidad avanzada donde la comunicación se invierte temporalmente. Permite que un servidor MCP solicite al cliente que invoque al LLM para generar texto en su nombre. Esto es útil si el servidor necesita capacidades de razonamiento de la IA para procesar un dato interno antes de devolver el resultado final de una herramienta.

## Transportes: Comunicación entre Cliente y Servidor

El protocolo MCP define dos mecanismos de transporte para intercambiar los mensajes JSON-RPC, dependiendo de dónde se encuentre alojado el servidor:

1. **`stdio` (Standard Input/Output):** Es el transporte utilizado para servidores locales. El Host (cliente) lanza el servidor como un proceso hijo dentro de la misma computadora. La comunicación se realiza de forma segura y directa a través de los flujos estándar de entrada (`stdin`) y salida (`stdout`) del sistema operativo, sin abrir puertos de red.
2. **Streamable HTTP (SSE):** Utilizado para conectar clientes con servidores remotos a través de internet o redes locales. Utiliza *Server-Sent Events (SSE)* para los mensajes que fluyen del servidor al cliente (manteniendo una conexión abierta) y peticiones *HTTP POST* estándar para los mensajes del cliente al servidor.

## Versión de la Especificación

La arquitectura, primitivas y definiciones de transporte documentadas en esta investigación están basadas en la versión **2024-11-05** de la especificación oficial del Model Context Protocol (MCP), la cual representa el estándar estable actual de lanzamiento.
