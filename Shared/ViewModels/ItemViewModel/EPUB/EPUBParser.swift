//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2023 Jellyfin & Jellyfin Contributors
//

import ZIPFoundation
import Foundation

class EPUBParser {
    static func parseFile(at sourceURL: URL) -> EPUBBook? {
        // Get the ePub's filename
        let filename = sourceURL.deletingPathExtension().lastPathComponent
        // The directory to save the unzipped files
        let destinationURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true).appendingPathComponent(filename)
        // Get the file manager
        let fileManager = FileManager()
        // Check if already unzipped
        if fileManager.fileExists(atPath: destinationURL.path) == false {
            do {
                // Make sure the directory exists. if not, create one
                try fileManager.createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
                // Unzip the ePub file
                try fileManager.unzipItem(at: zipFileURL, to: destinationURL)
            } catch {
                print("Extraction of the ePub file failed with error: \(error)")
                return nil
            }
        }
        // Parse the ePub file
        return EPUBBook(contentsOf: destinationURL)
    }
}
