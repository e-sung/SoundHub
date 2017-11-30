//
//  NetworkController.swift
//  soundHubPractice
//
//  Created by 류성두 on 2017. 11. 28..
//  Copyright © 2017년 류성두. All rights reserved.
//

import Foundation
import UIKit

class NetworkController{
    
    static let main = NetworkController()
    
    var recentPosts:[Post] = []

    private let baseURL:URL
    private let signUpURL:URL
    private let loginURL:URL
    private let postURL:URL


    init(){
        baseURL = URL(string: "https://soundhub.che1.co.kr")!
        signUpURL = URL(string: "/user/signup/", relativeTo: baseURL)!
        loginURL = URL(string: "/user/login", relativeTo: baseURL)!
        postURL = URL(string: "/post/", relativeTo: baseURL)!
    }
    
    func fetchRecentPost(on tableView:UITableView){
        URLSession.shared.dataTask(with: postURL) { (data, response, error) in
            if let error = error { print(error) }
            guard let data = data else { print("data is invalid"); return}
            
            guard let postlist = try? JSONDecoder().decode([Post].self, from: data) else {
                print("Decoding failed")
                return
            }
            self.recentPosts = postlist
            DispatchQueue.main.async(execute: {tableView.reloadData()})
        }.resume()
    }

    func sendRequest(with signUpContent:signUpRequest, from VC:UIViewController){
        guard let signUpData = try? JSONEncoder().encode(signUpContent) else {return}
        let request = generatePostRequest(with: self.signUpURL, and: signUpData)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response as? HTTPURLResponse {
                if response.statusCode == 201 {
                    DispatchQueue.main.async {VC.performSegue(withIdentifier: "profileSetUpToMain", sender: nil)}
                }else{
                    DispatchQueue.main.async {VC.alert(msg: "\(response.statusCode)")}
                }
            }
        }.resume()
    }
    
    func login(with email:String, and password:String){
        let loginInfo = ["email":email,"password":password]
        guard let loginData = try? JSONEncoder().encode(loginInfo) else {
            print("Encoding failed")
            return
        }
        let request = generatePostRequest(with: loginURL, and: loginData)
        URLSession.shared.dataTask(with: request) { (data, response, error) in

            if let data = data{
                guard let decodedData = try? JSONDecoder().decode(LoginResponse.self, from: data) else{
                    print("decoding fail")
                    return
                }
                print(decodedData)
            }
        }.resume()
    }
    
    
    func downloadAudio(from remoteURL:URL, to playerVC:DetailViewController){
        
        // then lets create your document folder url
        let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        // lets create your destination file url
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(remoteURL.lastPathComponent)
        print(destinationUrl)

        // to check if it exists before downloading it
        if FileManager.default.fileExists(atPath: destinationUrl.path) {
            print("The file already exists at path")
            playerVC.audioLocalURLs.append(destinationUrl)
        } else {
            URLSession.shared.downloadTask(with: remoteURL, completionHandler: { (location, response, error) -> Void in
                guard let location = location, error == nil else { return }
                do {
                    // after downloading your file you need to move it to your destination url
                    try FileManager.default.moveItem(at: location, to: destinationUrl)
                    playerVC.audioLocalURLs.append(destinationUrl)
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }).resume()
        }
    }
    
    func generatePostRequest(with url:URL, and body:Data)->URLRequest{
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-type")
        request.httpMethod = "POST"
        request.httpBody = body
        return request
    }
}
