<!-- Improved compatibility of back to top link -->
<a name="readme-top"></a>
<!--
*** Thanks for checking out the Best-README-Template. If you have a suggestion
*** that would make this better, please fork the repo and create a pull request
*** or simply open an issue with the tag "enhancement".
*** Don't forget to give the project a star!
*** Thanks again! Now go create something AMAZING! :D
-->



<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->
[![LinkedIn][linkedin-shield]][linkedin-url]
[![MIT License][license-shield]][license-url]




<!-- PROJECT LOGO -->
<br />

  <p align="center">
    <img src="https://raw.githubusercontent.com/GeekAthonNeuralNinjas/Atlas/ad18f48728c81dee1986d64a210f9b5d405e01b7/Atlas/Assets.xcassets/logo-geekathon.imageset/logo-geekathon.svg" alt="Logo" width="160" height="80">

  </p>
<div align="center">
  <a href="https://github.com/JoaoFranco03/Foco">
    <img src="https://github.com/GeekAthonNeuralNinjas/Atlas/blob/main/Atlas/Assets.xcassets/app_icon.imageset/app_icon.png?raw=true" alt="Logo" width="80" height="80">
  </a>

  <h3 align="center">Atlas<h3>
    <br />
    <br />

</div>



<!-- ABOUT THE PROJECT -->
# About The Project

[![Product Name Screen Shot][product-screenshot]](https://github.com/JoaoFranco03/Foco)
This project is an innovative tour planning system, comprising an interactive iOS app and a Flask API, leveraging the power of Gemini and API's such as the Google Places API and the OpenWeatherMap API.

# Problem Addressed

Planning vacations or activities in an unfamiliar city can be a daunting and time-consuming task. From choosing the right places to visit to organizing them into a coherent schedule, travelers often face challenges that reduce the joy of exploring new destinations.

# Our Solution
Our solution aims to simplify and enhance the travel planning experience. With our Atlas app, users can:

1. **Specify Their Preferences**: Set the city they want to visit, the number of days available, and other travel preferences through an intuitive app interface.
2. **Automated Itinerary Generation**: The Flask API, powered by Gemini capabilities, processes the user’s inputs to create a personalized and optimized activity plan, based on API Data and User Needs for his context, giving it a sense of grounding, reducing hallucinations and inacurrate data.
3. **Detailed Guided Tours**: Once a tour is generated, users can view their itinerary with detailed activity descriptions, organized by dates, and explore the city using an interactive guided map.
4. **Explore Landmarks in 3D**: Dive deeper into your destination with 3D models of iconic landmarks, offering an immersive way to preview and explore famous attractions before even arriving.


This seamless integration between the iOS app and the backend API ensures a user-friendly experience while delivering intelligent and practical solutions for travel planning.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## How to Test

To get the Atlas project up and running on your local environment, follow these steps:

1. **Open the Xcode Project**:
   - Download the repository and open the Xcode solution file (`.xcworkspace` or `.xcodeproj`) using Xcode.

2. **Configure Signing**:
   - In Xcode, go to the project navigator and select your target (usually named after the app).
   - Open the **Signing & Capabilities** tab.
   - Under **Signing**, change the **Bundle Identifier** to a unique one (e.g., `com.yourname.AtlasApp`).
   - Select your Apple Developer Team if you have one, or configure Xcode to use automatic signing.

3. **Build & Run**:
   - Connect your iPhone or choose a simulator from Xcode's toolbar.
   - For best results, use a modern iPhone simulator like iPhone 15 or iPhone 16.
   - Press the **Run** button (or `Cmd + R`) to build and run the app.
   - If prompted, trust the app on your iPhone under **Settings > General > Device Management**.

By following these instructions, you should be able to explore and test the functionality of Atlas, including itinerary creation, map navigation, and more.

<p align="right">(<a href="#readme-top">back to top</a>)</p>



## Built With

* [![Swift][Swift.org]][Swift-url]
* [![Xcode][xcode-shield]][xcode-url]
* [![Flask][flask-shield]][flask-url]
* [![Python][python-shield]][python-url]
* [![iOS][ios-shield]][ios-url]
* [![Google Places API][googleplaces-shield]][googleplaces-url]
* [![OpenWeatherMap API][openweathermap-shield]][openweathermap-url]
* [![Gemini][gemini-shield]][gemini-url]

<p align="right">(<a href="#readme-top">back to top</a>)</p>


<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/othneildrew/Best-README-Template.svg?style=for-the-badge
[contributors-url]: https://github.com/othneildrew/Best-README-Template/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/othneildrew/Best-README-Template.svg?style=for-the-badge
[forks-url]: https://github.com/othneildrew/Best-README-Template/network/members
[stars-shield]: https://img.shields.io/github/stars/othneildrew/Best-README-Template.svg?style=for-the-badge
[stars-url]: https://github.com/othneildrew/Best-README-Template/stargazers
[issues-shield]: https://img.shields.io/github/issues/othneildrew/Best-README-Template.svg?style=for-the-badge
[issues-url]: https://github.com/othneildrew/Best-README-Template/issues
[xcode-shield]: https://img.shields.io/badge/Xcode-007ACC?style=for-the-badge&logo=Xcode&logoColor=white
[xcode-url]: https://developer.apple.com/xcode/
[license-shield]: https://img.shields.io/github/license/JoaoFranco03/Foco.svg?style=for-the-badge
[license-url]: https://github.com/JoaoFranco03/Foco/blob/main/LICENSE
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[linkedin-url]: https://www.linkedin.com/in/joão-franco-452161195/
[product-screenshot]: assets/Mockup.png
[Swift.org]: https://img.shields.io/badge/Swift-FA7343?style=for-the-badge&logo=swift&logoColor=white
[Swift-url]: https://www.swift.org
<!-- MARKDOWN LINKS & IMAGES -->
[flask-shield]: https://img.shields.io/badge/Flask-000000?style=for-the-badge&logo=flask&logoColor=white
[flask-url]: https://flask.palletsprojects.com/
[ios-shield]: https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=apple&logoColor=white
[ios-url]: https://developer.apple.com/ios/
[googleplaces-shield]: https://img.shields.io/badge/Google%20Places%20API-4285F4?style=for-the-badge&logo=google&logoColor=white
[googleplaces-url]: https://developers.google.com/maps/documentation/places
[openweathermap-shield]: https://img.shields.io/badge/OpenWeatherMap-FF5733?style=for-the-badge&logo=openweathermap&logoColor=white
[openweathermap-url]: https://openweathermap.org/api
[gemini-shield]: https://img.shields.io/badge/Gemini-FF9900?style=for-the-badge&logo=gemini&logoColor=white
[gemini-url]: https://aws.amazon.com/bedrock/
[python-shield]: https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white
[python-url]: https://www.python.org/
