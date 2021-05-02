---
author: Manuel Rademaker
categories:
- Python
- Telethon
- Telegram API
- API
date: "2021-05-01"
draft: false
excerpt: A step by step guide showing how to use Python and the 
  <a href=https://github.com/LonamiWebs/Telethon target = "_blank"> Telethon library</a> to access the 
  <a href=https://core.telegram.org/ target="_blank">Telegram API</a>. I'll walk you through how to parse text messages (in this case
  messages containing answers to quiz questions) and
  subsequently write them to an Excel (.xlsx) file. With some changes the process 
  is of course applicable to any kind of text from any number of Telegram messages.
layout: single
links:
- icon: github
  icon_pack: fab
  name: Get complete code
  url: https://github.com/M-E-Rademaker/personal-website/tree/main/code
subtitle: A step by step guide showing how to use Python and the 
  Telethon library to access the Telegram API to parse text messages.

title: Using Python and Telethon to access the Telegram API
output:
  blogdown::html_page:
    toc: true
    number_sections: true
    toc_depth: 2
---

During lockdown my friends and I started having regular quiz nights via
Zoom and <a href=https://telegram.org/ target="_blank">Telegram</a>. Initially, my wife and I were the hosts. In subsequent rounds the winning 
team of the last quiz would have the honor (or burden?) of being the new hosts. 
So one team prepares questions from varying categories, poses them via Zoom, and the others answer by sending their answers via Telegram to the host team. To collect and sort the Telegram answers from each team one of the host team
members had to manually copy-paste these in an Excel file for evaluation -- not a particularly effective process. We thought about shared documents
(Google Docs and friends), however, no satisfactory solution was agreed upon.

As I started learning Python a couple of weeks ago, I thought it would be much more 
effective (and a good exercise for that matter) to use Python to read the 
answers via the Telegram API, process them and finally write them to an Excel file.
Turns out to be even easier than I thought.

