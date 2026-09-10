import Foundation

// MARK: - Generic JSON:API envelope

public struct ListResponse<Resource: Decodable>: Decodable {
    public var data: [Resource]
    public var meta: ResponseMeta?

    public init(data: [Resource], meta: ResponseMeta? = nil) {
        self.data = data
        self.meta = meta
    }
}

public struct SingleResponse<Resource: Decodable>: Decodable {
    public var data: Resource

    public init(data: Resource) {
        self.data = data
    }
}

public struct ResponseMeta: Decodable {
    public var pagination: Pagination?

    public init(pagination: Pagination? = nil) {
        self.pagination = pagination
    }
}

public struct Pagination: Decodable {
    public var total: Int?
    public var count: Int?
    public var perPage: Int?
    public var currentPage: Int?
    public var totalPages: Int?

    enum CodingKeys: String, CodingKey {
        case total, count
        case perPage = "per_page"
        case currentPage = "current_page"
        case totalPages = "total_pages"
    }

    public init(total: Int? = nil, count: Int? = nil, perPage: Int? = nil, currentPage: Int? = nil, totalPages: Int? = nil) {
        self.total = total
        self.count = count
        self.perPage = perPage
        self.currentPage = currentPage
        self.totalPages = totalPages
    }
}
