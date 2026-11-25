# Deployment auf dem Dots-Server

Ziel-URLs:

```
http://<Server>:3838/musikalische_entwicklung_messen/JAJ/
http://<Server>:3838/musikalische_entwicklung_messen/BDS/
```

Shiny Server bildet Ordner unter `/srv/shiny-server` direkt auf URL-Pfade ab
(Groß-/Kleinschreibung zählt). Die Apps kommen also nach
`/srv/shiny-server/musikalische_entwicklung_messen/JAJ` bzw. `.../BDS`.

Grundsatz: **kein** `sudo systemctl restart shiny-server` (bricht laufende
Sitzungen anderer Studien ab). Einzelne Apps lädt man mit `restart.txt` neu.

## Erstes Deployment

### 1. Einloggen

Wie gewohnt per SSH auf den Server (`ubuntu@…`).

### 2. Repository holen *(harmlos)*

```bash
cd /srv/shiny-server
sudo git clone https://github.com/antonskrywer/Seminar2627_batteries.git
```

### 3. Pakete prüfen *(harmlos, nur lesen)*

```bash
Rscript -e 'packageVersion("psychTestR"); packageVersion("psychTestRCAT"); packageVersion("JAJ"); packageVersion("BDS"); args(BDS::BDS)'
```

Erwartet: fünf Ausgaben ohne Fehler; `args(BDS::BDS)` enthält
`with_training` und `with_finish`.

### 4. Apps in die Zielordner kopieren *(harmlos)*

```bash
sudo mkdir -p /srv/shiny-server/musikalische_entwicklung_messen
sudo rsync -a --exclude output /srv/shiny-server/Seminar2627_batteries/jaj_battery/ /srv/shiny-server/musikalische_entwicklung_messen/JAJ/
sudo rsync -a --exclude output /srv/shiny-server/Seminar2627_batteries/bds_battery/ /srv/shiny-server/musikalische_entwicklung_messen/BDS/
sudo chown -R shiny:shiny /srv/shiny-server/musikalische_entwicklung_messen/JAJ /srv/shiny-server/musikalische_entwicklung_messen/BDS
```

Der Schrägstrich am Ende der Quelle (`jaj_battery/`) ist wichtig: Sonst
landet der Ordner als `JAJ/jaj_battery` im Ziel.

### 5. Admin-Passwort prüfen

Die Batterien nutzen dasselbe Passwort wie die Lernprotokolle
(`PROTOCOL_ADMIN_PASSWORD`). Prüfen (Ausgabe `1` = gesetzt):

```bash
sudo grep -c PROTOCOL_ADMIN_PASSWORD /home/shiny/.Renviron
```

Nur bei `0`, `DEIN_PASSWORT` ersetzen:

```bash
echo 'PROTOCOL_ADMIN_PASSWORD=DEIN_PASSWORT' | sudo tee -a /home/shiny/.Renviron
```

### 6. Apps laden *(harmlos, betrifft nur diese Apps)*

```bash
sudo touch /srv/shiny-server/musikalische_entwicklung_messen/JAJ/restart.txt
sudo touch /srv/shiny-server/musikalische_entwicklung_messen/BDS/restart.txt
```

### 7. Im Browser ausprobieren

Beide URLs von oben mit einer Test-ID (z. B. `99999999`) einmal ganz
durchlaufen. Prüfen: Texte deutsch und mit „Du“, Übung, 16 (JAJ) bzw. 18
(BDS) Items, keine Rückmeldung, am Ende „Deine Ergebnisse wurden
gespeichert“. Danach:

```bash
ls /srv/shiny-server/musikalische_entwicklung_messen/JAJ/output/results
ls /srv/shiny-server/musikalische_entwicklung_messen/BDS/output/results
```

### 8. Lernmonitor anbinden

Zuerst den Monitor auf den neuen Stand bringen (BDS-Eintrag, Commit
`57e8ad1` in `learning_monitor`), so wie er bisher deployt wurde.

Dann die Ergebnisordner in `MONITOR_TEST_DIRS` eintragen. Prüfen, ob die
Variable schon existiert:

```bash
sudo grep MONITOR_TEST_DIRS /home/shiny/.Renviron
```

- **Keine Ausgabe:** neu anlegen.

  ```bash
  echo 'MONITOR_TEST_DIRS=/srv/shiny-server/musikalische_entwicklung_messen/JAJ/output/results;/srv/shiny-server/musikalische_entwicklung_messen/BDS/output/results' | sudo tee -a /home/shiny/.Renviron
  ```

- **Zeile vorhanden:** nicht noch einmal anhängen, sondern mit
  `sudo nano /home/shiny/.Renviron` die beiden Pfade, getrennt durch `;`,
  an die bestehende Zeile anfügen.

Der Monitor liest die Variable nur beim Start, deshalb ihn neu laden
(`<monitor-ordner>` = Ordner des Lernmonitors unter `/srv/shiny-server`):

```bash
sudo touch /srv/shiny-server/<monitor-ordner>/restart.txt
```

Im Monitor mit der Test-ID anmelden: In der Übersicht stehen
„Arbeitsgedächtnis (JAJ)“ und „Ziffernfolgen rückwärts (BDS)“.

### 9. Testdaten löschen, bevor die Studierenden testen *(löscht Daten!)*

Nur ausführen, solange noch keine echten Teilnehmenden dabei waren:

```bash
sudo rm -rf /srv/shiny-server/musikalische_entwicklung_messen/JAJ/output
sudo rm -rf /srv/shiny-server/musikalische_entwicklung_messen/BDS/output
```

Die Ordner werden beim nächsten Durchlauf neu angelegt.

## Updates

```bash
cd /srv/shiny-server/Seminar2627_batteries && sudo git pull
sudo rsync -a --exclude output /srv/shiny-server/Seminar2627_batteries/jaj_battery/ /srv/shiny-server/musikalische_entwicklung_messen/JAJ/
sudo rsync -a --exclude output /srv/shiny-server/Seminar2627_batteries/bds_battery/ /srv/shiny-server/musikalische_entwicklung_messen/BDS/
sudo chown -R shiny:shiny /srv/shiny-server/musikalische_entwicklung_messen/JAJ /srv/shiny-server/musikalische_entwicklung_messen/BDS
sudo touch /srv/shiny-server/musikalische_entwicklung_messen/JAJ/restart.txt /srv/shiny-server/musikalische_entwicklung_messen/BDS/restart.txt
```

`--exclude output` sorgt dafür, dass erhobene Daten erhalten bleiben.

## Fehlersuche

App zeigt „An error has occurred“:

```bash
ls -t /var/log/shiny-server/ | head -5
sudo tail -50 /var/log/shiny-server/<neueste Datei>
```