In the following, I walk you through each step. The complete code without any comments can also be found at the end of this post or you download the `.py` file (including comments) from my [GitHub repo](https://github.com/M-E-Rademaker/personal-website/tree/main/code). 

## Step 1: Sign up for the Telegram API

Before we start with the actual code, you need to register as a developer for 
the Telegram API. To do so, head over to <https://core.telegram.org/api/obtaining_api_id> and follow the steps to
obtain your `api_id` and `api_hash`. You need a phone number and Telegram installed
on your device to be able to receive a confirmation code. 
In the process you will also be asked to enter some details about the application
you plan to develop. Don't be confused. Just give it some meaningful name. The Telegram API is, of course, typically not used for such simple tasks as getting answers to
quiz questions but to write applications like chat bots or some more advanced message parsers to analyze e.g., group chat sentiment (google it; there are some really
interesting applications!).

## Step 2: Setup



First we load the necessary libraries. 

```python
from telethon import TelegramClient, __version__ as tele_version, sync
import xlsxwriter
import re
```
Library `re` (for **r**egular **e**xpressions) is build-in, no need to install it. You may have to install the other two libraries
if you don't have them already. Use e.g., `py -m pip install telethon xlsxwriter` 
from your command line -- assuming you are on Windows and have Python on your PATH. 
I used `telethon` version 1.21.1 and `xlsxwriter` version 1.3.9.

Note that <a href = https://docs.telethon.dev/en/latest/basic/quick-start.html target = "_blank">Telethon is an asynchronous library</a> which means that normally you would need to
take an extra round of getting to know `asyncio` before using Telethon effectively. Since we only need Telethon to fetch the text messages from the Telegram API once, 
we don't need to dive into what `asyncio` is and why it can be extremely useful. 
However, make sure you import the `sync` module to essentially tell Telethon that
we don't want to bother with `asyncio`.


```python
api_id   = "<your number here>"
api_hash = "<your number here>"
         
client = TelegramClient('my_session', api_id, api_hash)
client.start()
```

Once you have your `api_id` and `api_hash` you are good to go. Thanks to the
Telethon library connecting to the Telegram API is done in just two lines of code.
First: set up a client object by giving it a name of your choice, your `api_id`, and 
your `api_hash`. Second: use the `start()` method to open the connection.

## Step 3: Parse and process

Now that we have a connection we need to decide which messages to fetch. 
Of course, there are many strategies to do so. Since we don't plan on reading 
millions of lines of text, we don't not need to worry about speed or efficiency consideration. I tend to be pragmatic in such cases, choosing the strategy 
that seems most "natural" to me -- and, hence, most likely to be easily understandable when coming back to the code a couple of month or years from now.[^1] 

### Strategy
Alright, so here is the plan.

First, we create a dictionary entry for each team and their Telegram phone number.
You could also use their Telegram username, however, I think the phone number is
less error-prone as people sometimes have really odd usernames.... 


```python
teams = {"Team 1": "<Telegram phone number here>", 
         "Team 2": "<Telegram phone number here>", 
         "Team 3": "<Telegram phone number here>"}
```

Now, for every team/telegram account...

1. Get the last `n_messages` and save them in `messages`.
1. Reverse the order of the messages from oldest first to newest last.
1. For every message:
   1. Identify which message contains an answer to a question.
   1. Extract the question number.
   1. Extract the answer belonging to that question number.
   1. Save question (`key`) and answer (`value`) pairs in a dictionary called
      `q_and_a_all`.
1. Save each `q_and_a_all` dictionary as the `value` of another dictionary called `answers_team` with the key being the team name.


```python
n_messages = 20
answers_team = dict()
for team in teams:
  try:
    messages  = client.get_messages(teams[team], limit=n_messages)
  except:
    print("Ooops, something went wrong.")
  
  messages = messages[::-1]
  
  q_and_a_all = dict()
  for m in messages:
    matches = re.findall("\\d+[.:]\\d+[.: ].*", m.message)
    if len(matches) < 1:
      continue
    else:
      keys = re.findall("(\\d+[.:]\\d+)[.: ].*", "\n".join(matches))
      values =  re.findall("\\d+[.:]\\d+[.: ](.*)", "\n".join(matches))
      q_and_a = dict(zip(keys, values))
      
      for key in q_and_a.keys():
        q_and_a_all[key] = q_and_a[key]
  
  answers_team[team] = q_and_a_all
```

As you can see, fetching the messages is as easy as opening a file or an URL.
Simply use `client.get_messages(<phone-number>)`. By default (`limit=1`) only
the last message is returned. In our case we get `limit = n_messages = 20` messages.

After reversing the order of the messages from oldest first to newest last, the inner loop begins. The reason for reversing is that if someone changes an answer, the newest (more recent) answer always "wins", i.e. the older answer is overwritten. 

To detect an answer in a message, some sort of pattern needs to be agreed upon that
indicates a question-answer message. In our case, we agreed on the following rules:

1. To indicate the question use the pattern: *category number* followed
   by a *dot* or a *colon*, followed by the *question number*, followed by
   another *dot*, *colon* or *whitespace*.
1. Anything after that pattern until the next linebreak is the answer.[^2]

In regular expression terms that pattern is: `"\\d+[.:]\\d+[.: ].*"`.

- `\d` matches any digit. The `+` indicates one or more times.
- `[.:]` matches anything between the `[]`. Here: a dot or a colon.
- `.` is the special character matching any character. The `*` indicates zero or
  more times (until a linebreak is found).
- The `\` is the escape character.

Here is a typical question-answer message.
![](telegram_message.png)

As you can see, one message can contain several question-answer pairs. That's
why I join all answers into one big string and subsequently extract the key
and value part. Note that the `()` in the regular expressions used in the second and
third `re.findall()` call is the regular expression way of saying: "I only
want the part inside of the braces".

After running the two loops, the resulting object `answers_all` is a dictionary of dictionaries. A quick manual inspection should give
you a good sense of whether everything worked as expected. 

## Step 4: Write to Excel

Writing the results to an .xlsx file is straightforward. 


```python
workbook  = xlsxwriter.Workbook('results.xlsx')

for team in teams.keys():
  worksheet = workbook.add_worksheet("Answers_"+team)
  
  count = 0
  for question in answers_team[team].keys():
    count += 1
    worksheet.write(count, 0, question)
    worksheet.write(count, 1, answers_team[team][question])

workbook.close()
```

First, set up an empty workbook. Now, for each team:

1. Add a worksheet and name it "Answers_Team1", "Answers_Team2" etc.
1. Write the questions, row by row, in the first column
1. Write the answers, row by row, in the second column

Once done, close the workbook and that's it! 🥳

# Code

Note: the code does not run right now as you need to manually
change things like your access token and the list of people whose messages 
you want to read and process.


```python
from telethon import TelegramClient, __version__ as tele_version, sync
import xlsxwriter
import re

api_id   = "<your number here>"
api_hash = "<your number here>"
         
client = TelegramClient('my_session', api_id, api_hash)
client.start()

teams = {"Team 1": "<Telegram phone number here>", 
         "Team 2": "<Telegram phone number here>", 
         "Team 3": "<Telegram phone number here>"}
         
n_messages = 20
answers_team = dict()
for team in teams:
  try:
    messages  = client.get_messages(teams[team], limit=n_messages)
  except:
    print("Ooops, something went wrong.")

  messages = messages[::-1]
  
  q_and_a_all = dict()
  for m in messages:
    matches = re.findall("\\d+[.:]\\d+[.: ].*", m.message)
    if len(matches) < 1:
      continue
    else:
      keys = re.findall("(\\d+[.:]\\d+)[.: ].*", "\n".join(matches))
      values =  re.findall("\\d+[.:]\\d+[.: ](.*)", "\n".join(matches))
      q_and_a = dict(zip(keys, values))
      
      for key in q_and_a.keys():
        q_and_a_all[key] = q_and_a[key]
  
  answers_team[team] = q_and_a_all

workbook  = xlsxwriter.Workbook('results.xlsx')

for team in teams.keys():
  worksheet = workbook.add_worksheet("Answers_"+team)
  
  count = 0
  for question in answers_team[team].keys():
    count += 1
    worksheet.write(count, 0, question)
    worksheet.write(count, 1, answers_team[team][question])

workbook.close()
```


[^1]: Having used R for the last 8+ years, this is kind of a relief. While control structures such as for loops are perfectly 
valid in R, they tend to be frowned upon because using R is closely tied to the
idea of vectorization. Roughly speaking vectorization means that operations like
applying function `foo()` to a list occur in parallel. Since vectorized operations are, generally speaking, much faster when the object they are applied on becomes larger, [functionals](https://adv-r.hadley.nz/functionals.html) such as `lapply()` are often preferred.
Thinking in vectorized terms is a matter of practice, can lead to more readable code, and has certainly helped me
write short, efficient, and "elegant" code in many instances. Yet, I've experienced that I often find it harder to understand what the hack I was doing when coming 
back to nicely vectorized code several month (or years) later.

[^2]: One could probably simplify this part by agreeing on some sequence that indicates the start of an answer plus the requirement to always use this sequence at the 
start of a line. In this case string method `startswith()` could be used without the need for nasty regular expressions. 
