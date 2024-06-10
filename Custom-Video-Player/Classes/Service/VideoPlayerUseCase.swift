import Foundation

/// Protocol defining the use case for a video player.
public protocol VideoPlayerUseCase {
    
    /// Fetches the M3U8 configuration data for a given video URL.
    ///
    /// - Parameters:
    ///   - videoURL: The URL of the video.
    ///   - completion: A closure to be called when the request finishes, containing a `Result` enum with either the M3U8 configuration data or an error.
    func getM3U8Config(videoURL: URL, completion: @escaping (Result<Data, Error>) -> Void)
}

/// A service class that implements the `VideoPlayerUseCase` protocol to handle video player functionality.
public final class VideoPlayerService: VideoPlayerUseCase {
    let apiClient: APIClientService
    
    /// Initializes the `VideoPlayerService` with a default `APIClientService` instance.
    public init() {
        apiClient = APIClientService()
    }
    
    /// Fetches the M3U8 configuration data for a given video URL using the `APIClientService`.
    ///
    /// - Parameters:
    ///   - videoURL: The URL of the video.
    ///   - completion: A closure to be called when the request finishes, containing a `Result` enum with either the M3U8 configuration data or an error.
    public func getM3U8Config(videoURL: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        return apiClient.requestData(from: videoURL, completion: completion)
    }
}
