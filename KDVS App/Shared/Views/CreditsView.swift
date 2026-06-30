//
//  CreditsView.swift
//  KDVS
//
//  Created by John Carraher on 8/6/23.
//

import Foundation
import SwiftUI

struct CreditView: View {
    
    var body: some View {
        VStack{
            Text("\(version())")
                .fontWeight(.bold)
                .environment(\.colorScheme, .dark)
                .foregroundColor(Color("ThirdText"))
            HStack (alignment: .center, spacing: 1){
                Text("Made by ") // Regular text
                    .fontWeight(.bold)
                    .environment(\.colorScheme, .dark)
                    .foregroundColor(Color("ThirdText"))
                
                // Link for John Carraher
                Link(destination: URL(string: "https://www.jkcarraher.com")!) {
                    Text("John Carraher")
                        .fontWeight(.bold)
                        .environment(\.colorScheme, .dark)

                }.foregroundColor(.white)
                Text(" for ") // Regular text
                    .fontWeight(.bold)
                    .environment(\.colorScheme, .dark)
                    .foregroundColor(Color("ThirdText"))
                // Link for KDVS
                Link(destination: URL(string: "https://kdvs.org")!) {
                    Text("KDVS")
                        .fontWeight(.bold)
                        .environment(\.colorScheme, .dark)
                }.foregroundColor(.white)
            }.frame(maxWidth: .infinity)
        }.frame(maxWidth: .infinity, maxHeight: 100)

    }
    
    func version() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        return "\(version) (\(build))"
    }
}
