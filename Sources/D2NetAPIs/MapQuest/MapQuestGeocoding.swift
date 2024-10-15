struct MapQuestGeocoding: Sendable, Codable {
    let info: Info?
    let options: Options?
    let results: [GeocodingResult]

    struct Info: Sendable, Codable {
        let statuscode: Int?
        let copyright: Copyright?

        struct Copyright: Sendable, Codable {
            let text: String?
            let imageUrl: String?
            let imageAltText: String?
        }
    }

    struct Options: Sendable, Codable {
        let maxResults: Int?
        let thumbMaps: Bool?
        let ignoreLatLngInput: Bool?
    }

    struct GeocodingResult: Sendable, Codable {
        let providedLocation: ProvidedLocation?
        let locations: [Location]

        struct ProvidedLocation: Sendable, Codable {
            let location: String?
        }

        struct Location: Sendable, Codable {
            let latLng: LatLng
            let displayLatLng: LatLng?
            let mapUrl: String?

            struct LatLng: Sendable, Codable {
                let lat: Double
                let lng: Double
            }
        }
    }
}
