import Dispatch
import Basic
import Commands
import Workspace
import PackageLoading
import PackageGraph
import PackageModel
import Build
import POSIX
import Utility

class ToolWorkspaceDelegate: WorkspaceDelegate {
    func fetchingMissingRepositories(_ urls: Set<String>) {
    }

    func fetching(repository: String) {
        print("Fetching \(repository)")
    }

    func cloning(repository: String) {
        print("Cloning \(repository)")
    }

    func checkingOut(repository: String, at reference: String) {
        // FIXME: This is temporary output similar to old one, we will need to figure
        // out better reporting text.
        print("Resolving \(repository) at \(reference)")
    }

    func removing(repository: String) {
        print("Removing \(repository)")
    }

    func warning(message: String) {
        print("warning: " + message)
    }
}

let toolchain = try! LanguageServerToolchain()

let path = AbsolutePath("/Users/ryan/Source/langserver-swift")
let buildPath = path.appending(component: ".build")
let edit = path.appending(component: "Packages")
let pins = path.appending(component: "Package.pins")

let manifestLoader = ManifestLoader(resources: toolchain)
let delegate = ToolWorkspaceDelegate()

let ws = try! Workspace(dataPath: buildPath, editablesPath: edit, pinsFile: pins, manifestLoader: manifestLoader, delegate: delegate)

let buildFlags = BuildFlags(xcc: nil, xswiftc: nil, xlinker: nil)

/// Build the package graph using swift-build-tool.
func build(graph: PackageGraph, includingTests: Bool, config: Build.Configuration) throws {
    let yaml = try describe(buildPath, config, graph, flags: buildFlags, toolchain: toolchain)
    dump(yaml)
    //    try Commands.build(yamlPath: yaml, target: includingTests ? "test" : nil)
}

do {
  ws.registerPackage(at: path)
  let pg = try ws.loadPackageGraph()
  dump(pg)
  try build(graph: pg, includingTests: false, config: .debug)
} catch ManifestParseError.invalidManifestFormat(let error) {
    print(error)
}
