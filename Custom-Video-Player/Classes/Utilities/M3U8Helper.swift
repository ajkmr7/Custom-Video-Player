import Foundation

/// A structure representing the video quality with bitrate and resolution.
struct VideoQuality {
    let bitrate: Double
    let resolution: String
}

/// Extension to provide additional functionalities for arrays of VideoQuality.
extension [VideoQuality] {
    
    /// Sorts the video qualities by bitrate in descending order and inserts an "Auto" option at the beginning.
    mutating func sortAndInsertAutoVideoQualityOption() {
        sort(by: { $0.bitrate >= $1.bitrate })
        let autoQualityOption = VideoQuality(bitrate: Double.greatestFiniteMagnitude, resolution: "Auto")
        insert(autoQualityOption, at: 0)
    }
}

/// A helper class for handling M3U8 manifest data to fetch supported video qualities.
class M3u8Helper {
    
    /// Constants used for parsing the M3U8 manifest.
    private enum Constants {
        static let bandwidth = "BANDWIDTH"
        static let resolution = "RESOLUTION"
    }

    /// An array to store the video qualities.
    private var qualities: [VideoQuality] = []

    /// Fetches supported video qualities from the provided M3U8 manifest data.
    ///
    /// - Parameter data: The M3U8 manifest data.
    /// - Returns: An array of `VideoQuality` objects representing the supported qualities.
    func fetchSupportedVideoQualities(with data: Data) -> [VideoQuality] {
        handleManifest(data: data)
        qualities.sortAndInsertAutoVideoQualityOption()
        return qualities
    }

    /// Handles the M3U8 manifest data by parsing it to extract video qualities.
    ///
    /// - Parameter data: The M3U8 manifest data.
    private func handleManifest(data: Data) {
        if let stringData = String(data: data, encoding: .utf8) {
            qualities = parse(stringData: stringData)
        }
    }

    /// Parses the string representation of the M3U8 manifest to extract video qualities.
    ///
    /// - Parameter stringData: The string representation of the M3U8 manifest.
    /// - Returns: An array of `VideoQuality` objects.
    private func parse(stringData: String) -> [VideoQuality] {
        var result: [VideoQuality] = []
        let rows = stringData.components(separatedBy: "\n")

        for row in rows {
            if let quality = quality(from: row) {
                if let index = result.firstIndex(where: { $0.resolution == quality.resolution }) {
                    if result[index].bitrate < quality.bitrate {
                        result.remove(at: index)
                        result.append(quality)
                    }
                } else {
                    result.append(quality)
                }
            }
        }
        return result
    }

    /// Extracts a `VideoQuality` object from a single row of the M3U8 manifest.
    ///
    /// - Parameter segments: A single row of the M3U8 manifest.
    /// - Returns: A `VideoQuality` object if parsing is successful, otherwise `nil`.
    private func quality(from segments: String) -> VideoQuality? {
        let dataSegments = segments.components(separatedBy: ",")

        if let bandwidthSegments = dataSegments.first(where: { $0.contains(Constants.bandwidth) }),
           let resolutionSegments = dataSegments.first(where: { $0.contains(Constants.resolution) }) {
            
            let bandwidth = bandwidthSegments.components(separatedBy: "=")
            let resolution = resolutionSegments.components(separatedBy: "=")

            if bandwidth.count > 1, resolution.count > 1,
               let bitrate = Double(bandwidth[1]), 
               let resolution = prettyResolution(from: resolution[1]) {
                return VideoQuality(bitrate: bitrate, resolution: resolution)
            }
        }

        return nil
    }

    /// Converts a resolution string from the M3U8 manifest into a more readable format.
    ///
    /// - Parameter resolution: The resolution string from the manifest.
    /// - Returns: A formatted resolution string, or `nil` if the format is invalid.
    private func prettyResolution(from resolution: String) -> String? {
        let resolutionSegments = resolution.lowercased().components(separatedBy: "x")

        if resolutionSegments.count > 1 {
            return resolutionSegments[1] + "p"
        }

        return nil
    }
}
