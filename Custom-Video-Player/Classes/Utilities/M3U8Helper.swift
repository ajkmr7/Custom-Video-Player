import Foundation

struct VideoQuality {
    let bitrate: Double
    let resolution: String
}

extension [VideoQuality] {
    mutating func sortAndInsertAutoVideoQualityOption() {
        sort(by: { $0.bitrate >= $1.bitrate })
        let autoQualityOption = VideoQuality(bitrate: Double.greatestFiniteMagnitude, resolution: "Auto")
        insert(autoQualityOption, at: 0)
    }
}

class M3u8Helper {
    private enum Constants {
        static let bandwidth = "BANDWIDTH"
        static let resolution = "RESOLUTION"
    }

    private var qualities: [VideoQuality] = []

    func fetchSupportedVideoQualities(with data: Data) -> [VideoQuality] {
        handleManifest(data: data)
        qualities.sortAndInsertAutoVideoQualityOption()
        return qualities
    }

    private func handleManifest(data: Data) {
        if let stringData = String(data: data, encoding: .utf8) {
            qualities = parse(stringData: stringData)
        }
    }

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

    private func quality(from segments: String) -> VideoQuality? {
        let dataSegments = segments.components(separatedBy: ",")

        if let bandwidthSegments = dataSegments.first(where: { $0.contains(Constants.bandwidth) }),
           let resolutionSegments = dataSegments.first(where: { $0.contains(Constants.resolution) })
        {
            let bandwidth = bandwidthSegments.components(separatedBy: "=")
            let resolution = resolutionSegments.components(separatedBy: "=")

            if bandwidth.count > 1, resolution.count > 1, let bitrate = Double(bandwidth[1]), let resolution = prettyResolution(from: resolution[1]) {
                return VideoQuality(bitrate: bitrate, resolution: resolution)
            }
        }

        return nil
    }

    private func prettyResolution(from resolution: String) -> String? {
        let resolutionSegments = resolution.lowercased().components(separatedBy: "x")

        if resolutionSegments.count > 1 {
            return resolutionSegments[1] + "p"
        }

        return nil
    }
}
