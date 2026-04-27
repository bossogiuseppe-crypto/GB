import Foundation

/// Calcola il codice fiscale italiano a partire dai dati anagrafici di una persona.
///
/// L'algoritmo segue le specifiche ufficiali dell'Agenzia delle Entrate (D.M. 23 dicembre 1976).
/// Il codice fiscale risultante è sempre di 16 caratteri:
/// ```
/// [Cognome 3] [Nome 3] [Anno 2] [Mese 1] [Giorno+Sesso 2] [Comune 4] [Controllo 1]
/// ```
struct CodiceFiscaleCalculator {

    // MARK: - Public

    /// Calcola il codice fiscale completo (16 caratteri) per la persona fornita.
    ///
    /// - Parameter persona: I dati anagrafici della persona, incluso il codice catastale del comune di nascita.
    /// - Returns: Il codice fiscale di 16 caratteri in maiuscolo.
    static func calcola(persona: Persona) -> String {
        let cf = cognomeParte(persona.cognome)
             + nomeParte(persona.nome)
             + annoParte(persona.dataNascita)
             + meseParte(persona.dataNascita)
             + giornoParte(persona.dataNascita, sesso: persona.sesso)
             + persona.codiceComune.uppercased()
        return cf + carattereControllo(cf)
    }

    // MARK: - Consonanti e vocali

    /// Restituisce le consonanti presenti nella stringa, in ordine, in maiuscolo.
    private static func consonanti(_ s: String) -> [Character] {
        s.uppercased().filter { "BCDFGHJKLMNPQRSTVWXYZ".contains($0) }
    }

    /// Restituisce le vocali presenti nella stringa, in ordine, in maiuscolo.
    private static func vocali(_ s: String) -> [Character] {
        s.uppercased().filter { "AEIOU".contains($0) }
    }

    // MARK: - Cognome (3 caratteri)

    /// Calcola i 3 caratteri del cognome per il codice fiscale.
    ///
    /// Regola: consonanti in ordine + vocali in ordine + padding `X` se necessario.
    /// Vengono presi i primi 3 caratteri del risultato.
    private static func cognomeParte(_ cognome: String) -> String {
        var chars = consonanti(cognome) + vocali(cognome)
        while chars.count < 3 { chars.append("X") }
        return String(chars.prefix(3))
    }

    // MARK: - Nome (3 caratteri)

    /// Calcola i 3 caratteri del nome per il codice fiscale.
    ///
    /// Regola speciale: se il nome ha 4 o più consonanti, si usano la 1ª, 3ª e 4ª consonante.
    /// Altrimenti: consonanti + vocali + padding `X`, presi i primi 3.
    private static func nomeParte(_ nome: String) -> String {
        let cons = consonanti(nome)
        if cons.count >= 4 {
            // prende 1a, 3a, 4a consonante
            return String([cons[0], cons[2], cons[3]])
        }
        var chars = cons + vocali(nome)
        while chars.count < 3 { chars.append("X") }
        return String(chars.prefix(3))
    }

    // MARK: - Anno (2 cifre)

    /// Restituisce le ultime 2 cifre dell'anno di nascita, con zero iniziale se necessario.
    private static func annoParte(_ data: Date) -> String {
        let anno = Calendar.current.component(.year, from: data)
        return String(format: "%02d", anno % 100)
    }

    // MARK: - Mese (lettera)

    /// Tabella ufficiale dei codici mese: A=Gen, B=Feb, C=Mar, D=Apr, E=Mag, H=Giu,
    /// L=Lug, M=Ago, P=Set, R=Ott, S=Nov, T=Dic.
    private static let codiciMese = ["A","B","C","D","E","H","L","M","P","R","S","T"]

    /// Restituisce il codice lettera del mese di nascita secondo la tabella ufficiale.
    private static func meseParte(_ data: Date) -> String {
        let mese = Calendar.current.component(.month, from: data)
        return codiciMese[mese - 1]
    }

    // MARK: - Giorno + sesso

    /// Calcola i 2 caratteri del giorno di nascita, tenendo conto del sesso.
    ///
    /// - Maschio: giorno di nascita (01–31)
    /// - Femmina: giorno di nascita + 40 (41–71)
    private static func giornoParte(_ data: Date, sesso: Sesso) -> String {
        var giorno = Calendar.current.component(.day, from: data)
        if sesso == .femmina { giorno += 40 }
        return String(format: "%02d", giorno)
    }

    // MARK: - Carattere di controllo

    /// Calcola il carattere di controllo (16° carattere) sui primi 15 caratteri del CF.
    ///
    /// L'algoritmo usa due tabelle di conversione ufficiali:
    /// - `dispari`: valori per i caratteri in posizione dispari (1ª, 3ª, 5ª, ...)
    /// - `pari`: valori per i caratteri in posizione pari (2ª, 4ª, 6ª, ...)
    ///
    /// La somma di tutti i valori viene divisa per 26; il resto indica la lettera
    /// di controllo (A=0, B=1, ..., Z=25).
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
        let lettera = Character(UnicodeScalar(65 + resto)!) // 'A' = 65
        return String(lettera)
    }
}
