package mx.ipn.escom.gestor_archivos

import android.net.Uri
import androidx.documentfile.provider.DocumentFile
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

private const val FILE_CHANNEL = "mx.ipn.escom/authorized_documents"

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, FILE_CHANNEL)
            .setMethodCallHandler { call, result ->
                try {
                    when (call.method) {
                        "listDirectory" -> result.success(listDirectory(call.argument<String>("uri")))
                        "readBytes" -> result.success(readBytes(call.argument<String>("uri")))
                        "writeBytes" -> {
                            writeBytes(
                                required(call.argument<String>("destinationUri")),
                                required(call.argument<String>("name")),
                                call.argument<ByteArray>("bytes") ?: error("Faltan datos."),
                            )
                            result.success(null)
                        }
                        "createDirectory" -> {
                            val parent = document(call.argument<String>("uri"))
                            val name = required(call.argument<String>("name"))
                            check(parent.isDirectory) { "El destino no es una carpeta." }
                            check(parent.createDirectory(name) != null) {
                                "El proveedor no permite crear la carpeta."
                            }
                            result.success(null)
                        }
                        "copy" -> {
                            copyDocument(
                                required(call.argument<String>("sourceUri")),
                                required(call.argument<String>("destinationUri")),
                                required(call.argument<String>("name")),
                            )
                            result.success(null)
                        }
                        "move" -> {
                            moveDocument(
                                required(call.argument<String>("sourceUri")),
                                required(call.argument<String>("destinationUri")),
                                required(call.argument<String>("name")),
                            )
                            result.success(null)
                        }
                        "rename" -> {
                            val item = document(call.argument<String>("uri"))
                            check(item.renameTo(required(call.argument<String>("name")))) {
                                "El proveedor no permite renombrar el documento."
                            }
                            result.success(null)
                        }
                        "delete" -> {
                            check(document(call.argument<String>("uri")).delete()) {
                                "El proveedor no permite eliminar el documento."
                            }
                            result.success(null)
                        }
                        "isAccessible" -> result.success(
                            runCatching {
                                document(call.argument<String>("uri")).exists()
                            }.getOrDefault(false),
                        )
                        else -> result.notImplemented()
                    }
                } catch (error: Exception) {
                    result.error("AUTHORIZED_DOCUMENT_ERROR", error.message, null)
                }
            }
    }

    private fun required(value: String?): String =
        value ?: error("Falta un parámetro requerido.")

    private fun document(uri: String?): DocumentFile {
        val parsed = Uri.parse(required(uri))
        check(parsed.scheme == "content") { "URI externa no autorizada." }
        return DocumentFile.fromSingleUri(this, parsed)
            ?: error("No se pudo acceder al documento autorizado.")
    }

    private fun listDirectory(uri: String?): List<Map<String, Any?>> {
        val directory = document(uri)
        check(directory.isDirectory) { "El recurso no es una carpeta." }
        return directory.listFiles().map { item ->
            mapOf(
                "name" to (item.name ?: "Sin nombre"),
                "uri" to item.uri.toString(),
                "isDirectory" to item.isDirectory,
                "size" to if (item.isDirectory) null else item.length(),
                "modified" to if (item.lastModified() == 0L) null else item.lastModified(),
                "mimeType" to item.type,
            )
        }
    }

    private fun readBytes(uri: String?): ByteArray {
        val item = document(uri)
        check(item.isFile) { "El recurso no es un archivo." }
        return contentResolver.openInputStream(item.uri)?.use { it.readBytes() }
            ?: error("No se pudo abrir el documento.")
    }

    private fun writeBytes(destinationUri: String, name: String, bytes: ByteArray) {
        val destination = document(destinationUri)
        check(destination.isDirectory) { "El destino no es una carpeta." }
        check(destination.findFile(name) == null) { "Ya existe un elemento con ese nombre." }
        val target = destination.createFile("application/octet-stream", name)
            ?: error("El proveedor no permite crear el archivo.")
        contentResolver.openOutputStream(target.uri)?.use { output ->
            output.write(bytes)
        } ?: error("No se pudo abrir el destino.")
    }

    private fun copyDocument(sourceUri: String, destinationUri: String, name: String) {
        val source = document(sourceUri)
        val destination = document(destinationUri)
        check(destination.isDirectory) { "El destino no es una carpeta." }
        check(destination.findFile(name) == null) { "Ya existe un elemento con ese nombre." }
        copyRecursive(source, destination, name)
    }

    private fun copyRecursive(source: DocumentFile, destination: DocumentFile, name: String) {
        if (source.isDirectory) {
            val target = destination.createDirectory(name)
                ?: error("El proveedor no permite crear la carpeta.")
            source.listFiles().forEach { child ->
                copyRecursive(child, target, child.name ?: "Sin nombre")
            }
        } else {
            val target = destination.createFile(
                source.type ?: "application/octet-stream",
                name,
            ) ?: error("El proveedor no permite crear el archivo.")
            contentResolver.openInputStream(source.uri)?.use { input ->
                contentResolver.openOutputStream(target.uri)?.use { output ->
                    input.copyTo(output)
                } ?: error("No se pudo abrir el destino.")
            } ?: error("No se pudo abrir el origen.")
        }
    }

    private fun moveDocument(sourceUri: String, destinationUri: String, name: String) {
        val source = document(sourceUri)
        val destination = document(destinationUri)
        check(destination.findFile(name) == null) { "Ya existe un elemento con ese nombre." }
        copyRecursive(source, destination, name)
        check(source.delete()) { "El proveedor no permitió eliminar el origen." }
    }
}
