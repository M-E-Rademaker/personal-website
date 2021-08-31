## ----warning=FALSE, message=FALSE----------------------------------------
require(tidyverse)  # tidyverse packages
require(scales)     # formating numbers
require(sf)         # working with shape files
require(readr)      # fast reading of csv files
require(gt)         # create nice-looking tables
require(patchwork)  # combine plots
require(glue)       # Glue strings to data in R
require(ggiraph)    # Create interactive graphs
require(zoo)        # to compute the rolling 7-day sum
require(xts)        # for working with time series
require(dygraphs)   # interactive time series

## # 2017 german parliamentary election results
## election_results_2017 <- read_csv2("election_results_2017.csv", skip = 5)
## # Shapefile with the geometry of the 299 german Wahlkreise
## wahlkreise_shp_2017   <- st_read("wahlkreise_shp_2017/Geometrie_Wahlkreise_20DBT_VG250_geo.shp")
## # Shapefile with the geometry (including population) of the 401 Landkreise and kreisfreie Städte
## vg250_ew_2020         <- st_read("vg250_ew_2020/vg250-ew_12-31.gk3.shape.ebenen/vg250-ew_ebenen_1231/VG250_KRS.shp")
## # Absolute number of people vaccinated by characteristics
## vaccinated_raw <- read_csv("https://raw.githubusercontent.com/robert-koch-institut/COVID-19-Impfungen_in_Deutschland/master/Aktuell_Deutschland_Landkreise_COVID-19-Impfungen.csv")
## # Absolute number SARS-COV-2 infections by characteristics
## infections_raw <- read_csv("https://media.githubusercontent.com/media/robert-koch-institut/SARS-CoV-2_Infektionen_in_Deutschland/master/Aktuell_Deutschland_SarsCov2_Infektionen.csv")

# 2017 german parliamentary election results
election_results_2017_url <- "https://www.bundeswahlleiter.de/dam/jcr/72f186bb-aa56-47d3-b24c-6a46f5de22d0/btw17_kerg.csv"
download.file(election_results_2017_url, destfile = "election_results_2017.csv")
election_results_2017 <- read_csv2("election_results_2017.csv", skip = 5)

# Shapefile with the geometry of the 299 german Wahlkreise 
wahl_shp_url <- "https://www.bundeswahlleiter.de/dam/jcr/4238f883-5a9b-4da6-a4d5-ac86f3752b88/btw21_geometrie_wahlkreise_vg250_geo_shp.zip"
download.file(wahl_shp_url, destfile = "wahlkreise_shp_2017.zip")
unzip("wahlkreise_shp_2017.zip", exdir = "wahlkreise_shp_2017")
wahlkreise_shp_2017 <- st_read("wahlkreise_shp_2017/Geometrie_Wahlkreise_20DBT_VG250_geo.shp")

# Shapefile with the geometry (including population) of the 401 Landkreise and kreisfreie Städte
vg250_ew_2020_url <- "https://daten.gdz.bkg.bund.de/produkte/vg/vg250-ew_ebenen_1231/aktuell/vg250-ew_12-31.gk3.shape.ebenen.zip"
download.file(vg250_ew_2020_url, destfile = "vg250_ew_2020.zip")
unzip("vg250_ew_2020.zip", exdir = "vg250_ew_2020")
vg250_ew_2020 <- st_read("vg250_ew_2020/vg250-ew_12-31.gk3.shape.ebenen/vg250-ew_ebenen_1231/VG250_KRS.shp")

# Absolute number of people vaccinated by characteristics
vaccinated_raw <- read_csv("https://raw.githubusercontent.com/robert-koch-institut/COVID-19-Impfungen_in_Deutschland/master/Aktuell_Deutschland_Landkreise_COVID-19-Impfungen.csv")

