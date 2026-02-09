#!/usr/bin/env bash

set -eu

CODESIGN_KEY='Apple Distribution: <YOUR_CODESIGN_NAME>'
API_KEY='<YOUR_API_KEY>'
API_ISSUER='<YOUR_API_ISSUER>'

dotnet publish -f net9.0-ios -c Release -p:ArchiveOnBuild=true -p:RuntimeIdentifier=ios-arm64 -p:CodesignKey="$CODESIGN_KEY" -p:CodesignProvision='Prod ExampleNotification' -p:CodesignEntitlements='./Platforms/iOS/Entitlements.production.plist'

xcrun altool --upload-app -t ios -f "./bin/Release/net9.0-ios/ios-arm64/publish/ExampleNotification.ipa" --apiKey "$API_KEY" --apiIssuer "$API_ISSUER" --verbose
