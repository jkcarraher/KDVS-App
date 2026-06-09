//
//  config.swift
//  KDVS
//
//  Created by John Carraher on 6/9/26.
//

import Foundation

enum API {
    enum KDVS_App {
        static let v1 = URL(string: "https://kdvs-api.jkcarraher.com/v1")!
    }
}

enum Stream {
    static let kdvsArchive = URL(string: "https://archives.kdvs.org/stream")!
}