# Absolute number SARS-COV-2 infections by characteristics
infections_raw <- read_csv("https://media.githubusercontent.com/media/robert-koch-institut/SARS-CoV-2_Infektionen_in_Deutschland/master/Aktuell_Deutschland_SarsCov2_Infektionen.csv")


## Load showtext for fonts
require(showtext)

# Load fonts
# font_add(family = "commissioner",
#          regular = "_not_for_git/Commissioner/static/Commissioner-Light.ttf")
# font_add(family = "fraunces",
#          regular = "_not_for_git/Fraunces/static/Fraunces_9pt_Soft/Fraunces_9pt_Soft-Regular.ttf")

# ## Load fonts
# font_add(family = "commissioner",
#          regular = "../fonts/Commissioner-Light.ttf")
# font_add(family = "fraunces",
#          regular = "../fonts/Fraunces_9pt_Soft-Regular.ttf")

## Colors
main_color    = "#516DB0"
txt_color     = "#404040"
bg_color      = "#f2f2f1"
bg_color2     = "#FFFFFF"
# color_scheme  = c("#6796DE", "#B54256", "#EFCB8F", "#569AA3", "#E38D4C")

## Create & set custom theme
website_theme <- theme_light() + theme(
   plot.title       = element_text(color = main_color, family = "fraunces"),
   plot.subtitle    = element_text(color = txt_color, family = "commissioner"),
   plot.caption     = element_text(color = txt_color, family = "commissioner"),
   plot.background  = element_rect(fill = bg_color, color = bg_color),
   axis.title       = element_text(color = txt_color, family = "commissioner"),
   axis.text        = element_text(color = txt_color, family = "commissioner"),
   panel.background = element_rect(color = bg_color2),
   panel.border     = element_blank(),
   legend.background = element_rect(fill = bg_color),
   legend.text      = element_text(color = txt_color, family = "commissioner"),
   legend.title     = element_text(color = txt_color, family = "commissioner")
)

theme_set(website_theme)


## ------------------------------------------------------------------------
election_results_2017 %>% head(16) %>% gt()


## ------------------------------------------------------------------------
election_results <- election_results_2017 %>% 
   # select and rename relevant variables
   select(Wahlkreis_nr = Nr, Wahlkreis = Gebiet, `gehört zu`, Gültig = X18, 
          CDU = X22, SPD = X26, `DIE LINKE` = X30, `DIE GRÜNEN` = X34,
          CSU = X38, FDP = X42, AFD = X46) %>%
   # remove line 1 and 2 (headers)
   slice(-c(1:2)) %>% 
   # convert all columns but the "Wahlkreis" column to numeric
   mutate(across(-Wahlkreis, as.numeric)) %>% 
   # combine CDU and CSU votes across columns (hence rowwise()). 
   # Without rowwise(), computation would be across rows not columns.
   rowwise() %>% 
   mutate("CDU/CSU" = sum(CDU, CSU, na.rm = TRUE)) %>% 
   # ungroup to remove rowwise flag
   ungroup() %>% 
   # remove CDU and CSU columns
   select(-CDU, -CSU)

election_results %>% head(14) %>% gt()


## ------------------------------------------------------------------------
election_results_percent <- election_results %>% 
   # remove rows containing the aggreagted results by Bundesland
   filter(`gehört zu` != 99) %>% 
   # compute percent of valid votes for each party
   mutate(across(-c(Wahlkreis_nr, Wahlkreis, `gehört zu`, Gültig), .fns = ~ (.x / Gültig)*100)) %>%
   # pivot into long format
   pivot_longer(SPD:`CDU/CSU`, names_to = "Party", values_to = "Results")

election_results_percent %>% head(8) %>% gt()


## ------------------------------------------------------------------------
election_cleaned <- election_results %>% 
   # filter only the 16 Bundesländer
   filter(`gehört zu` == 99) %>% 
   select(Bundesland_id = Wahlkreis_nr, Bundesland = Wahlkreis) %>% 
   # join by Wahlkreis_nr and corresponding `gehört zu` column
   right_join(election_results_percent, by = c("Bundesland_id" = "gehört zu")) %>%
   relocate(Bundesland) %>% 
   arrange(Bundesland, Wahlkreis_nr) %>% 
   select(-`Bundesland_id`, -Gültig)

