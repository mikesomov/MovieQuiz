import Foundation

extension Date {
    var dateTimeString: String {
        DateFormatter.moscowDateTime.string(from: self)
    }
}

private extension DateFormatter {
    static let moscowDateTime: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
        dateFormatter.timeZone = TimeZone(identifier: "Europe/Moscow")
        return dateFormatter
    }()
}
