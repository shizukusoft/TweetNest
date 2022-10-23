#!/bin/bash

set -e -x

IOS_DEVICES=(
    'iPhone 14 Pro Max' # 6.5 Inch
    'iPhone 14 Pro' # 5.8 Inch
    'iPhone 8 Plus' # 5.5 Inch
    'iPhone SE (3rd generation)' # 4.7 Inch
    'iPad Pro (12.9-inch) (6th generation)' # 12.9 Inch, iPad Pro (3rd generation)
    'iPad Pro (11-inch) (4th generation)' # 11 Inch
    'iPad Pro (12.9-inch) (2nd generation)' # 12.9 Inch, iPad Pro (2nd generation)
)

WATCHOS_DEVICES=(
    'Apple Watch Series 8 - 45mm' # Series 8 (45mm)
)

#######################################################################################################################

xcodebuild -scheme "TweetNest" -testPlan "ScreenTests" -destination 'generic/platform=macOS' build-for-testing
xcodebuild -scheme "TweetNest" -testPlan "ScreenTests" -destination 'generic/platform=iOS Simulator' build-for-testing
xcodebuild -scheme "TweetNest Watch App" -testPlan "ScreenTests" -destination 'generic/platform=watchOS Simulator' build-for-testing

#######################################################################################################################

xcodebuild -scheme "TweetNest" -testPlan "ScreenTests" -destination 'platform=macOS' -resultBundlePath 'ScreenTests (macOS).xcresult' test-without-building

#######################################################################################################################

ios_destinations=()
for ios_device in "${IOS_DEVICES[@]}"
do
    xcrun simctl shutdown "$ios_device" >/dev/null 2>/dev/null || true
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

xcodebuild -scheme "TweetNest" -testPlan "ScreenTests" "${ios_destinations[@]}" -resultBundlePath 'ScreenTests (iOS).xcresult' test-without-building

for ios_device in "${IOS_DEVICES[@]}"
do
    xcrun simctl shutdown "$ios_device"
done

#######################################################################################################################

watchos_destinations=()
for watchos_device in "${WATCHOS_DEVICES[@]}"
do
    watchos_destinations+=("-destination" "platform=watchOS Simulator,name=$watchos_device")
done

xcodebuild -scheme "TweetNest Watch App" -testPlan "ScreenTests" "${watchos_destinations[@]}" -resultBundlePath 'ScreenTests (watchOS).xcresult' test-without-building
