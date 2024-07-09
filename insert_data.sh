#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
 echo $($PSQL "TRUNCATE teams, games") 
  cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
  do
    if [[ $YEAR != "year" ]]
    then
        TEAM1=$($PSQL "SELECT teams FROM teams WHERE name='$WINNER'")
        if [[ -z $TEAM1 ]]
        then
          INSERT_TEAM1=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")          
         
        fi

        TEAM2=$($PSQL "SELECT teams FROM teams WHERE name='$OPPONENT'")
        if [[ -z $TEAM2 ]]
        then
          INSERT_TEAM2=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")          
        fi


        TEAM1_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
        TEAM2_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
        
        INSERT_GAME=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ('$YEAR', '$ROUND', '$TEAM1_ID', '$TEAM2_ID', '$WINNER_GOALS', '$OPPONENT_GOALS')")
    fi
  done