election_cleaned %>% head(8) %>% gt()


## ------------------------------------------------------------------------
party_colors = c(
  "CDU/CSU" = "#000000", 
  "SPD" = "#E3000F", 
  "DIE GRÜNEN" = "#1AA037",
  "DIE LINKE" =  	"#A6006B",
  "FDP" = "#FFEF00",
  "AFD" =  "#0489DB")

election_cleaned %>% 
   filter(Wahlkreis_nr == 251) %>%
   # convert Party to factor and reorder levels by party results (decending) 
   # to ensure bars are ordered in decending order as well
   mutate(Party = fct_reorder(Party, -Results)) %>% 
   ggplot(aes(x = Party, y = Results, fill = Party)) + 
   geom_col(show.legend = FALSE, alpha = 0.7) + 
   geom_text(aes(label = scales::percent(Results/100)), nudge_y = +1, color = "black") + 
   expand_limits(y = c(0, 40)) + 
   scale_y_continuous(labels = scales::label_percent(scale = 1)) + 
   scale_fill_manual(values = party_colors) +
   labs(
     title = "Zweitstimmenergebnis: Wahlkreis Würzburg",
     subtitle = "Amtliches Endergebnis Bundestagswahl 2017",
     x = "",
     y = "",
     caption = "Source: Bundeswahlleiter"
   ) +
   theme(
     panel.border = element_blank(),
     panel.grid.major.x = element_blank()
   )


## ------------------------------------------------------------------------
election_matched <- wahlkreise_shp_2017 %>% 
  left_join(election_cleaned, by = c("WKR_NR" = "Wahlkreis_nr"))


## ------------------------------------------------------------------------
# Check if everything got matched
wahlkreise_shp_2017 %>% 
  anti_join(election_cleaned, by = c("WKR_NR" = "Wahlkreis_nr")) 


## ------------------------------------------------------------------------
plot_election_results <- function(party, color_high) {
  election_matched %>% 
      filter(Party == party) %>% 
      ggplot(aes(fill = Results)) +
      geom_sf() +
      scale_fill_gradient(high = color_high, low = "white", 
                          labels = scales::label_percent(scale = 1)) + 
      labs(
         title = "Bundestagswahl 2017",
         # the term inside the {} is evaluated an inserted when exectued. See ?glue
         subtitle = glue::glue("Zweitstimmen der {party} in %"),
         fill = ""
         # caption = "Source election results: Bundeswahlleiter\nSource map: Bundesamt für Kartographie und Geodäsie"
      ) + 
      theme(
         panel.background = element_rect(fill = "white", colour = "white"),
         plot.background = element_rect(fill = "white", colour = "white"),
         legend.background = element_rect(fill = "white", colour = "white"),
         axis.title = element_blank(),
         axis.text = element_blank(),
         axis.ticks = element_blank(),
         panel.grid.major = element_blank(),
         legend.position = "bottom"
      )
}


## ------------------------------------------------------------------------
a <- plot_election_results("CDU/CSU", color_high = party_colors["CDU/CSU"])
b <- plot_election_results("SPD", color_high = party_colors["SPD"])
a + b  +
   plot_annotation(
      caption = "Source election results: Bundeswahlleiter\nSource map: Bundesamt für Kartographie und Geodäsie"
      ) &
   theme(plot.background = element_rect(fill = "white", colour = "white"))


## ------------------------------------------------------------------------
a <- plot_election_results("DIE GRÜNEN", color_high = party_colors["DIE GRÜNEN"])
b <- plot_election_results("FDP", color_high = party_colors["FDP"])
a + b +
   plot_annotation(
      caption = "Source election results: Bundeswahlleiter\nSource map: Bundesamt für Kartographie und Geodäsie"
      ) &
   theme(plot.background = element_rect(fill = "white", colour = "white"))


