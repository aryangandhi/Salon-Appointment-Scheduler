#! /bin/bash

echo -e "\n~~~~~ MY SALON ~~~~\n"

echo -e "\nWelcome to My Salon, how can I help you?\n"

MAIN_MENU() {

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

SERVICES=$($PSQL "SELECT service_id, name FROM services")


echo "$SERVICES" | while read SERVICE_ID BAR NAME
do
    echo "$SERVICE_ID) $NAME"
done


read SERVICE_SELECTION
HAVE_SERVICE=$($PSQL "SELECT * FROM services WHERE service_id=$SERVICE_SELECTION")

if [[ -z $HAVE_SERVICE ]];
then
    echo -e "\nI could not find that service. What would you like today?"
    MAIN_MENU
fi

IFS="|" read -r SERVICE_ID_SELECTED SERVICE_NAME < <(echo "$HAVE_SERVICE")

echo -e "\nWhat is your phone number?"
read CUSTOMER_PHONE

HAVE_CUSTOMER=$($PSQL "SELECT * FROM customers WHERE phone='$CUSTOMER_PHONE'")

if [[ -z $HAVE_CUSTOMER ]];
then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    psql --username=freecodecamp --dbname=salon -c "INSERT INTO customers (phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')"
fi

CUSTOMER=$($PSQL "SELECT * FROM customers WHERE phone='$CUSTOMER_PHONE'")

IFS="|" read -r CUSTOMER_ID CUSTOMER_PHONE CUSTOMER_NAME < <(echo "$CUSTOMER")

echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME

psql --username=freecodecamp --dbname=salon -c "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')"

echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."

}


MAIN_MENU
