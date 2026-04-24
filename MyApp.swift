// CodiceFiscalePlayground.swift
// Versione per Swift Playgrounds su iPad.
//
// Come usarlo:
// 1. Apri Swift Playgrounds sul tuo iPad
// 2. Crea un nuovo App Playground
// 3. Sostituisci il contenuto di MyApp.swift con questo file

import SwiftUI

// MARK: - Modelli

struct Persona {
    var nome: String
    var cognome: String
    var dataNascita: Date
    var sesso: Sesso
    var comuneNascita: String
    var codiceComune: String
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
        let resto = somma % 26
        return String(Character(UnicodeScalar(65 + resto)!))
    }
}

// MARK: - UI

struct ContentView: View {
    @State private var nome = ""
    @State private var cognome = ""
    @State private var dataNascita = Date()
    @State private var sesso: Sesso = .maschio
    @State private var comuneNascita = ""
    @State private var codiceComune = ""
    @State private var codiceFiscale = ""
    @State private var mostraRisultato = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Dati anagrafici") {
                    TextField("Nome", text: $nome)
                        .autocorrectionDisabled()
                    TextField("Cognome", text: $cognome)
                        .autocorrectionDisabled()
                    DatePicker("Data di nascita", selection: $dataNascita, displayedComponents: .date)
                    Picker("Sesso", selection: $sesso) {
                        ForEach(Sesso.allCases) { s in
                            Text(s.label).tag(s)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("Comune di nascita") {
                    TextField("Comune", text: $comuneNascita)
                        .autocorrectionDisabled()
                    TextField("Codice catastale (es. H501)", text: $codiceComune)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.characters)
                }

                Section {
                    Button(action: calcola) {
                        Label("Calcola codice fiscale", systemImage: "person.text.rectangle")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!inputValido)
                }
            }
            .navigationTitle("Codice Fiscale")
            .alert("Il tuo codice fiscale", isPresented: $mostraRisultato) {
                Button("Copia") {
                    UIPasteboard.general.string = codiceFiscale
                }
                Button("OK", role: .cancel) {}
            } message: {
                Text(codiceFiscale)
                    .font(.system(.title2, design: .monospaced))
                    .bold()
            }
        }
    }

    private var inputValido: Bool {
        !nome.trimmingCharacters(in: .whitespaces).isEmpty &&
        !cognome.trimmingCharacters(in: .whitespaces).isEmpty &&
        codiceComune.count == 4
    }

    private func calcola() {
        let persona = Persona(
            nome: nome.trimmingCharacters(in: .whitespaces),
            cognome: cognome.trimmingCharacters(in: .whitespaces),
            dataNascita: dataNascita,
            sesso: sesso,
            comuneNascita: comuneNascita,
            codiceComune: codiceComune
        )
        codiceFiscale = CodiceFiscaleCalculator.calcola(persona: persona)
        mostraRisultato = true
    }
}

// MARK: - Entry point

@main
struct CodiceFiscaleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
