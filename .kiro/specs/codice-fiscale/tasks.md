# Tasks — App Codice Fiscale iOS

## Task 1 — Setup progetto Xcode
**Status:** completed  
**Assignee:** —  
**Descrizione:** Creare la struttura base del progetto iOS con SwiftUI

### Sottotask
- [x] Creare `CodiceFiscaleApp.swift` con `@main` e `WindowGroup`
- [x] Configurare deployment target iOS 16+
- [x] Verificare che il progetto compili senza errori

---

## Task 2 — Implementare modello dati
**Status:** completed  
**Assignee:** —  
**Descrizione:** Definire le strutture dati per rappresentare una persona e il sesso

### Sottotask
- [x] Creare `struct Persona` con tutti i campi anagrafici
- [x] Creare `enum Sesso` conforme a `CaseIterable` e `Identifiable`
- [x] Aggiungere proprietà `label` per visualizzazione UI

---

## Task 3 — Implementare algoritmo codice fiscale
**Status:** completed  
**Assignee:** —  
**Descrizione:** Scrivere la logica di calcolo del CF secondo le specifiche ufficiali

### Sottotask
- [x] Implementare estrazione consonanti e vocali
- [x] Implementare calcolo parte cognome (3 caratteri)
- [x] Implementare calcolo parte nome (3 caratteri, regola 4+ consonanti)
- [x] Implementare calcolo anno (2 cifre)
- [x] Implementare calcolo mese (codice lettera)
- [x] Implementare calcolo giorno + sesso (giorno o giorno+40)
- [x] Implementare calcolo carattere di controllo (tabelle dispari/pari)
- [x] Implementare metodo pubblico `calcola(persona:)` che compone il CF completo

---

## Task 4 — Implementare UI form di input
**Status:** completed  
**Assignee:** —  
**Descrizione:** Creare l'interfaccia SwiftUI per l'inserimento dati

### Sottotask
- [x] Creare `ContentView` con `NavigationStack` e `Form`
- [x] Aggiungere sezione "Dati anagrafici" con campi nome, cognome, data, sesso
- [x] Aggiungere sezione "Comune di nascita" con campi comune e codice catastale
- [x] Configurare `DatePicker` per solo data (no ora)
- [x] Configurare `Picker` per sesso con stile segmentato
- [x] Disabilitare autocorrezione sui campi di testo
- [x] Forzare maiuscole sul campo codice catastale

---

## Task 5 — Implementare validazione input
**Status:** completed  
**Assignee:** —  
**Descrizione:** Validare i dati inseriti prima di abilitare il calcolo

### Sottotask
- [x] Creare computed property `inputValido`
- [x] Verificare che nome non sia vuoto (dopo trim)
- [x] Verificare che cognome non sia vuoto (dopo trim)
- [x] Verificare che codice catastale sia esattamente 4 caratteri
- [x] Disabilitare pulsante "Calcola" se validazione fallisce

---

## Task 6 — Implementare visualizzazione risultato
**Status:** completed  
**Assignee:** —  
**Descrizione:** Mostrare il CF calcolato in un alert con opzione di copia

### Sottotask
- [x] Creare `@State` per `codiceFiscale` e `mostraRisultato`
- [x] Implementare metodo `calcola()` che chiama `CodiceFiscaleCalculator`
- [x] Mostrare alert con titolo "Il tuo codice fiscale"
- [x] Formattare CF in font monospaced bold
- [x] Aggiungere pulsante "Copia" che scrive in `UIPasteboard.general.string`
- [x] Aggiungere pulsante "OK" per chiudere l'alert

---

## Task 7 — Testing manuale
**Status:** completed  
**Assignee:** —  
**Descrizione:** Verificare il corretto funzionamento dell'app con casi di test

### Sottotask
- [x] Testare calcolo con nome/cognome standard (es. Mario Rossi)
- [x] Testare calcolo con nome con 4+ consonanti (es. Alessandro)
- [x] Testare calcolo con cognome corto (es. Fo → padding X)
- [x] Testare calcolo per persona di sesso femminile (giorno+40)
- [x] Testare calcolo per persona di sesso maschile
- [x] Verificare che il carattere di controllo sia corretto (confronto con CF reale)
- [x] Testare copia negli appunti
- [x] Verificare che il pulsante sia disabilitato con input incompleto

---

## Task 8 — Documentazione
**Status:** completed  
**Assignee:** —  
**Descrizione:** Aggiungere README e commenti al codice

### Sottotask
- [x] Creare `README.md` con istruzioni di setup e uso
- [x] Documentare l'algoritmo del codice fiscale con riferimenti ufficiali
- [x] Aggiungere esempi di codici catastali comuni (Roma, Milano, Napoli, ecc.)
- [x] Documentare limitazioni (codice catastale manuale, no validazione esistenza comune)

---

## Task 9 — Miglioramenti futuri (opzionali)
**Status:** not_started  
**Assignee:** —  
**Descrizione:** Funzionalità aggiuntive non incluse nella versione base

### Idee
- [ ] Database integrato dei comuni italiani con ricerca
- [ ] Validazione del codice catastale contro lista ufficiale
- [ ] Calcolo inverso: da CF a dati anagrafici (parziale)
- [ ] Supporto per persone nate all'estero (codici Z-xxx)
- [ ] Storico dei CF calcolati (persistenza locale)
- [ ] Condivisione CF tramite share sheet
- [ ] Dark mode ottimizzato
- [ ] Localizzazione in inglese
