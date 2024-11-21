# Currency Converter App

## Overview

This is a SwiftUI-based Currency Converter app that uses the [ExchangeRates API](https://api.exchangeratesapi.io/) to provide exchange rates. Users can convert currencies by entering the amount and selecting the currencies they wish to convert between. The app supports both portrait and landscape orientations.

### Key Features:

- Currency conversion using live exchange rates from the ExchangeRates API after open the app.
- Supports both portrait and landscape orientations.
- SwiftUI user interface for a modern and responsive design.
- Notifies the user when the app is offline and some error occurs.

## Steps to Build and Run

### Prerequisites:

- Xcode 12.0 or higher.
- Swift 5.0 or higher.
- CocoaPods 1.10.0 or higher.
- An active internet connection.

### Build Instructions:

1. **Clone the repository:**

   ```bash
   git clone https://github.com/Huy203/TymeX-Program.git
   cd currency-converter
   ```

2. **Open the Xcode project:**

   ```bash
   open currency-converter.xcodeproj
   ```

3. **Set up the API key:**

- Create an account on [ExchangeRates API](https://api.exchangeratesapi.io/) and get your API key.
- Create a Env file in **/currency-converter/Resources/Secrets** folder and add your API key and Base URL in the file

4. **Build and run the project in Xcode (⌘+R).**

- Pod install if you have not installed pods yet

  ```bash
  pod install
  ```

- The app should now build and run successfully on the iOS Simulator or a physical device.
- Select the target device (simulator or physical device).
- Press Cmd + R to build and run the app or press the play button in Xcode.

## Challenges and Notes

- Handling Secret Keys: One of the challenges faced during development was retrieving the API key via .xcconfig file and Info.plist. The solution was to create a Secrets folder in the project and store the API key in a separate file. This file was then added to the .gitignore file to prevent it from being pushed to the repository.
- Unit Testing: This project marked the first time unit tests were implemented for a SwiftUI app. The focus was on testing currency conversion logic and ensuring the app functions as expected.

## Demo Videos

- [Portrait Mode](https://drive.google.com/file/d/1r1P3PRUeF1gagXv6ivL64Vhir5ijoVKh/view?usp=sharing "Portrait Mode")
- [Landscape Mode](https://drive.google.com/file/d/1qO29ZgEU27JyblpF51ZUw9374h5lt05s/view?usp=sharing "Landscape Mode")
- [Offline Mode](https://drive.google.com/file/d/1DFsn1HXMzGjrgXS0yc4WS-nQ46b8uWHK/view?usp=sharing "Offline Mode")
