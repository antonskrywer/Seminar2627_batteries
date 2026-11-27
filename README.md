# Seminar2627_batteries

Kurze psychTestR-Testbatterien für das Seminar „Musikalische Entwicklung und
ihre Messbarkeit“ (WS 26/27). Die Studierenden führen sie im Seminarraum durch,
die Ergebnisse erscheinen im Lernmonitor (`../learning_monitor`).

## Batterien

| Ordner | Test | Ablauf | Wert im Monitor |
|---|---|---|---|
| [`jaj_battery/`](jaj_battery/) | Johann und Johanna Gedächtnistest (`JAJ`), visuell-räumliches Arbeitsgedächtnis, adaptiv | Matrikelnummer → Begrüßung, Übung, 16 Items → Schluss | `JAJ$ability` (IRT-Fähigkeitswert) |
| [`bds_battery/`](bds_battery/) | Backwards Digit Span (`BDS`), Ziffernfolgen rückwärts | Matrikelnummer → Begrüßung, Übung, 18 Items → Schluss | `BDS$score` (Anteil richtiger Antworten, 0–1) |
| [`tom_battery/`](tom_battery/) | Fragebogen zur Selbsttheorie der Musikalität (`psyquest::TOM`), 12 Items | Matrikelnummer → Durchgang (1, 2, 3, 4 oder öfter) → Instruktion, 12 Items → Schluss | `TOM$Incremental`, `TOM$Entity` (Skalenmittel 1–5), Durchgang `TOM_RUN$run` |

- Standardlänge der Pakete, keine Rückmeldung im Test, Ansprache mit „Du“
  (der TOM-Text selbst ist die psyquest-Fassung mit kleinem „du“).
- Den TOM füllen die Studierenden in einer Sitzung zweimal aus, am Anfang und
  am Ende. Sie geben an, zum wievielten Mal, das letzte Jahr eingerechnet.
  Der Monitor zeigt den Durchgang in der Übersicht; Anfang und Ende bestimmt
  er aber aus der Uhrzeit, nicht aus der Angabe.
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
shiny::runApp("tom_battery")
```

Benötigte Pakete: `psychTestR`, `psychTestRCAT`, `JAJ`, `BDS`, `psyquest`
(GitHub: `klausfrieler/JAJ`, `klausfrieler/BDS`, `klausfrieler/psyquest`).

## Dots-Server

Die Apps laufen unter `/musikalische_entwicklung_messen/JAJ/`,
`/musikalische_entwicklung_messen/BDS/` und `/musikalische_entwicklung_messen/TOM/`.
Schritt für Schritt: [DEPLOY.md](DEPLOY.md).

- Admin-Passwort wie bei den Lernprotokollen aus `PROTOCOL_ADMIN_PASSWORD`
  (`/home/shiny/.Renviron`).
- Der Lernmonitor findet die Ergebnisse jeder Batterie unter
  `/srv/shiny-server/musikalische_entwicklung_messen/*/output/results` von selbst
  (Standard von `MONITOR_TEST_DIRS`).

Ergebnisse (`output/`) gehören nicht ins Repository.
