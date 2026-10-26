//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2023 Jellyfin & Jellyfin Contributors
//

import Foundation

class EPUBBook {
    let container: ContainerDocument
    
    init?(contentsOf baseURL: URL) {
        // Find the location of container.xml
        let containerURL = baseURL.appendingPathComponent("META-INF/container.xml")
        // Parse the container file
        guard let container = ContainerDocument(url: containerURL) else { return nil }
        self.container = container
        // Get the location of the OPF file
        let opfURL = baseURL.appendingPathComponent(container.opfPath)
    }
}
