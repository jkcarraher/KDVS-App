//
//  ShowDTO.swift
//  KDVS
//
//  Created by John Carraher on 6/6/26.
//

struct ShowDTO: Decodable {
    let id: String
    let name: String
    let category: String
    let image_url: String
    let created_at: String
    let updated_at: String
}