## ------------------------------------------------------------------------
a <- plot_election_results("AFD", color_high = party_colors["AFD"])
b <- plot_election_results("DIE LINKE", color_high = party_colors["DIE LINKE"])
a + b +
   plot_annotation(
      caption = "Source election results: Bundeswahlleiter\nSource map: Bundesamt für Kartographie und Geodäsie"
      ) &
   theme(plot.background = element_rect(fill = "white", colour = "white"))


## ------------------------------------------------------------------------
afd_plot <- election_matched %>% 
   filter(Party == "AFD") %>% 
   # Add binned election results according to the bins of the original figure
   mutate(
      Results_binned = cut(Results, 
                           breaks = c(4.9, 10, 15, 20, 25, 35.5),
                           labels = c("4,9 bis 10", "bis 15", "bis 20", "bis 25", "bis 35,5"))
   ) %>% 
   ggplot() +
   # use the interactive version and add a tooltip; glue comes in very handy here!
   geom_sf_interactive(aes(fill = Results_binned, 
                           tooltip = glue("Wahlkreis: {Wahlkreis}\nResult: {scales::percent((Results/100), accuracy = 0.01)}"))) + 
   scale_fill_brewer(palette = "Blues") + 
   labs(
      title = "Bundestagswahl 2017",
      # the term inside the {} is evaluated an inserted when exectued. See ?glue
      subtitle ="Zweitstimmen in Prozent (AfD)",
      fill = "",
      caption = "Sources: Bundeswahlleiter; Bundesamt für Kartographie und Geodäsie"
      ) + 
   theme(
      panel.background = element_rect(fill = "white", colour = "white"),
      plot.background = element_rect(fill = "white", colour = "white"),
      legend.background = element_rect(fill = "white", colour = "white"),
      axis.title = element_blank(),
      axis.text = element_blank(),
      axis.ticks = element_blank(),
      panel.grid.major = element_blank(),
      legend.position = "bottom"
      )

girafe(ggobj = afd_plot)


## ------------------------------------------------------------------------
infections_raw %>% head(8) %>% gt()


## ----echo=FALSE, include=FALSE-------------------------------------------
inf_for_text <- infections_raw %>% 
   filter(NeuerFall == 1) %>% 
   arrange(Meldedatum)


## ------------------------------------------------------------------------
infections_raw %>% 
   filter(NeuerFall == 1) %>% 
   arrange(Meldedatum) %>% 
   head(6)


## ------------------------------------------------------------------------
infections <- infections_raw %>% 
  select(IdLandkreis, Altersgruppe, Geschlecht, Meldedatum, AnzahlFall) %>% 
  group_by(IdLandkreis, Meldedatum) %>% 
  summarise(AnzahlFall = sum(AnzahlFall)) %>%
  ungroup()

infections %>% head(6) %>%  gt()


## ------------------------------------------------------------------------
infections <- infections %>% 
   # filter the 12 Berlin districts and summarize numbers by Meldedatum
   filter(IdLandkreis %in% 11001:11012) %>% 
   group_by(Meldedatum) %>% 
   summarise(AnzahlFall = sum(AnzahlFall)) %>% 
   # create new column IdLandkreis with only the value 11000 (AGS for Berlin)
   mutate(IdLandkreis = 11000) %>% 
   # Bind the Berlin rows back into the "main" data (with the individual Berlin districts removed)
   bind_rows({infections %>% filter(!(IdLandkreis %in% 11001:11012))}) %>% 
   # arrange by Landkreis and Meldedatum
   arrange(IdLandkreis, Meldedatum) %>%
   # Fix the missing leading zero in IdLandkreis and rename to AGS
   group_by(IdLandkreis, Meldedatum) %>% 
   mutate(AGS = if_else(IdLandkreis < 10000, paste0(0, IdLandkreis), as.character(IdLandkreis))) %>% 
   # cleanup
   ungroup() %>% 
   select(-IdLandkreis) %>%
   relocate(AGS)


