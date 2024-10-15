import Foundation

public struct EpicFreeGames: Sendable, Codable {
    public let data: ResponseData

    public struct ResponseData: Sendable, Codable {
        public enum CodingKeys: String, CodingKey {
            case catalog = "Catalog"
        }

        public let catalog: Catalog

        public struct Catalog: Sendable, Codable {
            public let searchStore: SearchStore

            public struct SearchStore: Sendable, Codable {
                public let elements: [Element]

                public struct Element: Sendable, Codable {
                    public let title: String
                    public let id: String?
                    public let namespace: String?
                    public let description: String?
                    public let keyImages: [KeyImage]?
                    public let seller: Seller?
                    public let productSlug: String?
                    public let urlSlug: String?
                    public let customAttributes: [CustomAttribute]?
                    public let price: Price?
                    public let promotions: Promotions?

                    public struct KeyImage: Sendable, Codable {
                        public let type: String
                        public let url: String?
                    }

                    public struct Seller: Sendable, Codable {
                        public let id: String
                        public let name: String
                    }

                    public struct CustomAttribute: Sendable, Codable {
                        public let key: String?
                        public let value: String?
                    }

                    public struct Price: Sendable, Codable {
                        public let totalPrice: TotalPrice?

                        public struct TotalPrice: Sendable, Codable {
                            public let discountPrice: Int?
                            public let originalPrice: Int?
                            public let currencyCode: String?
                            public let currencyInfo: CurrencyInfo?
                            public let fmtPrice: FmtPrice?

                            public struct CurrencyInfo: Sendable, Codable {
                                public let decimals: Int?
                            }

                            public struct FmtPrice: Sendable, Codable {
                                public let originalPrice: String?
                                public let discountPrice: String?
                                public let intermediatePrice: String?
                            }
                        }
                    }

                    public struct Promotions: Sendable, Codable {
                        public let promotionalOffers: [Promotion]?
                        public let upcomingPromotionalOffers: [Promotion]?

                        public var allPromotions: [Promotion] { (promotionalOffers ?? []) + (upcomingPromotionalOffers ?? []) }
                        public var allOffers: [Promotion.Offer] { allPromotions.flatMap { $0.promotionalOffers ?? [] } }

                        public struct Promotion: Sendable, Codable {
                            public let promotionalOffers: [Offer]?

                            public struct Offer: Sendable, Codable, CustomStringConvertible {
                                public let startDate: String?
                                public let endDate: String?
                                public let discountSetting: DiscountSetting?

                                public var description: String {
                                    let parser = ISO8601DateFormatter()
                                    let formatter = DateFormatter()
                                    parser.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                                    parser.timeZone = TimeZone(secondsFromGMT: 0)!
                                    formatter.dateFormat = "dd.MM. HH:mm"
                                    return [
                                        discountSetting.map { "\($0)" },
                                        startDate.flatMap(parser.date(from:)).map { "from \(formatter.string(from: $0))" },
                                        endDate.flatMap(parser.date(from:)).map { "to \(formatter.string(from: $0))" }
                                    ].compactMap { $0 }.joined(separator: " ")
                                }

                                public struct DiscountSetting: Sendable, Codable, CustomStringConvertible {
                                    public let discountType: String
                                    public let discountPercentage: Int?

                                    public var description: String {
                                        if discountType == "PERCENTAGE" {
                                            return discountPercentage == 0 ? "Free" : "\(discountPercentage.map(String.init) ?? "?") %"
                                        } else {
                                            return "?"
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
