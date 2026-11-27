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
sudo rsync -a --exclude output /srv/shiny-server/Seminar2627_batteries/tom_battery/ /srv/shiny-server/musikalische_entwicklung_messen/TOM/
sudo chown -R shiny:shiny /srv/shiny-server/musikalische_entwicklung_messen/JAJ /srv/shiny-server/musikalische_entwicklung_messen/BDS /srv/shiny-server/musikalische_entwicklung_messen/TOM
sudo touch /srv/shiny-server/musikalische_entwicklung_messen/JAJ/restart.txt /srv/shiny-server/musikalische_entwicklung_messen/BDS/restart.txt /srv/shiny-server/musikalische_entwicklung_messen/TOM/restart.txt
```

`--exclude output` sorgt dafür, dass erhobene Daten erhalten bleiben.

## TOM-Fragebogen ergänzen

Ziel-URL: `http://<Server>:3838/musikalische_entwicklung_messen/TOM/`

### 1. Code holen und Paket prüfen *(harmlos)*

```bash
cd /srv/shiny-server/Seminar2627_batteries && sudo git pull
Rscript -e 'packageVersion("psyquest"); sum(psyquest::psyquest_item_bank$q_id == "TOM")'
```

Erwartet: eine Versionsnummer und `12`.

### 2. App kopieren und laden *(harmlos)*

```bash
sudo rsync -a --exclude output /srv/shiny-server/Seminar2627_batteries/tom_battery/ /srv/shiny-server/musikalische_entwicklung_messen/TOM/
sudo chown -R shiny:shiny /srv/shiny-server/musikalische_entwicklung_messen/TOM
sudo touch /srv/shiny-server/musikalische_entwicklung_messen/TOM/restart.txt
```

### 3. Im Browser ausprobieren

Mit der Test-ID `99999999` zweimal durchlaufen, einmal Durchgang 1, einmal
Durchgang 2. Beide Male muss der Fragebogen von vorn beginnen. Danach:

```bash
ls /srv/shiny-server/musikalische_entwicklung_messen/TOM/output/results
```

### 4. Lernmonitor: neue Version und Vorjahresdaten

Den Monitor auf den neuen Stand bringen, so wie er bisher deployt wurde
(`git pull` in seinem Ordner, dann `restart.txt`).

Prüfen, ob `MONITOR_TEST_DIRS` fest eingetragen ist:

```bash
sudo grep MONITOR_TEST_DIRS /home/shiny/.Renviron
```

Steht dort eine feste Liste (nur JAJ und BDS), findet der Monitor den TOM
nicht. Dann die Zeile mit `sudo nano /home/shiny/.Renviron` löschen (der
Standard `/srv/shiny-server/musikalische_entwicklung_messen/*/output/results`
findet alle Batterien) oder den TOM-Pfad mit `;` anfügen.

Die TOM-Werte aus dem WiSe 25/26 liegen lokal in
`learning_monitor/data/tom_wise2526.csv` (erzeugt mit
`learning_monitor/tools/convert_tom_wise2526.R`). Sie enthalten
Matrikelnummern und kommen deshalb nicht in ein Repository und nicht unter
`/srv/shiny-server`, sondern nach `/home/shiny/monitor_data`. Vom eigenen
Rechner hochladen:

```bash
scp learning_monitor/data/tom_wise2526.csv ubuntu@<Server>:/tmp/
```

Auf dem Server:

```bash
sudo mkdir -p /home/shiny/monitor_data
sudo mv /tmp/tom_wise2526.csv /home/shiny/monitor_data/
sudo chown -R shiny:shiny /home/shiny/monitor_data
sudo chmod 700 /home/shiny/monitor_data && sudo chmod 600 /home/shiny/monitor_data/tom_wise2526.csv
sudo touch /srv/shiny-server/<monitor-ordner>/restart.txt
```

Im Monitor mit `99999999` anmelden: In der Übersicht stehen zwei
TOM-Zeilen je Skala mit Durchgang 1 und 2; unter Univariat gibt es
„Anfang der Sitzung“, „Ende der Sitzung“ und „Veränderung“.

### 5. Testdaten löschen *(löscht Daten!)*

Nur solange noch keine Studierenden den TOM ausgefüllt haben:

```bash
sudo rm -rf /srv/shiny-server/musikalische_entwicklung_messen/TOM/output
```

## Fehlersuche

App zeigt „An error has occurred“:

```bash
ls -t /var/log/shiny-server/ | head -5
sudo tail -50 /var/log/shiny-server/<neueste Datei>
```
