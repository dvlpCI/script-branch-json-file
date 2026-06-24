import SwiftUI

// MARK: - JSON Models
struct MenuItemData: Decodable, Identifiable {
    let name: String
    let des: String
    let action: String
    let actionType: ActionType
    var id: String { name }

    enum ActionType { case command, execSourceFunAndArgs }

    enum CodingKeys: String, CodingKey {
        case name = "key"
        case des
        case command
        case execSourceFunAndArgs
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        name = try c.decode(String.self, forKey: .name)
        des = try c.decode(String.self, forKey: .des)
        if let val = try? c.decode(String.self, forKey: .execSourceFunAndArgs) {
            action = val
            actionType = .execSourceFunAndArgs
        } else {
            action = try c.decode(String.self, forKey: .command)
            actionType = .command
        }
    }
}

struct CategoryData: Decodable, Identifiable {
    let categoryId: String
    let categoryValues: [MenuItemData]
    var id: String { categoryId }
    enum CodingKeys: String, CodingKey {
        case categoryId = "type", categoryValues = "values"
    }
}

struct MenuSource: Identifiable {
    let id: String
    let displayName: String
    let jsonPath: String
    let categoryType: String
    var categories: [CategoryData]
}

struct MenuJSON: Decodable {
    struct DynamicCodingKeys: CodingKey {
        var stringValue: String
        var intValue: Int? { nil }
        init?(stringValue: String) { self.stringValue = stringValue }
        init?(intValue: Int) { return nil }
    }

    let categories: [CategoryData]

    static func decode(from data: Data, type: String?) throws -> MenuJSON {
        let decoder = JSONDecoder()
        let container = try decoder.decode(MenuJSONDecoderContainer.self, from: data)
        let keysToTry: [String]
        if let type = type { keysToTry = [type] }
        else { keysToTry = ["catalog", "custom"] }

        for key in keysToTry {
            if let k = DynamicCodingKeys(stringValue: key),
               let cats = container.dict[k.stringValue] {
                return MenuJSON(categories: cats)
            }
        }
        throw DecodingError.dataCorrupted(.init(
            codingPath: [], debugDescription: "未找到有效的分类 key（尝试: \(keysToTry.joined(separator: ", "))）"
        ))
    }
}

struct MenuJSONDecoderContainer: Decodable {
    let dict: [String: [CategoryData]]
    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        dict = try c.decode([String: [CategoryData]].self)
    }
}

// MARK: - App
@main
struct QtoolApp: App {
    var body: some Scene {
        WindowGroup { ContentView().frame(minWidth: 500, minHeight: 400) }
    }
}

// MARK: - Content View


struct ContentView: View {
    @State private var menuSources: [MenuSource] = []
    @State private var selectedSourceId: String = ""
    @State private var basePath: String = ""
    @State private var binDir: String = ""
    @State private var errorMessage: String? = nil
    @State private var searchText: String = ""
    @State private var selectedCategory: String? = nil
    @State private var executedAction: String? = nil

    var currentSource: MenuSource? {
        menuSources.first { $0.id == selectedSourceId }
    }

    var currentCategories: [CategoryData] {
        currentSource?.categories ?? []
    }

    var filteredCategories: [CategoryData] {
        if !searchText.isEmpty {
            return currentCategories.compactMap { cat in
                let filtered = cat.categoryValues.filter {
                    $0.name.localizedCaseInsensitiveContains(searchText) ||
                    $0.des.localizedCaseInsensitiveContains(searchText)
                }
                return filtered.isEmpty ? nil : CategoryData(categoryId: cat.categoryId, categoryValues: filtered)
            }
        }
        return currentCategories
    }

    var totalCount: Int {
        currentCategories.reduce(0) { $0 + $1.categoryValues.count }
    }

    var body: some View {
        VStack(spacing: 0) {
            if menuSources.count > 1 {
                HStack {
                    Picker("菜单源", selection: $selectedSourceId) {
                        ForEach(menuSources) { s in
                            Text(s.displayName).tag(s.id)
                        }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(nsColor: .controlBackgroundColor))
            }
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("搜索操作...", text: $searchText)
                    .textFieldStyle(.plain)
                if !basePath.isEmpty, let src = currentSource {
                    Button {
                        NSWorkspace.shared.open(URL(fileURLWithPath: src.jsonPath))
                    } label: {
                        Text(src.jsonPath)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                    .buttonStyle(.link)
                    .help("打开 JSON 文件")
                }
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
                        categories: currentCategories,
                        selectedCategory: $selectedCategory
                    )
                }
            }

            if let src = currentSource {
                Divider()
                HStack(spacing: 4) {
                    Text("📄")
                        .font(.caption2)
                    Text(src.jsonPath)
                        .font(.caption2)
                        .lineLimit(1)
                        .truncationMode(.middle)
                    Text("[\(src.categoryType)]")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                    Spacer()
                }
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 3)
                .background(Color(nsColor: .controlBackgroundColor))
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
        if item.actionType == .command {
            runCommand(item.action)
        } else {
            runQtoolAction(item.action)
        }
    }

