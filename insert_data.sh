#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

$PSQL "TRUNCATE TABLE games, teams RESTART IDENTITY"

TEAM_VALUES=""
GAME_VALUES=""

while IFS="," read -r year round winner opponent winner_goals opponent_goals
do
    [[ "$year" == "year" || -z "$year" ]] && continue

    opponent_goals=${opponent_goals//$'\r'/}

    TEAM_VALUES+="('$winner'), ('$opponent'), "

    GAME_VALUES+="($year, '$round', (SELECT team_id FROM teams WHERE name='$winner'), (SELECT team_id FROM teams WHERE name='$opponent'), $winner_goals, $opponent_goals), "

done < <(tail -n +2 games.csv)

TEAM_VALUES=${TEAM_VALUES%, }
GAME_VALUES=${GAME_VALUES%, }

$PSQL "INSERT INTO teams(name) VALUES $TEAM_VALUES ON CONFLICT (name) DO NOTHING"

$PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES $GAME_VALUES"