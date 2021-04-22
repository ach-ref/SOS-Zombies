# SOS Zombie
A simple app allowing the user to get a suggested list of hospitals sorted by average waiting time according to the the painLevel.

<p align="center">
    <a href="#"><img src="https://img.shields.io/badge/Swift-5.3-orange" /></a>
    <a href="#"><img src="https://img.shields.io/badge/platform-ios-lightgrey" /></a>
    <a href="#"><img src="https://img.shields.io/badge/license-MIT-green" /></a>
</p>

## Usage

To run the app, it is simple

1. Download and extract the zip
2. Open the workspace with xcode
    - No need to run **\"pod install\"**
    - The `pod` diectory is tracked
3. `cmd+Shift+K` to clean then `cmd+R` to run

## Requirement

- Swift 5.3
- iOS 12.1 and above

## Design pattern

This app uses the classic Apple's MVC pattern.

## Discussion

- Each time the app is launched the data is synchroised with the backend unless there is a network error in which case the `user` is alerted.

- The `user` has the possibility to register the `illeness` and the `pain level` in order to access the hospitals waiting time directly without passing through the registration form again.

- The `user` has the possibility to `delete` a registration from the list at anytime by a simple swipe to the left.

- The registration process is like follow :
    + The `user` chooses an `illness` from the list
    + The next screen is a form including the `name` (compulsory), `insurance ID` and the `pain level` from 0 to 4.
    + Once the form is valid the user is shown a list of hospitals ordered by average waiting time from shortest to longest

- The `user` has the possibility to sort the hospitals by `distance` in which case the location access must be granted beforehand. The hospitals are sorted from the closest to the farthest.

- The app is localized and supports both English and French.

- The app is `DarkMode` compatible and works on iPhoe and iPad