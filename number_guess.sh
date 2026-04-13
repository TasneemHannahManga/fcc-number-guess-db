#!/bin/bash

PSQL="psql -q --username=freecodecamp --dbname=number_guess -t --no-align -c"

NUMBER=$(( RANDOM % 1000 + 1 ))

echo Enter your username:
read NAME

NAME_QUERY=$($PSQL "SELECT username, games_played, best_game FROM users WHERE username = '$NAME'")

if [[ -z $NAME_QUERY ]]
then 
  $PSQL "INSERT INTO users(username) VALUES('$NAME')"
  echo "Welcome, $NAME! It looks like this is your first time here." 
else
    echo "$NAME_QUERY" | while IFS='|' read -r USERNAME GAMES_PLAYED BEST_GAME; do
    echo "Welcome back, $NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

echo "Guess the secret number between 1 and 1000:"
GUESSES=0
while true
do
  read GUESS
  if  ! [[ $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    continue
  fi

  (( GUESSES++ ))

  if [[ $GUESS -lt $NUMBER ]]
  then
    echo "It's higher than that, guess again:"
  elif [[ $GUESS -gt $NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  elif [[ $GUESS -eq $NUMBER ]]
  then
    NUMBER_PLAYS=$($PSQL "SELECT games_played FROM users WHERE username = '$NAME'")
    if [[ -z $NUMBER_PLAYS ]]
    then
      $PSQL "UPDATE users SET games_played = 1 WHERE username = '$NAME'"
    else
      $PSQL "UPDATE users SET games_played = games_played + 1 WHERE username = '$NAME'"
    fi

    BEST_SCORE=$($PSQL "SELECT best_game FROM users WHERE username = '$NAME'")
    if [[ -z $BEST_SCORE || $GUESSES -lt $BEST_SCORE ]]
    then
      $PSQL "UPDATE users SET best_game = $GUESSES WHERE username = '$NAME'"
    fi

    echo "You guessed it in $GUESSES tries. The secret number was $NUMBER. Nice job!"
    break
  fi
done

