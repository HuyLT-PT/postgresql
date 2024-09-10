#!/bin/bash

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

GET_SERVICES_ID() {
  LIST_SERVICES=$($PSQL "SELECT service_id, name FROM services")

  echo "$LIST_SERVICES" | while IFS='|' read SERVICE_ID_SELECTED SERVICE
  do
    SERVICE_ID_SELECTED=$(echo "$SERVICE_ID_SELECTED" | sed 's/^[ \t]*//;s/[ \t]*$//')
    SERVICE=$(echo "$SERVICE" | sed 's/^[ \t]*//;s/[ \t]*$//')
  
    echo "$SERVICE_ID_SELECTED) $SERVICE"
  done


  read SERVICE_CHOSE

  SERVICE_ID_EXIST=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_CHOSE")

  if [[ -z $SERVICE_ID_EXIST ]]; then
    echo -e "\nI could not find that service. What would you like today?"
    GET_SERVICES_ID
  else 
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    IS_CUSTOMER_EXIST=$($PSQL "SELECT customer_id, name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    if [[ -z $IS_CUSTOMER_EXIST ]]; then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    else
      CUSTOMER_ID=$(echo "$IS_CUSTOMER_EXIST" | cut -d '|' -f 1 | sed 's/^[ \t]*//;s/[ \t]*$//')
      CUSTOMER_NAME=$(echo "$IS_CUSTOMER_EXIST" | cut -d '|' -f 2 | sed 's/^[ \t]*//;s/[ \t]*$//')
    fi

    echo -e "What time would you like your service, $CUSTOMER_NAME?"
    read SERVICE_TIME
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_EXIST, '$SERVICE_TIME')")

    SERVICE_NAME_EXIST=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_CHOSE")
    SERVICE_NAME=$(echo "$SERVICE_NAME_EXIST" | cut -d '|' -f 1 | sed 's/^[ \t]*//;s/[ \t]*$//')

    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

GET_SERVICES_ID
