//
//  NetworkController.swift
//  soundHubPractice
//
//  Created by 류성두 on 2017. 11. 28..
//  Copyright © 2017년 류성두. All rights reserved.
//

import Foundation
import Alamofire
import UIKit

class NetworkController{
    
    static let main = NetworkController()
    
    internal let baseURL:URL
    private let signUpURL:URL
    private let loginURL:URL
    private let postURL:URL
    internal let baseMediaURL:URL
    internal let generalHomeURL:URL

    var multipartFormDataHeader:HTTPHeaders{
        get{
            return [
                "Authorization": "Token \(UserDefaults.standard.string(forKey: token)!)",
                "Content-type": "multipart/form-data"
            ]
        }
    }

    init(){
        baseURL = URL(string: "https://soundhub.che1.co.kr")!
        baseMediaURL = URL(string: "https://s3.ap-northeast-2.amazonaws.com/che1-soundhub/media/")!
        signUpURL = URL(string: "/user/signup/", relativeTo: baseURL)!
        loginURL = URL(string: "/user/login/", relativeTo: baseURL)!
        postURL = URL(string: "/post/", relativeTo: baseURL)!
        generalHomeURL = URL(string: "/home/", relativeTo: baseURL)!
    }
    
    func fetchHomePage(of category:Categori, with option:String, completion:@escaping()->Void){
        var entryURL:URL?
        if category == .general {
            entryURL = generalHomeURL
        }else{
            entryURL = URL(string: "\(category.rawValue)", relativeTo: generalHomeURL)
        }
        let homeURL = entryURL!.appendingPathComponent(option)
        URLSession.shared.dataTask(with: homeURL) { (data, response, error) in
            if let error = error { print(error) }
            guard let data = data else { print("data is invalid"); return}
            guard let homePageData = try? JSONDecoder().decode(HomePage.self, from: data) else {
                print("decoding failed")
                return
            }
            print(homePageData)
            DataCenter.main.homePages[category] = homePageData
            completion()
        }.resume()
    }
    
    func fetchGenreHomePage(genre:Genre){
        let url = URL(string: "\(genre.rawValue.lowercased())/", relativeTo: generalHomeURL)!
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error { print(error) }
            guard let data = data else { print("data is invalid"); return}
            guard let homePageData = try? JSONDecoder().decode(HomePage.self, from: data) else {
                print("decoding failed")
                return
            }
            print(homePageData)
            DataCenter.main.homePages[.genre] = homePageData
        }.resume()
    }
    
    func fetchRecentPost(on tableView:UITableView){
        URLSession.shared.dataTask(with: postURL) { (data, response, error) in
            if let error = error { print(error) }
            guard let data = data else { print("data is invalid"); return}
            guard let postlist = try? JSONDecoder().decode([Post].self, from: data) else { print("Decoding failed");return }
            DataCenter.main.recentPosts = postlist
            DispatchQueue.main.async(execute: { tableView.reloadData() })
        }.resume()
    }

    func sendRequest(with signUpContent:signUpRequest, from VC:UIViewController){
        guard let signUpData = try? JSONEncoder().encode(signUpContent) else {return}
        let request = generatePostRequest(with: self.signUpURL, and: signUpData)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 201 {
                    DispatchQueue.main.async {VC.performSegue(withIdentifier: "profileSetUpToMain", sender: nil)}
                }else{ DispatchQueue.main.async {VC.alert(msg: "\(response.statusCode)")} }
            }
        }.resume()
    }
    
    func login(with email:String, and password:String, done:@escaping (_ result:LoginResponse)->Void){
        let loginInfo = ["email":email,"password":password]
        guard let loginData = try? JSONEncoder().encode(loginInfo) else {print("Encoding failed");return}
        
        let request = generatePostRequest(with: loginURL, and: loginData)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error { print(error) }
            guard let data = data else {return}
            guard let result = try? JSONDecoder().decode(LoginResponse.self, from: data) else{return}
            done(result)
        }.resume()
    }
    
    func uploadAudio(In localURL:URL, genre:String, instrument:String, completion:@escaping ()->Void){
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                let filename = localURL.lastPathComponent.split(separator: ".")[0]
                multipartFormData.append(filename.data(using: .utf8)!, withName: "title")
                multipartFormData.append(localURL, withName: "author_track")
                multipartFormData.append(genre.lowercased().data(using: .utf8)!, withName: "genre")
                multipartFormData.append(instrument.lowercased().data(using: .utf8)!, withName: "instrument")
        },
            to: postURL, headers:multipartFormDataHeader,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        debugPrint(response)
                        completion()
                    }
                case .failure(let encodingError):
                    print(encodingError)
                    completion()
                }
            }
        )
    }
    
    func downloadAudio(from remoteURL:URL, done:@escaping (_ localURL:URL)->Void){
        let documentsDirectoryURL = DataCenter.documentsDirectoryURL
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(remoteURL.lastPathComponent)
        
        if FileManager.default.fileExists(atPath: destinationUrl.path) { done(destinationUrl); return }
        
        URLSession.shared.downloadTask(with: remoteURL, completionHandler: { (location, response, error) -> Void in
            guard let location = location, error == nil else { return }
            do {
                try FileManager.default.moveItem(at: location, to: destinationUrl)
                done(destinationUrl)
            } catch let error as NSError {
                print(error)
            }
        }).resume()
    }
    

    func generatePostRequest(with url:URL, and body:Data)->URLRequest{
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-type")
        request.httpMethod = "POST"
        request.httpBody = body
        return request
    }
}
