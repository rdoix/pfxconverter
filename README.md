# Convert Certificate to PFX Script

This script converts a private key and public certificate (with an optional intermediate certificate) into a PFX file. It uses OpenSSL for conversion and validation of the resulting PFX file.

## Features
- Supports multiple certificate file formats:
  - **Private Key**: `.pem`, `.key`
  - **Public Certificate**: `.crt`, `.pem`, `.cer`, `.der`, `.p7b`
  - **Intermediate Certificate** (optional): `.crt`, `.pem`
- Validates the resulting PFX file.
- Highlights errors if any step fails.

## Requirements
- Bash shell (Linux/MacOS) or WSL (Windows Subsystem for Linux).
- OpenSSL installed:
    ```bash
    openssl version
    ```

## Installation
1. Clone this repository:
    ```bash
    git clone https://github.com/rdoix/pfxconverter.git
    cd pfxconverter
    ```

## Usage
Run the script with the following command:
```bash
./pfxconverter.sh
```

Follow the prompts to provide:
- PFX output file name.
- Paths to private key, public certificate, and intermediate certificate (optional).

## Example Output

### Input Prompts
```plaintext
Enter the PFX output file name.
Example: /home/user/output.pfx
>> /home/user/output.pfx

Do you have an intermediate certificate? (y/N)
Example: /etc/ssl/certs/ca-bundle.crt, /etc/ssl/certs/intermediate.crt
>> y

Enter the path to the intermediate certificate.
>> /etc/ssl/certs/ca-bundle.crt

Enter the path to the private key.
Example: /etc/ssl/private/privatekey.pem, /etc/ssl/private/server.key
>> /etc/ssl/private/privatekey.pem

Enter the path to the public certificate.
Example: /etc/ssl/certs/certificate.crt, /etc/ssl/certs/certificate.pem
>> /etc/ssl/certs/certificate.crt

Converting certificate to PFX...
/home/user/output.pfx has been successfully created!
```

### Validation Output
```plaintext
Would you like to validate the PFX file? (y/N)
>> y

Validating the generated PFX file...
Enter the password used to import the PFX file:
PFX file validation successful!
==================================
Certificate Information:
  Domain (CN):    *.example.com
  Issuer:         Sectigo RSA Domain Validation Secure Server CA
  Valid From:     Nov 22 00:00:00 2024 GMT
  Valid Until:    Dec 23 23:59:59 2025 GMT
==================================
```

## Notes
- If any step fails, the script will display an error message.
- Ensure that paths to the certificate files are correct and accessible.

## License
This project is licensed under the [MIT License](LICENSE).
