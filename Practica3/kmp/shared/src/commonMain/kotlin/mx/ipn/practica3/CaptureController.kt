package mx.ipn.practica3

import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

public enum class CaptureKind { PHOTO, AUDIO }

public data class CaptureItem(
    val id: String,
    val path: String,
    val kind: CaptureKind,
    val createdAtMillis: Long,
    val label: String = ""
)

public expect class PlatformCapture {
    public suspend fun requestPermissions(): Boolean
    public suspend fun capturePhoto(): CaptureItem
    public suspend fun startAudioRecording(): CaptureItem
    public suspend fun stopAudioRecording(): CaptureItem
}

public class CaptureController(private val platformCapture: PlatformCapture) {
    private val mutableItems = MutableStateFlow<List<CaptureItem>>(emptyList())
    public val items: StateFlow<List<CaptureItem>> = mutableItems.asStateFlow()

    public suspend fun requestPermissions(): Boolean = platformCapture.requestPermissions()

    public suspend fun capturePhoto(): CaptureItem = platformCapture.capturePhoto().also(::add)

    public suspend fun startAudioRecording(): CaptureItem = platformCapture.startAudioRecording().also(::add)

    public suspend fun stopAudioRecording(): CaptureItem = platformCapture.stopAudioRecording().also(::add)

    private fun add(item: CaptureItem) {
        mutableItems.value = listOf(item) + mutableItems.value
    }
}
