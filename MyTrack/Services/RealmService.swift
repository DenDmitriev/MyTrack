//
//  RealmService.swift
//  MyTrack
//
//  Created by Denis Dmitriev on 03.02.2023.
//

import Foundation
import RealmSwift

class RealmService {
    
    var realm = try? Realm()
    
    func getPathForDataFile() {
        let string = "Realm data base created on path - " + (realm?.configuration.fileURL?.absoluteString ?? "no realm file")
        print(string)
    }
    
    //MARK: - Tracks funcs
    
    func addTrack(startTime: Date, finishTime: Date, distance: Double, locations: [Location]) {
        guard let realm = realm else { return }
        
        do {
            let track = Track()
            track.startTime = startTime
            track.finishTime = finishTime
            track.distance = distance
            
            try realm.write {
                realm.add(track)
                realm.add(locations)
                
                locations.forEach { location in
                    location.track = track
                }
                
                track.locations.append(objectsIn: locations)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getTracks(sorting: Sorting) -> [Track]? {
        guard let realm = realm else { return nil }
        
        let tracks = realm.objects(Track.self)
        
        switch sorting {
        case .new:
            return tracks.sorted { $0.startTime > $1.startTime }
        case .old:
            return tracks.sorted { $0.startTime < $1.startTime }
        }
    }
    
    enum Sorting {
        case old, new
    }
    
    func getLocations(for track: Track) -> [Location]? {
        guard let realm = realm else { return nil }
        
        let locations = realm.objects(Location.self).where {
            $0.track == track
        }
        return locations.sorted { $0.timestamp < $1.timestamp }
        
    }
    
    func removeTrack(track: Track) {
        guard let realm = realm else { return }
        
        if let locations = getLocations(for: track) {
            do {
                try realm.write {
                    realm.delete(locations)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        
        do {
            try realm.write {
                realm.delete(track)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func removeAll() {
        guard let realm = realm else { return }
        
        do {
            try realm.write {
                realm.deleteAll()
            }
        } catch {
            print(error)
        }
    }
    
    //MARK: - User funcs
    
    struct Error: AppError {
        var title: String
        var description: String?
        
        init(title: String?, description: String? = nil) {
            self.title = title ?? "Unknown error"
            self.description = description
        }
        
        static let realmError = Error(title: "Realm context error")
        static let passwordIncorrect = Error(title: "Incorrect password")
        static let userNotFound = Error(title: "User is not find")
    }
    
    func addUser(login: String, password: String, age: Int? = nil, gender: Bool? = nil, completion: @escaping ((User?, Error?) -> Void)) {
        guard let realm = realm else {
            completion(nil, .realmError)
            return
        }
        
        if let user = realm.objects(User.self).first(where: { $0.login.lowercased() == login.lowercased() }) {
            //return false
            //Если он существует, измените ему пароль (да, это нелогично с точки зрения здравого смысла, но для обучения – хороший вариант).
            do {
                user.password = password
                try realm.write {
                    realm.add(user, update: .modified)
                }
                completion(user, nil)
            } catch {
                print(error.localizedDescription)
                completion(nil , Error(title: "Realm modifi error", description: error.localizedDescription))
            }
        } else {
            let user = User()
            user.login = login
            user.password = password
            user.age = age
            user.gender = gender
            
            do {
                try realm.write {
                    realm.add(user)
                }
                completion(user, nil)
            } catch {
                print(error.localizedDescription)
                completion(nil , Error(title: "Realm write error", description: error.localizedDescription))
            }
        }
    }
    
    func verifyUser(login: String, password: String, completion: @escaping ((User?, Error?) -> Void)) {
        guard let realm = realm else {
            completion(nil, .realmError)
            return
        }
        
        if let user = realm.object(ofType: User.self, forPrimaryKey: login)  {
            switch user.password == password {
            case true:
                completion(user, nil)
            case false:
                completion(user, .passwordIncorrect)
            }
        } else {
            completion(nil, .userNotFound)
        }
    }
    
    func getPassword(for login: String, completion: @escaping ((String?, Error?) -> Void)) {
        guard let realm = realm else {
            completion(nil, .realmError)
            return
        }
        
        if let user = realm.object(ofType: User.self, forPrimaryKey: login)  {
            completion(user.password, nil)
        } else {
            completion(nil, .userNotFound)
        }
    }

}
