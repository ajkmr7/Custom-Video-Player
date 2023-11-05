import Foundation

class APIClientService {
    func requestData(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        let session = URLSession.shared

        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            } else if let data = data {
                DispatchQueue.main.async {
                    completion(.success(data))
                }
            } else {
                let unknownError = NSError(domain: "UnknownError", code: 0, userInfo: nil)
                DispatchQueue.main.async {
                    completion(.failure(unknownError))
                }
            }
        }
        task.resume()
    }
}
