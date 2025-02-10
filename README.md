# Walkaro

Walkaro is a Flutter-based mobile application designed to help users track their daily steps, calories burned, time spent walking, and speed. The app features a motivational quote system to keep users inspired and a user-friendly interface with a curved navigation bar for easy access to settings and home screens.

## Installation
Clone the Repository
git clone https://github.com/yourusername/walkaro.git
cd walkaro

Install Dependencies:
flutter pub get

Run:
flutter run



Once the app is running, you can:Track your daily steps and view your progress on a radial gauge.Monitor calories burned, time spent walking, and speed.Get inspired by motivational quotes that change periodically.Use the reset button to clear your progress and start fresh.

Here's a snippet of the main functionality:

void _onStepCount(StepCount event) {

  setState(() {

    stepCount = event.steps.toDouble();

    calories = stepCount * 0.04;

    timeSpent = stepCount / 100;

    speed = (stepCount / timeSpent) * 0.06;

  });

}


## License

This project is licensed under the MIT License - see the  file for details

## Badges

Add badges from somewhere like: [shields.io](https://shields.io/)

[![MIT License](https://img.shields.io/badge/License-MIT-green.svg)](https://choosealicense.com/licenses/mit/)
[![GPLv3 License](https://img.shields.io/badge/License-GPL%20v3-yellow.svg)](https://opensource.org/licenses/)
[![AGPL License](https://img.shields.io/badge/license-AGPL-blue.svg)](http://www.gnu.org/licenses/agpl-3.0)

![Logo](https://dev-to-uploads.s3.amazonaws.com/uploads/articles/th5xamgrr6se0x5ro4g6.png)

## Documentation

https://github.com/yourusername/walkaro/wiki

## FAQ

####  How do I reset my step count and other metrics?

Simply press the "Reset" button on the main screen to clear all metrics.

#### What permissions does the app require?

The app requires permission to access activity recognition and body sensors to track steps accurately.

####Can I customize the motivational quotes?

Yes, you can modify the list of quotes in the HomeScreen widget's state.
