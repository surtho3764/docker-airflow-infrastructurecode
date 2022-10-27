#!/usr/bin/env bash



# Setting  env
: "${REDIS_HOST:="redis"}"
: "${REDIS_PORT:="6379"}"
: "${REDIS_PASSWORD:=""}"

: "${MYSQL_HOST:="mysql"}"
: "${MYSQL_PORT:="3306"}"
: "${MYSQL_USER:="airflow"}"
: "${MYSQL_PASSWORD:="airflow"}"
: "${MYSQL_DB:="airflow"}"

# Setting Configuration Options
: "${AIRFLOW_HOME:="/home/airflow"}"

# setting EXECUTOR method in airflow.cfg file parameters
# default EXECUTOR=SequentialExecutor
: "${EXECUTOR:="SequentialExecutor"}"
: "${AIRFLOW__CORE__EXECUTOR:=${EXECUTOR}}"


# setting load example in airflow.cfg
# default LOAD_EXAMPLES  is False
#AIRFLOW__CORE__LOAD_EXAMPLES=True

AIRFLOW__CORE__LOAD_EXAMPLES=False

#: "${AIRFLOW__CORE__FERNET_KEY:=${FERNET_KEY:=$(python3 -c "from cryptography.fernet import Fernet; FERNET_KEY = Fernet.generate_key().decode(); print(FERNET_KEY)")}}"



# setting email SMTP
: "${AIRFLOW__SMTP__SMTP_HOST=smtp.gmail.com}"
: "${AIRFLOW__SMTP__SMTP_STARTTLS=True}"
: "${AIRFLOW__SMTP__SMTP_USER=tdcetl@gmail.com}"
: "${AIRFLOW__SMTP__SMTP_PASSWORD=vetypicqxfvxbmrk}"
: "${AIRFLOW__SMTP__SMTP_PORT=587}"
: "${AIRFLOW__SMTP__SMTP_MAIL_FROM=tdcetl@gmail.com}"


export \
  AIRFLOW_HOME \
  AIRFLOW__CORE__EXECUTOR \
  AIRFLOW__CORE__SQL_ALCHEMY_CONN \
  AIRFLOW__CELERY__BROKER_URL \
  AIRFLOW__CELERY__RESULT_BACKEND \
  AIRFLOW__CORE__LOAD_EXAMPLES \
  AIRFLOW__SMTP__SMTP_HOST \
  AIRFLOW__SMTP__SMTP_STARTTLS \
  AIRFLOW__SMTP__SMTP_USER \
  AIRFLOW__SMTP__SMTP_PASSWORD \
  AIRFLOW__SMTP__SMTP_PORT \
  AIRFLOW__SMTP__SMTP_MAIL_FROM








# Setting root user can start celery
export C_FORCE_ROOT="true"




#AIRFLOW__CORE__SQL_ALCHEMY_CONN="mysql://airflow:airflow@localhost:3306/airflow"
#AIRFLOW__CELERY__BROKER_URL="redis://127.0.0.1:6379/0"
#AIRFLOW__CELERY__RESULT_BACKEND="db+mysql://airflow:airflow@localhost:3306/airflow"

# Create folder
#mkdir ${AIRFLOW_HOME}/dags
#mkdir ${AIRFLOW_HOME}/lib
#mkdir ${AIRFLOW_HOME}/script



# Setting metadata connect mysql configure in airflow.cfg file parameters
# setting sql_alchemy_conn parameters value in airflow.cfg file
AIRFLOW__CORE__SQL_ALCHEMY_CONN="mysql://$MYSQL_USER:$MYSQL_PASSWORD@$MYSQL_HOST:$MYSQL_PORT/$MYSQL_DB"

# setting result_backend parameters value in airflow.cfg file
AIRFLOW__CELERY__RESULT_BACKEND="db+mysql://$MYSQL_USER:$MYSQL_PASSWORD@$MYSQL_HOST:$MYSQL_PORT/$MYSQL_DB"




# Wait host port open running
TRY_LOOP="20"

wait_for_port() {
  local name="$1" host="$2" port="$3"
  local j=0
  while ! nc -z "$host" "$port" >/dev/null 2>&1 < /dev/null; do
    j=$((j+1))
    if [ $j -ge $TRY_LOOP ]; then
      echo >&2 "$(date) - $host:$port still not reachable, giving up"
      exit 1
    fi
    echo "$(date) - waitind for $name... $j/$TRY_LOOP"
    sleep 5
  done
}

wait_for_port "mysql" "$MYSQL_HOST" "$MYSQL_PORT"



# check redis  password is empty
if [ -n "$REDIS_PASSWORD" ]; then
    REDIS_PREFIX=:${REDIS_PASSWORD}@
else
    REDIS_PREFIX=
fi

#setting EXECUTOR=CeleryExecutor value condition in airflow.cfg file
if [ "$AIRFLOW__CORE__EXECUTOR" == "CeleryExecutor" ]; then
  # setting broker_url parameters value in airflow.cfg file
  AIRFLOW__CELERY__BROKER_URL="redis://$REDIS_PREFIX$REDIS_HOST:$REDIS_PORT/0"
  wait_for_port "Redis" "$REDIS_HOST" "$REDIS_PORT"
fi


case "${1}" in
  webserver)
    airflow initdb
    if [ "$AIRFLOW__CORE__EXECUTOR" == "LocalExecutor" ]; then
      # With the "Local" executors it should all run in one container.
      airflow scheduler &
    fi
    if [ "$AIRFLOW__CORE__EXECUTOR" == "SequentialExecutor" ]; then
      # With the "Sequential" executors it should all run in one container.
      airflow scheduler &
    fi
    exec airflow webserver
    ;;
  worker|scheduler)
    # To give the webserver time to run initdb.
    sleep 30
    exec airflow "${1}"
    ;;
  flower)
    # To give the webserver time to run initdb.
    sleep 30
    exec airflow "${1}"
    ;;
  *)
    echo "$@"
    ;;
esac
