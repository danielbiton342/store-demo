#!/bin/bash

# List your available acrs
az acr list --resource-group terraform-test --output table

# Getting hold of the acr pass for login process
ACR_PASS=$(az acr credential show --name myacrdemo --query "passwords[0].value" -o tsv)

# Logging in to acr registry
docker login myacrdemo.azurecr.io -u myacrdemo -p "$ACR_PASS"


# First initializing the Application images to ACR
# makeline
cd makeline-service
docker build -t makeline-service .
docker tag makeline-service myacrdemo.azurecr.io/makeline-service:v1
docker push myacrdemo.azurecr.io/makeline-service:v1

# order
cd ../order-service
docker build -t order-service .
docker tag order-service myacrdemo.azurecr.io/order-service:v1
docker push myacrdemo.azurecr.io/order-service:v1

# product
cd ../product-service
docker build -t product-service .
docker tag product-service myacrdemo.azurecr.io/product-service:v1
docker push myacrdemo.azurecr.io/product-service:v1

# store admin
cd ../store-admin
docker build -t store-admin .
docker tag store-admin myacrdemo.azurecr.io/store-admin:v1
docker push myacrdemo.azurecr.io/store-admin:v1

# store front
cd ../store-front
docker build -t store-front .
docker tag store-front myacrdemo.azurecr.io/store-front:v1
docker push myacrdemo.azurecr.io/store-front:v1


# Checking the repositories
az acr repository list --name myacrdemo --output table






