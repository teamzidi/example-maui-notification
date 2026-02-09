#!/bin/bash

KEYSTORE_PATH="<YOUR_KEYSTORE>"
ALIAS="<YOUR_ALIAS>"
PASSWD=$(pbpaste)

# パスワードが取得できたか確認
if [ -z "PASSWD" ]; then
  echo "Error: Could not retrieve passwords from Keychain. Make sure they are saved correctly."
  exit 1
fi

echo "Starting Android release build..."

# dotnet publish コマンドでビルド
dotnet publish -f net9.0-android -c Release \
    -p:AndroidKeyStore=True \
    -p:AndroidSigningKeyStore="$KEYSTORE_PATH" \
    -p:AndroidSigningKeyAlias="$ALIAS" \
    -p:AndroidSigningStorePass="$PASSWD" \
    -p:AndroidSigningKeyPass="$PASSWD"

if [ $? -eq 0 ]; then
    echo "Android release build completed successfully."
else
    echo "Android release build failed."
fi
