eyamldecrypt
-----------
```
eyamldecrypt -k|--key <private_key_file> -p|--pub <pkcs_public_key_file> -d|--directory <dir-with-eyml-files>

# environment variables (has priority over params)
  PRIVATE_KEY      PKCS7 private key            export PRIVATE_KEY=$(cat ./keys/private_key.pkcs7.pem)
  PUBLIC_KEY       PKCS7 public key             export PUBLIC_KEY=$(cat ./keys/public_key.pkcs7.pem)
  CONF_DIR         Directory of eyml files      export CONF_DIR=./application/configs/
```
