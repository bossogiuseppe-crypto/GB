// CodiceFiscaleCalculatorTests.swift
// Test algoritmici per CodiceFiscaleCalculator.
//
// NOTA: Questo file non è un target XCTest — non esiste un test target nel progetto.
// I test sono implementati come funzioni statiche con assert() e print().
// Per eseguirli, chiama CodiceFiscaleCalculatorTests.runTests() da un punto
// conveniente (es. in ContentView.onAppear durante lo sviluppo).
//
// NOTA — Test non automatizzabili:
//   • "Testare copia negli appunti": richiede un dispositivo fisico o simulatore
//     con UIPasteboard attivo; non verificabile senza UI/device.
//   • "Verificare che il pulsante sia disabilitato con input incompleto":
//     test di UI che richiede XCUITest o ispezione manuale del simulatore.

import Foundation

// MARK: - Helper per costruire date in modo deterministico

private func makeDate(year: Int, month: Int, day: Int) -> Date {
    var comps = DateComponents()
    comps.year  = year
    comps.month = month
    comps.day   = day
    // Usiamo il calendario gregoriano con fuso UTC per evitare ambiguità
    var cal = Calendar(identifier: .gregorian)
    cal.timeZone = TimeZone(identifier: "UTC")!
    return cal.date(from: comps)!
}

// MARK: - Suite di test

struct CodiceFiscaleCalculatorTests {

    // Contatori globali per il riepilogo finale
    private static var passed = 0
    private static var failed = 0

    /// Esegue tutti i test e stampa un riepilogo.
    static func runTests() {
        passed = 0
        failed = 0

        testMarioRossi()
        testAlessandroBianchi_nome4Consonanti()
        testCognomeCortoPaddingX()
        testSessoMaschio()
        testSessoFemmina()
        testCarattereControlloCorretto()

        print("\n=== Risultati: \(passed) passati, \(failed) falliti ===\n")
    }

    // MARK: - Test 1: nome/cognome standard — Mario Rossi

    /// Cognome "Rossi": consonanti R,S,S → RSS
    /// Nome "Mario": consonanti M,R → < 4 cons → M,R + vocali A,I,O → MRA
    /// Anno 1980 → 80, Mese gennaio → A, Giorno 15 maschio → 15
    /// Comune Roma → H501
    /// CF atteso (primi 15 char): RSSMRA80A15H501
    private static func testMarioRossi() {
        let persona = Persona(
            nome: "Mario",
            cognome: "Rossi",
            dataNascita: makeDate(year: 1980, month: 1, day: 15),
            sesso: .maschio,
            comuneNascita: "Roma",
            codiceComune: "H501"
        )
        let risultato = CodiceFiscaleCalculator.calcola(persona: persona)

        // Verifica i primi 15 caratteri (tutto tranne il carattere di controllo)
        let corpo = String(risultato.prefix(15))
        check("Test 1a — Mario Rossi corpo CF", corpo, "RSSMRA80A15H501")

        // Verifica lunghezza totale
        check("Test 1b — Mario Rossi lunghezza = 16", String(risultato.count), "16")
    }

    // MARK: - Test 2: nome con 4+ consonanti — Alessandro Bianchi

    /// Nome "Alessandro": consonanti L,S,S,N,D,R → ≥4 → usa 1a=L, 3a=S, 4a=N → LSN
    /// Cognome "Bianchi": consonanti B,N,C,H → BNC
    /// Anno 1990 → 90, Mese maggio → E, Giorno 20 maschio → 20
    /// Comune Milano → F205
    /// CF atteso: BNCLSN90E20F205G
    private static func testAlessandroBianchi_nome4Consonanti() {
        let persona = Persona(
            nome: "Alessandro",
            cognome: "Bianchi",
            dataNascita: makeDate(year: 1990, month: 5, day: 20),
            sesso: .maschio,
            comuneNascita: "Milano",
            codiceComune: "F205"
        )
        let atteso = "BNCLSN90E20F205G"
        let risultato = CodiceFiscaleCalculator.calcola(persona: persona)
        check("Test 2 — Alessandro Bianchi (nome ≥4 consonanti)", risultato, atteso)
    }

    // MARK: - Test 3: cognome corto con padding X — "Fo"

