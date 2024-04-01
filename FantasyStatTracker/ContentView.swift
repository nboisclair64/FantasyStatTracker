//
//  ContentView.swift
//  FantasyStatTracker
//
//  Created by NICHOLAS BOISCLAIR on 2024-03-28.
//

import SwiftUI
var idCount = 1;

struct ContentView: View {
    @Environment(RetrievePlayerAPIData.self) var apiData
    @State private var playerName:String = ""
    @State private var teamAbr:String = "EDM"
    @State private var isViewingPlayer = false
    var body: some View {
        VStack {
            Spacer()
            PlayerList(isViewingPlayer: $isViewingPlayer)
            
            if !isViewingPlayer {
                HStack {
                    TextField(text: $playerName, prompt: Text("Player Name")) {
                            Text("Username")
                    }.frame(width:210).onSubmit {
                        apiData.addPlayer(playerName: playerName, teamAbr: teamAbr)
                        playerName = ""
                    }
                    Spacer()
                    Picker("Team", selection: $teamAbr) {
                        ForEach(apiData.teamList, id: \.self) { team in
                                            Text(team)
                                        }
                                    }
                                    .labelsHidden()
                                    .frame(width: 120) // Adjust the width as needed
                                    .clipped()
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.blue, lineWidth: 1)
                                    )
                    Button(action: {apiData.addPlayer(playerName: playerName, teamAbr: teamAbr); playerName=""}) {
                        Image(systemName: "plus.circle")
                }            }.padding()
            }
            if isViewingPlayer{
                Color.clear //Clears display
            }
            
                }
        .textFieldStyle(.roundedBorder).onAppear{
            isViewingPlayer = false
            apiData.getTeamAbr()
//            let calendar = Calendar.current
//            let currentDate = Date()
//            let currentHour = calendar.component(.hour, from: currentDate)
//            if currentHour >= 0 && currentHour < 12 {
//                print("Reset")
//                apiData.resetList()
//                
//            }
//            else{
//                print("No Reset")
//            }
            apiData.playerList = apiData.loadList()
        }
        }
    }

#Preview {
    ContentView().environment(RetrievePlayerAPIData())
}
