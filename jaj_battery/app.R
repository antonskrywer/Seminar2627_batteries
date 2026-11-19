# JAJ-Batterie (Seminar "Musikalische Entwicklung und ihre Messbarkeit", WS 26/27)
#
# Johann und Johanna Gedächtnistest (JAJ, visuell-räumliches Arbeitsgedächtnis,
# adaptiv, IRT) in Standardlänge. Ablauf: Matrikelnummer, JAJ (Begrüßung,
# Übung, 16 Items), Schlussseite. Keine Rückmeldung im Test: Das Ergebnis
# (JAJ$ability) erscheint im Lernmonitor.
#
# Start: shiny::runApp("jaj_battery")

library(psychTestR)
library(JAJ)

# ---- Einstellungen ----
# Admin-Passwort aus der Umgebungsvariable PROTOCOL_ADMIN_PASSWORD (auf dem
# Server in /home/shiny/.Renviron), wie bei den Lernprotokollen. Ohne Variable
# gilt ein zufälliges Passwort, das Admin-Panel ist dann nicht erreichbar.
admin_password <- Sys.getenv("PROTOCOL_ADMIN_PASSWORD")
if (admin_password == "") admin_password <- paste(sample(c(letters, 0:9), 24, TRUE), collapse = "")

# ---- Dictionary ----
battery_dict <- i18n_dict$new(read.csv2("jaj_battery_dict.csv", fileEncoding = "UTF-8",
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
elts <- join(
  new_timeline(id_page(), dict = battery_dict),
  JAJ(num_items = 16L, take_training = TRUE, with_welcome = TRUE,
      with_finish = FALSE, feedback = NULL),
  elt_save_results_to_disk(complete = TRUE),
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
