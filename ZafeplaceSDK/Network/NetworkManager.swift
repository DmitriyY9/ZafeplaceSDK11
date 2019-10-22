//
//  NetworkManager.swift
//  Vibe
//
//  Created by Z4
//Copyright © 2018 Dmitriy Zhyzhko. All rights reserved.
//

import Foundation

class NetworkManager {
    private(set) var session: URLSession
    
    init(with session: URLSession = .shared) {
        self.session = session
    }

    @discardableResult
    func execute(_ request: URLRequest, completion: @escaping (Result<[String: Any]>, Int) -> Void) -> RequestToken {
        NetworkActivity.started()
        print("👍 ", String(describing: type(of: self)),":", #function, " ", request)
        let task = session.dataTask(with: request) {
            (data, response, error) in

            defer { NetworkActivity.finished() }

            print("👍 ", String(describing: type(of: self)),":", #function, " ", response ?? "EXECUTE=NETWORK-MANAGER")
            
            guard let response = response as? HTTPURLResponse else {
                if let error = error {
                    completion(.failure(error), -1009)
                }
                return
            }
            
            let code = response.statusCode
            
            switch error {
            case .some(let error as NSError) where error.code == URLError.cancelled.rawValue:
                // Request was cancelled, no need to do any handling
                break

            case .some(let error as NSError) where error.code == NSURLErrorNotConnectedToInternet:
                DispatchQueue.main.async { completion(.failure(error), response.statusCode) }

            case .some(let error):
                print("👍 ", String(describing: type(of: self)),":", #function, " ", error)
                DispatchQueue.main.async { completion(.failure(error), response.statusCode) }

            case .none where 200 ... 399 ~= response.statusCode:
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: [])
                
                    if let array = json as? [[String: Any]] {
                        let response = ["values": array]
                        DispatchQueue.main.async { completion(.success(response), code) }
                    } else {
                        let response = json as? [String: Any] ?? [:]
                       // print("CODE = \(response["abi"])")
                        if let error = self.checkErrorCode(json: response) {
                            DispatchQueue.main.async { completion(.failure(error), error.code) }
                            return
                        }
                        DispatchQueue.main.async { completion(.success(response),code) }
                    }

                } catch {
                    DispatchQueue.main.async { completion(.failure(error), response.statusCode) }
                }

            case .none:
                print("⚠️ ", String(describing: type(of: self)),":", #function, " response status " , response.statusCode, " - " , error?.localizedDescription ?? "Empty")

                print("data :", String(data: data!, encoding: .utf8)!)
                
                if (response.statusCode == 410) {
                    let userInfo = [
                        NSLocalizedDescriptionKey: "User not found"
                    ]
                    let error = NSError(domain: "", code: 404, userInfo: userInfo)
                    DispatchQueue.main.async {
                        completion(.failure(error), 0)
                    }
                    
                    return
                }

                DispatchQueue.main.async {
                    if let res = try? JSONSerialization.jsonObject(with: data!, options: []) {
                        let json = res as? [String: Any] ?? [:]
                        if let err = self.checkErrorCode(json: json) {
                            completion(.failure(err), err.code)
                        }
                    }
                }
            }
        }
        task.resume()

        return RequestToken(task: task)

    }
    
    func checkErrorCode(json: [String: Any] ) -> NSError? {
        if let errorCode = json["errorCode"] as? Int, let message = json["message"] as? String {
            return NSError.init(domain: message, code: errorCode, userInfo: nil)
        }
        if let message = json["message"] as? String {
            return NSError.init(domain: message, code: 102, userInfo: nil)
        }
        return nil
    }
}


