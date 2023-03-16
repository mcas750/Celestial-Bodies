#!/bin/bash
echo -e "\n~~~~~ MY SALON ~~~~~\n"
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "\nWelcome to My Salon, how can I help you?"
  GET_LIST_SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id")
  echo "$GET_LIST_SERVICES" | while read SERVICE_ID BAR NAME

  do
    echo "$SERVICE_ID) $NAME"
  done

  read SERVICE_ID_SELECTED

  if [[ -z $SERVICE_ID_SELECTED || ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    CHOICE_SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    if [[ -z $CHOICE_SERVICE_ID ]]
    then
      MAIN_MENU "I could not find that service. What would you like today?"
    else
      echo -e "\nWhat's your phone number?"
      read CUSTOMER_PHONE
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
      if [[ -z $CUSTOMER_NAME ]]
      then
        echo -e "\nI don't have a record for that phone number, what's your name?"
        read CUSTOMER_NAME
        INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      fi
      echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME"
      read SERVICE_TIME
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
      INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id ='$SERVICE_ID_SELECTED'")
      SERVICE_NAME_CORR=$(echo $SERVICE_NAME | sed 's/ |/"/')
      CUSTOMER_NAME_CORR=$(echo $CUSTOMER_NAME | sed 's/ |/"/')
      echo -e "\nI have put you down for a $SERVICE_NAME_CORR at $SERVICE_TIME, $CUSTOMER_NAME_CORR."
    fi
  fi
}

MAIN_MENU
