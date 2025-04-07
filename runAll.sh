#!/bin/bash

# Function to create an Azure Resource group
function init_resourse_group_name() {
    PET_STORE_RG_NAME="petstorerg"
}

# Function to create an Azure Resource group
function create_resourse_group() {
    local resourse_group_location="$1"

    echo "Creating Resource group: $PET_STORE_RG_NAME"
    az group create  \
        --name ${PET_STORE_RG_NAME} \
        --location ${loc_pet_store_us} \
        --output none
}

# Function to create an Container Registriy
function create_container_registry() {
    local cr_pet_store="$1"

    echo "Creating Container Registriy: $cr_pet_store"
    az acr create \
        --resource-group ${PET_STORE_RG_NAME} \
        --name ${cr_pet_store} \
        --sku 'Basic' \
        --admin-enabled 'true' \
        --output none
}

# Function to create an Container Registriy
function build_docker_image() {
    local cr_pet_store="$1"

    echo "Creating Container Registriy: $cr_pet_store"
    az acr create \
        --resource-group ${PET_STORE_RG_NAME} \
        --name ${cr_pet_store} \
        --sku 'Basic' \
        --admin-enabled 'true' \
        --output none
}