## ------------------------------------------------------------------------
infections_with_geometry <- vg250_ew_2020 %>%  
   # remove doubled rows
   filter(EWZ > 0) %>% 
   # select only relevant columns
   select(AGS, Landkreis_name = GEN, EWZ, geometry) %>% 
   # join in the infections data
   left_join({
      infections %>% 
         group_by(AGS) %>% 
         # see ?rollsum for what fill = NA does
         mutate(
            seven_day_rollmean = zoo::rollmeanr(AnzahlFall, k = 7, fill = NA),
            seven_day_rollsum  = zoo::rollsumr(AnzahlFall, k = 7, fill = NA)
         )
   }, by = "AGS") %>% 
   # compute 7-day incidence
   mutate(Infections_per_100k = seven_day_rollsum / (EWZ/1e5)) %>% 
   ungroup()


## ------------------------------------------------------------------------
infections_plot <- infections_with_geometry %>% 
   tibble() %>% 
   select(AGS, Meldedatum, AnzahlFall) %>% 
   group_by(Meldedatum) %>% 
   summarise(Cases = sum(AnzahlFall))
   
   
# dygraph requires an xts object 
xts_series <- xts(x = infections_plot$Cases, order.by = infections_plot$Meldedatum)

# Create an R wrapper for the barplott plotter
dyBarChart <- function(dygraph) {
  dyPlotter(dygraph = dygraph,
            name = "BarChart",
            path = system.file("plotters/barchart.js",
                               package = "dygraphs"))
}

dygraph(xts_series, main = "New COVID-19 cases in Germany by reporting date") %>% 
   dyBarChart() %>% 
   dyRangeSelector()  %>% 
   dyCrosshair(direction = "vertical") %>% 
   dyAxis("x", drawGrid = FALSE) %>%
   dyAxis("y", label = "# Cases") %>%
   dyRoller(rollPeriod = 1)


## ------------------------------------------------------------------------
infections_plot <- infections_with_geometry %>% 
   filter(Meldedatum == "2020-12-18") %>% 
   # Add bins
   mutate(
      Infections_per_100k_binned = cut(Infections_per_100k, 
                           breaks = c(25, 50, 100, 250, 500, 1000),
                           labels = c("über 25\nbis 50", "über 50\nbis 100", "über 100\nbis 250", "über 250\nbis 500", "über 500\nbis 1.000"))
   ) %>% 
   ggplot() +
   # use the interactive version and add a tooltip; glue comes in very handy here!
   # geom_sf_interactive(aes(fill = Infections_per_100k_binned, 
   geom_sf(aes(fill = Infections_per_100k_binned)) + 
   scale_fill_brewer(palette = "OrRd") + 
   labs(
      title = "Fälle letzte 7 Tage pro 100.000 Einwohner",
      fill = "",
      caption = "Sources: RKI GitHub; Bundesamt für Kartographie und Geodäsie\nStand: 18.12.2020."
   ) + 
   theme(
      panel.background = element_rect(fill = "white", colour = "white"),
      plot.background = element_rect(fill = "white", colour = "white"),
      legend.background = element_rect(fill = "white", colour = "white"),
      axis.title = element_blank(),
      axis.text = element_blank(),
      axis.ticks = element_blank(),
      panel.grid.major = element_blank(),
      legend.position = "bottom"
   )
# interactive version
# girafe(ggobj = infections_plot)
infections_plot


