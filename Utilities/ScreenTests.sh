#!/bin/bash

IOS_DEVICES=(
    'iPhone 13 Pro Max'
    'iPhone 13'
    'iPhone 13 mini'
    'iPhone 8'
    'iPhone 8 Plus'
    'iPhone 11'
)

IPADOS_DEVICES=(
    'iPad Pro (12.9-inch) (5th generation)'
    'iPad Pro (11-inch) (3rd generation)'
    'iPad Air (4th generation)'
    'iPad (9th generation)'
    'iPad mini (6th generation)'
)

WATCHOS_DEVICES=(
    'Apple Watch Series 6 - 40mm'
    'Apple Watch Series 6 - 44mm'
    'Apple Watch Series 7 - 41mm'
    'Apple Watch Series 7 - 45mm'
)

#######################################################################################################################

ios_destinations=()
for ios_device in "${IOS_DEVICES[@]}"
do
    xcrun simctl shutdown "$ios_device" >/dev/null 2>/dev/null
    xcrun simctl boot "$ios_device"
    xcrun simctl status_bar "$ios_device" override\
        --time '9:41 AM'\
        --dataNetwork 'wifi'\
        --wifiMode 'active'\
        --wifiBars 3\
        --cellularMode 'active'\
        --cellularBars 4\
        --operatorName ''\
        --batteryState 'discharging'\
        --batteryLevel 100

    ios_destinations+=("-destination" "platform=iOS Simulator,name=$ios_device")
done

xcodebuild -scheme "TweetNest (iOS)" -only-testing "TweetNest Tests (iOS)/TweetNestScreenTests" -resultBundlePath 'ScreenTests (iOS).xcresult' "${ios_destinations[@]}" test

for ios_device in "${IOS_DEVICES[@]}"
do
    xcrun simctl shutdown "$ios_device"
done

#######################################################################################################################

ipados_destinations=()
for ipados_device in "${IPADOS_DEVICES[@]}"
do
    xcrun simctl shutdown "$ipados_device" >/dev/null 2>/dev/null
    xcrun simctl boot "$ipados_device"
    xcrun simctl status_bar "$ipados_device" override\
        --time '9:41 AM'\
        --dataNetwork 'wifi'\
        --wifiMode 'active'\
        --wifiBars 3\
        --cellularMode 'active'\
        --cellularBars 4\
        --operatorName ''\
        --batteryState 'discharging'\
        --batteryLevel 100

    ipados_destinations+=("-destination" "platform=iOS Simulator,name=$ipados_device")
done

xcodebuild -scheme "TweetNest (iOS)" -only-testing "TweetNest Tests (iOS)/TweetNestScreenTests" -resultBundlePath 'ScreenTests (iPadOS).xcresult' "${ipados_destinations[@]}" test

for ipados_device in "${IPADOS_DEVICES[@]}"
do
    xcrun simctl shutdown "$ipados_device"
done

#######################################################################################################################

watchos_destinations=()
for watchos_device in "${WATCHOS_DEVICES[@]}"
do
    watchos_destinations+=("-destination" "platform=watchOS Simulator,name=$watchos_device")
done

xcodebuild -scheme "TweetNest (watchOS)" -only-testing "TweetNest Tests (watchOS)/TweetNestScreenTests" -testLanguage en -testRegion US -resultBundlePath 'ScreenTests (watchOS)(en-US).xcresult' "${watchos_destinations[@]}" test
xcodebuild -scheme "TweetNest (watchOS)" -only-testing "TweetNest Tests (watchOS)/TweetNestScreenTests" -testLanguage ko -testRegion KR -resultBundlePath 'ScreenTests (watchOS)(ko-KR).xcresult' "${watchos_destinations[@]}" test
