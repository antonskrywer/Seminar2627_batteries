# Seminar2627_batteries

Kurze psychTestR-Testbatterien für das Seminar „Musikalische Entwicklung und
ihre Messbarkeit“ (WS 26/27). Die Studierenden führen sie im Seminarraum durch,
die Ergebnisse erscheinen im Lernmonitor (`../learning_monitor`).

## Batterien

| Ordner | Test | Ablauf | Wert im Monitor |
|---|---|---|---|
| [`jaj_battery/`](jaj_battery/) | Johann und Johanna Gedächtnistest (`JAJ`), visuell-räumliches Arbeitsgedächtnis, adaptiv | Matrikelnummer → Begrüßung, Übung, 16 Items → Schluss | `JAJ$ability` (IRT-Fähigkeitswert) |
| [`bds_battery/`](bds_battery/) | Backwards Digit Span (`BDS`), Ziffernfolgen rückwärts | Matrikelnummer → Begrüßung, Übung, 18 Items → Schluss | `BDS$score` (Anteil richtiger Antworten, 0–1) |

- Standardlänge der Pakete, keine Rückmeldung im Test, Ansprache mit „Du“.
- Die ID ist die Matrikelnummer, wie in den Lernprotokollen. Eine eigene
  ID-Seite ersetzt `get_p_id()`, damit eine Wiederholung eine neue Sitzung
  beginnt, statt die alte fortzusetzen.
- BDS ist nicht adaptiv und schätzt keinen Fähigkeitswert. Deshalb zeigt der
  Monitor den Anteil richtiger Antworten.

## Starten

Arbeitsverzeichnis ist die Projektwurzel:

```r
shiny::runApp("jaj_battery")
shiny::runApp("bds_battery")
```

Benötigte Pakete: `psychTestR`, `psychTestRCAT`, `JAJ`, `BDS`
(GitHub: `klausfrieler/JAJ`, `klausfrieler/BDS`).

## Dots-Server

1. Die Ordner `jaj_battery/` und `bds_battery/` nach `/srv/shiny-server/`
   kopieren und `output/` für den Nutzer `shiny` beschreibbar machen.
2. Das Admin-Passwort kommt wie bei den Lernprotokollen aus
   `PROTOCOL_ADMIN_PASSWORD` (`/home/shiny/.Renviron`).
3. Die Ergebnisordner in `MONITOR_TEST_DIRS` des Lernmonitors eintragen:
   `/srv/shiny-server/jaj_battery/output/results;/srv/shiny-server/bds_battery/output/results`

Ergebnisse (`output/`) gehören nicht ins Repository.
