import Foundation

enum QuoteService {
    private static func yahooURL(_ ticker: String, range: String = "1d", interval: String = "1d") -> URL {
        let t = ticker.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? ticker
        return URL(string: "https://query1.finance.yahoo.com/v8/finance/chart/\(t)?interval=\(interval)&range=\(range)")!
    }

    nonisolated static func fetchQuote(_ ticker: String) async throws -> Quote {
        let (data, _) = try await URLSession.shared.data(from: yahooURL(ticker))
        return try parseQuote(data: data, ticker: ticker)
    }

    nonisolated static func fetchHistory(_ ticker: String, range: String) async throws -> [ChartPoint] {
        let interval = range == "1d" ? "5m" : "1d"
        let (data, _) = try await URLSession.shared.data(from: yahooURL(ticker, range: range, interval: interval))
        return try parseHistory(data: data)
    }

    private static func parseQuote(data: Data, ticker: String) throws -> Quote {
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard
            let chart = json?["chart"] as? [String: Any],
            let results = chart["result"] as? [[String: Any]],
            let first = results.first,
            let meta = first["meta"] as? [String: Any],
            let price = meta["regularMarketPrice"] as? Double
        else { throw URLError(.cannotParseResponse) }

        let prev = (meta["previousClose"] as? Double) ?? (meta["chartPreviousClose"] as? Double) ?? price
        let change = price - prev
        let name = (meta["shortName"] as? String) ?? ticker
        return Quote(ticker: ticker, price: price, change: change,
                     changePercent: prev > 0 ? (change / prev) * 100 : 0, name: name)
    }

    private static func parseHistory(data: Data) throws -> [ChartPoint] {
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard
            let chart = json?["chart"] as? [String: Any],
            let results = chart["result"] as? [[String: Any]],
            let first = results.first,
            let timestamps = first["timestamp"] as? [Double],
            let indicators = first["indicators"] as? [String: Any],
            let quoteArr = indicators["quote"] as? [[String: Any]],
            let closes = quoteArr.first?["close"] as? [Double?]
        else { throw URLError(.cannotParseResponse) }

        let fmt = DateFormatter()
        fmt.dateFormat = "MMM d"

        return timestamps.enumerated().compactMap { i, ts in
            guard i < closes.count, let val = closes[i], val > 0 else { return nil }
            let date = Date(timeIntervalSince1970: ts)
            return ChartPoint(index: i, value: val, label: fmt.string(from: date))
        }
    }

    nonisolated static func fetchManyQuotes(_ tickers: [String]) async -> [String: Quote] {
        await withTaskGroup(of: (String, Quote?).self) { group in
            for ticker in tickers {
                group.addTask {
                    let q = try? await fetchQuote(ticker)
                    return (ticker, q)
                }
            }
            var result: [String: Quote] = [:]
            for await (ticker, quote) in group {
                if let q = quote { result[ticker] = q }
            }
            return result
        }
    }
}
