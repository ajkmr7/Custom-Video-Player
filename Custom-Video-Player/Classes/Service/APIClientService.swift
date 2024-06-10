import Foundation

/// A service class for making network requests.
class APIClientService {
    
    /// Makes a data request from the specified URL.
    ///
    /// - Parameters:
    ///   - url: The URL to request data from.
    ///   - completion: A closure to be executed when the request finishes, containing a `Result` enum with either the requested data or an error.
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
                // If no data or error is received, create an unknown error and return it.
                let unknownError = NSError(domain: "UnknownError", code: 0, userInfo: nil)
                DispatchQueue.main.async {
                    completion(.failure(unknownError))
                }
            }
        }
        task.resume()
    }
}
