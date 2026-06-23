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
        WindowGroup { ContentView().frame(minWidth: 500, minHeight: 400) }
    }
}

// MARK: - Content View
struct ContentView: View {
    @State private var categories: [CategoryData] = []
    @State private var basePath: String = ""
    @State private var binDir: String = ""
    @State private var errorMessage: String? = nil
    @State private var searchText: String = ""
    @State private var selectedCategory: String? = nil
    @State private var executedAction: String? = nil

    var filteredCategories: [CategoryData] {
        if !searchText.isEmpty {
            return categories.compactMap { cat in
                let filtered = cat.categoryValues.filter {
                    $0.name.localizedCaseInsensitiveContains(searchText) ||
                    $0.des.localizedCaseInsensitiveContains(searchText)
                }
                return filtered.isEmpty ? nil : CategoryData(categoryId: cat.categoryId, categoryValues: filtered)
            }
        }
        return categories
    }

    var totalCount: Int {
        categories.reduce(0) { $0 + $1.categoryValues.count }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("搜索操作...", text: $searchText)
                    .textFieldStyle(.plain)
            }
            .padding(10)
            .background(Color(nsColor: .controlBackgroundColor))

            if let err = errorMessage {
                ScrollView { Text(err).foregroundStyle(.red).padding() }
            } else {
                ZStack(alignment: .trailing) {
                    ScrollViewReader { proxy in
                        List {
                            ForEach(filteredCategories) { cat in
                                Section {
                                    ForEach(cat.categoryValues) { item in
                                        ActionRowView(
                                            item: item,
                                            isExecuted: executedAction == item.id,
                                            action: { execute(item) }
                                        )
                                    }
                                } header: {
                                    HStack(spacing: 4) {
                                        Text(cat.categoryId)
                                            .font(.caption)
                                            .foregroundStyle(selectedCategory == cat.categoryId ? Color.accentColor : .secondary)
                                            .fontWeight(selectedCategory == cat.categoryId ? .semibold : .regular)
                                        Text("(\(cat.categoryValues.count))")
                                            .font(.caption2)
                                            .foregroundStyle(.tertiary)
                                    }
                                }
                                .id(cat.id)
                            }
                        }
                        .listStyle(.sidebar)
                        .onChange(of: selectedCategory) { _, newValue in
                            if let id = newValue {
                                withAnimation { proxy.scrollTo(id, anchor: .top) }
                            }
                        }
                    }

                    CategoryIndexView(
                        categories: categories,
                        selectedCategory: $selectedCategory
                    )
                }
            }
        }
        .onAppear(perform: loadConfig)
    }

    func execute(_ item: MenuItemData) {
        withAnimation(.easeInOut(duration: 0.15)) {
            executedAction = item.id
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            executedAction = nil
        }
        openInTerminal(action: item.action)
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

    func openInTerminal(action: String) {
        guard let wrapper = findResource("qtool_run_action.sh", near: basePath)
                ?? findResource("qtool_run_action.sh", near: binDir) else {
            errorMessage = "❌ 找不到 qtool_run_action.sh"
            return
        }

        let scriptContent = "clear\nsh \(wrapper) \"\(basePath)\" \"\(action)\"\n"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("qtool_run.command")
        try? scriptContent.write(to: tempURL, atomically: true, encoding: .utf8)
        try? FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: tempURL.path)
        NSWorkspace.shared.open(tempURL)
    }

}

// MARK: - Action Row
struct ActionRowView: View {
    let item: MenuItemData
    let isExecuted: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(iconForAction(item.name))
                    .font(.body)
                Text(item.name)
                    .font(.body.monospaced().bold())
                    .lineLimit(1)
                Text("— \(item.des)")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Spacer()
                if isExecuted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Category Index
struct CategoryIndexView: View {
    let categories: [CategoryData]
    @Binding var selectedCategory: String?

    var body: some View {
        VStack(spacing: 0) {
            rowView(
                label: "全部",
                count: categories.reduce(0) { $0 + $1.categoryValues.count },
                isSelected: selectedCategory == nil
            )
            .onTapGesture { selectedCategory = nil }

            ForEach(categories) { cat in
                rowView(
                    label: cat.categoryId,
                    count: cat.categoryValues.count,
                    isSelected: selectedCategory == cat.categoryId
                )
                .onTapGesture { selectedCategory = cat.categoryId }
            }
        }
        .frame(width: 110)
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.trailing, 6)
    }

    func rowView(label: String, count: Int, isSelected: Bool) -> some View {
        HStack(spacing: 0) {
            Text(label)
                .font(.caption)
            Spacer()
            Text("\(count)")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .foregroundStyle(isSelected ? .white : .secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
        .frame(maxWidth: .infinity)
        .background(isSelected ? Color.accentColor : Color.clear)
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .contentShape(Rectangle())
    }
}

// MARK: - Icon Mapping
func iconForAction(_ name: String) -> String {
    switch name {
    case "docHome", "docVersionPlan", "docWorkPlan", "docTodoBug":
        return "📄"
    case "custom_website", "recommend_website":
        return "🌐"
    case "gitBranch", "goGitRefsRemotes":
        return "🌿"
    case "createJsonFile", "updateJsonFile", "noPackBranch":
        return "📋"
    case "gitCommitMessage":
        return "✏️"
    case "rebaseCheck", "rebaseHook":
        return "🔄"
    case "updatePageKey":
        return "📊"
    case "jenkins":
        return "📦"
    case "signApk":
        return "🔏"
    case "goPP":
        return "📱"
    case "uploadDSYM":
        return "📈"
    case "deal_custom_script":
        return "⚙️"
    default:
        return "⚡"
    }
}
