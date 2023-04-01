//
// Swiftfin is subject to the terms of the Mozilla Public
// License, v2.0. If a copy of the MPL was not distributed with this
// file, you can obtain one at https://mozilla.org/MPL/2.0/.
//
// Copyright (c) 2023 Jellyfin & Jellyfin Contributors
//

import Foundation
import Kanna

struct ContainerDocument {
    let opfPath: String

    let document: XMLDocument

    init?(url: URL) {
        do {
            // Just one line to get the DOM document of a XML file
            document = try Kanna.XML(url: url, encoding: .utf8)
            // Create namespace for the 'container' element
            let namespace = ["ctn": "urn:oasis:names:tc:opendocument:xmlns:container"]
            // Our first XPath query
            let xpath = "//ctn:rootfile[@full-path]/@full-path"
            // Execute the XPath query by 'at_xpath'
            guard let path = document.at_xpath(xpath, namespaces: XPath.container.namespace)?.text else { return nil }
            opfPath = path
        } catch {
            print("Parsing the XML file at \(url) failed with error: \(error)")
            return nil
        }
    }
}
