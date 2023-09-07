# KDVS Radio App
Listen to 24/7 Freeform Radio anywhere in the world

<p align="center">
    <img src="https://github.com/jkcarraher/KDVS-App/assets/16822729/d987e931-69c4-43ad-85a4-b62924f81ade.jpg" width=20% height=20%>
    <img src="https://github.com/jkcarraher/KDVS-App/assets/16822729/d7e850d8-9c66-4d35-87bd-a832fd57be61" width=20% height=20%>
    <img src="https://github.com/jkcarraher/KDVS-App/assets/16822729/28c52e1a-0410-41a6-acf9-d9b2959dacfe" width=20% height=20%>
    <img src="https://github.com/jkcarraher/KDVS-App/assets/16822729/90b175a7-0df4-4b54-96e8-5643716b4ac2" width=20% height=20%>
</p>

## How it works

Simpily start up the app and press play to tune into KDVS Davis 90.3 FM via internet webstream. you can press the calendar button to see the current season's schedule/show list, seach for shows and turn on show reminders. Clicking the info button on the player screen allows you to turn on reminders and identify songs live on air. 

## Under the Hood
the KDVS Radio App was built with:
- Swift & SwiftUI for front end app components. 
- Javascript, HTML & CSS to display live counter.
- AVPlayer to play live web-stream
- ShazamKit to identify songs on air
- SwiftSoup to scrape basic show information from the KDVS website.
- Core Data to store show information
- SocketIO to track live listeners to the stream 
- Node.js hosted on a glitch server to display the listener count.
