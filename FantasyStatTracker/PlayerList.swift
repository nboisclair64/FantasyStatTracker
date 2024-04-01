//
//  PlayerList.swift
//  FantasyStatTracker
//
//  Created by NICHOLAS BOISCLAIR on 2024-03-28.
//

import SwiftUI

struct PlayerList: View {
    @Environment(RetrievePlayerAPIData.self) var apiData
    @Binding var isViewingPlayer: Bool
    var body: some View {
        NavigationSplitView {
            List{
                ForEach(apiData.playerList){
                    player in
                    NavigationLink{ PlayerView(player: player,isViewingPlayer: $isViewingPlayer)}
                                   label: {
                        PlayerRow(player: player)
                    }
                }
            }.listStyle(PlainListStyle())
            .refreshable {
                print("Refreshed")
        }.navigationTitle("Players")
        } detail:{
            Text("Select a Player")
        }
    }
}

//#Preview {
//    PlayerList(isViewingPlayer: ).environment(RetrievePlayerAPIData())
//}
