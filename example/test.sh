#!/bin/sh
# This is Wi-Fi scanning script for testing
# Example {"rssi": -47, "noise": -96, "ssid": "test_ssid"}
airport -I | awk '{gsub(/ /,"", $0);print $1}' | awk -F ':' '/^agrCtlRSSI/{rssi = int($2)} /^agrCtlNoise/{noise = int($2)} /^SSID/{ssid = $2} END {printf "{\"rssi\": %d, \"noise\": %d, \"ssid\": \"%s\"}", rssi, noise, ssid}'
