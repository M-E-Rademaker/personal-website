---
author: Manuel Rademaker
categories:
- R
- R package
- Structural equation modeling (SEM)
- Composite-based SEM
date: "2021-04-24"
draft: false
excerpt: cSEM is an R package for composite-based structural equation modeling (SEM).
  The package is available on CRAN.
layout: single
images:
  - featured-hex.png
  - featured-hex.png
links:
- icon: door-open
  icon_pack: fas
  name: website
  url: https://m-e-rademaker.github.io/cSEM/
- icon: github
  icon_pack: fab
  name: Source code
  url: https://github.com/M-E-Rademaker/cSEM
subtitle: An R package for composite-based structural equation modeling (SEM)
tags:
- hugo-site
title: cSEM
---
## [cSEM](https://github.com/M-E-Rademaker/cSEM) allows users to estimate, analyze, test, and study linear, nonlinear, hierarchical and multi-group structural equation models using composite-based approaches and procedures. The focus is one usability and, hence, extremely easy to use.
---

## What is cSEM

The idea of cSEM is twofold:

1. Provide a unified framework to all common composite-based SEM approaches, 
   including typical postestimation procedures. In principal, it should be 
   similar to what [lavaan](https://lavaan.ugent.be/) does for covariance-bases/factor-based SEM.
2. Make the user experience as hassle-free as possible. 

The first point is an always ongoing task since approaches are constantly evolving
with new developments appearing at a pace that we, the package authors, will not
be able to keep up with. The second point, however, was particularly important
to us as we have been frustrated ourselves by how technical, unfriendly packages
in R can be. Hence, from the very start we envisioned a workflow that essentially
only comprises three steps:

1. **Get the essential**: no estimator or approach works without data and a description
   of what parameters are to be estimated and how data is related to these parameters, 
   i.e. a model. Hence, we always need a data set and model.
   Since, model specification in [lavaan model syntax](https://lavaan.ugent.be/tutorial/syntax1.html) is probably unbeatable in its
   ease and well known to R users that have an interest in SEM, to us, [lavaan model syntax](https://lavaan.ugent.be/tutorial/syntax1.html) 
   is the obvious tool for users to specify their model. Experience tells,
   that for R beginners the biggest obstacle has been to get the data into R. 
   However, largely thanks to the [tidyverse](https://www.tidyverse.org/) and 
   [RStudio](https://www.rstudio.com/), data import and data transformation 
   are nowadays relatively easy to handle. See the [Preparing the data](#preparedata)
   and the [Specifying a model](#specifyingamodel) sections below.
1. **Estimate**: no matter the model and type of data, estimation is always done using one
   central function with the data as its first and the model as its second argument:
   ```{r eval = FALSE}
   csem(.data = my_data, .model = my_model)
   ```
   Naturally, the `csem()` function has a number of additional arguments to fine-tune the estimation,
   however, since `csem()` automatically recognizes, for instance, whether a concept
   was modeled as a common factor or composite and automatically applies appropriate
   correction for attenuation, default arguments are often sufficient. See the 
   [Estimate using csem()](#estimate) section below.
1. **Postestimate**: Inspired by the [grammar of data manipulation](https://dplyr.tidyverse.org/) 
   underlying the [dplyr](https://dplyr.tidyverse.org/) package, cSEM provides
   5 postestimation verbs that concisely cover all common postestimation tasks
   as well as 4 additional test commands and 2 general do commands:
   1. `assess()`
   1. `infer()`
   1. `predict()`
   1. `summarize()`
   1. `verify()`
   1. `testOMF()`
   1. `testMICOM()`
   1. `testHausman()`
   1. `testMGD()`
   1. `doIPMA()`
   1. `doNonlinearRedundancyAnalysis()`
   1. `doRedundancyAnalysis()`
   
   All verbs accept the result of a call to `csem()` as input which makes working
   with these function extremely simple. You only need to remember the word, not any
   specific syntax or arguments. Of course, all functions have a number 
   of additional arguments to fine-tune the postestimation. See the 
   [Apply postestimation functions](#postestimate) sections below. For details
   on the arguments consult the individual help files.

The price we pay for an increase in flexibility is primarily a, mostly minor, loss 
in computational speed, in particular, when intense resampling is involved 
(i.e., 5000 bootstrap run for a complex model with, say, 1000 observations).
Users looking for the most efficient implementation of common resampling routines 
may find faster implementations. That said, we believe, the time saved when using a 
standardized estimate-postestimate workflow, no matter the model or data used, 
well outweighs the potential loss in computational
efficiency.

The following sections describe the workflow in more detail.
