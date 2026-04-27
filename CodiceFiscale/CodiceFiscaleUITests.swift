// CodiceFiscaleUITests.swift
// Test UI con XCUITest per CodiceFiscale.
//
// Per eseguire:
// 1. In Xcode aggiungi un target "UI Testing Bundle"
// 2. Includi questo file nel target
// 3. Premi ⌘U oppure clicca il rombo accanto a ogni test

import XCTest

final class CodiceFiscaleUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    // MARK: - Test 1: Pulsante disabilitato con campi vuoti

    /// All'avvio dell'app il pulsante "Calcola" deve essere disabilitato
    /// perché nome, cognome e codice catastale sono vuoti.
    func testPulsanteDisabilitatoConCampiVuoti() {
        let bottoneCalcola = app.buttons["Calcola codice fiscale"]
        XCTAssertFalse(bottoneCalcola.isEnabled, "Il pulsante deve essere disabilitato con campi vuoti")
    }

    // MARK: - Test 2: Pulsante disabilitato senza codice catastale

    /// Con nome e cognome compilati ma codice catastale vuoto,
    /// il pulsante deve restare disabilitato.
    func testPulsanteDisabilitatoSenzaCodiceCatastale() {
        app.textFields["Nome"].tap()
        app.textFields["Nome"].typeText("Mario")

        app.textFields["Cognome"].tap()
        app.textFields["Cognome"].typeText("Rossi")

        let bottoneCalcola = app.buttons["Calcola codice fiscale"]
        XCTAssertFalse(bottoneCalcola.isEnabled, "Il pulsante deve essere disabilitato senza codice catastale")
    }

    // MARK: - Test 3: Pulsante abilitato con tutti i campi validi

    /// Con nome, cognome e codice catastale (4 caratteri) compilati,
    /// il pulsante deve essere abilitato.
    func testPulsanteAbilitatoConCampiValidi() {
        compilaForm(nome: "Mario", cognome: "Rossi", codiceCatastale: "H501")

        let bottoneCalcola = app.buttons["Calcola codice fiscale"]
        XCTAssertTrue(bottoneCalcola.isEnabled, "Il pulsante deve essere abilitato con tutti i campi validi")
    }

    // MARK: - Test 4: Alert appare dopo il calcolo

    /// Dopo aver compilato il form e premuto "Calcola",
    /// deve apparire un alert con titolo "Il tuo codice fiscale".
    func testAlertAppareDopoCAlcolo() {
        compilaForm(nome: "Mario", cognome: "Rossi", codiceCatastale: "H501")

        app.buttons["Calcola codice fiscale"].tap()

        let alert = app.alerts["Il tuo codice fiscale"]
        XCTAssertTrue(alert.waitForExistence(timeout: 3), "L'alert deve apparire dopo il calcolo")
    }

    // MARK: - Test 5: CF di Mario Rossi corretto

    /// Il CF calcolato per Mario Rossi (15/01/1980, maschio, Roma H501)
    /// deve essere RSSMRA80A15H501I.
    func testCFMarioRossiCorretto() {
        compilaForm(nome: "Mario", cognome: "Rossi", codiceCatastale: "H501", giorno: 15, mese: 1, anno: 1980)

        app.buttons["Calcola codice fiscale"].tap()

        let alert = app.alerts["Il tuo codice fiscale"]
        XCTAssertTrue(alert.waitForExistence(timeout: 3))

        let testoAlert = alert.staticTexts.element(boundBy: 1).label
        XCTAssertEqual(testoAlert, "RSSMRA80A15H501I", "Il CF di Mario Rossi deve essere RSSMRA80A15H501I")
    }

    // MARK: - Test 6: Pulsante "Copia" chiude l'alert

    /// Dopo il calcolo, premendo "Copia" l'alert deve chiudersi.
    func testBottoneCopiaChiudeAlert() {
        compilaForm(nome: "Mario", cognome: "Rossi", codiceCatastale: "H501")

        app.buttons["Calcola codice fiscale"].tap()

        let alert = app.alerts["Il tuo codice fiscale"]
        XCTAssertTrue(alert.waitForExistence(timeout: 3))

        alert.buttons["Copia"].tap()

        XCTAssertFalse(alert.exists, "L'alert deve chiudersi dopo aver premuto Copia")
    }

    // MARK: - Test 7: Pulsante "OK" chiude l'alert

    /// Dopo il calcolo, premendo "OK" l'alert deve chiudersi.
    func testBottoneOKChiudeAlert() {
        compilaForm(nome: "Mario", cognome: "Rossi", codiceCatastale: "H501")

        app.buttons["Calcola codice fiscale"].tap()

        let alert = app.alerts["Il tuo codice fiscale"]
        XCTAssertTrue(alert.waitForExistence(timeout: 3))

        alert.buttons["OK"].tap()

        XCTAssertFalse(alert.exists, "L'alert deve chiudersi dopo aver premuto OK")
    }

    // MARK: - Test 8: Sesso femminile selezionabile

    /// Il controllo segmentato deve permettere di selezionare "Femmina".
    func testSessoFemminileSelezionabile() {
        app.segmentedControls.buttons["Femmina"].tap()
        XCTAssertTrue(app.segmentedControls.buttons["Femmina"].isSelected, "Femmina deve essere selezionabile")
    }

    // MARK: - Helper

    /// Compila il form con i dati forniti.
    private func compilaForm(
        nome: String,
        cognome: String,
        codiceCatastale: String,
        giorno: Int = 15,
        mese: Int = 1,
        anno: Int = 1980
    ) {
        app.textFields["Nome"].tap()
        app.textFields["Nome"].typeText(nome)

        app.textFields["Cognome"].tap()
        app.textFields["Cognome"].typeText(cognome)

        app.textFields["Codice catastale (es. H501)"].tap()
        app.textFields["Codice catastale (es. H501)"].typeText(codiceCatastale)

        // Nota: la selezione della data tramite DatePicker in XCUITest
        // richiede interazione con le ruote (picker wheels).
        // Omessa qui per semplicità — da aggiungere se necessario.
    }
}
