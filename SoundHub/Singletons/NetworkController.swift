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
    // MARK: Stored Properties
    /// HTTP 통신을 담당하는 싱글턴 객체
    static let main = NetworkController()
    /// https://soundhub.che1.co.kr/
    internal let hostURL:URL
    /// https://soundhub.che1.co.kr/user/signup/
    private let signUpURL:URL
    /// https://soundhub.che1.co.kr/user/login/
    private let loginURL:URL
    /// https://soundhub.che1.co.kr/post/
    private let postURL:URL
    /// https://s3.ap-northeast-2.amazonaws.com/che1-soundhub/media/
    internal let baseMediaURL:URL
    /// https://soundhub.che1.co.kr/home/
    internal let generalHomeURL:URL
 
    init(){
        hostURL = URL(string: "https://soundhub.che1.co.kr/")!
        baseMediaURL = URL(string: "https://s3.ap-northeast-2.amazonaws.com/che1-soundhub/media/")!
        signUpURL = URL(string: "user/signup/", relativeTo: hostURL)!
        loginURL = URL(string: "user/login/", relativeTo: hostURL)!
        postURL = URL(string: "post/", relativeTo: hostURL)!
        generalHomeURL = URL(string: "home/", relativeTo: hostURL)!
    }
}

// MARK: Fetching Functions
extension NetworkController{
    /**
     [User 객체조회 API](https://nachwon.gitbooks.io/soundhub/content/user/user-retrieve.html) 참고
    */
    func fetchUser(id:Int, completion:@escaping(User?)->Void){
        let url = URL(string: "/user/\(id)/", relativeTo: hostURL)!
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error { print(error); completion(nil); return }
            guard let data = data else { print("data is corrupted") ; completion(nil); return }
            guard let userInfo = try? JSONDecoder().decode(User.self, from: data) else {
                print("User Info Decoding failed"); completion(nil); return
            }
            completion(userInfo)
        }.resume()
    }
    /**
     [Post 객체조회 API](https://nachwon.gitbooks.io/soundhub/content/post/post-detail.html) 참고
     */
    func fetchPost(id:Int, completion:@escaping(Post)->Void){
        let url = URL(string: "\(id)/", relativeTo: postURL)!
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {print ("data is corrupted") ; return}
            guard let post = try? JSONDecoder().decode(Post.self, from: data) else { return }
            completion(post)
            }.resume()
    }
    /**
     메인(홈)화면에 뿌려질 데이터 요청 함수
     응답 결과는 DataCenter.main 에 저장된다.
     [HomePage 조회 API](https://nachwon.gitbooks.io/soundhub/content/homepages/main-homepage.html) 참고
     - parameter category : 메인홈/장르별 홈/악기별 홈
     - parameter option : 세부장르/세부악기 등
     - completion : 응답이 되돌아 온 뒤 해야 할 일
    */
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
}

// MARK: 오디오 관련 요청들
extension NetworkController{
    /**
     오디오 **코맨트**를 업로드하는 함수
     - parameter localURL: 업로드 할 음악 파일이 저장되어있는 장소
     - parameter postId: 지금 댓글을 달려고 하는 포스트의 id
    */
    func uploadAudioComment(In localURL:URL, to postId:Int,instrument:String, completion:@escaping ()->Void){
        let url = URL(string: "\(postId)/comments/", relativeTo: postURL)!
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(localURL, withName: "comment_track")
                multipartFormData.append(instrument.data(using: .utf8)!, withName: "instrument")
        },
            to: url, headers:["Authorization": "\(authToken)", "Content-type": "multipart/form-data"],
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in debugPrint(response); completion() }
                case .failure(let encodingError):
                    print(encodingError); completion()
                }
        })
    }
    /**
     오디오 **포스트**를 업로드하는 함수
     - parameter localURL: 업로드 할 음악 파일이 저장되어있는 장소
     */
    func uploadAudio(In localURL:URL, genre:String, instrument:String, bpm:Int, albumCover:UIImage, completion:@escaping ()->Void){
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                let filename = localURL.lastPathComponent.split(separator: ".")[0]
                multipartFormData.append(filename.data(using: .utf8)!, withName: "title")
                multipartFormData.append(localURL, withName: "author_track")
                multipartFormData.append(genre.lowercased().data(using: .utf8)!, withName: "genre")
                multipartFormData.append(instrument.lowercased().data(using: .utf8)!, withName: "instrument")
                multipartFormData.append("\(bpm)".data(using: .utf8)!, withName: "bpm")
                let albumData = (UIImagePNGRepresentation(albumCover) ?? Data())
                multipartFormData.append(albumData, withName: "post_img")
        },
            to: postURL, headers:["Authorization": "\(authToken)", "Content-type": "multipart/form-data"],
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in debugPrint(response); completion() }
                case .failure(let encodingError):
                    print(encodingError); completion()
                }
            }
        )
    }
    
    /**
     서버의 remoteURL에 있는 파일을 다운받아 localURL의 위치에 저장하는 함수
     - parameter remoteURL : 오디오가 저장되어 있는 서버측 URL
    */
    func downloadAudio(from remoteURL:URL, completion:@escaping (_ localURL:URL)->Void){
        let documentsDirectoryURL = DataCenter.documentsDirectoryURL
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(parseLocalURL(from: remoteURL))

        if FileManager.default.fileExists(atPath: destinationUrl.path) {
            completion(destinationUrl)
            return
        }
        URLSession.shared.downloadTask(with: remoteURL, completionHandler: { (location, response, error) -> Void in
            guard let location = location, error == nil else { return }
            do {
                try FileManager.default.moveItem(at: location, to: destinationUrl)
                DispatchQueue.main.async { completion(destinationUrl) }
            } catch let error as NSError { print(error) }
        }).resume()
    }
    /**
     [Mix-Tracks API](https://nachwon.gitbooks.io/soundhub/content/post/mix-tracks.html) 참고
     - parameter comments : 믹스하려고 하는 코맨트들의 **id** 값들
     - parameter post : 지금 믹스가 일어나는 포스트의 **id**값
    */
    func mix(comments:[Int], on post:Int, completion:@escaping ()->Void){
        let url = URL(string: "\(post)/mix/", relativeTo: postURL)!
        var tracksToMix = ""
        for comment in comments{ tracksToMix += "\(comment) ," }
        let parameter:Parameters = ["mix_tracks": tracksToMix]
        let headers: HTTPHeaders = ["Authorization": authToken]
        Alamofire.request(url, method: .patch, parameters: parameter, encoding: JSONEncoding.default, headers:headers).response { (response) in
            completion()
        }
    }
}

