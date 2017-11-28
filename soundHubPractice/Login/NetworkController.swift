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
    
    private let baseURL:URL
    private let signUpURL:URL
    
    init(){
        baseURL = URL(string: "http://soundhub-dev.ap-northeast-2.elasticbeanstalk.com")!
        signUpURL = URL(string: "/user/signup/", relativeTo: baseURL)!
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
    
    func generatePostRequest(with url:URL, and body:Data)->URLRequest{
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-type")
        request.httpMethod = "POST"
        request.httpBody = body
        return request
    }
}
