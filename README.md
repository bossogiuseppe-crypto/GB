# Codice Fiscale

App iOS nativa in SwiftUI per il calcolo del codice fiscale italiano, seguendo l'algoritmo ufficiale dell'Agenzia delle Entrate.

---

## Requisiti

- Xcode 15+
- iOS 16+ (deployment target)
- Swift 5.9+
- Nessuna dipendenza esterna

---

## Setup

```bash
git clone https://github.com/tuoutente/codice-fiscale.git
cd codice-fiscale
open CodiceFiscale.xcodeproj
```

Seleziona un simulatore o dispositivo iOS 16+ e premi **Run** (⌘R).

> Se non hai un file `.xcodeproj`, crea un nuovo progetto Xcode (App, SwiftUI, Swift) e aggiungi i file dalla cartella `CodiceFiscale/`.

---

## Come si usa

1. Apri l'app
2. Inserisci **nome** e **cognome**
3. Seleziona la **data di nascita** con il date picker
4. Scegli il **sesso** (Maschio / Femmina)
5. Inserisci il **comune di nascita** (campo descrittivo, opzionale)
6. Inserisci il **codice catastale** del comune (4 caratteri, es. `H501` per Roma)
7. Premi **Calcola codice fiscale**
8. Il codice fiscale appare in un alert — puoi copiarlo con il pulsante **Copia**

Il pulsante "Calcola" rimane disabilitato finché nome, cognome e codice catastale (4 caratteri) non sono compilati.

---

## Algoritmo del codice fiscale

Il codice fiscale italiano è composto da **16 caratteri** così strutturati:

```
[Cognome 3] [Nome 3] [Anno 2] [Mese 1] [Giorno+Sesso 2] [Comune 4] [Controllo 1]
```

### Cognome (posizioni 1–3)
1. Estrai le consonanti in ordine
2. Aggiungi le vocali in ordine
3. Se il risultato è < 3 caratteri, aggiungi `X` come padding
4. Prendi i primi 3 caratteri

Esempio: `ROSSI` → consonanti `RSS`, vocali `OI` → `RSS`

### Nome (posizioni 4–6)
1. Estrai le consonanti in ordine
2. Se le consonanti sono **4 o più**, usa la 1ª, 3ª e 4ª consonante
3. Altrimenti: consonanti + vocali + padding `X`, prendi i primi 3

Esempio: `MARIO` → consonanti `MR`, vocali `AIO` → `MRA`  
Esempio: `ALESSANDRO` → consonanti `LSSNDR` (≥4) → 1ª=`L`, 3ª=`S`, 4ª=`N` → `LSN`

### Anno (posizioni 7–8)
Ultime 2 cifre dell'anno di nascita, con zero iniziale se necessario.

Esempio: `1985` → `85`

### Mese (posizione 9)
Ogni mese ha un codice lettera secondo la tabella ufficiale:

| Mese | Codice | Mese | Codice |
|------|--------|------|--------|
| Gennaio | A | Luglio | L |
| Febbraio | B | Agosto | M |
| Marzo | C | Settembre | P |
| Aprile | D | Ottobre | R |
| Maggio | E | Novembre | S |
| Giugno | H | Dicembre | T |

### Giorno + sesso (posizioni 10–11)
- **Maschio**: giorno di nascita (01–31)
- **Femmina**: giorno di nascita + 40 (41–71)

Esempio: maschio nato il 7 → `07`; femmina nata il 7 → `47`

### Comune (posizioni 12–15)
Codice catastale del comune di nascita in maiuscolo (4 caratteri alfanumerici).

### Carattere di controllo (posizione 16)
Calcolato sui primi 15 caratteri del CF usando due tabelle di conversione ufficiali:

- **Posizioni dispari** (1ª, 3ª, 5ª, ...): tabella con valori non lineari
- **Posizioni pari** (2ª, 4ª, 6ª, ...): tabella con valori lineari (A=0, B=1, ...)

Si sommano tutti i valori, si calcola `somma % 26` e si converte in lettera (A=0, Z=25).

**Riferimento ufficiale:** [Agenzia delle Entrate — Codice fiscale](https://www.agenziaentrate.gov.it/portale/web/guest/schede/istanze/richiesta-ts_cf/informazioni-codice-fiscale-cittadini)  
**Decreto ministeriale:** D.M. 23 dicembre 1976 (G.U. n. 345 del 29/12/1976)

---

## Codici catastali comuni

Alcuni codici catastali di riferimento per le principali città italiane:

| Comune | Codice catastale |
|--------|-----------------|
| Roma | H501 |
| Milano | F205 |
| Napoli | F839 |
| Torino | L219 |
| Palermo | G273 |
| Genova | D969 |
| Bologna | A944 |
| Firenze | D612 |
| Bari | A662 |
| Venezia | L736 |
| Catania | C351 |
| Verona | L781 |
| Messina | F158 |
| Padova | G224 |
| Trieste | L424 |

Per trovare il codice catastale di qualsiasi comune italiano, consulta il sito dell'[Agenzia delle Entrate](https://www1.agenziaentrate.gov.it/servizi/codici/ricerca/guidaricerca.htm) o il [database ISTAT](https://www.istat.it/it/archivio/6789).

---

## Limitazioni note

- **Codice catastale manuale**: l'app non include un database dei comuni italiani. L'utente deve inserire manualmente il codice catastale a 4 caratteri. Non viene verificato che il codice corrisponda a un comune realmente esistente.
- **Nessuna validazione del comune**: è possibile inserire qualsiasi stringa di 4 caratteri come codice catastale, anche se non valida. Il calcolo verrà eseguito ugualmente.
- **Persone nate all'estero**: i codici per i paesi esteri iniziano con `Z` (es. `Z112` per la Francia). L'app li accetta ma non fornisce una lista di riferimento.
- **Omocodia non gestita**: in caso di omocodia (stesso CF per persone diverse), l'Agenzia delle Entrate sostituisce alcune cifre con lettere. Questa casistica non è gestita dall'app.
- **Nessuna persistenza**: i dati inseriti non vengono salvati tra una sessione e l'altra.

---

## Licenza

MIT License — vedi [LICENSE](LICENSE) per i dettagli.
