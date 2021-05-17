## ----message=FALSE, warning=FALSE-------------------------------------------------------
require(tidytuesdayR) # to easily get the tidy Tuesday data
require(tidyverse)    # includes dplyr, tidyr, ggplot, forcats etc.
require(visdat)       # for visualizing missing data (and data types)


## ----echo=FALSE, message=FALSE, warning=FALSE-------------------------------------------
## Setup options
knitr::opts_chunk$set(
   echo         = TRUE,
   fig.showtext = TRUE,
   fig.align    = "center",
   message      = FALSE,
   warning      = FALSE,
   collapse     = TRUE
   )

## Load showtext for fonts
require(showtext)

## Load fonts
# font_add(family = "commissioner",
#          regular = "_not_for_git/Commissioner/static/Commissioner-Light.ttf")
# font_add(family = "fraunces",
#          regular = "_not_for_git/Fraunces/static/Fraunces_9pt_Soft/Fraunces_9pt_Soft-Regular.ttf")

## Load fonts
font_add(family = "commissioner",
         regular = "../../fonts/Commissioner-Light.ttf")
font_add(family = "fraunces",
         regular = "../../fonts/Fraunces_9pt_Soft-Regular.ttf")

## Colors 
main_color    = "#516DB0"
txt_color     = "#404040"
bg_color      = "#f2f2f1"
bg_color2     = "#FFFFFF"
color_scheme  = c("#6796DE", "#B54256", "#EFCB8F", "#569AA3", "#E38D4C")

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

## For default color scheme
scale_colour_discrete <- function(...) {
  scale_colour_manual(..., values = color_scheme)
}


## ----echo=FALSE, include=FALSE----------------------------------------------------------
ceo <- readr::read_csv("../tt_data/ceo.csv")

## ----eval=FALSE-------------------------------------------------------------------------
## tt  <- tidytuesdayR::tt_load('2021-04-27')
## ceo <- tt$departures


## ---------------------------------------------------------------------------------------
dim(ceo)
vis_dat(ceo)


## ---------------------------------------------------------------------------------------
ggplot(ceo, aes(y = departure_code)) + 
   geom_bar(fill = main_color) +
   labs(
      title    = "Reason for CEO departure",
      x = "",
      y = ""
   )


## ---------------------------------------------------------------------------------------
ceo %>% 
   group_by(fyear, departure_code) %>% 
   count()


## ---------------------------------------------------------------------------------------
ceo_reduced <- ceo %>% 
   filter(departure_code %in% 3:7) %>% 
   mutate(
      departure_label = as.factor(recode(departure_code,
         `3` = "Bad performance",
         `4` = "Legal",
         `5` = "Retired",
         `6` = "New opportunity",
         `7` = "Other")),
      fyear = lubridate::make_date(fyear)) %>% 
   relocate(fyear, departure_label)


## ---------------------------------------------------------------------------------------
ceo_reduced %>% 
   group_by(departure_label) %>% 
   count() %>% 
   ggplot(aes(y = fct_reorder(departure_label, n), x = n)) + 
   geom_col(fill = main_color) +
   labs(
      title = "CEO depature by reason",
      subtitle = "S&P 1500 firms between 1987 - 2019",
      x = "",
      y = "",
      caption = "Source: Gentry et al."
   ) + 
   scale_x_continuous(breaks = scales::breaks_width(500))


## ---------------------------------------------------------------------------------------
ceo_reduced %>%
   group_by(fyear, departure_label) %>% 
   count() %>% 
   ggplot(aes(x = fyear, y = n, color = departure_label)) + 
   geom_line() + 
   labs(
      title = "CEO departure by reason over time",
      subtitle = "S&P 1500 firms between 1987 - 2019",
      color = "Reason",
      y     = "",
      x     = ""
   )


## ---------------------------------------------------------------------------------------
ceo_reduced %>%
   filter(fyear != "1987-01-01")  %>%
   group_by(fyear, departure_label) %>% 
   count() %>% 
   group_by(fyear) %>% 
   mutate(share_fyear = n/sum(n)) %>% 
   ungroup() %>% # for fct_reorder!
   mutate(departure_label = fct_reorder(departure_label, -share_fyear, last)) %>% 
   ggplot(aes(x = fyear, y = share_fyear, color = departure_label)) + 
   geom_line() + 
   labs(
      title = "CEO departure by Reason over time",
      subtitle = "S&P 1500 firms between 1987 - 2019",
      color = "Reason",
      x     = "",
      y     = "% of total departures"
   ) + 
   scale_y_continuous(labels = scales::label_percent()) +
   scale_x_date(
      breaks = scales::breaks_width("4 years"),
      labels = scales::label_date("%Y")
      )


## ---------------------------------------------------------------------------------------
ceo_al_twice <- ceo_reduced %>%
   group_by(exec_fullname) %>% 
   mutate(appears_al_twice = n(), .after = departure_label) %>% 
   filter(appears_al_twice > 1) %>%
   ungroup()

length(unique(ceo_al_twice$exec_fullname))


## ---------------------------------------------------------------------------------------
# Note: divide to get the unique values
table(ceo_al_twice$appears_al_twice) / c(2, 3, 4)


## ---------------------------------------------------------------------------------------
ceo_changes <- ceo_al_twice %>% 
   arrange(fyear) %>% 
   group_by(exec_fullname) %>% 
   mutate(departure_no = 1:n(), .after = departure_label,
          departure_no = fct_inorder(recode(departure_no,
             `1` = "First departure",
             `2` = "Second departure",
             `3` = "Third departure",
             `4` = "Fourth departure"))) %>% 
   ungroup()

ggplot(ceo_changes, aes(x = departure_no, y = departure_label, group = exec_fullname)) + 
   geom_line() +
   labs(
      x = "",
      y = ""
   )


## ---------------------------------------------------------------------------------------
ceo_changes_freq <- ceo_changes %>% 
   count(departure_label, departure_no)

ceo_4_changes <- ceo_changes %>% 
   filter(appears_al_twice  == 4)

ggplot(ceo_changes, aes(x = departure_no, y = departure_label)) + 
   geom_line(aes(group = exec_fullname), alpha = 0.2) +
   geom_point(
      data = ceo_changes_freq, 
      mapping = aes(size = n)) + 
   geom_line(
      data = ceo_4_changes, 
      mapping = aes(group = exec_fullname, color = exec_fullname),
      show.legend = FALSE) +
   geom_text(      
      data = filter(ceo_4_changes, departure_no  == "Fourth departure"), 
      mapping = aes(label = exec_fullname),
      nudge_y = -0.1
      ) + 
   labs(
      title = "Trajectories of the reasons for CEO departure",
      subtitle = "S&P 1500 firms between 1987 - 2019",
      x = "",
      y = "",
      size = "Number of cases"
   ) + 
   theme(legend.position="bottom")

