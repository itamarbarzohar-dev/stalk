import Foundation
import SwiftUI

// MARK: - Market Calendar

enum MarketCalendar {
    static let eastern = TimeZone(identifier: "America/New_York")!

    // MARK: - Holiday logic

    static func isUSMarketHoliday(_ date: Date) -> Bool {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = eastern
        let year  = cal.component(.year,    from: date)
        let month = cal.component(.month,   from: date)
        let day   = cal.component(.day,     from: date)

        // Observe Saturday holidays on Friday, Sunday on Monday
        func observed(_ m: Int, _ d: Int) -> (month: Int, day: Int) {
            var comps = DateComponents(year: year, month: m, day: d)
            comps.timeZone = eastern
            let h = cal.date(from: comps)!
            let wd = cal.component(.weekday, from: h)
            if wd == 7 { // Saturday → Friday
                let fri = cal.date(byAdding: .day, value: -1, to: h)!
                return (cal.component(.month, from: fri), cal.component(.day, from: fri))
            }
            if wd == 1 { // Sunday → Monday
                let mon = cal.date(byAdding: .day, value: 1, to: h)!
                return (cal.component(.month, from: mon), cal.component(.day, from: mon))
            }
            return (m, d)
        }

        // Fixed observed holidays
        let newYear    = observed(1, 1)
        let juneteenth = observed(6, 19)
        let july4      = observed(7, 4)
        let christmas  = observed(12, 25)

        if month == newYear.month    && day == newYear.day    { return true }
        if month == juneteenth.month && day == juneteenth.day { return true }
        if month == july4.month      && day == july4.day      { return true }
        if month == christmas.month  && day == christmas.day  { return true }

        // MLK Day: 3rd Monday of January
        if month == 1 {
            let mlk = nthWeekday(2, week: 3, month: 1, year: year, cal: cal)
            if day == mlk { return true }
        }

        // Presidents Day: 3rd Monday of February
        if month == 2 {
            let pres = nthWeekday(2, week: 3, month: 2, year: year, cal: cal)
            if day == pres { return true }
        }

        // Good Friday: 2 days before Easter
        if let gf = goodFriday(year: year, cal: cal) {
            let gfMonth = cal.component(.month, from: gf)
            let gfDay   = cal.component(.day,   from: gf)
            if month == gfMonth && day == gfDay { return true }
        }

        // Memorial Day: last Monday of May
        if month == 5 {
            let mem = lastWeekday(2, month: 5, year: year, cal: cal)
            if day == mem { return true }
        }

        // Labor Day: 1st Monday of September
        if month == 9 {
            let lab = nthWeekday(2, week: 1, month: 9, year: year, cal: cal)
            if day == lab { return true }
        }

        // Thanksgiving: 4th Thursday of November
        if month == 11 {
            let tg = nthWeekday(5, week: 4, month: 11, year: year, cal: cal)
            if day == tg { return true }
        }

        return false
    }

    private static func nthWeekday(_ weekday: Int, week: Int, month: Int, year: Int, cal: Calendar) -> Int {
        var comps = DateComponents(year: year, month: month, day: 1)
        comps.timeZone = eastern
        let first = cal.date(from: comps)!
        let firstWD = cal.component(.weekday, from: first)
        var offset = weekday - firstWD
        if offset < 0 { offset += 7 }
        let day = 1 + offset + (week - 1) * 7
        return day
    }

    private static func lastWeekday(_ weekday: Int, month: Int, year: Int, cal: Calendar) -> Int {
        // Find last day of month
        var comps = DateComponents(year: year, month: month + 1, day: 0)
        comps.timeZone = eastern
        let lastDay = cal.date(from: comps)!
        let lastDayNum = cal.component(.day, from: lastDay)
        let lastWD = cal.component(.weekday, from: lastDay)
        var offset = lastWD - weekday
        if offset < 0 { offset += 7 }
        return lastDayNum - offset
    }

