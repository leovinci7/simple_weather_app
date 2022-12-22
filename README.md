# simple_weather_app

Developer: Me   
Scope: Home Assignment for iOS position interview 

## Project Detail:  
https://github.com/leovinci7/simple_weather_app/blob/main/take_home_project.pdf

## Trade Offs and Architecture:
- Followed simple MVVM pattern to keep view and business logic separate and clean. Kept the model and API services independent from View and View Model (Presentation layer)
- Kept the API and Model layer testable and extendable following single responsibility principle and dependency injection. 
- Given the scope focused mainly on architecture, rather than handling corner case scenarios and performance optimisation 
## How to Run:
Simply open Xcode and run the app in simulator. No signing is required
- The app will display Toronto weather information and relevant icon from given endpoint
- Loading button will reload the data (date displayed are random, since all the dates are old) 
## 3rd party Library/Code
- No 3rd party library has been used. Some snippets of code were inspired from iOS essential Dev tutorials. 

