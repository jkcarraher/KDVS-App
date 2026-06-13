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
            return URL(string: "http://192.168.254.203:3000/v1")!
            #else
            return URL(string: "https://kdvs-api.jkcarraher.com/v1")!
            #endif
        }
    }
}

enum Stream {
    static let kdvsArchive = URL(string: "https://archives.kdvs.org/stream")!
}
