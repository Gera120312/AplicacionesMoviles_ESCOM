import SwiftUI

struct ContentView: View {
    @State private var currentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    @State private var entries: [URL] = []
    @State private var showingNewFile = false
    @State private var newFileName = ""

    var body: some View {
        NavigationStack {
            List(entries, id: \.self) { entry in
                Label(entry.lastPathComponent, systemImage: isDirectory(entry) ? "folder" : "doc.text")
                    .contentShape(Rectangle())
                    .onTapGesture { open(entry) }
                    .swipeActions {
                        Button(role: .destructive) { delete(entry) } label: { Label("Eliminar", systemImage: "trash") }
                    }
            }
            .navigationTitle("Archivos")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showingNewFile = true } label: { Image(systemName: "plus") }
                }
            }
            .searchable(text: .constant(""), prompt: "Buscar en esta carpeta")
            .refreshable { load() }
            .onAppear { load() }
            .alert("Nuevo archivo", isPresented: $showingNewFile) {
                TextField("Nombre", text: $newFileName)
                Button("Crear") { createFile() }
                Button("Cancelar", role: .cancel) {}
            }
        }
    }

    private func load() {
        entries = (try? FileManager.default.contentsOfDirectory(at: currentDirectory, includingPropertiesForKeys: [.isDirectoryKey])) ?? []
            .sorted { $0.lastPathComponent.localizedCaseInsensitiveCompare($1.lastPathComponent) == .orderedAscending }
    }

    private func isDirectory(_ url: URL) -> Bool {
        (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) ?? false
    }

    private func open(_ url: URL) {
        if isDirectory(url) { currentDirectory = url; load() }
    }

    private func createFile() {
        guard !newFileName.isEmpty else { return }
        let url = currentDirectory.appendingPathComponent(newFileName).appendingPathExtension("txt")
        try? Data().write(to: url)
        newFileName = ""
        load()
    }

    private func delete(_ url: URL) {
        try? FileManager.default.removeItem(at: url)
        load()
    }
}

#Preview { ContentView() }
