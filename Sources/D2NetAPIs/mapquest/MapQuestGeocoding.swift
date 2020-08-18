struct MapQuestGeocoding: Codable {
    let info: Info?
    let options: Options?
    let results: [GeocodingResult]

    struct Info: Codable {
        let statuscode: Int?
        let copyright: Copyright?

        struct Copyright: Codable {
            let text: String?
            let imageUrl: String?
            let imageAltText: String?
        }
    }

    struct Options: Codable {
        let maxResults: Int?
        let thumbMaps: Bool?
        let ignoreLatLngInput: Bool?
    }

    struct GeocodingResult: Codable {
        let providedLocation: ProvidedLocation?
        let locations: [Location]

        struct ProvidedLocation: Codable {
            let location: String?
        }

        struct Location: Codable {
            let latLng: LatLng
            let displayLatLng: LatLng?
            let mapUrl: String?

            struct LatLng: Codable {
                let lat: Double
                let lng: Double
            }
        }
    }
}
