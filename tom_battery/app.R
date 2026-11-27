# TOM-Batterie (Seminar "Musikalische Entwicklung und ihre Messbarkeit", WS 26/27)
#
# Fragebogen zur Selbsttheorie der Musikalität (Theory of Musicality, TOM,
# psyquest, 12 Items). Ablauf: Matrikelnummer, Durchgang, TOM (Instruktion,
# 12 Items), Schlussseite. Keine Rückmeldung im Fragebogen: Die Skalenwerte
# (TOM$Incremental, TOM$Entity) erscheinen im Lernmonitor.
#
# Der Fragebogen wird in einer Sitzung zweimal ausgefüllt (Anfang und Ende).
# Die Studierenden geben an, zum wievielten Mal sie ihn ausfüllen, das
# letzte Jahr eingerechnet (1, 2, 3, 4 = "4 oder öfter"). Gespeichert als
# TOM_RUN$run.
#
# Start: shiny::runApp("tom_battery")

library(psychTestR)
library(psyquest)

# ---- Einstellungen ----
# Admin-Passwort aus der Umgebungsvariable PROTOCOL_ADMIN_PASSWORD (auf dem
# Server in /home/shiny/.Renviron), wie bei den Lernprotokollen. Ohne Variable
# gilt ein zufälliges Passwort, das Admin-Panel ist dann nicht erreichbar.
admin_password <- Sys.getenv("PROTOCOL_ADMIN_PASSWORD")
if (admin_password == "") admin_password <- paste(sample(c(letters, 0:9), 24, TRUE), collapse = "")

# ---- Dictionary ----
battery_dict <- i18n_dict$new(read.csv2("tom_battery_dict.csv", fileEncoding = "UTF-8",
                                        stringsAsFactors = FALSE))

# ---- ID-Seite ----
# Eigene Seite statt get_p_id(): get_p_id() setzt eine gespeicherte Sitzung
# mit derselben ID fort. Beim zweiten Durchgang landete man so auf der
# Schlussseite, statt neu zu beginnen. Als Funktion, weil i18n() nur
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

# ---- Durchgang ----
# Eigenes Modul, damit die Antwort als TOM_RUN$run in der Ergebnisdatei steht.
run_page <- function() join(
  begin_module("TOM_RUN"),
  NAFC_page(
    label   = "run",
    prompt  = shiny::p(i18n("RUN_PROMPT")),
    choices = c("1", "2", "3", "4"),
    labels  = list("1", "2", "3", i18n("RUN_4")),
    arrange_vertically = FALSE,
    button_style = "min-width: 80px"
  ),
  end_module()
)

# ---- Timeline ----
elts <- join(
  new_timeline(join(id_page(), run_page()), dict = battery_dict),
  TOM(),
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
