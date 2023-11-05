import Foundation

public protocol VideoPlayerUseCase {
    func getM3U8Config(videoURL: URL, completion: @escaping (Swift.Result<Data, Error>) -> Void)
}

public final class VideoPlayerService: VideoPlayerUseCase {
    let apiClient: APIClientService
    init() {
        apiClient = APIClientService()
    }
    public func getM3U8Config(videoURL: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        return apiClient.requestData(from: videoURL, completion: completion)
    }
}

