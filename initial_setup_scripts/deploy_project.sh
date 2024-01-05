#!/bin/bash

# Define an array for each environment variable set
DB_NAMES=("ANPUltimusdb" "ANPMementodb")
DB_USERS=("vsap1" "vsap2")
DB_PASSWORDS=("safetyapp2020" "safetyapp2020")
PROJECT_NAMES=("ANP Ultimus" "ANP Memento")
PROJECT_CODES=("ANP ULTIMUS" "ANP MEMENTO")
ZONE_NAMES=("West Pune" "West Pune")
CITIES=("PUNE" "PUNE")
CONTACT_NUMBERS=("8888037788" "8888037788")
ADDRESSES=("S.No. 157,158, Jamdade Wasti, Near Savata Mali Temple, Wakad, Pune 411057" "S.No.83 (P),87 (P),88 (P) & 139 (P) Bhumkar Chowk, Wakad, Pune-411057")
NUM_BUILDINGS=("6" "4")
VS_PROJECT_ONE_PORTS=("3031" "3032")
GITTAG="1.0.272"
PROJECT_Directory_NAMES=("ANP_Ultimus" "ANP_Memento")

# Iterate through the arrays
for i in "${!DB_NAMES[@]}"; do
    export DB_NAME="${DB_NAMES[i]}"
    export DB_USER="${DB_USERS[i]}"
    export DB_PASSWD="${DB_PASSWORDS[i]}"
    export PROJECT_NAME="${PROJECT_NAMES[i]}"
    export PROJECT_CODE="${PROJECT_CODES[i]}"
    export ZONE_NAME="${ZONE_NAMES[i]}"
    export CITY="${CITIES[i]}"
    export CONTACT_NUMBER="${CONTACT_NUMBERS[i]}"
    export ADDRESS="${ADDRESSES[i]}"
    export NUMBER_OF_BUILDINGS="${NUM_BUILDINGS[i]}"
    export VS_PROJECT_ONE_PORT="${VS_PROJECT_ONE_PORTS[i]}"
    export GITTAG="${GITTAG}"
    export PROJECT_Directory_NAME="${PROJECT_Directory_NAMES[i]}"

    # Print environment variables for the current project
    echo "Running Project $((i+1)): $PROJECT_NAME"
    echo "DB_NAME=$DB_NAME"
    echo "DB_USER=$DB_USER"
    echo "DB_PASSWD=$DB_PASSWD"
    echo "PROJECT_NAME=$PROJECT_NAME"
    echo "PROJECT_CODE=$PROJECT_CODE"
    echo "ZONE_NAME=$ZONE_NAME"
    echo "CITY=$CITY"
    echo "CONTACT_NUMBER=$CONTACT_NUMBER"
    echo "ADDRESS=$ADDRESS"
    echo "NUMBER_OF_BUILDINGS=$NUMBER_OF_BUILDINGS"
    echo "VS_PROJECT_ONE_PORT=$VS_PROJECT_ONE_PORT"
    echo "GITTAG=$GITTAG"
    echo "PROJECT_Directory_NAME=$PROJECT_Directory_NAME"
    echo "--------------------------------------------"

    # Run your project script here with the current set of environment variables
    ./project_script.sh

    # Add a delay if needed before the next iteration
    sleep 5
done


