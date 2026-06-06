//
//  SeasonDTO.swift
//  KDVS
//
//  Created by John Carraher on 6/6/26.
//

struct SeasonDTO: Decodable {
    let id: String
    let name: String
    let start_date: String
    let end_date: String
    let is_auto_generated: Bool
    let created_at: String
    let updated_at: String
}
