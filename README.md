# tibber_live
This QuickApp gets your energy consumption and production data from Tibber Live. 
This QuickApp can be used in combination with the Tibber Monitor to get the Tibber Prices. 
Based on the Fibaro WebSockets/GraphQL demo by Peter Gebruers 
 
If you use Tibber for your Energy Panel, you can use this Tibber Live QuickApp for your energy consumption and production combined with the Tibber Monitor QuickApp to provide the Energy Panel with the hourly prices. 
 
image.thumb.png.56fe7d0592d4954d5fe3f40f4c7b0549.png
 
Main device with positive or negative actual power consumption
 
Child devices are available for:
- power (Actual consumption with maxPower in log text)
- powerProduction (Actual production with maxPowerProduction in log text)
- accumulatedConsumption (Todays consumption, also child device for the Energy Panel)
- accumulatedProduction (Todays production)
- accumulatedCost (Todays cost)
- lastMeterConsumption (Total consumption)
- lastMeterProduction (Total production)
- voltagePhase1
- voltagePhase2
- voltagePhase3
- currentL1
- currentL2
- currentL3
 
image.thumb.png.ae32b9cd06deb943ea439fb6b3686db7.png
 
Available information: 
- power (Consumption at the moment (Watt))
- maxPower (Peak consumption since midnight (Watt))
- powerProduction (Net production (A-) at the moment (Watt))
- maxPowerProduction (Max net production since midnight (Watt))
- accumulatedConsumption (kWh consumed since midnight)
- accumulatedProduction (net kWh produced since midnight)
- accumulatedCost (Accumulated cost since midnight; requires active Tibber power deal)
- currency (Currency of displayed cost; requires active Tibber power deal)
- lastMeterConsumption (Last meter active import register state (kWh))
- lastMeterProduction (Last meter active export register state (kWh))
- voltagePhase1 (Voltage on phase 1) *
- voltagePhase2 (Voltage on phase 2) *
- voltagePhase3 (Voltage on phase 3) *
- currentL1 (Current on L1) *
- currentL2 (Current on L2) *
- currentL3 (Current on L3) *
- accumulatedConsumptionLastHour (kWh consumed since since last hour shift)
- accumulatedProductionLastHour (net kWh produced since last hour shift)
- accumulatedReward (Accumulated reward since midnight; requires active Tibber power deal)
- minPower (Min consumption since midnight (Watt))
- averagePower (Average consumption since midnight (Watt))
- powerReactive (Reactive consumption (Q+) at the moment (kVAr)) *
- powerProductionReactive (Net reactive production (Q-) at the moment (kVAr)) *
- minPowerProduction (Min net production since midnight (Watt))
- powerFactor (Power factor (active power / apparent power)) *
- signalStrength (Device signal strength (Pulse - dB; Watty - percent)) *
- timestamp (Timestamp when usage occurred)
* on Kaifa and Aidon meters the value is not part of every HAN data frame therefore the value is null at timestamps with second value other than 0, 10, 20, 30, 40, 50. There can be other deviations based on concrete meter firmware. In this QuickApp "null" values are replaced by their previous values. 
 
To communicate with the API you need to acquire a OAuth access token and pass this along with every request passed to the server.
A Personal Access Token give you access to your data and your data only. 
This is ideal for DIY people that want to leverage the Tibber platform to extend the smartness of their home. 
Such a token can be acquired here: https://developer.tibber.com
 
When creating your access token or OAuth client you???ll be asked which scopes you want the access token to be associated with. 
These scopes tells the API which data and operations the client is allowed to perform on the user???s behalf. 
The scopes your app requires depend on the type of data it is trying to request. 
If you for example need access to user information you add the USER scope. 
If information about the user's homes is needed you add the appropriate HOME scopes.
If you have more than one home in your subscription, you need to fill in your home number the change between your homes. 

If the Tibber server disconnects the webSocket, the QuickApp wil do a re-connect for the amount in the QuickApp variable reconnect. 
If the re-connect fails for that amount, there will be a timeout for the seconds in the QuickApp variable timeout. 

Use this QuickApp at your own risk. You are responsible for ensuring that the information provided via this QuickApp do not contain errors. 
Tibber is a registered trademark being the property of TIBBER. TIBBER reserves all rights to the registered trademarks.
Information which is published on TIBBER???s websites belongs to TIBBER or is used with the permission of the rights holder. 
Making of copies, presentations, distribution, display or any other transfer of the information on the website to the public is, except for strictly private use, prohibited unless done with the consent of TIBBER. 
Published material on dedicated TIBBER press websites, intended for public use, is exempt from the consent requirement.
Also see: https://tibber.com/en/legal-notice

Guide Communicating with the Tibber API: https://developer.tibber.com/docs/guides/calling-api
Tibber API Explorer: https://developer.tibber.com/explorer
Fibaro webSocket manual: https://manuals.fibaro.com/knowledge-base-browse/hc3-quick-apps-websocket-client/
Fibaro Forum Headers in webSocket: https://forum.fibaro.com/topic/60307-added-support-for-headers-in-websocket-connections-any-documentation
WebSocket++ Documentation: https://docs.websocketpp.org
GraphQL query language: https://spec.graphql.org/June2018/#sec-Language
 
Version 1.0 (19th June 2022)
- Initial webSocket version Tibber Live
- Thanks @JcBorgs for testing all beta versions and great suggestion to improve the quickapp
- Based on the Fibaro WebSockets/GraphQL demo by Peter Gebruers 

Variables (mandatory and created automatically): 
- token = Authorization token (see the Tibber website: https://developer.tibber.com)
- homeId = Tibber Home ID (see the Tibber website: https://developer.tibber.com)
- reconnect = Amount of re-connects after disconnect from Tibber server (default = 10)
- timeout = Pause after maximum amount of re-connects (default = 300)
- debugLevel = Number (1=some, 2=few, 3=all, 4=Offline Simulation Mode, 5=Live Test Mode) (default = 1)
 
Fibaro Firmware:
- Minimal version 5.111.48 (beta)
