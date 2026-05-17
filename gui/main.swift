import SwiftUI

// MARK: - JSON Models
struct MenuItemData: Decodable, Identifiable {
    let name: String
    let des: String
    let action: String
    var id: String { name }
}

struct CategoryData: Decodable, Identifiable {
    let categoryId: String
    let categoryValues: [MenuItemData]
    var id: String { categoryId }
    enum CodingKeys: String, CodingKey {
        case categoryId = "category_id", categoryValues = "category_values"
    }
}

struct MenuJSON: Decodable { let catalog: [CategoryData] }

// MARK: - App
@main
struct QtoolApp: App {
    var body: some Scene {
        WindowGroup { ContentView().frame(minWidth: 900, minHeight: 500) }
    }
}

let categoryColors: [Color] = [.blue, .purple, .green, .cyan, .orange]

// MARK: - Content View
struct ContentView: View {
    @State private var categories: [CategoryData] = []
    @State private var basePath: String = ""
    @State private var binDir: String = ""
    @State private var errorMessage: String? = nil
    @State private var selectedKey: String? = nil

    var selectionBinding: Binding<String?> {
        Binding(
            get: { selectedKey },
            set: {
                selectedKey = $0
                if $0 != nil { openInTerminal() }
            }
        )
    }

    var body: some View {
        NavigationSplitView {
            List(selection: selectionBinding) {
                ForEach(Array(categories.enumerated()), id: \.element.id) { cIdx, cat in
                    Section {
                        ForEach(Array(cat.categoryValues.enumerated()), id: \.element.id) { iIdx, item in
                            HStack(spacing: 6) {
                                Text("\(cIdx + 1).\(iIdx + 1)")
                                    .font(.body.monospaced())
                                    .foregroundStyle(categoryColors[cIdx % categoryColors.count])
                                Text(item.name).font(.body.monospaced())
                            }
                        }
                    } header: {
                        Label(cat.categoryId, systemImage: "folder").font(.headline)
                    }
                }
            }
            .listStyle(.sidebar)
            .navigationSplitViewColumnWidth(min: 300, ideal: 350)
        } detail: {
            if let err = errorMessage {
                ScrollView { Text(err).foregroundStyle(.red).padding() }
            } else if let key = selectedKey, let (item, cIdx, iIdx) = findItem(key) {
                VStack(spacing: 12) {
                    ContentUnavailableView(
                        "已在终端打开",
                        systemImage: "terminal",
                        description: Text("请切换到终端窗口操作\n\n\(cIdx + 1).\(iIdx + 1) \(item.des)")
                    )
                }
            } else {
                ContentUnavailableView(
                    "选择菜单项",
                    systemImage: "arrow.left",
                    description: Text("点击左侧菜单项，自动在终端中执行")
                )
            }
        }
        .onAppear(perform: loadConfig)
    }

    func findItem(_ key: String) -> (MenuItemData, Int, Int)? {
        for (cIdx, cat) in categories.enumerated() {
            for (iIdx, item) in cat.categoryValues.enumerated() {
                if item.id == key { return (item, cIdx, iIdx) }
            }
        }
        return nil
    }

    func loadConfig() {
        let arg0 = CommandLine.arguments[0]
        if arg0.hasPrefix("/") {
            binDir = (arg0 as NSString).deletingLastPathComponent
        } else {
            let cwd = FileManager.default.currentDirectoryPath
            let absPath = (cwd as NSString).appendingPathComponent(arg0)
            binDir = ((absPath as NSString).standardizingPath as NSString).deletingLastPathComponent
        }

        var searchDirs: [String] = [binDir, (binDir as NSString).deletingLastPathComponent]
        // Also check Homebrew qtool lib path
        if let brewPath = brewQtoolLibPath() { searchDirs.append(brewPath) }

        for dir in searchDirs {
            let jsonPath = (dir as NSString).appendingPathComponent("qtool_menu_public.json")
            if FileManager.default.fileExists(atPath: jsonPath) {
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: jsonPath))
                    categories = try JSONDecoder().decode(MenuJSON.self, from: data).catalog
                    basePath = dir
                    return
                } catch {
                    errorMessage = "❌ 加载失败: \(jsonPath)\n\n\(error)"
                    return
                }
            }
        }
        errorMessage = "❌ 找不到 qtool_menu_public.json"
    }

    func brewQtoolLibPath() -> String? {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/opt/homebrew/bin/brew")
        task.arguments = ["--prefix", "qtool"]
        let pipe = Pipe()
        task.standardOutput = pipe
        guard (try? task.run()) != nil else { return nil }
        task.waitUntilExit()
        guard task.terminationStatus == 0 else { return nil }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let prefix = String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines), !prefix.isEmpty else { return nil }
        return (prefix as NSString).appendingPathComponent("lib")
    }

    func findResource(_ name: String, near base: String) -> String? {
        let candidates = [
            (base as NSString).appendingPathComponent("gui/\(name)"),
            (base as NSString).appendingPathComponent(name),
            ((base as NSString).deletingLastPathComponent as NSString).appendingPathComponent("Resources/\(name)"),
        ]
        for p in candidates {
            if FileManager.default.fileExists(atPath: p) { return p }
        }
        return nil
    }

    func openInTerminal() {
        guard let key = selectedKey, let (item, _, _) = findItem(key) else { return }
        guard let wrapper = findResource("qtool_run_action.sh", near: basePath)
                ?? findResource("qtool_run_action.sh", near: binDir) else {
            errorMessage = "❌ 找不到 qtool_run_action.sh"
            return
        }

        let scriptContent = "clear\nsh \(wrapper) \"\(basePath)\" \"\(item.action)\"\n"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("qtool_run.command")
        try? scriptContent.write(to: tempURL, atomically: true, encoding: .utf8)
        try? FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: tempURL.path)
        NSWorkspace.shared.open(tempURL)

        DispatchQueue.main.async { selectedKey = nil }
    }

}