    func loadConfig() {
        let args = CommandLine.arguments
        let resourcesDir: String

        // Determine resourcesDir from binary location
        let arg0 = args[0]
        if arg0.hasPrefix("/") {
            binDir = (arg0 as NSString).deletingLastPathComponent
        } else {
            let cwd = FileManager.default.currentDirectoryPath
            let absPath = (cwd as NSString).appendingPathComponent(arg0)
            binDir = ((absPath as NSString).standardizingPath as NSString).deletingLastPathComponent
        }
        resourcesDir = (binDir as NSString).deletingLastPathComponent + "/Resources"

        // Collect source configs: CLI args or Info.plist
        struct SourceDef {
            let file: String; let type: String; let name: String
        }
        var sourceConfigs: [SourceDef] = []

        if args.count >= 3 && (args.count % 2 == 1) {
            // CLI: ./Qtool <path1> <type1> [<path2> <type2> ...]
            for i in stride(from: 1, to: args.count, by: 2) {
                let f = args[i]; let t = args[i+1]
                sourceConfigs.append(SourceDef(file: f, type: t, name: (f as NSString).lastPathComponent))
            }
        } else if let dict = Bundle.main.infoDictionary,
                  let sources = dict["QBMenuSources"] as? [[String: String]] {
            for s in sources {
                if let file = s["file"], let type = s["type"] {
                    let name = s["name"] ?? (file as NSString).lastPathComponent
                    sourceConfigs.append(SourceDef(file: file, type: type, name: name))
                }
            }
        }

        if sourceConfigs.isEmpty {
            // Fallback: search standard locations for qtool_menu_public.json
            var searchDirs: [String] = [binDir, (binDir as NSString).deletingLastPathComponent, resourcesDir]
            if let brewPath = brewQtoolLibPath() { searchDirs.append(brewPath) }
            for dir in searchDirs {
                let p = (dir as NSString).appendingPathComponent("qtool_menu_public.json")
                if FileManager.default.fileExists(atPath: p) {
                    sourceConfigs.append(SourceDef(file: "qtool_menu_public.json", type: "catalog", name: "qtool_menu_public.json"))
                    break
                }
            }
            if sourceConfigs.isEmpty {
                sourceConfigs.append(SourceDef(file: "qtool_menu_public.json", type: "catalog", name: "qtool_menu_public.json"))
            }
        }

        var loaded: [MenuSource] = []
        for def in sourceConfigs {
            let filePath: String
            if def.file.hasPrefix("/") {
                filePath = def.file
            } else {
                let searchDirs = [resourcesDir, binDir, (binDir as NSString).deletingLastPathComponent]
                var found = ""
                for d in searchDirs {
                    let p = (d as NSString).appendingPathComponent(def.file)
                    if FileManager.default.fileExists(atPath: p) { found = p; break }
                }
                if found.isEmpty, let brew = brewQtoolLibPath() {
                    let p = (brew as NSString).appendingPathComponent(def.file)
                    if FileManager.default.fileExists(atPath: p) { found = p }
                }
                filePath = found
            }
            guard !filePath.isEmpty, let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else {
                continue
            }
            if let json = try? MenuJSON.decode(from: data, type: def.type) {
                loaded.append(MenuSource(
                    id: "\(def.file):\(def.type)",
                    displayName: def.name,
                    jsonPath: filePath,
                    categoryType: def.type,
                    categories: json.categories
                ))
            }
        }

        if loaded.isEmpty {
            errorMessage = "❌ 未加载到任何菜单源"
            return
        }

        menuSources = loaded
        selectedSourceId = loaded[0].id
        basePath = resourcesDir
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

    func runQtoolAction(_ action: String) {
        guard let wrapper = findResource("qtool_run_action.sh", near: basePath)
                ?? findResource("qtool_run_action.sh", near: binDir) else {
            errorMessage = "❌ 找不到 qtool_run_action.sh"
            return
        }

        // 脚本目录优先用 brew lib（已有的安装），让 qtool_run_action.sh 能找到对应脚本，且是库可正常执行
        let scriptDir = brewQtoolLibPath() ?? basePath
        let scriptContent = "clear\nsh \(wrapper) \"\(scriptDir)\" \"\(action)\"\n"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("qtool_run.command")
        try? scriptContent.write(to: tempURL, atomically: true, encoding: .utf8)
        try? FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: tempURL.path)
        NSWorkspace.shared.open(tempURL)
    }

    func runCommand(_ command: String) {
        let scriptContent = "clear\n\(command)\n"
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
