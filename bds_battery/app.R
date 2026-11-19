# BDS-Batterie (Seminar "Musikalische Entwicklung und ihre Messbarkeit", WS 26/27)
#
# Backwards Digit Span (BDS, Ziffernfolgen rückwärts, verbales
# Arbeitsgedächtnis) in Standardlänge. Ablauf: Matrikelnummer, BDS
# (Begrüßung, Übung, 18 Items), Schlussseite. Keine Rückmeldung im Test.
#
# Der BDS ist nicht adaptiv und schätzt keinen Fähigkeitswert. Er speichert
# BDS$score (Anteil richtiger Antworten, 0-1) und BDS$num_questions; score
# erscheint im Lernmonitor.
#
# Start: shiny::runApp("bds_battery")

library(psychTestR)
library(BDS)

# ---- Einstellungen ----
# Admin-Passwort aus der Umgebungsvariable PROTOCOL_ADMIN_PASSWORD (auf dem
# Server in /home/shiny/.Renviron), wie bei den Lernprotokollen. Ohne Variable
# gilt ein zufälliges Passwort, das Admin-Panel ist dann nicht erreichbar.
admin_password <- Sys.getenv("PROTOCOL_ADMIN_PASSWORD")
if (admin_password == "") admin_password <- paste(sample(c(letters, 0:9), 24, TRUE), collapse = "")

# ---- Dictionary ----
battery_dict <- i18n_dict$new(read.csv2("bds_battery_dict.csv", fileEncoding = "UTF-8",
                                        stringsAsFactors = FALSE))

# ---- ID-Seite ----
# Eigene Seite statt get_p_id(): get_p_id() setzt eine gespeicherte Sitzung
# mit derselben ID fort. Bei einer Wiederholung des Tests landete man so auf
# der Schlussseite, statt neu zu beginnen. Als Funktion, weil i18n() nur
# innerhalb von new_timeline() übersetzt wird.
id_page <- function() text_input_page(
  label       = "p_id",
  prompt      = i18n("ENTER_ID"),
  placeholder = paste(i18n("E.G."), "10492817"),
  button_text = i18n("CONTINUE"),
  save_answer = FALSE,
  validate    = function(answer, ...) {
    if (grepl("^[A-Za-z0-9_]{1,100}$", trimws(answer))) TRUE
    else "Bitte nur Ziffern und Buchstaben eingeben."
  },
  on_complete = function(answer, state, ...) {
    set_p_id <- utils::getFromNamespace("p_id<-", "psychTestR")
    set_p_id(state, trimws(answer))
  }
)

# ---- Timeline ----
# BDS() speichert am Ende selbst (complete = TRUE).
elts <- join(
  new_timeline(id_page(), dict = battery_dict),
  BDS(num_items = 18L, with_welcome = TRUE, with_training = TRUE,
      with_finish = FALSE, feedback = NULL),
  new_timeline(
    final_page(shiny::div(
      shiny::p(shiny::strong(i18n("THANKS"))),
      shiny::p(i18n("RESULTS_SAVED"))
    )),
    dict = battery_dict
  )
)

make_test(
  elts,
  opt = test_options(
    title                 = battery_dict$translate("TITLE", "de"),
    admin_password        = admin_password,
    demo                  = FALSE,
    languages             = "de",
    enable_resume_session = FALSE,
    logo                  = "uhh-logo.svg",
    logo_width            = "110px",
    logo_height           = "auto"
  )
)
