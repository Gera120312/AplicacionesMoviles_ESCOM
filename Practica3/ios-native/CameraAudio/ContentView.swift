import AVFoundation
import SwiftUI

@MainActor
final class CaptureViewModel: NSObject, ObservableObject {
    @Published var cameraAuthorized = false
    @Published var microphoneAuthorized = false
    @Published var isRecording = false
    private var recorder: AVAudioRecorder?

    func requestPermissions() async {
        cameraAuthorized = await AVCaptureDevice.requestAccess(for: .video)
        microphoneAuthorized = await AVCaptureDevice.requestAccess(for: .audio)
    }

    func startAudioRecording() {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("audio-\(Int(Date().timeIntervalSince1970)).m4a")
        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        recorder = try? AVAudioRecorder(url: url, settings: settings)
        recorder?.record()
        isRecording = recorder?.isRecording == true
    }

    func stopAudioRecording() {
        recorder?.stop()
        isRecording = false
    }
}

struct ContentView: View {
    @StateObject private var model = CaptureViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: "camera.metering.center.weighted")
                    .font(.system(size: 54))
                Text(model.cameraAuthorized ? "Camara autorizada" : "Camara pendiente")
                Text(model.microphoneAuthorized ? "Microfono autorizado" : "Microfono pendiente")
                Button("Solicitar permisos") { Task { await model.requestPermissions() } }
                Button(model.isRecording ? "Detener audio" : "Grabar audio") {
                    model.isRecording ? model.stopAudioRecording() : model.startAudioRecording()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!model.microphoneAuthorized)
            }
            .padding()
            .navigationTitle("Captura")
        }
    }
}

#Preview { ContentView() }
