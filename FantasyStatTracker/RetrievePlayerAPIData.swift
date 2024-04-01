//
//  RetrievePlayerAPIData.swift
//  FantasyStatTracker
//
//  Created by NICHOLAS BOISCLAIR on 2024-03-28.
//Steps:
//1. Get Player Info from name (or get ID from name)
//2. Get Team ABR
//3. Get most recent game
//4. Find its gameid and retrive its boxscore
//5. Find player in box score and retrieve their stats
//https://api-web.nhle.com/v1/club-schedule/TOR/week/now
import Foundation
@Observable
class RetrievePlayerAPIData{
    private let listKey = "savedList"
    
    var playerList = [Player]()
    var testPlayer = Player(name: "Sidney Crosby",id:0,teamAbr: "PIT",headshot: "https://cdn.nhlpa.com/img/assets/players/headshots/450x450/55190.jpg",nextGameId: 1,pos:"F", goals:0,assists: 0,shots: 0)
    var teamList = [String]()
    func updatePlayerStats(player: Player,completion: @escaping (Player) -> Void){
        print("Updating \(player.name) stats")
        
        let apiUrl = URL(string: "https://api-web.nhle.com/v1/gamecenter/\(player.nextGameId)/boxscore")!
        let session = URLSession.shared
        let task = session.dataTask(with: apiUrl){ data, response,
            error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            // Check if response contains data
            guard let responseData = data else {
                print("Error: No data received")
                return
            }
            do{
                guard let json = try JSONSerialization.jsonObject(with: responseData,options:[] ) as? [String: Any], let playerStats = json["playerByGameStats"] as? [String: Any], let home = json["homeTeam"] as? [String: Any], let homeAbr = home["abbrev"], let away = json["awayTeam"] as? [String: Any], let awayAbr = away["abbrev"], let homeStats = playerStats["homeTeam"] as? [String: Any], let awayStats = playerStats["awayTeam"] as? [String: Any], let homeF = homeStats["forwards"] as? [[String: Any]], let awayF = awayStats["forwards"] as? [[String: Any]],  let homeD = homeStats["defense"] as? [[String: Any]], let awayD = awayStats["defense"] as? [[String: Any]] else{
                    print("Invalid JSON format, Game has not started!")
                    var modifiedPlayer = player
                    modifiedPlayer.goals = 0
                    modifiedPlayer.assists = 0
                    modifiedPlayer.shots = 0
                    completion(modifiedPlayer)
                    return
                }
                var modifiedPlayer = player
                if modifiedPlayer.pos == "F" {
                    print("Forward")
                    if modifiedPlayer.teamAbr == homeAbr as! String {
                        print("Home Forward")
                        for p in homeF {
                            if p["playerId"] as! Int == modifiedPlayer.id {
                                modifiedPlayer.goals = p["goals"] as! Int
                                modifiedPlayer.assists = p["assists"] as! Int
                                modifiedPlayer.shots = p["shots"] as! Int
                            }
                        }
                    }
                    else if modifiedPlayer.teamAbr == awayAbr as! String{
                        print("Away Forward")
                        for p in awayF {
                            if p["playerId"] as! Int == modifiedPlayer.id {
                                print("Found player, new stats: \(p["goals"]) \(p["assists"]) \(p["shots"])")
                                modifiedPlayer.goals = p["goals"] as! Int
                                modifiedPlayer.assists = p["assists"] as! Int
                                modifiedPlayer.shots = p["shots"] as! Int
                            }
                        }
                    }
                }
                else if modifiedPlayer.pos == "D" {
                    print("Defense")
                }
                else if modifiedPlayer.pos == "G" {
                    print("GOALIE")
                }
                completion(modifiedPlayer)
            }catch{
                print("Error parsing JSON: \(error)")
            }
            
            
        }
        
        task.resume()
        
    }
    func getTeamAbr(){
        let apiUrl =  URL(string: "https://api-web.nhle.com/v1/standings/now")!
        let session = URLSession.shared
        let task = session.dataTask(with: apiUrl){ [self] data,response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            // Check if response contains data
            guard let responseData = data else {
                print("Error: No data received")
                return
            }
            do{
                guard let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any],let standings = json["standings"] as? [[String:Any]] else {
                    print("Invalid JSON format")
                    return
                }
                for team in standings {
                    if let abr = team["teamAbbrev"] as? [String: String],
                       let teamAbr = abr["default"] {
                        teamList.append(teamAbr)
                    }
                }
                
            }catch{
                print("Error parsing JSON: \(error)")
            }
            
        }
        task.resume()
    }
    func addPlayer(playerName: String,teamAbr: String){
        let group = DispatchGroup()
        var playerId: Int?
        var playerHeadshot: String?
        var gameId: Int?
        var playerPos: String?
        group.enter()
        findPlayerId(playerName: playerName, teamAbr: teamAbr) { id, pos in
            playerId = id
            if pos == "C" || pos == "L" || pos == "R"{
                playerPos = "F"
            }
            else{
                playerPos = pos
            }
            
            group.leave()
        }
            
        group.notify(queue:.main){ [self] in
                guard let playerId = playerId else {
                    // Player ID not found or error occurred
                    print("Player ID not found")
                    return
                }
                group.enter()
                findPlayerHeadshot(playerId: playerId){ headshot in
                    playerHeadshot = headshot
                    group.leave()
                }
            group.notify(queue: .main){ [self] in
                guard let playerHeadshot = playerHeadshot else{
                    print("Error: Player Headshot URL not found")
                    return
                }
                group.enter()
                findPlayerMostRecentGame(teamAbr:teamAbr){ id in
                        gameId = id
                    group.leave()
                }
                group.notify(queue: .main){ [self] in
                    guard let gameId = gameId else{
                        print("Error: Game ID not found")
                        return
                    }
                    print("Player Id: \(playerId)")
                    print("Headshot URL: \(playerHeadshot)")
                    print("Game Id: \(gameId)")
                    var currentPlayer = Player(name: playerName, id: playerId, teamAbr: teamAbr, headshot: playerHeadshot,nextGameId: gameId,pos: playerPos ?? "",goals: 0, assists: 0,shots: 0)
                    idCount += 1
                    group.enter()
                    updatePlayerStats(player: currentPlayer){ newplayer in
                    currentPlayer = newplayer
                        group.leave()
                    }
                    group.notify(queue: .main){
                        
                        print(currentPlayer)
                        self.playerList.append(currentPlayer)
                        self.saveList()
                    }
                    
                }
                
                
            }
                
            }

        
        
    }
    func findPlayerMostRecentGame(teamAbr: String, completion: @escaping (Int?) -> Void){
        let apiUrl = URL(string: "https://api-web.nhle.com/v1/club-schedule/\(teamAbr)/week/now")!
        let session = URLSession.shared
        let task = session.dataTask(with: apiUrl){ data,response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            // Check if response contains data
            guard let responseData = data else {
                print("Error: No data received")
                return
            }
            do{
                guard let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any],let games = json["games"] as? [[String:Any]],let firstGame = games.first, let gameId = firstGame["id"] as? Int else {
                    print("Invalid JSON format")
                    completion(nil)
                    return
                }
                completion(gameId)
                
            }catch{
                print("Error parsing JSON: \(error)")
            }
            
        } 
        task.resume()
        
    }
    func findPlayerId(playerName: String, teamAbr: String,completion: @escaping (Int?,String?) -> Void){
        //Get Player Info
        //https://api.nhle.com/stats/rest/en/skater/summary?limit=-1&sort=teamAbbrevs&cayenneExp=seasonId=20232024
        let apiUrl = URL(string: "https://api.nhle.com/stats/rest/en/skater/summary?limit=-1&sort=teamAbbrevs&cayenneExp=seasonId=20232024")!
        let session = URLSession.shared
        let task = session.dataTask(with: apiUrl) { data, response, error in
            // Check for errors
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            // Check if response contains data
            guard let responseData = data else {
                print("Error: No data received")
                return
            }
            
            // Parse the response data
            do {
                // Parse the raw JSON data
                guard let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any],
                      let dataArray = json["data"] as? [[String: Any]] else {
                    print("Invalid JSON format")
                    return
                }

                // Print player statistics
                for playerData in dataArray {
                                if let fullname = playerData["skaterFullName"] as? String,
                                   let abr = playerData["teamAbbrevs"] as? String,
                                   let id = playerData["playerId"] as? Int,
                                   let pos = playerData["positionCode"] as? String{
                                    if playerName == fullname && teamAbr == abr {
                                        completion(id, pos) // Pass the player ID back to the caller
                                        return // Exit the function early
                                    }
                                }
                            }
                            completion(nil,nil) // Player ID not found
            } catch {
                print("Error parsing JSON: \(error)")
            }

        }
        task.resume()
        
        
    }
    func findPlayerHeadshot(playerId: Int,completion: @escaping (String?) -> Void){
        //Use ID to parse the data from the web request and get the headshot url
        let apiUrl = URL(string: "https://api-web.nhle.com/v1/player/\(playerId)/landing")!
        let session = URLSession.shared
        let task = session.dataTask(with: apiUrl) { data,response,error in
            // Check for errors
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            // Check if response contains data
            guard let responseData = data else {
                print("Error: No data received")
                return
            }
            do {
            // Parse the raw JSON data
            guard let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any]else {
                print("Invalid JSON format")
                return
            }
                if let headshot = json["headshot"] as? String {
                    completion(headshot)
                    return
                } else {
                    // The "headshot" key is not present in the JSON data or its value is nil
                    print("Headshot URL not found in JSON data")
                }

            // Print player statistics
//            for playerData in dataArray {
//                            if let fullname = playerData["skaterFullName"] as? String,
//                               let abr = playerData["teamAbbrevs"] as? String,
//                               let id = playerData["playerId"] as? Int {
//                                
//                            }
//                        }
                completion(nil)
        }catch {
            print("Error parsing JSON: \(error)")
        }
            
        }
        task.resume()
    }
    func saveList(){
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(playerList) {
                    UserDefaults.standard.set(encoded, forKey: listKey)
                }
    }
    func loadList() -> [Player] {
            if let savedList = UserDefaults.standard.object(forKey: listKey) as? Data {
                let decoder = JSONDecoder()
                if let loadedList = try? decoder.decode([Player].self, from: savedList) {
                    return loadedList
                }
            }
            // Return an empty list if no saved list is found
            return []
        }
    func resetList(){
        playerList = [Player]()
        saveList()
    }
//    func getPlayerId(playerName: String) -> Int{
//        
//    }
}






