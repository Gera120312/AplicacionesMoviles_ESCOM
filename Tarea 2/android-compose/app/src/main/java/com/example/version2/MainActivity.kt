package com.example.version2

import android.app.DatePickerDialog
import android.app.TimePickerDialog
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Badge
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.Checkbox
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Divider
import androidx.compose.material3.FilterChip
import androidx.compose.material3.DropdownMenu
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ExtendedFloatingActionButton
import androidx.compose.material3.FloatingActionButton
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.Slider
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.ui.unit.dp
import androidx.compose.ui.res.painterResource
import kotlinx.coroutines.launch
import com.example.version2.ui.theme.Version2Theme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            Version2Theme {
                CatalogoApp()
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CatalogoApp() {
    val secciones = listOf("Entrada", "Acciones", "Selección", "Listas", "Información", "Estructura")
    var seleccion by remember { mutableIntStateOf(0) }
    var textoCompartido by remember { mutableStateOf("") }
    var elementos by remember { mutableStateOf((1..15).map { "Elemento de catálogo $it" }) }
    val snackbar = remember { SnackbarHostState() }
    val scope = rememberCoroutineScope()
    Scaffold(
        topBar = { TopAppBar(title = { Text("Catálogo UI · ${secciones[seleccion]}") }, actions = { IconButton({ scope.launch { snackbar.showSnackbar("Catálogo de componentes interactivos") } }) { Icon(Icons.Default.Info, "Información") } }) },
        snackbarHost = { SnackbarHost(snackbar) },
        bottomBar = { NavigationBar { secciones.forEachIndexed { index, nombre -> NavigationBarItem(selected = seleccion == index, onClick = { seleccion = index }, icon = { Icon(if (index == 0) Icons.Default.Home else Icons.Default.Info, nombre) }, label = { Text(nombre) }) } } },
        floatingActionButton = { if (seleccion == 1) { Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) { FloatingActionButton(onClick = { scope.launch { snackbar.showSnackbar("FAB pulsado") } }) { Icon(Icons.Default.Add, "Agregar") }; ExtendedFloatingActionButton(onClick = { scope.launch { snackbar.showSnackbar("Acción extendida ejecutada") } }, icon = { Icon(Icons.Default.Add, "Agregar") }, text = { Text("Nueva acción") }) } } }
    ) { padding ->
        LazyColumn(modifier = Modifier.padding(padding).padding(horizontal = 16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
            item { Spacer(Modifier.height(8.dp)); Text("Elementos básicos de interfaz", style = MaterialTheme.typography.headlineSmall); Text("Cada muestra es interactiva y documenta su propósito.") }
            item {
                when (seleccion) {
                    0 -> EntradaSection(onAdd = { textoCompartido = it })
                    1 -> AccionesSection { scope.launch { snackbar.showSnackbar("Respuesta visible: acción realizada") } }
                    2 -> SeleccionSection()
                    3 -> ListasSection(elementos, { elementos = elementos - it }, { elementos = (1..15).map { "Elemento de catálogo $it" } }, textoCompartido)
                    4 -> InformacionSection { scope.launch { snackbar.showSnackbar("Mensaje emergente con acción") } }
                    else -> EstructuraSection()
                }
            }
        }
    }
}

@Composable
fun DemoTitle(titulo: String, descripcion: String) { Card { Column(Modifier.padding(16.dp)) { Text(titulo, style = MaterialTheme.typography.titleMedium); Text(descripcion, style = MaterialTheme.typography.bodySmall); Spacer(Modifier.height(10.dp)) } } }

@Composable
fun EntradaSection(onAdd: (String) -> Unit) {
    var nombre by remember { mutableStateOf("") }; var buscar by remember { mutableStateOf("") }; var mostrar by remember { mutableStateOf(false) }; var error by remember { mutableStateOf(true) }; var opcion by remember { mutableStateOf(false) }
    Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
        DemoTitle("Campo de texto", "Captura información breve; la etiqueta mantiene claro el propósito del dato.")
        OutlinedTextField(nombre, { nombre = it; error = it.isBlank() }, label = { Text("Nombre para la lista") }, isError = error, supportingText = { if (error) Text("El nombre es obligatorio") }, modifier = Modifier.fillMaxWidth())
        OutlinedTextField("secreto", {}, label = { Text("Contraseña") }, visualTransformation = if (mostrar) androidx.compose.ui.text.input.VisualTransformation.None else androidx.compose.ui.text.input.PasswordVisualTransformation(), trailingIcon = { TextButton({ mostrar = !mostrar }) { Text(if (mostrar) "Ocultar" else "Mostrar") } }, modifier = Modifier.fillMaxWidth())
        OutlinedTextField("correo@ejemplo.com", {}, label = { Text("Correo electrónico") }, keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Email), modifier = Modifier.fillMaxWidth())
        OutlinedTextField("Texto multilínea", {}, label = { Text("Comentario") }, minLines = 3, modifier = Modifier.fillMaxWidth())
        OutlinedTextField(buscar, { buscar = it }, label = { Text("Buscar") }, leadingIcon = { Icon(Icons.Default.Search, "Buscar") }, modifier = Modifier.fillMaxWidth())
        Row(verticalAlignment = Alignment.CenterVertically) { Switch(opcion, { opcion = it }); Text("Sugerencias automáticas activas") }
        Button(onClick = { if (nombre.isNotBlank()) onAdd(nombre) }, enabled = nombre.isNotBlank()) { Text("Agregar a Listas") }
    }
}