    /// Cognome "Fo": consonanti=F, vocali=O → F,O → padding → FOX
    /// Nome "Dario": consonanti D,R → < 4 → D,R + vocali A,I,O → DRA
    /// Anno 2000 → 00, Mese giugno → H, Giorno 10 maschio → 10
    /// Comune Roma → H501
    /// CF atteso: FOXDRA00H10H501? (carattere di controllo calcolato)
    private static func testCognomeCortoPaddingX() {
        let persona = Persona(
            nome: "Dario",
            cognome: "Fo",
            dataNascita: makeDate(year: 2000, month: 6, day: 10),
            sesso: .maschio,
            comuneNascita: "Roma",
            codiceComune: "H501"
        )
        let risultato = CodiceFiscaleCalculator.calcola(persona: persona)

        // Verifica strutturale: i primi 3 caratteri devono essere "FOX"
        let cognomeParte = String(risultato.prefix(3))
        check("Test 3a — Cognome corto 'Fo' → parte cognome = FOX", cognomeParte, "FOX")

        // Verifica lunghezza totale: il CF deve essere sempre 16 caratteri
        check("Test 3b — Lunghezza CF = 16", String(risultato.count), "16")
    }

    // MARK: - Test 4: sesso maschile — giorno invariato

    /// Giorno 15, maschio → parte giorno = "15"
    private static func testSessoMaschio() {
        let persona = Persona(
            nome: "Luca",
            cognome: "Verdi",
            dataNascita: makeDate(year: 1985, month: 3, day: 15),
            sesso: .maschio,
            comuneNascita: "Napoli",
            codiceComune: "F839"
        )
        let risultato = CodiceFiscaleCalculator.calcola(persona: persona)
        // Posizioni 10–11 (indice 9–10) = parte giorno
        let giornoParte = String(risultato.dropFirst(9).prefix(2))
        check("Test 4 — Sesso maschio: giorno invariato (15 → '15')", giornoParte, "15")
    }

    // MARK: - Test 5: sesso femminile — giorno + 40

    /// Giorno 8, femmina → 8 + 40 = 48 → parte giorno = "48"
    /// Maria Rossi, 1995-03-08, femmina, Roma (H501)
    /// Cognome "Rossi" → RSS, Nome "Maria" → MRA
    /// Anno 95, Mese marzo → C, Giorno 48
    /// CF atteso: RSSMRA95C48H501C
    private static func testSessoFemmina() {
        let persona = Persona(
            nome: "Maria",
            cognome: "Rossi",
            dataNascita: makeDate(year: 1995, month: 3, day: 8),
            sesso: .femmina,
            comuneNascita: "Roma",
            codiceComune: "H501"
        )
        let risultato = CodiceFiscaleCalculator.calcola(persona: persona)

        // Verifica parte giorno (posizioni 10–11, indice 9–10)
        let giornoParte = String(risultato.dropFirst(9).prefix(2))
        check("Test 5a — Sesso femmina: giorno + 40 (8 → '48')", giornoParte, "48")

        // Verifica CF completo
        let atteso = "RSSMRA95C48H501C"
        check("Test 5b — Maria Rossi femmina CF completo", risultato, atteso)
    }

    // MARK: - Test 6: carattere di controllo — verifica algoritmo

    /// Il carattere di controllo deve essere una lettera maiuscola A–Z.
    /// Verifica anche che il CF di Mario Rossi abbia il corpo corretto
    /// e che il carattere di controllo sia deterministico (stesso input → stesso output).
    private static func testCarattereControlloCorretto() {
        let persona = Persona(
            nome: "Mario",
            cognome: "Rossi",
            dataNascita: makeDate(year: 1980, month: 1, day: 15),
            sesso: .maschio,
            comuneNascita: "Roma",
            codiceComune: "H501"
        )
        let risultato1 = CodiceFiscaleCalculator.calcola(persona: persona)
        let risultato2 = CodiceFiscaleCalculator.calcola(persona: persona)

        // Il carattere di controllo deve essere una lettera A–Z
        let cc = risultato1.last!
        let isLettera = cc >= "A" && cc <= "Z"
        check("Test 6a — Carattere di controllo è lettera A–Z", isLettera ? "ok" : "no", "ok")

        // Il calcolo deve essere deterministico
        check("Test 6b — Calcolo deterministico (stesso input → stesso output)", risultato1, risultato2)

        // Il corpo (primi 15 char) deve essere corretto indipendentemente dal check char
        let corpo = String(risultato1.prefix(15))
        check("Test 6c — Corpo CF Mario Rossi corretto", corpo, "RSSMRA80A15H501")
    }

    // MARK: - Utility

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
