---
author: Manuel Rademaker
categories:
- "Covid 19"
- SARS-COV2
- "2017 Election"
- R
date: "2021-08-25"
draft: false
excerpt: About election results, incidence rates, and vaccination rates  
layout: single
links:
subtitle: Some text
title: Incidence rates, vaccination rates and election results
output:
  blogdown::html_page:
    toc: true
    number_sections: true
    toc_depth: 2
---

Recently I stumbled across this graphic from great [katapult magazin](https://katapult-magazin.de/de):

![](katapult_afd_election_incidence.png)



```r
require(tidyverse)  # tidyverse packages
require(sf)         # working with shape files
require(COVID19)    # Covid 19 data 
require(readr)      # read csv files
```