    private static func goodFriday(year: Int, cal: Calendar) -> Date? {
        // Gauss Easter algorithm
        let a = year % 19
        let b = year / 100
        let c = year % 100
        let d = b / 4
        let e = b % 4
        let f = (b + 8) / 25
        let g = (b - f + 1) / 3
        let h = (19 * a + b - d - g + 15) % 30
        let i = c / 4
        let k = c % 4
        let l = (32 + 2 * e + 2 * i - h - k) % 7
        let m = (a + 11 * h + 22 * l) / 451
        let month = (h + l - 7 * m + 114) / 31
        let day   = ((h + l - 7 * m + 114) % 31) + 1

        var comps = DateComponents(year: year, month: month, day: day)
        comps.timeZone = eastern
        guard let easter = cal.date(from: comps) else { return nil }
        return cal.date(byAdding: .day, value: -2, to: easter)
    }

    // MARK: - Public API

    static func isTradingDay(_ date: Date = Date()) -> Bool {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = eastern
        let wd = cal.component(.weekday, from: date)
        if wd == 1 || wd == 7 { return false }
        return !isUSMarketHoliday(date)
    }

    static func marketOpenDate(on date: Date = Date()) -> Date {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = eastern
        var c = cal.dateComponents([.year, .month, .day], from: date)
        c.hour = 9; c.minute = 30; c.second = 0; c.timeZone = eastern
        return cal.date(from: c)!
    }

    static func marketCloseDate(on date: Date = Date()) -> Date {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = eastern
        var c = cal.dateComponents([.year, .month, .day], from: date)
        c.hour = 16; c.minute = 0; c.second = 0; c.timeZone = eastern
        return cal.date(from: c)!
    }

    static func nextTradingDay(after date: Date = Date()) -> Date {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = eastern
        var d = cal.date(byAdding: .day, value: 1, to: date)!
        var limit = 0
        while !isTradingDay(d) && limit < 10 {
            d = cal.date(byAdding: .day, value: 1, to: d)!
            limit += 1
        }
        return d
    }

    static func status(at date: Date = Date()) -> MarketStatus {
        let now = date
        if isTradingDay(now) {
            let open  = marketOpenDate(on: now)
            let close = marketCloseDate(on: now)
            if now < open  { return .preMarket(opensIn: open.timeIntervalSince(now), opensAt: open) }
            if now < close { return .open(closesIn: close.timeIntervalSince(now)) }
        }
        let nextDay  = nextTradingDay(after: now)
        let nextOpen = marketOpenDate(on: nextDay)
        return .closed(opensIn: nextOpen.timeIntervalSince(now), nextDay: nextDay)
    }
}

// MARK: - Market Status

enum MarketStatus {
    case open(closesIn: TimeInterval)
    case preMarket(opensIn: TimeInterval, opensAt: Date)
    case closed(opensIn: TimeInterval, nextDay: Date)

    var isLive: Bool { if case .open = self { return true }; return false }

    var dotColor: Color {
        switch self {
        case .open:      return Color(hex: "#22C55E")
        case .preMarket: return Color(hex: "#F59E0B")
        case .closed:    return Color(hex: "#94A3B8")
        }
    }

    var label: String {
        switch self {
        case .open:      return "Market Open"
        case .preMarket: return "Pre-Market"
        case .closed:    return "Market Closed"
        }
    }

    var subtitle: String {
        switch self {
        case .open(let t):
            return "Closes in \(t.hhmm)"
        case .preMarket(let t, _):
            return "Opens in \(t.hhmm)"
        case .closed(let t, let d):
            let f = DateFormatter(); f.dateFormat = "EEEE"
            return "Opens \(f.string(from: d)) in \(t.hhmm)"
        }
    }
}

extension TimeInterval {
    var hhmm: String {
        let total = max(0, Int(self))
        let h = total / 3600
        let m = (total % 3600) / 60
        if h > 0 { return "\(h)h \(m)m" }
        return "\(m)m"
    }
}
