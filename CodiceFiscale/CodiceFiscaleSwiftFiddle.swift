// ============================================================
// Codice pronto per SwiftFiddle — swiftfiddle.com
// Incolla tutto questo file e premi Run
// ============================================================

import Foundation

// MARK: - Modelli

struct Persona {
    var nome: String
    var cognome: String
    var dataNascita: Date
    var sesso: Sesso
    var comuneNascita: String
    var codiceComune: String
}

enum Sesso: String {
    case maschio = "M"
    case femmina = "F"
}

// MARK: - Calcolatore

struct CodiceFiscaleCalculator {

    static func calcola(persona: Persona) -> String {
        let cf = cognomeParte(persona.cognome)
             + nomeParte(persona.nome)
             + annoParte(persona.dataNascita)
             + meseParte(persona.dataNascita)
             + giornoParte(persona.dataNascita, sesso: persona.sesso)
             + persona.codiceComune.uppercased()
        return cf + carattereControllo(cf)
    }

    private static func consonanti(_ s: String) -> [Character] {
        s.uppercased().filter { "BCDFGHJKLMNPQRSTVWXYZ".contains($0) }
    }

    private static func vocali(_ s: String) -> [Character] {
        s.uppercased().filter { "AEIOU".contains($0) }
    }

    private static func cognomeParte(_ cognome: String) -> String {
        var chars = consonanti(cognome) + vocali(cognome)
        while chars.count < 3 { chars.append("X") }
        return String(chars.prefix(3))
    }

    private static func nomeParte(_ nome: String) -> String {
        let cons = consonanti(nome)
        if cons.count >= 4 {
            return String([cons[0], cons[2], cons[3]])
        }
        var chars = cons + vocali(nome)
        while chars.count < 3 { chars.append("X") }
        return String(chars.prefix(3))
    }

    private static func annoParte(_ data: Date) -> String {
        let anno = Calendar.current.component(.year, from: data)
        return String(format: "%02d", anno % 100)
    }

    private static let codiciMese = ["A","B","C","D","E","H","L","M","P","R","S","T"]

    private static func meseParte(_ data: Date) -> String {
        let mese = Calendar.current.component(.month, from: data)
        return codiciMese[mese - 1]
    }

    private static func giornoParte(_ data: Date, sesso: Sesso) -> String {
        var giorno = Calendar.current.component(.day, from: data)
        if sesso == .femmina { giorno += 40 }
        return String(format: "%02d", giorno)
    }

    private static func carattereControllo(_ cf: String) -> String {
        let dispari: [Character: Int] = [
            "0":1,"1":0,"2":5,"3":7,"4":9,"5":13,"6":15,"7":17,"8":19,"9":21,
            "A":1,"B":0,"C":5,"D":7,"E":9,"F":13,"G":15,"H":17,"I":19,"J":21,
            "K":2,"L":4,"M":18,"N":20,"O":11,"P":3,"Q":6,"R":8,"S":12,"T":14,
            "U":16,"V":10,"W":22,"X":25,"Y":24,"Z":23
        ]
        let pari: [Character: Int] = [
            "0":0,"1":1,"2":2,"3":3,"4":4,"5":5,"6":6,"7":7,"8":8,"9":9,
            "A":0,"B":1,"C":2,"D":3,"E":4,"F":5,"G":6,"H":7,"I":8,"J":9,
            "K":10,"L":11,"M":12,"N":13,"O":14,"P":15,"Q":16,"R":17,"S":18,"T":19,
            "U":20,"V":21,"W":22,"X":23,"Y":24,"Z":25
        ]
        var somma = 0
        for (i, char) in cf.uppercased().enumerated() {
            somma += (i % 2 == 0) ? (dispari[char] ?? 0) : (pari[char] ?? 0)
        }
        return String(Character(UnicodeScalar(65 + somma % 26)!))
    }
}

// MARK: - Helper date

func makeDate(year: Int, month: Int, day: Int) -> Date {
    var comps = DateComponents()
    comps.year  = year
    comps.month = month
    comps.day   = day
    var cal = Calendar(identifier: .gregorian)
    cal.timeZone = TimeZone(identifier: "UTC")!
    return cal.date(from: comps)!
}

// MARK: - Suite di test

struct Tests {
    private static var passed = 0
    private static var failed = 0

    static func run() {
        passed = 0
        failed = 0

        testMarioRossi()
        testAlessandroBianchi()
        testCognomeCortoPaddingX()
        testSessoMaschio()
        testSessoFemmina()
        testCarattereControllo()
        testGiuseppeBosso()

        print("\n=== Risultati: \(passed) passati, \(failed) falliti ===")
    }

