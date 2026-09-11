import Foundation

#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

public struct FireflyClient: FireflyAPI, Sendable {
    public var baseURL: URL
    public var token: String
    public var session: URLSession

    public init(baseURL: URL, token: String, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.token = token
        self.session = session
    }

    public init(config: FinaConfig, session: URLSession = .shared) throws {
        let trimmed =
            config.baseURL.hasSuffix("/") ? String(config.baseURL.dropLast()) : config.baseURL
        guard let url = URL(string: trimmed) else {
            throw FireflyError.invalidBaseURL(config.baseURL)
        }
        self.init(baseURL: url, token: config.token, session: session)
    }

    func apiURL(_ path: String, query: [URLQueryItem] = []) -> URL? {
        var comps = URLComponents(
            url: baseURL.appendingPathComponent("api/v1\(path)"), resolvingAgainstBaseURL: false)
        if !query.isEmpty {
            comps?.queryItems = query
        }
        return comps?.url
    }

    func makeRequest(url: URL, method: String, body: Data? = nil) -> URLRequest {
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        if let body {
            req.setValue("application/json", forHTTPHeaderField: "Content-Type")
            req.httpBody = body
        }
        return req
    }

    func perform<T: Decodable>(_ request: URLRequest, as type: T.Type) async throws -> T {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw FireflyError.networkError(error.localizedDescription)
        }
        guard let http = response as? HTTPURLResponse else {
            throw FireflyError.networkError("Invalid response")
        }
        guard (200..<300).contains(http.statusCode) else {
            let msg = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw FireflyError.requestFailed(status: http.statusCode, message: msg)
        }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw FireflyError.decodingFailed(error.localizedDescription)
        }
    }

    public func listAccounts() async throws -> [Account] {
        guard let url = apiURL("/accounts") else {
            throw FireflyError.invalidBaseURL(baseURL.absoluteString)
        }
        let decoded: ListResponse<AccountResource> = try await perform(
            makeRequest(url: url, method: "GET"), as: ListResponse<AccountResource>.self)
        return decoded.data.map(Account.from(resource:))
    }

    public func listTransactions(limit: Int?, account: String?) async throws -> [TransactionView] {
        var query: [URLQueryItem] = []
        if let limit {
            query.append(URLQueryItem(name: "limit", value: String(limit)))
        }
        guard let url = apiURL("/transactions", query: query) else {
            throw FireflyError.invalidBaseURL(baseURL.absoluteString)
        }
        let decoded: ListResponse<TransactionResource> = try await perform(
            makeRequest(url: url, method: "GET"), as: ListResponse<TransactionResource>.self)
        var views: [TransactionView] = []
        for group in decoded.data {
            for split in group.attributes.transactions ?? [] {
                views.append(TransactionView.from(groupId: group.id, split: split))
            }
        }
        // Reverse-chronological is API default; filter first, then cap the
        // filtered result so combined --account + --limit behaves predictably.
        if let account, !account.isEmpty {
            views = views.filter { $0.source == account || $0.destination == account }
        }
        if let limit, views.count > limit {
            views = Array(views.prefix(limit))
        }
        return views
    }

    public func createTransaction(split: TransactionSplitRequest) async throws -> String {
        let store = try TransactionStoreRequest(transactions: [split])
        guard let url = apiURL("/transactions") else {
            throw FireflyError.invalidBaseURL(baseURL.absoluteString)
        }
        let body = try JSONEncoder().encode(store)
        let decoded: SingleResponse<TransactionResource> = try await perform(
            makeRequest(url: url, method: "POST", body: body),
            as: SingleResponse<TransactionResource>.self)
        return decoded.data.id
    }

    public func updateTransaction(id: String, fields: TransactionUpdateFields) async throws
        -> String
    {
        let split = fields.makeSplit(journalId: fields.journalId)
        let update = try TransactionUpdateRequest(transactions: [split])
        guard let url = apiURL("/transactions/\(id)") else {
            throw FireflyError.invalidBaseURL(baseURL.absoluteString)
        }
        let body = try JSONEncoder().encode(update)
        let decoded: SingleResponse<TransactionResource> = try await perform(
            makeRequest(url: url, method: "PUT", body: body),
            as: SingleResponse<TransactionResource>.self)
        return decoded.data.id
    }
}
