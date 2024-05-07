import Foundation
import System


extension URL {
    init(relativePath: String) {
        var path = FilePath(FileManager.default.currentDirectoryPath)
        path.append(relativePath)
        self.init(filePath: path.string)
    }
}

