#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Salon Booking ~~~~~\n"

MAIN_MENU() {
  # msg when redirected here 
  if [[ $1 ]]
  then 
    echo -e "\n$1"
  fi

  # display list of services 
  SERVICES_NAME_LIST=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")
  echo "$SERVICES_NAME_LIST" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo -e "\n$SERVICE_ID) $SERVICE_NAME"
  done
  # ask which service to book
  echo -e "\nWhich service would you like to book ?"
  read SERVICE_ID_SELECTED
  
  # get name of the selected service from service_id 
  SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")

  # if not a valid service_id, redirection to the list
  if [[ -z $SERVICE_NAME_SELECTED ]]
  then 
    # redirection
    MAIN_MENU "Not a valid service id"
  else
    # asking for customer info
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    # if phone number not present in the database, then we ask customer name and create new row in customers table 
    if [[ -z $CUSTOMER_ID ]]
    then
      echo -e "\nWhat's your name?"
      read CUSTOMER_NAME
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name,phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE'); ")
      CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    fi

    # ask for when they want to book
    echo -e "\nAt what time would you like to book this service ?"
    read SERVICE_TIME

    # we add a new raw in the appointment table
    INSERT_BOOKING_RESULT=$($PSQL "INSERT INTO appointments(time, customer_id,service_id) VALUES ('$SERVICE_TIME',$CUSTOMER_ID,$SERVICE_ID_SELECTED); ")
    # if booking was well created, we display a recap msg
    if [[ $INSERT_BOOKING_RESULT =~ 'INSERT 0 1' ]]
    then
      echo "I have put you down for a$SERVICE_NAME_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi
}

MAIN_MENU

# display a numbered list of the services  :    #) <service>

# pick a sevice

# if not a number

# redirect to SERVICE_MENU

# prompt users to enter a service_id, phone number, a name if they aren’t already a customer, and a time. You should use read to read these inputs into variables named SERVICE_ID_SELECTED, CUSTOMER_PHONE, CUSTOMER_NAME, and SERVICE_TIME
