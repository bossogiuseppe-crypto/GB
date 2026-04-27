import SwiftUI

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

#Preview {
    ContentView()
}
