#!/bin/bash

mkdir -p build/ios/iphoneos/Payload
mv build/ios/iphoneos/Runner.app build/ios/iphoneos/Payload
cd build/ios/iphoneos/
zip -r app-ios.ipa Payload