@Composable
fun AccionesSection(onAction: () -> Unit) { Column(verticalArrangement = Arrangement.spacedBy(10.dp)) { DemoTitle("Botones y acciones", "Los botones comunican acciones primarias, secundarias y estados de carga."); Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) { Button(onAction) { Text("Relleno") }; OutlinedButton(onAction) { Text("Contorno") }; TextButton(onAction) { Text("Solo texto") } }; Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) { Button(onAction) { Icon(Icons.Default.Add, "Agregar"); Text(" Con ícono") }; IconButton(onAction) { Icon(Icons.Default.Delete, "Eliminar") }; Button({}, enabled = false) { Text("Deshabilitado") } }; LinearProgressIndicator(Modifier.fillMaxWidth()); Text("Estado de carga en progreso", style = MaterialTheme.typography.bodySmall) } }

@Composable
fun SeleccionSection() {
    var marcado by remember { mutableStateOf(false) }
    var interruptor by remember { mutableStateOf(true) }
    var valor by remember { mutableFloatStateOf(.4f) }
    var menu by remember { mutableStateOf(false) }
    var elegido by remember { mutableStateOf("Opción A") }
    var rango by remember { mutableStateOf(.2f..0.8f) }
    var chip by remember { mutableStateOf("Diseño") }
    val context = androidx.compose.ui.platform.LocalContext.current
    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
        DemoTitle("Elementos de selección", "Permiten elegir opciones, estados y ajustar valores.")
        Row(verticalAlignment = Alignment.CenterVertically) { Checkbox(marcado, { marcado = it }); Text(if (marcado) "Casilla marcada" else "Casilla sin marcar") }
        Row(verticalAlignment = Alignment.CenterVertically) { Switch(interruptor, { interruptor = it }); Text("Interruptor") }
        Text("Selector segmentado: Todos | Activos | Favoritos")
        Slider(valor, { valor = it })
        RangeSliderCompat(rango) { rango = it }
        Button({ menu = true }) { Text("Selección: $elegido") }
        DropdownMenu(menu, { menu = false }) { listOf("Opción A", "Opción B", "Opción C").forEach { option -> DropdownMenuItem({ Text(option) }, { elegido = option; menu = false }) } }
        Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) { listOf("Diseño", "Accesibilidad", "Android").forEach { option -> FilterChip(selected = chip == option, onClick = { chip = option }, label = { Text(option) }) } }
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            Button({ val now = java.util.Calendar.getInstance(); DatePickerDialog(context, { _, y, m, d -> }, now.get(java.util.Calendar.YEAR), now.get(java.util.Calendar.MONTH), now.get(java.util.Calendar.DAY_OF_MONTH)).show() }) { Text("Elegir fecha") }
            Button({ val now = java.util.Calendar.getInstance(); TimePickerDialog(context, { _, _, _ -> }, now.get(java.util.Calendar.HOUR_OF_DAY), now.get(java.util.Calendar.MINUTE), true).show() }) { Text("Elegir hora") }
        }
    }
}

