import Foundation

struct Persona {
    var nome: String
    var cognome: String
    var dataNascita: Date
    var sesso: Sesso
    var comuneNascita: String
    var codiceComune: String // codice catastale (es. "H501" per Roma)
}

enum Sesso: String, CaseIterable, Identifiable {
    case maschio = "M"
    case femmina = "F"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .maschio: return "Maschio"
        case .femmina: return "Femmina"
        }
    }
}
