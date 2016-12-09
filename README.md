# FdTrivia

A trivia bot for FlowDock

## Main bits



#### [SurveySays](https://github.com/gogogarrett/fd_trivia/blob/master/lib/fd_trivia/survey_says.ex)

This is the main GenServer that powers the game.

We get a message from [flowdocks streaming api](https://www.flowdock.com/api/streaming) and pattern match this to workout what to do.

Responsibilities

- fetches a user list of people in a particular flow and stores their `user_id` and `nickname`
- send a `question` to the client every _x_ seconds.
- check submissions for correct answers
  - updates a players score if they get a correct answer
- responds to user functions:
  - ie: `bot:scores` will print the leaderboards back to the client

SurveySays is the glue that makes the game work, but most of the work is done in other modules.



#### [Bank](https://github.com/gogogarrett/fd_trivia/blob/master/lib/fd_trivia/bank.ex)

This module is responsible for providing a list of questions and answers one at a time



#### [GrantDenyer](https://github.com/gogogarrett/fd_trivia/blob/master/lib/fd_trivia/grant_denyer.ex)

![GrantDenyer](http://cdn.mamamia.com.au/wp-content/uploads/2014/10/Grant-Denyer-Insider-900x50.jpg)

This module checks for validity of the answer for a given question



#### [ScoreBoard](https://github.com/gogogarrett/fd_trivia/blob/master/lib/fd_trivia/score_board.ex)

This module takes care of updating the score board



#### [Ui.Bot](https://github.com/gogogarrett/fd_trivia/blob/master/lib/fd_trivia/ui/bot.ex)

This provides some util functions to make it easier to compose messages the bot sends to the client



#### [Ui.Leaderboard](https://github.com/gogogarrett/fd_trivia/blob/master/lib/fd_trivia/ui/leaderboard.ex)

A UI util to wrap players and scores in some presentation emojis
