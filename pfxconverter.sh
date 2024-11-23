#!/bin/bash

# Colors
RED="\033[1;31m"
GREEN="\033[1;32m"
BLUE="\033[1;34m"
YELLOW="\033[1;33m"
CYAN="\033[1;36m"
NC="\033[0m" # No Color

# Header
echo -e "${BLUE}=== Convert Certificate to PFX Script ===${NC}"

# Example Files
echo -e "${CYAN}Below are examples of supported file types and extensions:${NC}"
echo -e "${YELLOW}- Private Key:${NC} privatekey.pem, server.key, private.key"
echo -e "${YELLOW}- Public Certificate:${NC} certificate.crt, certificate.pem, certificate.cer, certificate.der, certificate.p7b"
echo -e "${YELLOW}- Intermediate Certificate:${NC} ca-bundle.crt, intermediate.crt, intermediate.pem"
echo -e "${YELLOW}- Output PFX File:${NC} output.pfx, server.pfx"
echo -e "${BLUE}==========================================${NC}"
echo ""

# Enter PFX Output File Name
echo -e "${CYAN}Enter the PFX output file name.${NC}"
echo -e "${YELLOW}Example:${NC} /home/user/output.pfx"
read -p ">> " PFX_NAME
echo ""

# Do You Have an Intermediate Certificate
echo -e "${CYAN}Do you have an intermediate certificate? (y/N)${NC}"
echo -e "${YELLOW}Example:${NC} /etc/ssl/certs/ca-bundle.crt, /etc/ssl/certs/intermediate.crt"
read -p ">> " HAS_CA_BUNDLE
echo ""

# Enter Intermediate Certificate Path
if [[ "$HAS_CA_BUNDLE" =~ ^[yY]$ ]]; then
    echo -e "${CYAN}Enter the path to the intermediate certificate.${NC}"
    read -p ">> " CA_BUNDLE
    if [[ ! -f "$CA_BUNDLE" ]]; then
        echo -e "${RED}Error:${NC} Intermediate certificate file '${CA_BUNDLE}' not found."
        exit 1
    fi
    echo ""
fi

# Enter Private Key Path
echo -e "${CYAN}Enter the path to the private key.${NC}"
echo -e "${YELLOW}Example:${NC} /etc/ssl/private/privatekey.pem, /etc/ssl/private/server.key"
read -p ">> " PRIVATE_KEY
if [[ ! -f "$PRIVATE_KEY" ]]; then
    echo -e "${RED}Error:${NC} Private key file '${PRIVATE_KEY}' not found."
    exit 1
fi
echo ""

# Enter Public Certificate Path
echo -e "${CYAN}Enter the path to the public certificate.${NC}"
echo -e "${YELLOW}Example:${NC} /etc/ssl/certs/certificate.crt, /etc/ssl/certs/certificate.pem, /etc/ssl/certs/certificate.cer, /etc/ssl/certs/certificate.der, /etc/ssl/certs/certificate.p7b"
read -p ">> " CERTIFICATE
if [[ ! -f "$CERTIFICATE" ]]; then
    echo -e "${RED}Error:${NC} Public certificate file '${CERTIFICATE}' not found."
    exit 1
fi
echo ""

# Conversion Process
echo -e "${CYAN}Converting certificate to PFX...${NC}"
if [[ "$HAS_CA_BUNDLE" =~ ^[yY]$ ]]; then
    openssl pkcs12 -export -out "$PFX_NAME" -inkey "$PRIVATE_KEY" -in "$CERTIFICATE" -certfile "$CA_BUNDLE" 2> error.log
else
    openssl pkcs12 -export -out "$PFX_NAME" -inkey "$PRIVATE_KEY" -in "$CERTIFICATE" 2> error.log
fi

# Validate if Error Occurs
if [[ $? -ne 0 ]]; then
    echo -e "${RED}Error:${NC} An error occurred while creating the PFX file. Error details:"
    cat error.log
    rm error.log
    exit 1
else
    rm -f error.log
    echo -e "${GREEN}${PFX_NAME} has been successfully created!${NC}"
fi
echo ""

# Validate PFX File
echo -e "${CYAN}Would you like to validate the PFX file? (y/N)${NC}"
read -p ">> " VALIDATE_PFX
echo ""

if [[ "$VALIDATE_PFX" =~ ^[yY]$ ]]; then
    echo -e "${CYAN}Validating the generated PFX file...${NC}"
    read -s -p "Enter the password used to import the PFX file: " PASSWORD
    echo ""

    # Password Validation
    if ! openssl pkcs12 -in "$PFX_NAME" -clcerts -nokeys -passin pass:"$PASSWORD" >/dev/null 2>&1; then
        echo -e "${RED}Error:${NC} Invalid password or the PFX file cannot be accessed."
        exit 1
    fi

    DOMAIN=$(openssl pkcs12 -in "$PFX_NAME" -clcerts -nokeys -passin pass:"$PASSWORD" | openssl x509 -noout -subject | sed 's/.*CN=//')
    ISSUER=$(openssl pkcs12 -in "$PFX_NAME" -clcerts -nokeys -passin pass:"$PASSWORD" | openssl x509 -noout -issuer | sed 's/.*CN=//')
    VALID_FROM=$(openssl pkcs12 -in "$PFX_NAME" -clcerts -nokeys -passin pass:"$PASSWORD" | openssl x509 -noout -startdate | sed 's/notBefore=//')
    VALID_UNTIL=$(openssl pkcs12 -in "$PFX_NAME" -clcerts -nokeys -passin pass:"$PASSWORD" | openssl x509 -noout -enddate | sed 's/notAfter=//')

    if [[ -z "$DOMAIN" ]]; then DOMAIN="Not found"; fi
    if [[ -z "$ISSUER" ]]; then ISSUER="Not found"; fi
    if [[ -z "$VALID_FROM" ]]; then VALID_FROM="Not found"; fi
    if [[ -z "$VALID_UNTIL" ]]; then VALID_UNTIL="Not found"; fi

    echo -e "${GREEN}PFX file validation successful!${NC}"
    echo -e "${BLUE}==================================${NC}"
    echo -e "${YELLOW}Certificate Information:${NC}"
    echo -e "  ${GREEN}Domain (CN):${NC}    $DOMAIN"
    echo -e "  ${GREEN}Issuer:${NC}         $ISSUER"
    echo -e "  ${GREEN}Valid From:${NC}     $VALID_FROM"
    echo -e "  ${GREEN}Valid Until:${NC}    $VALID_UNTIL"
    echo -e "${BLUE}==================================${NC}"
else
    echo -e "${YELLOW}Process completed.${NC}"
fi

