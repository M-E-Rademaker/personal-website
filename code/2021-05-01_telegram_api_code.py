from telethon import TelegramClient, events, sync
import xlsxwriter
import re

# Use your own from my.telegram.org
api_id   = "<your number here>"
api_hash = "<your number here>"
         
# Setup and start client
client = TelegramClient('my_session', api_id, api_hash)
client.start()

# Teams
teams = {"Team 1": "<Telegram phone number here>", 
         "Team 2": "<Telegram phone number here>", 
         "Team 3": "<Telegram phone number here>"}
         
# Begin parsing
n_messages = 20 # how many messages should be fetched for each team?
answers_team = dict()
for team in teams:
  try: # fetch messages
    messages  = client.get_messages(teams[team], limit=n_messages)
  except:
    print("Ooops, something went wrong.")
  
  # Reverse order to have messages from oldest first; this gives precedence
  # to the newer message in case teams want to correct their answers.
  messages = messages[::-1]
  
  q_and_a_all = dict()
  for m in messages:
    # For every message, extract all lines (until the linebreak) that 
    # contain the following pattern:
    # number.|:number.|: 
    matches = re.findall("\\d+[.:]\\d+[.: ].*", m.message)
    if len(matches) < 1:
      # continue if message does not follow this pattern
      continue
    else:
      # Extract 
      #   key (= the question number; the match itself) and 
      #   value (= the answer; anything after the match until a 
      #         linebreak appears) and
      # write them in a dictionary
      keys = re.findall("(\\d+[.:]\\d+)[.: ].*", "\n".join(matches))
      values =  re.findall("\\d+[.:]\\d+[.: ](.*)", "\n".join(matches))
      q_and_a = dict(zip(keys, values))
      
      # Add to list of all answers (note: if a key is already in the dict, 
      # its value will be overwritten by the newer value). This allows teams to
      # correct their answers.
      for key in q_and_a.keys():
        q_and_a_all[key] = q_and_a[key]
  
  answers_team[team] = q_and_a_all

# Write to xlsx
workbook  = xlsxwriter.Workbook('results.xlsx')

for team in teams.keys():
  # Add worksheet for every team
  worksheet = workbook.add_worksheet("Answers_"+team)
  
  # Question and answer
  count = 0
  for question in answers_team[team].keys():
    count += 1
    worksheet.write(count, 0, question)
    worksheet.write(count, 1, answers_team[team][question])

workbook.close()
