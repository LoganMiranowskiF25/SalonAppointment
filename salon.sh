#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n ~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

CREATE_APPOINTMENT(){
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | xargs)
  CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | xargs)

  echo -e "\nWhat time would you like your $SERVICE_NAME_FORMATTED, $CUSTOMER_NAME_FORMATTED?"
  read SERVICE_TIME
  
  $PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ('$CUSTOMER_ID', $SERVICE_ID_SELECTED, '$SERVICE_TIME')" >/dev/null
  
  echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
}

MAIN_MENU(){
if [[ $1 ]]
then
  echo -e "\n$1"
fi

SERVICES=$($PSQL "SELECT service_id, name FROM services")
echo "$SERVICES" | while read SERVICE_ID BAR NAME;
do
  echo "$SERVICE_ID) $NAME SERVICE"
done

read SERVICE_ID_SELECTED
HAVE_SERVICE=$($PSQL "SELECT service_id, name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

if [[ -z $HAVE_SERVICE ]];
then
  MAIN_MENU "I could not find that service. What would you like today?"
  return
fi

echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
CUSTOMER_ID=$(echo $CUSTOMER_ID | xargs)

if [[ -z $CUSTOMER_ID ]];
then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME

  $PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')" >/dev/null
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  CUSTOMER_NAME=$(echo $CUSTOMER_NAME | xargs)
else
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  CUSTOMER_NAME=$(echo $CUSTOMER_NAME | xargs)
fi

  CREATE_APPOINTMENT
}
MAIN_MENU
