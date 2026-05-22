//
//  LoadingPlayerView.swift
//  KDVS
//
//  Created by John Carraher on 5/10/26.
//

import SwiftUI

struct LoadingPlayerView : View {
    var body: some View {
        VStack {
            Rectangle()
                .fill(Color("DeadScreen"))
                .frame(width: 290, height: 290, alignment: .center)
                .cornerRadius(5)

            HStack (alignment: .top){
                VStack (alignment: .leading, spacing: 0) {
                    Rectangle().fill(Color("Loading"))
                        .frame(width: 230, height: 18)
                        .padding([.top], 3)
                    Rectangle().fill(Color("Loading"))
                        .frame(width: 100, height: 10)
                        .padding([.top], 7)

                
                }
                .frame(width: 230, alignment: .leading)
                .padding([.top, .trailing], 5)
                
                Button(action: {}, label: {
                    Image(systemName: "info.circle.fill")
                        .resizable()
                        .foregroundColor(Color("DisabledButton"))
                        .environment(\.colorScheme, .dark)
                        .background(Color.clear)
                        .frame(width: 20, height: 20)
                }).frame(width: 40, height: 40, alignment: .center)
                    .background(Color("NotiButtonColor"))
                    .cornerRadius(10)
                    .padding([.top], 7)
                    
            }
            .frame(width: 290, alignment: .leading)
            .padding([.leading], 15)
            
            
        }
        .frame(width: 310, height: 360, alignment: .top)
        .padding([.top], 10)
        .background(Color("BoxBlack"))
        .cornerRadius(10)
        .shadow(color: Color("InnerShadow"), radius: 1, x: 0, y: 2)
        
        
        //PAUSE PLAY BUTTONS
        ZStack {
            VStack{
                Button(action: {}, label: {
                    Image(systemName: "play.fill")
                        .resizable()
                        .foregroundColor(Color("DisabledButton"))
                        .environment(\.colorScheme, .dark)
                        .background(Color.clear)
                        .frame(width: 30, height: 30)
                        .padding(EdgeInsets(top: 0, leading: 22, bottom: 0, trailing: 0))
                }).frame(width: 70, height: 70, alignment: .leading)
                    .background(Color("BoxColor"))
                    .cornerRadius(35)
                    
            }.frame(width: 80, height: 80)
                .background(Color("ButtonBackground"))
                .cornerRadius(40)
        }.padding()
    }
}
