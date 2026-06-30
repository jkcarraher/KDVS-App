//
//  config.swift
//  KDVS
//
//  Created by John Carraher on 6/9/26.
//

import Foundation

enum API {
    enum KDVS_App {
        static var v1: URL {
            #if DEBUG
            return URL(string: "http://localhost:3000/v1")!
            #else
            return URL(string: "https://kdvs-app.jkcarraher.com/api/v1")!
            #endif
        }
    }
}

enum Socket {
    static let server = URL(string: "https://kdvs-app.jkcarraher.com/")
}

enum Stream {
    static let kdvsArchive = URL(string: "https://archives.kdvs.org/stream")!
}
