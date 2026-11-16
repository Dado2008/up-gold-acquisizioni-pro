# UP GOLD CRM PRO

## Architettura
Landing pubblica invariata; applicazione CRM separata, responsive. Backend PostgreSQL con autenticazione, ruoli e isolamento dei dati per organizzazione. Nessuna credenziale o dato cliente nel repository pubblico.

## Moduli
- Dashboard: contatti, trattative, appuntamenti, ricavi e scadenze.
- Proprietari: scheda, recapiti, immobili, stato, ultimo contatto, prossima azione.
- Pipeline: nuovo, da contattare, contattato, in attesa, appuntamento, previsionale inviato, firmato, non interessato, non risponde.
- Storico: attività datate, autore, esito, note e cambi di stato.
- Calendario e promemoria: appuntamenti, richiami, scadenze; integrazione Google Calendar da autorizzare.
- Previsionali: tariffa, occupazione, OTA, gestione, pulizie e imposte configurabili; export PDF.
- Contratti: archivio privato, scadenze e mandati.
- Amministrazione: registrazione commissioni, fatture e pagamenti.
- WhatsApp Business: link manuale iniziale; API ufficiale e consenso prima delle automazioni.
- AI: riepiloghi e bozze, con verifica umana.
- Report giornaliero: prossime azioni, arretrati e trattative.

## Modello dati
organizations, memberships, contacts, properties, activities, tasks, appointments, forecasts, contracts, invoices, payments. Ogni record appartiene a una organizzazione; attività legate al contatto e cronologia append-only. Controlli server-side, backup, esportazione e cancellazione controllate.

## Regole
Ogni modifica commerciale registra data, autore e attività. Un contatto inattivo da 7 giorni (soglia configurabile) appare nel report; scadenze e richiami non completati restano visibili. Invii esterni solo con autorizzazione e configurazione. Nessun dato reale prima di autenticazione e verifica dei permessi.

## Milestone
1. Schema, autenticazione e test di isolamento.
2. Schede, pipeline, storico e dashboard.
3. Calendario, previsionale, archivio e amministrazione.
4. Integrazioni, automazioni, test e rilascio.
