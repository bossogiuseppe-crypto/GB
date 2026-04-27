// CodiceFiscaleCalculatorXCTests.swift
// Test XCTest per CodiceFiscaleCalculator.
//
// Per eseguire: aggiungi questo file a un target XCTest in Xcode e premi ⌘U.

import XCTest
@testable import CodiceFiscale

final class CodiceFiscaleCalculatorXCTests: XCTestCase {

    // MARK: - Helper

    private func makeDate(year: Int, month: Int, day: Int) -> Date {
        var comps = DateComponents()
        comps.year  = year
        comps.month = month
        comps.day   = day
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC")!
        return cal.date(from: comps)!
    }

    // MARK: - Test 1: Mario Rossi (caso standard)

    /// Cognome "Rossi": R,S,S → RSS
    /// Nome "Mario": M,R + A,I,O → MRA
    /// Anno 1980 → 80, Mese gennaio → A, Giorno 15 maschio → 15
    /// Comune Roma → H501
    func testMarioRossi() {
        let persona = Persona(
            nome: "Mario",
            cognome: "Rossi",
            dataNascita: makeDate(year: 1980, month: 1, day: 15),
            sesso: .maschio,
            comuneNascita: "Roma",
            codiceComune: "H501"
        )
        let cf = CodiceFiscaleCalculator.calcola(persona: persona)
        XCTAssertEqual(String(cf.prefix(15)), "RSSMRA80A15H501")
        XCTAssertEqual(cf.count, 16)
    }

    // MARK: - Test 2: Nome con 4+ consonanti (Alessandro Bianchi)

    /// Nome "Alessandro": L,S,S,N,D,R → ≥4 cons → usa 1a=L, 3a=S, 4a=N → LSN
    /// Cognome "Bianchi": B,N,C,H → BNC
    /// Anno 1990 → 90, Mese maggio → E, Giorno 20 maschio → 20
    /// Comune Milano → F205
    func testNomeConQuattroConsonanti() {
        let persona = Persona(
            nome: "Alessandro",
            cognome: "Bianchi",
            dataNascita: makeDate(year: 1990, month: 5, day: 20),
            sesso: .maschio,
            comuneNascita: "Milano",
            codiceComune: "F205"
        )
        let cf = CodiceFiscaleCalculator.calcola(persona: persona)
        XCTAssertEqual(cf, "BNCLSN90E20F205G")
    }

    // MARK: - Test 3: Cognome corto con padding X ("Fo")

    /// Cognome "Fo": F + O → padding → FOX
    func testCognomeCortoPaddingX() {
        let persona = Persona(
            nome: "Dario",
            cognome: "Fo",
            dataNascita: makeDate(year: 2000, month: 6, day: 10),
            sesso: .maschio,
            comuneNascita: "Roma",
            codiceComune: "H501"
        )
        let cf = CodiceFiscaleCalculator.calcola(persona: persona)
        XCTAssertEqual(String(cf.prefix(3)), "FOX", "Cognome corto deve avere padding X")
        XCTAssertEqual(cf.count, 16)
    }

    // MARK: - Test 4: Sesso maschile — giorno invariato

    func testSessoMaschioGiornoInvariato() {
        let persona = Persona(
            nome: "Luca",
            cognome: "Verdi",
            dataNascita: makeDate(year: 1985, month: 3, day: 15),
            sesso: .maschio,
            comuneNascita: "Napoli",
            codiceComune: "F839"
        )
        let cf = CodiceFiscaleCalculator.calcola(persona: persona)
        let giorno = String(cf.dropFirst(9).prefix(2))
        XCTAssertEqual(giorno, "15", "Maschio: giorno deve essere invariato")
    }

    // MARK: - Test 5: Sesso femminile — giorno + 40

    /// Giorno 8, femmina → 8 + 40 = 48
    func testSessoFemminaGiornoPiuQuaranta() {
        let persona = Persona(
            nome: "Maria",
            cognome: "Rossi",
            dataNascita: makeDate(year: 1995, month: 3, day: 8),
            sesso: .femmina,
            comuneNascita: "Roma",
            codiceComune: "H501"
        )
        let cf = CodiceFiscaleCalculator.calcola(persona: persona)
        let giorno = String(cf.dropFirst(9).prefix(2))
        XCTAssertEqual(giorno, "48", "Femmina: giorno deve essere +40")
        XCTAssertEqual(cf, "RSSMRA95C48H501C")
    }

    // MARK: - Test 6: Carattere di controllo

    func testCarattereControlloELettera() {
        let persona = Persona(
            nome: "Mario",
            cognome: "Rossi",
            dataNascita: makeDate(year: 1980, month: 1, day: 15),
            sesso: .maschio,
            comuneNascita: "Roma",
            codiceComune: "H501"
        )
        let cf = CodiceFiscaleCalculator.calcola(persona: persona)
        let cc = cf.last!
        XCTAssertTrue(cc >= "A" && cc <= "Z", "Carattere di controllo deve essere A–Z")
    }

    func testCalcoloDeterministico() {
        let persona = Persona(
            nome: "Mario",
            cognome: "Rossi",
            dataNascita: makeDate(year: 1980, month: 1, day: 15),
            sesso: .maschio,
            comuneNascita: "Roma",
            codiceComune: "H501"
        )
        XCTAssertEqual(
            CodiceFiscaleCalculator.calcola(persona: persona),
            CodiceFiscaleCalculator.calcola(persona: persona),
            "Stesso input deve produrre sempre lo stesso CF"
        )
    }

    // MARK: - Test 7: Lunghezza sempre 16 caratteri

    func testLunghezzaSempreSediciCaratteri() {
        let casi: [(nome: String, cognome: String, anno: Int, mese: Int, giorno: Int, sesso: Sesso, comune: String)] = [
            ("Mario",      "Rossi",   1980, 1,  15, .maschio, "H501"),
            ("Maria",      "Rossi",   1995, 3,   8, .femmina, "H501"),
            ("Alessandro", "Bianchi", 1990, 5,  20, .maschio, "F205"),
            ("Dario",      "Fo",      2000, 6,  10, .maschio, "H501"),
            ("Luca",       "Verdi",   1985, 3,  15, .maschio, "F839"),
        ]
        for caso in casi {
            let persona = Persona(
                nome: caso.nome,
                cognome: caso.cognome,
                dataNascita: makeDate(year: caso.anno, month: caso.mese, day: caso.giorno),
                sesso: caso.sesso,
                comuneNascita: "",
                codiceComune: caso.comune
            )
            let cf = CodiceFiscaleCalculator.calcola(persona: persona)
            XCTAssertEqual(cf.count, 16, "CF di \(caso.nome) \(caso.cognome) deve essere 16 caratteri, ottenuto: \(cf)")
        }
    }
}
