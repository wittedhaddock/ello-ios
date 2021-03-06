////
///  Category.swift
//

import SwiftyJSON

public let CategoryVersion = 3

// Version 3: isSponsored, body, header, ctaCaption, ctaURL, promotionals

public final class Category: JSONAble, Groupable {
    static let featured = Category(id: "meta1", name: InterfaceString.Discover.Featured, slug: "recommended", order: 0, allowInOnboarding: false, usesPagePromo: true, level: .Meta, tileImage: nil)
    static let trending = Category(id: "meta2", name: InterfaceString.Discover.Trending, slug: "trending", order: 1, allowInOnboarding: false, usesPagePromo: true, level: .Meta, tileImage: nil)
    static let recent = Category(id: "meta3", name: InterfaceString.Discover.Recent, slug: "recent", order: 2, allowInOnboarding: false, usesPagePromo: true, level: .Meta, tileImage: nil)

    public let id: String
    public var groupId: String { return "Category-\(id)" }
    public let name: String
    public let slug: String
    public var tileURL: NSURL? { return tileImage?.url }
    public var isSponsored: Bool?
    public var body: String?
    public var header: String?
    public var ctaCaption: String?
    public var ctaURL: NSURL?
    public let tileImage: Attachment?
    public let order: Int
    public let allowInOnboarding: Bool
    public let level: CategoryLevel
    public var isMeta: Bool { return level == .Meta }
    public var usesPagePromo: Bool
    public var hasPromotionalData: Bool {
        return body != nil
    }

    public var endpoint: ElloAPI {
        switch level {
        case .Meta: return .Discover(type: DiscoverType(rawValue: slug)!)
        default: return .CategoryPosts(slug: slug)
        }
    }

    // links
    public var promotionals: [Promotional]? { return getLinkArray("promotionals") as? [Promotional] }
    private var _randomPromotional: Promotional?
    public var randomPromotional: Promotional? {
        get {
            if _randomPromotional == nil {
                _randomPromotional = promotionals?.randomItem()
            }
            return _randomPromotional
        }
        set {
            _randomPromotional = newValue
        }
    }

    var visibleOnSeeMore: Bool {
        return level == .Primary || level == .Secondary
    }

    public init(id: String,
        name: String,
        slug: String,
        order: Int,
        allowInOnboarding: Bool,
        usesPagePromo: Bool,
        level: CategoryLevel,
        tileImage: Attachment?)
    {
        self.id = id
        self.name = name
        self.slug = slug
        self.order = order
        self.allowInOnboarding = allowInOnboarding
        self.usesPagePromo = usesPagePromo
        self.level = level
        self.tileImage = tileImage
        super.init(version: CategoryVersion)
    }

    public required init(coder: NSCoder) {
        let decoder = Coder(coder)
        id = decoder.decodeKey("id")
        name = decoder.decodeKey("name")
        slug = decoder.decodeKey("slug")
        order = decoder.decodeKey("order")
        level = CategoryLevel(rawValue: decoder.decodeKey("level"))!
        let version: Int = decoder.decodeKey("version")
        if version > 1 {
            allowInOnboarding = decoder.decodeKey("allowInOnboarding")
        }
        else {
            allowInOnboarding = true
        }
        if version > 2 {
            usesPagePromo = decoder.decodeKey("usesPagePromo")
        }
        else {
            usesPagePromo = level == .Meta
        }
        tileImage = decoder.decodeOptionalKey("tileImage")
        isSponsored = decoder.decodeOptionalKey("isSponsored")
        body = decoder.decodeOptionalKey("body")
        header = decoder.decodeOptionalKey("header")
        ctaCaption = decoder.decodeOptionalKey("ctaCaption")
        ctaURL = decoder.decodeOptionalKey("ctaURL")
        super.init(coder: coder)
    }

    public override func encodeWithCoder(coder: NSCoder) {
        let encoder = Coder(coder)
        encoder.encodeObject(id, forKey: "id")
        encoder.encodeObject(name, forKey: "name")
        encoder.encodeObject(slug, forKey: "slug")
        encoder.encodeObject(order, forKey: "order")
        encoder.encodeObject(allowInOnboarding, forKey: "allowInOnboarding")
        encoder.encodeObject(usesPagePromo, forKey: "usesPagePromo")
        encoder.encodeObject(level.rawValue, forKey: "level")
        encoder.encodeObject(tileImage, forKey: "tileImage")
        encoder.encodeObject(isSponsored, forKey: "isSponsored")
        encoder.encodeObject(body, forKey: "body")
        encoder.encodeObject(header, forKey: "header")
        encoder.encodeObject(ctaCaption, forKey: "ctaCaption")
        encoder.encodeObject(ctaURL, forKey: "ctaURL")
        super.encodeWithCoder(coder)
    }

    override public func merge(other: JSONAble) -> JSONAble {
        if let other = other as? Category {
            if other.links?["promotionals"] == nil, let promotionals = promotionals
            where promotionals.count > 0 {
                other.addLinkArray("promotionals", array: promotionals.map { $0.id }, type: .PromotionalsType)
            }
        }
        return other
    }

    override public class func fromJSON(data: [String: AnyObject]) -> JSONAble {
        let json = JSON(data)
        let id = json["id"].stringValue
        let name = json["name"].stringValue
        let slug = json["slug"].stringValue
        let order = json["order"].intValue
        let allowInOnboarding = json["allow_in_onboarding"].bool ?? true
        let level: CategoryLevel = CategoryLevel(rawValue: json["level"].stringValue) ?? .Unknown
        let usesPagePromo = json["uses_page_promotionals"].bool ?? (level == .Meta)
        let tileImage: Attachment?
        if let assetJson = json["tile_image"].object as? [String: AnyObject],
            attachmentJson = assetJson["large"] as? [String: AnyObject]
        {
            tileImage = Attachment.fromJSON(attachmentJson) as? Attachment
        }
        else {
            tileImage = nil
        }

        // optional
        let isSponsored = json["is_sponsored"].bool
        let body = json["description"].string
        let header = json["header"].string
        let ctaCaption = json["cta_caption"].string
        let ctaURL = json["cta_href"].string.flatMap { NSURL(string: $0) }

        let category = Category(id: id, name: name, slug: slug, order: order, allowInOnboarding: allowInOnboarding, usesPagePromo: usesPagePromo, level: level, tileImage: tileImage)

        // links
        category.links = data["links"] as? [String: AnyObject]
        category.isSponsored = isSponsored
        category.body = body
        category.header = header
        category.ctaCaption = ctaCaption
        category.ctaURL = ctaURL

        return category
    }
}

extension Category: JSONSaveable {
    var uniqId: String? { return id }
}
