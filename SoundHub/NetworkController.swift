//
//  NetworkController.swift
//  soundHubPractice
//
//  Created by 류성두 on 2017. 11. 28..
//  Copyright © 2017년 류성두. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage
import UIKit

class NetworkController{
    
    static let main = NetworkController()
    
    internal let baseURL:URL
    private let signUpURL:URL
    private let loginURL:URL
    private let postURL:URL
    internal let baseStorageURL:URL
    internal let baseMediaURL:URL
    internal let generalHomeURL:URL
    
    private var authToken:String{
        get{
            guard let tkn = UserDefaults.standard.string(forKey: token) else { return "invalid Token" }
            return "Token \(tkn)"
        }
    }

    private var multipartFormDataHeader:HTTPHeaders{
        get{
            return [
                 "Authorization": "\(authToken)",
                "Content-type": "multipart/form-data"
            ]
        }
    }

    init(){
        baseURL = URL(string: "https://soundhub.che1.co.kr/")!
        baseStorageURL = URL(string: "https://s3.ap-northeast-2.amazonaws.com/che1-soundhub/")!
        baseMediaURL = URL(string: "media/", relativeTo: baseStorageURL)!
        signUpURL = URL(string: "user/signup/", relativeTo: baseURL)!
        loginURL = URL(string: "user/login/", relativeTo: baseURL)!
        postURL = URL(string: "post/", relativeTo: baseURL)!
        generalHomeURL = URL(string: "home/", relativeTo: baseURL)!
    }
    
    func patchUser(nickname:String, completion:@escaping(_ hasSuccess:Bool)->Void){
        guard let userId = UserDefaults.standard.string(forKey: id) else {
            completion(false)
            return
        }
        let nickNamePatchURL = URL(string: "/user/\(userId)/", relativeTo: baseURL)!
        let headers: HTTPHeaders = ["Authorization": authToken]
        let parameters: Parameters = ["nickname":nickname]
        Alamofire.request(nickNamePatchURL, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers:headers).response { (response) in
            if response.response?.statusCode == 200 { completion(true) }
            else{ completion(false) }
        }
    }
    
