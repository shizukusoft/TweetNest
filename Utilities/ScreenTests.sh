#!/bin/bash

IOS_DEVICES=(
    'iPhone 13 Pro Max' # 6.5 Inch
    'iPhone 13' # 5.8 Inch
    'iPhone 8 Plus' # 5.5 Inch
    'iPad Pro (12.9-inch) (5th generation)' # 12.9 Inch, iPad Pro (3rd generation)
    'iPad Pro (11-inch) (3rd generation)' # 11 Inch
    'iPad Pro (12.9-inch) (2nd generation)' # 12.9 Inch, iPad Pro (2nd generation)
)

WATCHOS_DEVICES=(
    'Apple Watch Series 7 - 45mm' # Series 7 (45mm)
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

watchos_destinations=()
for watchos_device in "${WATCHOS_DEVICES[@]}"
do
    watchos_destinations+=("-destination" "platform=watchOS Simulator,name=$watchos_device")
done

xcodebuild -scheme "TweetNest (watchOS)" -only-testing "TweetNest Tests (watchOS)/TweetNestScreenTests" -testLanguage en -testRegion US -resultBundlePath 'ScreenTests (watchOS)(en-US).xcresult' "${watchos_destinations[@]}" test
xcodebuild -scheme "TweetNest (watchOS)" -only-testing "TweetNest Tests (watchOS)/TweetNestScreenTests" -testLanguage ja -testRegion JP -resultBundlePath 'ScreenTests (watchOS)(ja-JP).xcresult' "${watchos_destinations[@]}" test
xcodebuild -scheme "TweetNest (watchOS)" -only-testing "TweetNest Tests (watchOS)/TweetNestScreenTests" -testLanguage ko -testRegion KR -resultBundlePath 'ScreenTests (watchOS)(ko-KR).xcresult' "${watchos_destinations[@]}" test

#######################################################################################################################

xcodebuild -scheme "TweetNest (macOS)" -only-testing "TweetNest Tests (macOS)/TweetNestScreenTests" -resultBundlePath 'ScreenTests (macOS).xcresult' test
