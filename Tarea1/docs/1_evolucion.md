# Evolución de los Modelos: De la predicción al razonamiento

## De LM a LLM: El impacto de la escala

Para entender cómo llegamos a la inteligencia artificial actual, primero hay que definir qué es un modelo de lenguaje (LM, por sus siglas en inglés). En su forma más básica, un LM es un sistema estadístico cuyo único objetivo es predecir cuál es la palabra (o token) que tiene mayor probabilidad de seguir en una secuencia de texto. Se podría comparar con la función de autocompletado del teclado de un celular: analiza lo que ya escribiste y adivina lo que sigue basándose en patrones.

La evolución hacia los Modelos de Lenguaje Grandes (LLM) no fue un cambio radical en la teoría base, sino un salto gigantesco en la escala. Las empresas comenzaron a aumentar drásticamente el número de parámetros (los "pesos" o conexiones internas de la red neuronal) y a entrenar estos modelos con terabytes de datos extraídos de internet. Al hacer esto, los investigadores notaron que la escala desataba "propiedades emergentes". De pronto, el modelo ya no solo completaba oraciones, sino que era capaz de traducir idiomas, escribir código fuente o resumir documentos, habilidades para las que no había sido programado directamente, sino que aprendió por la enorme cantidad de contexto que asimiló.

## El razonamiento explícito no es cuestión de tamaño

A pesar de lo sorprendentes que son los LLM tradicionales, tienen un límite claro: suelen fallar en problemas de lógica de varios pasos o matemáticas complejas porque intentan predecir la respuesta final casi de inmediato. Durante un tiempo se pensó que simplemente haciendo los modelos aún más grandes se volverían más inteligentes, pero la realidad demostró que el tamaño no es sinónimo de razonamiento.

Es un error común pensar que la capacidad de razonamiento aparece sola por poner más parámetros. Para que existan los modelos con razonamiento explícito, fue necesario cambiar el enfoque hacia dos factores fundamentales: las técnicas de entrenamiento y el cómputo en la fase de inferencia.

Por un lado, se aplican técnicas como el aprendizaje por refuerzo, donde se entrena al modelo no solo para predecir palabras, sino para que sea recompensado si llega a conclusiones lógicas válidas paso a paso. Por otro lado, y quizá la diferencia más importante, está el uso de cómputo adicional al momento de responder.

En lugar de generar la primera respuesta que estadísticamente suena bien, un modelo de razonamiento explícito se toma un tiempo antes de mostrar el resultado para generar una "cadena de pensamiento". En este proceso interno, el modelo plantea el problema, prueba diferentes rutas lógicas, detecta si se está equivocando en un paso, corrige su rumbo y, solo después de hacer todo ese trabajo de evaluación, entrega la respuesta final al usuario.