    private static func testMarioRossi() {
        let p = Persona(nome: "Mario", cognome: "Rossi",
                        dataNascita: makeDate(year: 1980, month: 1, day: 15),
                        sesso: .maschio, comuneNascita: "Roma", codiceComune: "H501")
        let cf = CodiceFiscaleCalculator.calcola(persona: p)
        check("Mario Rossi — corpo CF",     String(cf.prefix(15)), "RSSMRA80A15H501")
        check("Mario Rossi — lunghezza 16", String(cf.count),      "16")
    }

    private static func testAlessandroBianchi() {
        let p = Persona(nome: "Alessandro", cognome: "Bianchi",
                        dataNascita: makeDate(year: 1990, month: 5, day: 20),
                        sesso: .maschio, comuneNascita: "Milano", codiceComune: "F205")
        check("Alessandro Bianchi — nome ≥4 consonanti",
              CodiceFiscaleCalculator.calcola(persona: p), "BNCLSN90E20F205G")
    }

    private static func testCognomeCortoPaddingX() {
        let p = Persona(nome: "Dario", cognome: "Fo",
                        dataNascita: makeDate(year: 2000, month: 6, day: 10),
                        sesso: .maschio, comuneNascita: "Roma", codiceComune: "H501")
        let cf = CodiceFiscaleCalculator.calcola(persona: p)
        check("Cognome 'Fo' → padding FOX", String(cf.prefix(3)), "FOX")
        check("Cognome corto — lunghezza 16", String(cf.count), "16")
    }

    private static func testSessoMaschio() {
        let p = Persona(nome: "Luca", cognome: "Verdi",
                        dataNascita: makeDate(year: 1985, month: 3, day: 15),
                        sesso: .maschio, comuneNascita: "Napoli", codiceComune: "F839")
        let cf = CodiceFiscaleCalculator.calcola(persona: p)
        check("Maschio — giorno invariato (15 → '15')",
              String(cf.dropFirst(9).prefix(2)), "15")
    }

    private static func testSessoFemmina() {
        let p = Persona(nome: "Maria", cognome: "Rossi",
                        dataNascita: makeDate(year: 1995, month: 3, day: 8),
                        sesso: .femmina, comuneNascita: "Roma", codiceComune: "H501")
        let cf = CodiceFiscaleCalculator.calcola(persona: p)
        check("Femmina — giorno +40 (8 → '48')",
              String(cf.dropFirst(9).prefix(2)), "48")
        check("Maria Rossi femmina — CF completo", cf, "RSSMRA95C48H501C")
    }

    private static func testCarattereControllo() {
        let p = Persona(nome: "Mario", cognome: "Rossi",
                        dataNascita: makeDate(year: 1980, month: 1, day: 15),
                        sesso: .maschio, comuneNascita: "Roma", codiceComune: "H501")
        let cf1 = CodiceFiscaleCalculator.calcola(persona: p)
        let cf2 = CodiceFiscaleCalculator.calcola(persona: p)
        let cc  = cf1.last!
        check("Carattere controllo è lettera A–Z", (cc >= "A" && cc <= "Z") ? "ok" : "no", "ok")
        check("Calcolo deterministico", cf1, cf2)
    }

    private static func testGiuseppeBosso() {
        // Giuseppe Bosso, nato a Zofingen (Svizzera) il 12/09/1969
        // Cognome "Bosso": B,S,S → BSS
        // Nome "Giuseppe": consonanti G,S,P,P → ≥4 → usa 1a=G, 3a=P, 4a=P → GPP
        // Anno 1969 → 69, Mese settembre → P, Giorno 12 maschio → 12
        // Comune Zofingen (Svizzera) → Z133
        // CF atteso: BSSGPP69P12Z133S
        let p = Persona(nome: "Giuseppe", cognome: "Bosso",
                        dataNascita: makeDate(year: 1969, month: 9, day: 12),
                        sesso: .maschio, comuneNascita: "Zofingen", codiceComune: "Z133")
        check("Giuseppe Bosso — CF completo",
              CodiceFiscaleCalculator.calcola(persona: p), "BSSGPP69P12Z133S")
    }

    private static func check(_ nome: String, _ ottenuto: String, _ atteso: String) {
        if ottenuto == atteso {
            passed += 1
            print("✅ PASS — \(nome)")
        } else {
            failed += 1
            print("❌ FAIL — \(nome)")
            print("         Atteso:   \(atteso)")
            print("         Ottenuto: \(ottenuto)")
        }
    }
}

// MARK: - Esegui

Tests.run()