@Composable
fun RangeSliderCompat(value: ClosedFloatingPointRange<Float>, onChange: (ClosedFloatingPointRange<Float>) -> Unit) { Text("Rango: ${"%.0f".format(value.start * 100)} - ${"%.0f".format(value.endInclusive * 100)}"); Slider(value.start, { onChange(it..value.endInclusive) }); Slider(value.endInclusive, { onChange(value.start..it) }) }

@Composable
fun ListasSection(elementos: List<String>, onDelete: (String) -> Unit, onRefresh: () -> Unit, compartido: String) { var detalle by remember { mutableStateOf<String?>(null) }; Column(verticalArrangement = Arrangement.spacedBy(10.dp)) { DemoTitle("Listas y colecciones", "Las colecciones organizan información; toca una fila para consultar su detalle."); if (compartido.isNotBlank()) Text("Nuevo desde Entrada: $compartido", color = MaterialTheme.colorScheme.primary); Button(onRefresh) { Text("Actualizar lista") }; elementos.take(15).forEach { fila -> Card(onClick = { detalle = fila }) { Row(Modifier.fillMaxWidth().padding(12.dp), horizontalArrangement = Arrangement.SpaceBetween) { Text(fila); IconButton({ onDelete(fila) }) { Icon(Icons.Default.Delete, "Deslizar para eliminar") } } } }; if (elementos.isEmpty()) Text("Estado vacío: no hay elementos", style = MaterialTheme.typography.titleMedium); Text("Cuadrícula:  A1   A2   B1   B2"); Text("Pestañas: Recientes | Favoritos | Archivados"); detalle?.let { AlertDialog(onDismissRequest = { detalle = null }, confirmButton = { TextButton({ detalle = null }) { Text("Cerrar") } }, title = { Text("Detalle") }, text = { Text("Información de $it") }) } } }

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun InformacionSection(onSnack: () -> Unit) {
    var dialogo by remember { mutableStateOf(false) }
    var hoja by remember { mutableStateOf(false) }
    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
        DemoTitle("Información y retroalimentación", "Los mensajes y estados ayudan a entender lo que ocurre después de una acción.")
        Text("Título grande", style = MaterialTheme.typography.headlineSmall)
        Text("Texto destacado", style = MaterialTheme.typography.titleMedium)
        Text("Texto secundario y descriptivo")
        Image(painterResource(android.R.drawable.ic_menu_gallery), "Imagen local de la aplicación")
        Text("Imagen remota: https://picsum.photos/200 (URL documentada)", color = MaterialTheme.colorScheme.primary)
        LinearProgressIndicator(.65f, Modifier.fillMaxWidth())
        CircularProgressIndicator()
        Button(onSnack) { Text("Mostrar snackbar") }
        Button({ dialogo = true }) { Text("Diálogo de confirmación") }
        Button({ hoja = true }) { Text("Abrir hoja inferior") }
        Row(verticalAlignment = Alignment.CenterVertically) { Text("Tarjeta con separador"); Badge { Text("3") } }
        Divider()
        if (dialogo) {
            AlertDialog(
                onDismissRequest = { dialogo = false },
                confirmButton = { Button({ dialogo = false }) { Text("Confirmar") } },
                dismissButton = { TextButton({ dialogo = false }) { Text("Cancelar") } },
                title = { Text("¿Confirmar acción?") },
                text = { Text("Esta demostración requiere una decisión.") }
            )
        }
        if (hoja) {
            androidx.compose.material3.ModalBottomSheet(onDismissRequest = { hoja = false }) { Text("Hoja inferior interactiva", Modifier.padding(24.dp)) }
        }
    }
}

@Composable
fun EstructuraSection() { Column(verticalArrangement = Arrangement.spacedBy(10.dp)) { DemoTitle("Contenedores y estructura", "La composición combina filas, columnas, superposición y navegación para construir pantallas claras."); Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceEvenly) { Text("Fila"); Text("Fila"); Text("Fila") }; Column(Modifier.fillMaxWidth()) { Text("Columna"); Text("Columna"); Text("Columna") }; Card { Text("Superposición: contenido principal + distintivo", Modifier.padding(16.dp)) }; Text("Contenedor con desplazamiento vertical: esta pantalla se desplaza."); Text("Barra superior: título y acción de información."); Text("Barra inferior: seis destinos del catálogo."); Text("Pesos proporcionales: 25% | 50% | 25%") } }