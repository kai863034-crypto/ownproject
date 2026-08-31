import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var selectedFolder: URL?
    @State private var selectedFile: URL?
    @State private var status = "Choose an accessible folder to begin."
    @State private var showingFolderPicker = false
    @State private var showingFilePicker = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 18) {
                        VStack(spacing: 8) {
                            Image(systemName: "folder.badge.gearshape")
                                .font(.system(size: 52))
                                .foregroundStyle(.white)

                            Text("Free Fire File Manager")
                                .font(.title2.bold())
                                .foregroundStyle(.white)

                            Text("Accessible-folder file replacement tool")
                                .font(.subheadline)
                                .foregroundStyle(.gray)
                        }
                        .padding(.top, 28)

                        Card {
                            Label("Selected Folder", systemImage: "folder")
                                .foregroundStyle(.white)

                            Text(selectedFolder?.path ?? "No folder selected")
                                .font(.caption)
                                .foregroundStyle(.gray)
                                .lineLimit(3)

                            Button("Choose Folder") {
                                showingFolderPicker = true
                            }
                            .buttonStyle(.borderedProminent)
                        }

                        Card {
                            Label("Replacement File", systemImage: "doc")
                                .foregroundStyle(.white)

                            Text(selectedFile?.lastPathComponent ?? "No replacement file selected")
                                .font(.caption)
                                .foregroundStyle(.gray)

                            Button("Choose Replacement File") {
                                showingFilePicker = true
                            }
                            .buttonStyle(.bordered)
                        }

                        Button {
                            replaceFile()
                        } label: {
                            Label("Replace File", systemImage: "arrow.triangle.2.circlepath")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(selectedFolder == nil || selectedFile == nil)

                        Card {
                            Label("Status", systemImage: "info.circle")
                                .foregroundStyle(.white)
                            Text(status)
                                .font(.subheadline)
                                .foregroundStyle(.gray)
                        }

                        Text("This app only operates on folders the user explicitly grants access to through iOS Files. It does not bypass app sandbox protections.")
                            .font(.caption2)
                            .foregroundStyle(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
        }
        .fileImporter(
            isPresented: $showingFolderPicker,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                selectedFolder = urls.first
                status = "Folder selected."
            case .failure(let error):
                status = "Folder selection failed: \(error.localizedDescription)"
            }
        }
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.data],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                selectedFile = urls.first
                status = "Replacement file selected."
            case .failure(let error):
                status = "File selection failed: \(error.localizedDescription)"
            }
        }
    }

    private func replaceFile() {
        guard let folder = selectedFolder, let source = selectedFile else { return }

        let accessedFolder = folder.startAccessingSecurityScopedResource()
        let accessedSource = source.startAccessingSecurityScopedResource()
        defer {
            if accessedFolder { folder.stopAccessingSecurityScopedResource() }
            if accessedSource { source.stopAccessingSecurityScopedResource() }
        }

        let destination = folder.appendingPathComponent(source.lastPathComponent)
        let fm = FileManager.default

        do {
            if fm.fileExists(atPath: destination.path) {
                let backup = destination.appendingPathExtension("backup")
                if fm.fileExists(atPath: backup.path) {
                    try fm.removeItem(at: backup)
                }
                try fm.moveItem(at: destination, to: backup)
            }

            try fm.copyItem(at: source, to: destination)
            status = "✓ Replacement completed. A backup was created when an old file existed."
        } catch {
            status = "✗ Replacement failed: \(error.localizedDescription)"
        }
    }
}

struct Card<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(0.08))
        }
    }
}