## ------------------------------------------------------------------------
infections_with_geometry %>%
   tibble() %>% 
   select(AGS, Meldedatum, AnzahlFall, EWZ) %>% 
   mutate("Area" = if_else(startsWith(AGS, "14") | startsWith(AGS, "16") , "AFD stronghold (SN & TH)", "Rest of the Germany")) %>% 
   group_by(Area, Meldedatum) %>% 
   summarise(Cases = sum(AnzahlFall), Population = sum(EWZ)) %>% 
   mutate(
      seven_day_rollsum  = zoo::rollsumr(Cases, k = 7, fill = NA),
      Infections_per_100k = (seven_day_rollsum / Population)*1e5
      ) %>% 
   ggplot(aes(x = Meldedatum, y = Infections_per_100k, color = Area)) +
   geom_line() +
   scale_color_manual(values = c("AFD stronghold (SN & TH)" = unname(party_colors["AFD"]), "Rest of the Germany" = "green")) +
   labs(
      title = "7-day incidence per 100.000 people over time",
      x = "",
      y = ""
   )


## ------------------------------------------------------------------------
## Compute total by day, Landkreis and vaccination dose (1 or 2)
vaccinated <- vaccinated_raw %>% 
   rename(AGS = LandkreisId_Impfort) %>%
   # sum over all age groups
   group_by(Impfdatum, AGS, Impfschutz) %>% 
   summarise(Anzahl = sum(Anzahl)) %>% 
   # sum over all day
   group_by(AGS, Impfschutz) %>% 
   summarise(Geimpft = sum(Anzahl)) %>% 
   ungroup()

vaccinated %>% head(6) %>%  gt()


## ------------------------------------------------------------------------
vaccinated <- vaccinated %>% 
  filter(AGS != "u")

# Lets check if there are 401 Kreise
length(unique(vaccinated$AGS))


## ------------------------------------------------------------------------
vaccinated <- vaccinated %>% 
  filter(AGS != 17000)


## ------------------------------------------------------------------------
vaccinated_matched <- vg250_ew_2020 %>%  
   # remove doubled rows
   filter(EWZ > 0) %>% 
   # select only relevant columns
   select(AGS, Landkreis_name = GEN, EWZ, geometry) %>% 
   left_join(vaccinated, by = "AGS") %>% 
   mutate(
      vaccination_rate = Geimpft / EWZ
   )


## ------------------------------------------------------------------------
vaccination_plot <- vaccinated_matched %>% 
   # Remove "Auffrischungsimpfungen"
   filter(Impfschutz %in% 1:2) %>% 
   mutate(Impfschutz = if_else(Impfschutz == 1, "Einmal geimpft (ex Janssen)", "Voll geimpft (incl. Janssen)")) %>% 
   ggplot() +
   # use the interactive version and add a tooltip; glue comes in very handy here!
   # geom_sf_interactive(aes(fill = vaccination_rate, 
   #                         tooltip = glue("Landkreis: {Landkreis_name}\nVaccintion rate: {scales::percent(vaccination_rate, accuracy = 0.1)}"))) + 
   geom_sf(aes(fill = vaccination_rate)) +
   scale_fill_gradient(low = "white", high = party_colors["DIE GRÜNEN"],
                       label = scales::label_percent()) + 
   facet_grid(cols = vars(Impfschutz)) + 
   labs(
      title = "'Vaccination rate' by Landkreis",
      subtitle = "WARNING: vaccination rate based on where the vaccine was given, \nnot (!) the zip-code of the vaccinated person.",
      fill = "",
      caption = "Sources: RKI GitHub; Bundesamt für Kartographie und Geodäsie\nStand: 2021-08-31"
   ) + 
   theme(
      panel.background = element_rect(fill = "white", colour = "white"),
      plot.background = element_rect(fill = "white", colour = "white"),
      legend.background = element_rect(fill = "white", colour = "white"),
      axis.title = element_blank(),
      axis.text = element_blank(),
      axis.ticks = element_blank(),
      panel.grid.major = element_blank(),
      legend.position = "bottom"
   )

# Interactive version.
# girafe(ggobj = vaccination_plot)
vaccination_plot

