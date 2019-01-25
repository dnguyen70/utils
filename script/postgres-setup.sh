#!/bin/bash -e



echo "Local Postgresql Setup for Rally Dataship Purpose"
echo
echo "This script can be run repeatedly and keep tools up to date"
echo "Sets up the components necessary to local development including:"
echo "  * restart postgresql with port 8432"
echo "  * create database 'dataship'"
echo "  * create role 'rallyhealth'"
echo


read -p "Begin? [Y/n] " REPLY
if [[ $REPLY =~ ^[Nn]$ ]]
then
    exit 1
fi

function restartPostgres {

    sed -i.bak '/port =/d' /usr/local/var/postgres/postgresql.conf
    echo 'port = 8432' >> /usr/local/var/postgres/postgresql.conf
    kill -9 `pgrep postgres`
    brew services restart postgresql

}

function createUserAndDB {

    sleep 10

    psql postgres -p 8432 -tc "SELECT 1 FROM pg_user WHERE usename = 'rallyhealth'" | grep 1 || psql postgres -p 8432 -c "CREATE ROLE rallyhealth WITH LOGIN PASSWORD 'werally'"
    psql postgres -p 8432 -tc "SELECT 1 FROM pg_database WHERE datname = 'dataship'" | grep 1 || psql postgres -p 8432 -c "CREATE DATABASE dataship"
    psql postgres -p 8432 -c "GRANT ALL PRIVILEGES ON DATABASE dataship TO rallyhealth"

}


restartPostgres
createUserAndDB