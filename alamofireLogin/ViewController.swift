//
//  ViewController.swift
//  alamofireLogin
//
//  Created by 黃毓皓 on 04/08/2017.
//  Copyright © 2017 ice elson. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

//第一次post ["login" : 帳密Json格式] 取得回傳的token值
//第二次post ["checkanswer" : token的String] ,回傳取得最終答案

class ViewController: UIViewController {

    
    //用urlsession方式-第一次post
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let myUrl = URL(string:"http://35.197.97.179/bb/iapi/R1.php")
        var request  = URLRequest(url: myUrl!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let param2:[String:Any] = ["acc":"user01","pwd":"1a2b3cd4"]
        
        let data = try! JSONSerialization.data(withJSONObject: param2, options: JSONSerialization.WritingOptions.prettyPrinted)
        
        let json = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as? String
        if let json = json {
            print("json:\(json)")
        }
        
        let body = "login=\(json!)"
     
        let dataString = body.data(using:String.Encoding.utf8, allowLossyConversion: false)
        request.httpBody = dataString
        
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
                        if error != nil {
                            print("fail")
                            return
                        }
            
                            do {
                                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                                print ("jsonDownload:\(json!)")
                
                                if let parseJSON = json {
                
                                    let getUrlToken = parseJSON["token"] as? String
                                    
                                    if getUrlToken != nil {
                                        
                                        print("getUrlToken:\(getUrlToken!)")
                                        self.UrlsessionGetToken(UrlToken: getUrlToken!)
                                    } else {
                                        
                                        print ("canot get Token ")
                                    }
                                }
                            } catch{
                                print(error)
                            }
        }
        
        task.resume()

        
    }
    //用urlsession方式-第二次post
    func UrlsessionGetToken(UrlToken:String){
        let myUrl = URL(string:"http://35.197.97.179/bb/iapi/R1.php")
        var request  = URLRequest(url: myUrl!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let body = "checkanswer=\(UrlToken)"
        
        let dataString = body.data(using:String.Encoding.utf8, allowLossyConversion: false)
        request.httpBody = dataString
        
        
        let task2 = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                print("fail")
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                print ("jsonDownload:\(json!)")
                
                if let parseJSON = json {
                    
                    let getUrlToken = parseJSON["msg"] as? String
                    
                    if getUrlToken != nil {
                        
                        print("getFinalAnswer:\(getUrlToken!)")
                        self.popAlert(messageText: getUrlToken!)
                        
                    } else {
                        
                        print ("canot get Token ")
                    }
                }
            } catch{
                print(error)
            }
        }
        
        task2.resume()
    }
    
    
    
    //用Alamofire方式-第一次post
    @IBAction func loginPressed(_ sender: Any) {

        
        let url = URL(string:"http://35.197.97.179/bb/iapi/R1.php")
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
       
        let param2:[String:Any] = ["acc":"user01","pwd":"1a2b3cd4"]
        
        let data = try! JSONSerialization.data(withJSONObject: param2, options: JSONSerialization.WritingOptions.prettyPrinted)
        
        let NSjson = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        
        print("NSJson:\(NSjson!)")

        
        let loginPatam = ["login":NSjson!]
        

        Alamofire.request(url!, method: .post, parameters: loginPatam, encoding: URLEncoding.default, headers: headers).responseJSON { (response) in
            
            if response.error == nil{
                print(response.data)
                print(response.result.value)
                if  let getJson =  try! JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as? NSDictionary{
                    print(getJson)
                    print(getJson["token"]!)
                    
                    if let getToken = getJson["token"] as? String{
                        self.UseTokenToLog(passToken: getToken)
                    }
                    
                    
                }
                
                
            }else{
                print("response error:\(response.error)")
            }
            
        }
        
    }
     //用Alamofire方式-第二次post
    func UseTokenToLog(passToken:String){
        let url2 = URL(string:"http://35.197.97.179/bb/iapi/R1.php")
        
        let headers = [
            "Content-Type": "application/x-www-form-urlencoded"
        ]
        
        // let parameters = ["checkanswer":"testForSuccess"]
        let parameters = ["checkanswer":passToken]
        
        Alamofire.request(url2!, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON(completionHandler: { (response) in
            if response.error == nil{
                print(response.data!)
                print(response.result.value!)
                
                if  let getJson =  try! JSONSerialization.jsonObject(with: response.data!, options: .mutableContainers) as? NSDictionary{

                    
                    if let getAnswer = getJson["msg"] as? String{
                        self.popAlert(messageText: getAnswer)
                    }
                    
                    
                }
                
            }else{
                print("response error:\(response.error)")
            }
            
        })
    }
    
    //跳出提示視窗
    func popAlert(messageText:String){
        let alertController = UIAlertController(title: "success", message: messageText, preferredStyle: .alert)
        let DefaultAction = UIAlertAction(title: "ok", style: .default, handler: nil)
        alertController.addAction(DefaultAction)
        present(alertController, animated: true, completion: nil)
    }
   


}

