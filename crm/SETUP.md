# Attivazione CRM privato
1. Creare un progetto Supabase dedicato, in regione UE.
2. In Authentication disabilitare le registrazioni pubbliche e creare manualmente l'unico account amministratore. Non condividere la password in chat.
3. Eseguire database/schema.sql nel SQL Editor di un progetto vuoto. Inserire nella tabella private.crm_owner l'UUID dell'account appena creato.
4. Copiare config.example.js in config.js e impostare URL del progetto e chiave publishable (mai service_role).
5. Provare account.html su HTTPS. Verificare che anonimi e utenti autenticati non autorizzati non possano leggere o modificare alcuna tabella CRM.
6. Verificare inserimento contatto, modifica stato, data richiamo, storico, persistenza dopo ricarica e logout.
7. Solo dopo esito positivo pubblicare i file dell'applicazione nel ramo main; mantenere tutti i dati dei clienti esclusivamente nel database privato.
8. Configurare backup, MFA, documenti privati e tempi di conservazione prima dell'uso produttivo.

## Stato
Il prototipo pubblico non salva dati. Il modulo account è in sviluppo; non ancora collaudato su un progetto Supabase attivo. Le integrazioni WhatsApp e AI non sono attive.
