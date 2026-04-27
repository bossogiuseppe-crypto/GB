# Requisiti — App Codice Fiscale iOS

## Introduzione

App iOS nativa in SwiftUI che calcola il codice fiscale italiano a partire dai dati anagrafici di una persona, seguendo l'algoritmo ufficiale dell'Agenzia delle Entrate.

---

## Requisiti

### REQ-1 — Inserimento dati anagrafici
**Come** utente  
**Voglio** inserire i miei dati anagrafici (nome, cognome, data di nascita, sesso)  
**Per** ottenere il mio codice fiscale

#### Criteri di accettazione
- [ ] L'utente può inserire il nome tramite campo di testo libero
- [ ] L'utente può inserire il cognome tramite campo di testo libero
- [ ] L'utente può selezionare la data di nascita tramite DatePicker nativo iOS
- [ ] L'utente può selezionare il sesso (Maschio / Femmina) tramite controllo segmentato
- [ ] I campi nome e cognome hanno autocorrezione disabilitata

---

### REQ-2 — Inserimento comune di nascita
**Come** utente  
**Voglio** inserire il comune di nascita e il relativo codice catastale  
**Per** completare il calcolo del codice fiscale

#### Criteri di accettazione
- [ ] L'utente può inserire il nome del comune di nascita (campo libero, opzionale ai fini del calcolo)
- [ ] L'utente può inserire il codice catastale del comune (es. `H501` per Roma), obbligatorio per il calcolo
- [ ] Il campo codice catastale accetta esattamente 4 caratteri alfanumerici in maiuscolo
- [ ] Il tasto di calcolo è disabilitato finché il codice catastale non ha 4 caratteri

---

### REQ-3 — Calcolo del codice fiscale
**Come** utente  
**Voglio** premere un pulsante per calcolare il codice fiscale  
**Per** ottenere il risultato in modo immediato

#### Criteri di accettazione
- [ ] Il calcolo segue l'algoritmo ufficiale italiano:
  - Cognome: 3 caratteri (consonanti poi vocali, padding con X)
  - Nome: 3 caratteri (se ≥4 consonanti usa 1a, 3a, 4a; altrimenti consonanti + vocali + X)
  - Anno: ultime 2 cifre dell'anno di nascita
  - Mese: lettera codice mese (A=Gen, B=Feb, C=Mar, D=Apr, E=Mag, H=Giu, L=Lug, M=Ago, P=Set, R=Ott, S=Nov, T=Dic)
  - Giorno: giorno di nascita (maschio: 01–31, femmina: giorno + 40)
  - Comune: codice catastale in maiuscolo (4 caratteri)
  - Carattere di controllo: calcolato su posizioni dispari e pari con tabelle ufficiali
- [ ] Il codice fiscale risultante è sempre di 16 caratteri
- [ ] Il calcolo è eseguito interamente lato client, senza chiamate di rete

---

### REQ-4 — Visualizzazione e copia del risultato
**Come** utente  
**Voglio** vedere il codice fiscale calcolato e poterlo copiare  
**Per** usarlo dove ne ho bisogno

#### Criteri di accettazione
- [ ] Il risultato viene mostrato in un alert modale con font monospaced
- [ ] L'alert offre il pulsante "Copia" che copia il codice fiscale negli appunti di sistema (`UIPasteboard`)
- [ ] L'alert offre il pulsante "OK" per chiuderlo senza copiare

---

### REQ-5 — Validazione input
**Come** utente  
**Voglio** che l'app mi impedisca di calcolare con dati incompleti  
**Per** evitare risultati errati

#### Criteri di accettazione
- [ ] Il pulsante "Calcola" è disabilitato se nome è vuoto
- [ ] Il pulsante "Calcola" è disabilitato se cognome è vuoto
- [ ] Il pulsante "Calcola" è disabilitato se il codice catastale non è esattamente di 4 caratteri
- [ ] I campi di testo ignorano spazi iniziali e finali prima del calcolo (trim)

---

## Vincoli tecnici

- Linguaggio: Swift 5.9+
- UI framework: SwiftUI
- Deployment target: iOS 16+ (richiesto da `NavigationStack`)
- Nessuna dipendenza esterna (zero librerie di terze parti)
- Nessuna persistenza dei dati (no CoreData, no UserDefaults)
- Nessuna connessione di rete richiesta
