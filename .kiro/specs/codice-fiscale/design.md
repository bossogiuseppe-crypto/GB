# Design — App Codice Fiscale iOS

## Architettura

L'app segue un'architettura semplice a tre livelli senza framework esterni:

```
┌─────────────────────────────┐
│         ContentView         │  ← UI layer (SwiftUI)
│  Form con sezioni e alert   │
└────────────┬────────────────┘
             │ chiama
┌────────────▼────────────────┐
│   CodiceFiscaleCalculator   │  ← Business logic (pure functions)
│   Algoritmo stateless       │
└────────────┬────────────────┘
             │ usa
┌────────────▼────────────────┐
│     Models (Persona,        │  ← Data layer (value types)
│     Sesso)                  │
└─────────────────────────────┘
```

---

## Struttura file

| File | Responsabilità |
|------|---------------|
| `CodiceFiscaleApp.swift` | Entry point `@main`, setup `WindowGroup` |
| `Models.swift` | `struct Persona`, `enum Sesso` |
| `CodiceFiscaleCalculator.swift` | Algoritmo di calcolo CF (metodi statici) |
| `ContentView.swift` | Unica schermata: form input + alert risultato |

---

## Modello dati

### `struct Persona`
```swift
struct Persona {
    var nome: String
    var cognome: String
    var dataNascita: Date
    var sesso: Sesso
    var comuneNascita: String   // descrittivo, non usato nel calcolo
    var codiceComune: String    // codice catastale 4 caratteri (es. "H501")
}
```

### `enum Sesso`
```swift
enum Sesso: String, CaseIterable, Identifiable {
    case maschio = "M"
    case femmina = "F"
}
```

---

## Algoritmo codice fiscale

Il calcolo è implementato in `CodiceFiscaleCalculator` con metodi statici privati:

```
CF = cognomeParte(3) + nomeParte(3) + anno(2) + mese(1) + giorno(2) + comune(4) + controllo(1)
   = 16 caratteri totali
```

### Cognome (posizioni 1–3)
1. Estrai consonanti in ordine
2. Aggiungi vocali in ordine
3. Padding con `X` se < 3 caratteri
4. Prendi i primi 3

### Nome (posizioni 4–6)
1. Estrai consonanti in ordine
2. Se consonanti ≥ 4 → usa la 1a, 3a e 4a consonante
3. Altrimenti: consonanti + vocali + padding `X`, prendi i primi 3

### Anno (posizioni 7–8)
- Ultime 2 cifre dell'anno (`anno % 100`, formato `%02d`)

### Mese (posizione 9)
| Mese | Codice |
|------|--------|
| Gennaio | A |
| Febbraio | B |
| Marzo | C |
| Aprile | D |
| Maggio | E |
| Giugno | H |
| Luglio | L |
| Agosto | M |
| Settembre | P |
| Ottobre | R |
| Novembre | S |
| Dicembre | T |

### Giorno + sesso (posizioni 10–11)
- Maschio: giorno di nascita (01–31)
- Femmina: giorno di nascita + 40 (41–71)

### Comune (posizioni 12–15)
- Codice catastale in maiuscolo (4 caratteri, es. `H501`)

### Carattere di controllo (posizione 16)
- Somma i valori di ogni carattere usando due tabelle distinte:
  - Posizioni dispari (1a, 3a, 5a...): tabella `dispari`
  - Posizioni pari (2a, 4a, 6a...): tabella `pari`
- `resto = somma % 26`
- Carattere = lettera dell'alfabeto in posizione `resto` (A=0, B=1, ...)

---

## UI — ContentView

### Layout
```
NavigationStack
└── Form
    ├── Section "Dati anagrafici"
    │   ├── TextField — Nome
    │   ├── TextField — Cognome
    │   ├── DatePicker — Data di nascita
    │   └── Picker (segmented) — Sesso
    ├── Section "Comune di nascita"
    │   ├── TextField — Comune (descrittivo)
    │   └── TextField — Codice catastale (4 char, maiuscolo)
    └── Section (senza titolo)
        └── Button "Calcola codice fiscale" (borderedProminent)
            └── disabilitato se inputValido == false
```

### Alert risultato
```
Alert "Il tuo codice fiscale"
├── Messaggio: codice fiscale in font monospaced bold
├── Button "Copia" → UIPasteboard.general.string = codiceFiscale
└── Button "OK" (cancel)
```

### Logica di validazione (`inputValido`)
```swift
!nome.isEmpty && !cognome.isEmpty && codiceComune.count == 4
```

---

## Flusso utente

```
[Apri app]
     │
     ▼
[Compila form]
     │
     ├─ nome vuoto o cognome vuoto o codice < 4 char
     │        → pulsante disabilitato
     │
     └─ tutti i campi validi
              │
              ▼
         [Premi "Calcola"]
              │
              ▼
     [CodiceFiscaleCalculator.calcola()]
              │
              ▼
     [Alert con CF risultante]
              │
         ┌────┴────┐
         │         │
       [Copia]   [OK]
         │         │
    [Appunti]  [Chiudi]
```
