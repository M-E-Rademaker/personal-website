# Personal website

[![Netlify Status](https://api.netlify.com/api/v1/badges/d0b7c18d-f209-41b2-bab6-53087a822510/deploy-status)](https://app.netlify.com/sites/manuel-rademaker/deploys)

Source code for [my personal website](https://www.manuelrademaker.com/): about me, blog, projects, and CV.
Happy reading!

## How it works

- Built with [blogdown](https://pkgs.rstudio.com/blogdown/) and [Hugo](https://gohugo.io/) (v0.82.1) using the [Hugo Apéro](https://hugo-apero-docs.netlify.app/) theme.
- Posts are written in `.Rmarkdown` and knitted locally to `.markdown`; Netlify only runs `hugo`, so the rendered `.markdown` must be committed.
- Pushing to `main` deploys automatically via Netlify. The domain `manuelrademaker.com` is registered through Netlify with auto-renewal on.

## Local preview

```r
blogdown::serve_site()
```

## Code

The code used in my blog entries can be found in the `code` folder.
Raw data sitting next to a post (shapefiles, CSVs) is only needed for knitting and is excluded from the site via `ignoreFiles` in `config.yaml`.