    func patchProfileImage(with profileImage:UIImage?){
        guard let userId = UserDefaults.standard.string(forKey: id) else { return }
        let imagePatchURL = URL(string: "/user/\(userId)/profile-img/", relativeTo: baseURL)!
        guard let imageToSend = profileImage else { return }
        let profileImageData = UIImagePNGRepresentation(imageToSend)
        guard let imageData = profileImageData else { print("invalid image"); return }
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(imageData, withName: "profile_img",fileName: "profile_\(Date()).png", mimeType: "image/png")
        },
            to: imagePatchURL, method: .patch, headers: multipartFormDataHeader,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        self.removeUserProfileImageCache()
                        debugPrint(response)
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
            }
        )
    }
    
    func patchHeaderImage(with headerImage:UIImage?){
        guard let userId = UserDefaults.standard.string(forKey: id) else { return }
        let imagePatchURL = URL(string: "/user/\(userId)/profile-img/", relativeTo: baseURL)!
        guard let imageToSend = headerImage else { return }
        let headerImageData = UIImagePNGRepresentation(imageToSend)
        guard let imageData = headerImageData else { print("invalid image"); return }
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(imageData, withName: "profile_bg",fileName: "header_\(Date()).png", mimeType: "image/png")
        },
            to: imagePatchURL, method: .patch, headers: multipartFormDataHeader,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        self.removeUserProfileImageCache()
                        debugPrint(response)
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
        }
        )
    }
    
    func removeUserProfileImageCache(){
//        guard let userId = UserDefaults.standard.string(forKey: id) else { return }
//        let userProfileURL = URL(string: "user_\(userId)/profile_img/profile_img_200.png", relativeTo: baseMediaURL)!
//        let userProfileRequest = URLRequest(url: userProfileURL)
        let imageDownloader = UIImageView.af_sharedImageDownloader
        let buttonDownloader = UIButton.af_sharedImageDownloader
        imageDownloader.imageCache?.removeAllImages()
        buttonDownloader.imageCache?.removeAllImages()
        imageDownloader.sessionManager.session.configuration.urlCache?.removeAllCachedResponses()
//        imageDownloader.imageCache?.removeImage(for: userProfileRequest, withIdentifier: nil)
//        buttonDownloader.imageCache?.removeImage(for: userProfileRequest, withIdentifier: nil)
//        imageDownloader.sessionManager.session.configuration.urlCache?.removeCachedResponse(for: userProfileRequest)
    }
    
    func fetchUser(id:Int, completion:@escaping(User)->Void){
        let url = URL(string: "/user/\(id)/", relativeTo: baseURL)!
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else { print("data is corrupted") ; return }
            guard let userInfo = try? JSONDecoder().decode(User.self, from: data) else {
                print("User Info Decoding failed")
                return
            }
            completion(userInfo)
        }.resume()
    }
    
    func fetchPost(id:Int, completion:@escaping(Post)->Void){
        let url = URL(string: "\(id)/", relativeTo: postURL)!
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {print ("data is corrupted") ; return}
            guard let post = try? JSONDecoder().decode(Post.self, from: data) else { return }
            completion(post)
        }.resume()
    }
    func fetchHomePage(of category:Categori, with option:String, completion:@escaping()->Void){
        var entryURL:URL?
        if category == .general { entryURL = generalHomeURL }
        else{ entryURL = URL(string: "\(category.rawValue)", relativeTo: generalHomeURL) }
        
        let homeURL = entryURL!.appendingPathComponent(option)
        URLSession.shared.dataTask(with: homeURL) { (data, response, error) in
            if let error = error { print(error) }
            guard let data = data else { print("data is invalid"); return}
            do{
                let homePageData = try JSONDecoder().decode(HomePage.self, from: data)
                DataCenter.main.homePages[category] = homePageData
                completion()
            }catch let err as NSError{
                print(err)
            }
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
    
    func uploadAudioComment(In localURL:URL, to postId:Int,instrument:String, completion:@escaping ()->Void){
        let url = URL(string: "\(postId)/comments/", relativeTo: postURL)!
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(localURL, withName: "comment_track")
                multipartFormData.append(instrument.data(using: .utf8)!, withName: "instrument")
        },
            to: url, headers:multipartFormDataHeader,
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
        })
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
            } catch let error as NSError { print(error) }
        }).resume()
    }
    
    func merge(comments:[Int], on post:Int, completion:@escaping ()->Void){
        let url = URL(string: "\(post)/mix/", relativeTo: postURL)!
        var tracksToMix = ""
        for comment in comments{ tracksToMix += "\(comment) ," }
        let parameter:Parameters = ["mix_tracks": tracksToMix]
        let headers: HTTPHeaders = ["Authorization": authToken]
        Alamofire.request(url, method: .patch, parameters: parameter, encoding: JSONEncoding.default, headers:headers).response { (response) in
                completion()
            }
    }
    
    func sendLikeRequest(on postId:Int, completion:@escaping (_ num_liked:Int)->Void){
        let url = URL(string: "\(postId)/like/", relativeTo: postURL)!
        var request = generatePostRequest(with: url, and: nil)
        
        request.addValue("Token \(UserDefaults.standard.string(forKey: token)!)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else { print("data is corrupted") ; return }
            do{
                let post = try JSONDecoder().decode([String:Post].self, from: data)
                if let numLiked = post["post"]!.num_liked{ completion(numLiked) }
                else{ completion(0) }
            }catch let err as NSError { print(err) }
        }.resume()
    }
    

    func generatePostRequest(with url:URL, and body:Data?)->URLRequest{
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-type")
        request.httpMethod = "POST"
        if let body = body {
            request.httpBody = body
        }
        return request
    }
}
