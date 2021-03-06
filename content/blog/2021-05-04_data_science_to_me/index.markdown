---
author: Manuel Rademaker
categories:
- Data science
- Opinion
date: "2021-05-04"
draft: false
excerpt: My personal view on data science and its professional equivalent the
  data scientist. 
layout: single
links:
subtitle: My personal view on data science and its professional equivalent the
  data scientist. Since my views will likely change as my experience grows, don't
  consider this to be static and never changing but simply my opinion given the
  knowledge I have today! 
title: What is data science to me?
output:
  blogdown::html_page:
    toc: true
    number_sections: true
    toc_depth: 2
---

Data Science, Machine Learning, Artificial Intelligence (AI), and Big Data are 
probably the four most common buzzwords (or better buzzterms) you hear 
when people talk about digitalization, automation, data-driven decision
making or industry 4.0.
However, different professional backgrounds and hierarchy levels tend to have 
different ideas and expectations regarding the meaning of these terms. In this 
blog post, I want to give my personal view on one of these terms, namely the term
*data science* and its professional equivalent the *data scientist*.

In general, for me, the purpose of a data scientist is

1. to extract the maximum possible information from data given constraints such
as time and budget and to use this information 
1. to answer business relevant questions empirically, i.e. based on the insights gained from data, and
1. to communicate the insights and recommendations for action as such in a way that 
is most effective for the respective recipient, so that
1. concrete problems can be solved in a more informed way, i.e. with less uncertainty.

For me, this has a number of implications for what a (good) data scientist is or should be. I will discuss some of them next, although this is by no means a comprehensive
list but rather what I believe are the essential aspects of data science.

### The end justifies the means

The choice of statistical method, model, programming language, back end structure,
means of communication, and all other tools used in a data science project 
are merely means to achieve the end as described above. There is no universally
optimal combination of these components that addresses all question equally well. 
The space of possible types of problems is simply to large.
That being said, naturally some methods and in particular tools and programming languages have proven themselves to be more effective than others. Python and R 
coming to my mind here. While, for example, a tool such as Excel may well be appropriate to answer a particular data science question in some instances, it certainly is very limited with respect to the kinds
of data processing tasks it can do, the statistical models that are possible, and its scalability -- simply because that is not what Excel was designed for, so no 
Excel-bashing here.
Lower level languages such as C or C++ on the other hand produce long-lasting, robust and computationally efficient code that is easily scalable. However, good luck
trying to do interactive data exploration in C or C++...

Consequently, a data scientist has to decide in an unbiased, pragmatic way which statistical method, which programming languages, or which set of tools solve a given problem in the best way, i.e. in a way that minimizes cost, time, and effort.
This obviously requires knowledge of "what is out there". Still, no matter how 
smart a data scientist you find, no one knows all the tools there are, let alone is an
expert in its use. Hence, in particular with respect to programming languages and the tools to use, curiosity and open-mindedness towards new tools and technologies paired with the capability to adapt and apply these relatively quickly are more relevant
characteristics in a data scientist than the mere set of tools already mastered.[^1]

### Information is the limiting factor, not the statistical method

No statistical procedure is able to extract more information from data 
than there is (non-redundant) information in the data -- even if terms like
[neural networks](https://brilliant.org/wiki/artificial-neural-network/) or [deep learning](https://en.wikipedia.org/wiki/Deep_learning) may seem to suggest otherwise. This is probably the single 
most important message or disclaimer to tell someone who hasn't had any contact
with data science before:

> Data science is a science not data magic!

Roughly speaking, data science is therefore simply the act of approaching the information extraction, processing and communication task in a scientific way.  

### Communication is the bridge to the real world

Results that are not communicated in a way that is meaningful to key decision 
makers such that concrete problems can be solved have, in my view, no added value beyond 
the insight they generate in the data scientist herself -- which admittedly is
of value too! Nonetheless, didactic and convincing presentation skills, the power to persuade, empathy, and the general ability to communicate adequately is therefore 
just as important for a good data scientist as the methodological knowledge. 

[^1]: Clearly, the more tools a data scientist has in her portfolio, the more likely
she is to already have all that is required for a specific project. Therefore, a
solid command of at least one general purpose programming language as well as 
knowledge of visualization and communication tools is probably indispensable. 
Similarly, the number of tools a data scientist already masters are a good 
indicator of how quickly she can pick up a new one.