// MARK: Patching Functions
extension NetworkController{
    func patchUser(nickname:String, instrument:String, completion:@escaping(_ hasSuccess:Bool)->Void){
        guard let userId = UserDefaults.standard.string(forKey: id) else { completion(false); return}
        let nickNamePatchURL = URL(string: "/user/\(userId)/", relativeTo: hostURL)!
        let headers: HTTPHeaders = ["Authorization": authToken]
        let parameters: Parameters = ["nickname":nickname, "instrument":instrument]
        Alamofire.request(nickNamePatchURL, method: .patch, parameters: parameters, encoding: JSONEncoding.default, headers:headers).response { (response) in
            if response.response?.statusCode == 200 { completion(true) }
            else{ completion(false) }
        }
    }
    
    func patch(profileImage:UIImage?, headerImage:UIImage?){
        guard let userId = UserDefaults.standard.string(forKey: id) else { return }
        let imagePatchURL = URL(string: "/user/\(userId)/profile-img/", relativeTo: hostURL)!        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                if let imageData = self.dataRepresentationOf(image: profileImage){
                    multipartFormData.append(imageData, withName: "profile_img",fileName: "profile_\(Date()).png", mimeType: "image/png")
                }
                if let imageData = self.dataRepresentationOf(image: headerImage){
                    multipartFormData.append(imageData, withName: "profile_bg",fileName: "header_\(Date()).png", mimeType: "image/png")
                }
        },
            to: imagePatchURL, method: .patch,
            headers: ["Authorization": "\(authToken)", "Content-type": "multipart/form-data"],
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        DataCenter.main.removeUserProfileImageCache()
                        debugPrint(response)
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
        }
        )
    }
}

extension NetworkController{
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
    
    func sendLikeRequest(on postId:Int, completion:@escaping (_ num_liked:Int)->Void){
        let url = URL(string: "\(postId)/like/", relativeTo: postURL)!
        let headers: HTTPHeaders = ["Authorization": authToken]
        Alamofire.request(url, method: .post, parameters: nil, headers: headers).responseJSON { (response) in
            if let json = response.result.value {
                let post = json as! NSDictionary
                let numLiked = post["num_liked"] as! Int
                completion(numLiked)
            }
        }
    }
}

// MARK: Utility Functions & Computed Properties
extension NetworkController{
    /// UserDefault에 저장되어있는 토큰을 꺼내어, 백앤드가 원하는 형태로 가공해 반환함.
    /// UserDefault에 저장된 값이 없을 때는, "Invalid Token"이라는 문자열을 토큰 대신 반환함.
    private var authToken:String{
        get{
            guard let tkn = UserDefaults.standard.string(forKey: token) else { return "invalid Token" }
            return "Token \(tkn)"
        }
    }
    
    /// URL 요청에 Method와 기본 헤더만 달아주는 함수
    private func generatePostRequest(with url:URL, and body:Data?)->URLRequest{
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-type")
        request.httpMethod = "POST"
        if let body = body {
            request.httpBody = body
        }
        return request
    }
    
    /// UIImagePNGRpresentation Wrapper
    private func dataRepresentationOf(image:UIImage?)->Data?{
        if let image = image { if let data = UIImagePNGRepresentation(image){ return data } }
        return nil
    }
    
    private func parseLocalURL(from remoteURL:URL)->String{
        let user = remoteURL.absoluteString.split(separator: "/")[4]
        let postId = remoteURL.absoluteString.split(separator: "/")[5]
        return user + postId + remoteURL.lastPathComponent
    }
}
