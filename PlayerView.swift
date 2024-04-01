//
//  PlayerView.swift
//  FantasyStatTracker
//
//  Created by NICHOLAS BOISCLAIR on 2024-04-01.
//

import SwiftUI

struct PlayerView: View {
    var player: Player
    @Binding var isViewingPlayer: Bool
    var body: some View {
        ZStack {
            Color.white
            VStack{
                RemoteImageView(imageUrl: URL(string: player.headshot)!, placeholderImage: Image("mcdavid"))
                    .frame(width: 200, height: 200)
                Text("\(player.name)").font(.title).bold().padding(.bottom, 10)
                HStack {
                    Text("Current Game:").font(.title2)
                    Text("Goals")
                    Text("Shots")
                    Text("Assists")
                    Text("Points")
                }
                Spacer()
            }.onAppear{
                isViewingPlayer = true
            }.onDisappear{
                isViewingPlayer = false
        }
        }.opacity(isViewingPlayer ? 1: 0)
        
    }
    
}

//#Preview {
//    PlayerView(player: apiData.testPlayer, isViewingPlayer: <#Binding<Bool>#>)
//}
