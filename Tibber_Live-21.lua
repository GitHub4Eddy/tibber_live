-- QUICKAPP TIBBER LIVE

-- This QuickApp gets your energy consumption and production data from Tibber Live. 
-- This QuickApp can be used in combination with the Tibber Monitor to get the Tibber Prices. 
-- Based on the Fibaro WebSockets/GraphQL demo by Peter Gebruers 

-- If you use Tibber for your Energy Panel, you can use this Tibber Live QuickApp for your energy consumption and production combined with the Tibber Monitor QuickApp to provide the Energy Panel with the hourly prices. 


-- Available information: 
-- power (Consumption at the moment (Watt))
-- maxPower (Peak consumption since midnight (Watt))
-- powerProduction (Net production (A-) at the moment (Watt))
-- maxPowerProduction (Max net production since midnight (Watt))
-- accumulatedConsumption (kWh consumed since midnight)
-- accumulatedProduction (net kWh produced since midnight)
-- accumulatedCost (Accumulated cost since midnight; requires active Tibber power deal)
-- currency (Currency of displayed cost; requires active Tibber power deal)
-- lastMeterConsumption (Last meter active import register state (kWh))
-- lastMeterProduction (Last meter active export register state (kWh))
-- voltagePhase1 (Voltage on phase 1) *
-- voltagePhase2 (Voltage on phase 2) *
-- voltagePhase3 (Voltage on phase 3) *
-- currentL1 (Current on L1) *
-- currentL2 (Current on L2) *
-- currentL3 (Current on L3) *
-- accumulatedConsumptionLastHour (kWh consumed since since last hour shift)
-- accumulatedProductionLastHour (net kWh produced since last hour shift)
-- accumulatedReward (Accumulated reward since midnight; requires active Tibber power deal)
-- minPower (Min consumption since midnight (Watt))
-- averagePower (Average consumption since midnight (Watt))
-- powerReactive (Reactive consumption (Q+) at the moment (kVAr)) *
-- powerProductionReactive (Net reactive production (Q-) at the moment (kVAr)) *
-- minPowerProduction (Min net production since midnight (Watt))
-- maxPowerProduction (Max net production since midnight (Watt))
-- powerFactor (Power factor (active power / apparent power)) *
-- signalStrength (Device signal strength (Pulse - dB; Watty - percent)) *
-- timestamp (Timestamp when usage occurred)

-- * on Kaifa and Aidon meters the value is not part of every HAN data frame therefore the value is "null" at timestamps with second value other than 0, 10, 20, 30, 40, 50. There can be other deviations based on concrete meter firmware.) In this QuickApp "null" values are replaced by their previous values. 


-- Main device with positive or negative actual power consumption (with timestamp in the log text)

-- Child devices are available for:
-- power (Actual consumption with maxPower in log text)
-- powerProduction (Actual production with maxPowerProduction in log text)
-- accumulatedConsumption (Todays consumption, also the child device for the Energy Panel)
-- accumulatedProduction (Todays production)
-- accumulatedCost (Todays cost)
-- accumulatedConsumptionLastHour (Consumed since since last hour shift)
-- accumulatedProductionLastHour (Produced since last hour shift)
-- lastMeterConsumption (Total consumption)
-- lastMeterProduction (Total production)
-- voltagePhase1
-- voltagePhase2
-- voltagePhase3
-- currentL1
-- currentL2
-- currentL3


-- To communicate with the API you need to acquire a OAuth access token and pass this along with every request passed to the server.
-- A Personal Access Token give you access to your data and your data only. 
-- This is ideal for DIY people that want to leverage the Tibber platform to extend the smartness of their home. 
-- Such a token can be acquired here: https://developer.tibber.com

-- When creating your access token or OAuth client you’ll be asked which scopes you want the access token to be associated with. 
-- These scopes tells the API which data and operations the client is allowed to perform on the user’s behalf. 
-- The scopes your app requires depend on the type of data it is trying to request. 
-- If you for example need access to user information you add the USER scope. 
-- If information about the user's homes is needed you add the appropriate HOME scopes.
-- If you have more than one home in your subscription, you need to fill in your home number the change between your homes. 

-- If the Tibber server disconnects the webSocket, the QuickApp wil do a re-connect for the amount in the QuickApp variable reconnect. 
-- If the re-connect fails for that amount, there will be a timeout for the seconds in the QuickApp variable timeout. 

-- Use this QuickApp at your own risk. You are responsible for ensuring that the information provided via this QuickApp do not contain errors. 
-- Tibber is a registered trademark being the property of TIBBER. TIBBER reserves all rights to the registered trademarks.
-- Information which is published on TIBBER’s websites belongs to TIBBER or is used with the permission of the rights holder. 
-- Making of copies, presentations, distribution, display or any other transfer of the information on the website to the public is, except for strictly private use, prohibited unless done with the consent of TIBBER. 
-- Published material on dedicated TIBBER press websites, intended for public use, is exempt from the consent requirement.
-- Also see: https://tibber.com/en/legal-notice

-- Guide Communicating with the Tibber API: https://developer.tibber.com/docs/guides/calling-api
-- Tibber API Explorer: https://developer.tibber.com/explorer
-- Fibaro webSocket manual: https://manuals.fibaro.com/knowledge-base-browse/hc3-quick-apps-websocket-client/
-- Fibaro Forum Headers in webSocket: https://forum.fibaro.com/topic/60307-added-support-for-headers-in-websocket-connections-any-documentation
-- WebSocket++ Documentation: https://docs.websocketpp.org
-- GraphQL query language: https://spec.graphql.org/June2018/#sec-Language


-- TODO (maybe): 
-- Wrap json.decode in pcall (?)
-- Change global variables to local variables (?)
-- Add the “Extra Cost” from the Tibber Monitor QA to the “Todays Cost” in Tibber Live
-- Add extra timeout in reconnect routine (2x)
-- Show connection status in labels


-- Version 2.1 15th October 2022
-- Child devices are now updated every (whole) minute to reduce CPU load
-- Replaced zero values for Voltage L1 L2 L3 with the previous value


-- Version 2.0 (5th August 2022)
-- Added two child devices, Hourly Consumption and Hourly Production
-- Added re-connect routine to handleError. If an Tibber error occurs, the QuickApp will try to re-connect. Thanks @JcBorgs for testing. 
-- Improved routine to handle Tibber null value. Thanks @Darquan for testing. 
-- Changed labels a bit to save some space
-- Changed "volt" and "amp" text in the labels
-- Changed kWh device types from com.fibaro.electricMeter to com.fibaro.energyMeter

-- Version 1.0 (19th June 2022)
-- Initial webSocket version Tibber Live
-- Thanks @JcBorgs for testing all beta versions and great suggestion to improve the quickapp
-- Based on the Fibaro WebSockets/GraphQL demo by Peter Gebruers 

-- Variables (mandatory and created automatically): 
-- token = Authorization token (see the Tibber website: https://developer.tibber.com)
-- homeId = Tibber Home ID (see the Tibber website: https://developer.tibber.com)
-- reconnect = Amount of re-connects after disconnect from Tibber server (default = 10)
-- timeout = Pause after maximum amount of re-connects (default = 300 seconds)
-- debugLevel = Number (1=some, 2=few, 3=all, 4=Offline Simulation Mode, 5=Live Test Mode) (default = 1)

-- Fibaro Firmware minimal version 5.111.48 (beta)

-- No editing of this code is needed 


-- Child Devices

class 'power'(QuickAppChild)
function power:__init(dev)
  QuickAppChild.__init(self,dev)
end
function power:updateValue(data) 
  self:updateProperty("value", tonumber(string.format("%.3f",data.payload.data.liveMeasurement.power)))
  self:updateProperty("power", tonumber(string.format("%.3f",data.payload.data.liveMeasurement.power)))
  self:updateProperty("unit", "Watt")
  self:updateProperty("log", "Max " ..data.payload.data.liveMeasurement.maxPower .." Watt")
end

class 'powerProduction'(QuickAppChild)
function powerProduction:__init(dev)
  QuickAppChild.__init(self,dev)
end
function powerProduction:updateValue(data) 
  self:updateProperty("value", tonumber(string.format("%.3f",data.payload.data.liveMeasurement.powerProduction)))
  self:updateProperty("power", tonumber(string.format("%.3f",data.payload.data.liveMeasurement.powerProduction)))
  self:updateProperty("unit", "Watt")
  self:updateProperty("log", "Max " ..data.payload.data.liveMeasurement.maxPowerProduction .." Watt")
end

class 'accumulatedConsumption'(QuickAppChild)
function accumulatedConsumption:__init(dev)
  QuickAppChild.__init(self,dev)
  if fibaro.getValue(self.id, "rateType") ~= "consumption" then 
    self:updateProperty("rateType", "consumption")
    self:warning("Changed rateType interface of Todays Consumption child device (" ..self.id ..") to consumption")
  end
end
function accumulatedConsumption:updateValue(data) 
  self:updateProperty("value", tonumber(string.format("%.3f",data.payload.data.liveMeasurement.accumulatedConsumption)))
  self:updateProperty("unit", "kWh")
  self:updateProperty("log", "")
end

class 'accumulatedProduction'(QuickAppChild)
function accumulatedProduction:__init(dev)
  QuickAppChild.__init(self,dev)
  if fibaro.getValue(self.id, "rateType") ~= "production" then 
    self:updateProperty("rateType", "production")
    self:warning("Changed rateType interface of Todays Production child device (" ..self.id ..") to production")
  end
end
function accumulatedProduction:updateValue(data) 
  self:updateProperty("value", tonumber(string.format("%.3f",data.payload.data.liveMeasurement.accumulatedProduction)))
  self:updateProperty("unit", "kWh")
  self:updateProperty("log", "")
end

class 'accumulatedCost'(QuickAppChild)
function accumulatedCost:__init(dev)
  QuickAppChild.__init(self,dev)
end
function accumulatedCost:updateValue(data) 
  self:updateProperty("value", tonumber(string.format("%.3f",data.payload.data.liveMeasurement.accumulatedCost)))
  self:updateProperty("unit", data.payload.data.liveMeasurement.currency)
  self:updateProperty("log", " ")
end

class 'accumulatedConsumptionLastHour'(QuickAppChild)
function accumulatedConsumptionLastHour:__init(dev)
  QuickAppChild.__init(self,dev)
  if fibaro.getValue(self.id, "rateType") ~= "consumption" then 
    self:updateProperty("rateType", "consumption")
    self:warning("Changed rateType interface of Last Hour Consumption child device (" ..self.id ..") to consumption")
  end
end
function accumulatedConsumptionLastHour:updateValue(data) 
  self:updateProperty("value", tonumber(string.format("%.3f",data.payload.data.liveMeasurement.accumulatedConsumptionLastHour)))
  self:updateProperty("unit", "kWh")
  self:updateProperty("log", "")
end

class 'accumulatedProductionLastHour'(QuickAppChild)
function accumulatedProductionLastHour:__init(dev)
  QuickAppChild.__init(self,dev)
  if fibaro.getValue(self.id, "rateType") ~= "production" then 
    self:updateProperty("rateType", "production")
    self:warning("Changed rateType interface of Last Hour Production child device (" ..self.id ..") to production")
  end
end
function accumulatedProductionLastHour:updateValue(data) 
  self:updateProperty("value", tonumber(string.format("%.3f",data.payload.data.liveMeasurement.accumulatedProductionLastHour)))
  self:updateProperty("unit", "kWh")
  self:updateProperty("log", "")
end

class 'lastMeterConsumption'(QuickAppChild)
function lastMeterConsumption:__init(dev)
  QuickAppChild.__init(self,dev)
  if fibaro.getValue(self.id, "rateType") ~= "consumption" then 
    self:updateProperty("rateType", "consumption")
    self:warning("Changed rateType interface of Total Consumption child device (" ..self.id ..") to consumption")
  end
end
function lastMeterConsumption:updateValue(data) 
  self:updateProperty("value", tonumber(string.format("%.3f",data.payload.data.liveMeasurement.lastMeterConsumption)))
  self:updateProperty("unit", "kWh")
  self:updateProperty("log", " ")
end

class 'lastMeterProduction'(QuickAppChild)
function lastMeterProduction:__init(dev)
  QuickAppChild.__init(self,dev)
  if fibaro.getValue(self.id, "rateType") ~= "production" then 
    self:updateProperty("rateType", "production")
    self:warning("Changed rateType interface of Total Production child device (" ..self.id ..") to production")
  end
end
function lastMeterProduction:updateValue(data) 
  self:updateProperty("value", tonumber(string.format("%.3f",data.payload.data.liveMeasurement.lastMeterProduction)))
  self:updateProperty("unit", "kWh")
  self:updateProperty("log", "")
end

class 'voltagePhase1'(QuickAppChild)
function voltagePhase1:__init(dev)
  QuickAppChild.__init(self,dev)
end
function voltagePhase1:updateValue(data) 
  prevdata.voltagePhase1 = tonumber(self.properties.value) -- Save the latest value to replace null values
  self:updateProperty("value", tonumber(string.format("%.1f",data.payload.data.liveMeasurement.voltagePhase1)))
  self:updateProperty("unit", "Volt")
  self:updateProperty("log", " ")
end

class 'voltagePhase2'(QuickAppChild)
function voltagePhase2:__init(dev)
  QuickAppChild.__init(self,dev)
end
function voltagePhase2:updateValue(data) 
  prevdata.voltagePhase2 = tonumber(self.properties.value) -- Save the latest value to replace null values
  self:updateProperty("value", tonumber(string.format("%.1f",data.payload.data.liveMeasurement.voltagePhase2)))
  self:updateProperty("unit", "Volt")
  self:updateProperty("log", " ")
end

class 'voltagePhase3'(QuickAppChild)
function voltagePhase3:__init(dev)
  QuickAppChild.__init(self,dev)
end
function voltagePhase3:updateValue(data) 
  prevdata.voltagePhase3 = tonumber(self.properties.value) -- Save the latest value to replace null values
  self:updateProperty("value", tonumber(string.format("%.1f",data.payload.data.liveMeasurement.voltagePhase3)))
  self:updateProperty("unit", "Volt")
  self:updateProperty("log", " ")
end

class 'currentL1'(QuickAppChild)
function currentL1:__init(dev)
  QuickAppChild.__init(self,dev)
end
function currentL1:updateValue(data) 
  prevdata.currentL1 = tonumber(self.properties.value) -- Save the latest value to replace null values
  self:updateProperty("value", tonumber(string.format("%.1f",data.payload.data.liveMeasurement.currentL1)))
  self:updateProperty("unit", "Amp")
  self:updateProperty("log", "")
end

class 'currentL2'(QuickAppChild)
function currentL2:__init(dev)
  QuickAppChild.__init(self,dev)
end
function currentL2:updateValue(data) 
  prevdata.currentL2 = tonumber(self.properties.value) -- Save the latest value to replace null values
  self:updateProperty("value", tonumber(string.format("%.1f",data.payload.data.liveMeasurement.currentL2)))
  self:updateProperty("unit", "Amp")
  self:updateProperty("log", "")
end

class 'currentL3'(QuickAppChild)
function currentL3:__init(dev)
  QuickAppChild.__init(self,dev)
end
function currentL3:updateValue(data) 
  prevdata.currentL2 = tonumber(self.properties.value) -- Save the latest value to replace null values
  self:updateProperty("value", tonumber(string.format("%.1f",data.payload.data.liveMeasurement.currentL3)))
  self:updateProperty("unit", "Amp")
  self:updateProperty("log", "")
end


local function getChildVariable(child,varName)
  for _,v in ipairs(child.properties.quickAppVariables or {}) do
    if v.name==varName then return v.value end
  end
  return ""
end


-- QuickApp functions


function QuickApp:updateChildDevices() -- Update Child Devices
  for id,child in pairs(self.childDevices) do 
    child:updateValue(data) 
  end
end


function QuickApp:logging(level,text) -- Logging function for debug
  if tonumber(debugLevel) >= tonumber(level) then 
      self:debug(text)
  end
end


function QuickApp:buttonEvent() -- Button event
  self:logging(3, "QuickApp:buttonEvent")
    self:updateButtonLabel("Please wait...")
  --self:...() -- Do something
  fibaro.setTimeout(2000, function()
    self:updateButtonLabel("Refresh")
  end)
end


function QuickApp:updateButtonLabel(text) -- Update the label of the button 
  self:logging(3,"updateButtonLabel")
  self:updateView("button", "text", text)
end


function QuickApp:updateProperties() -- Update the properties
  self:logging(3,"updateProperties")
  self:updateProperty("value", tonumber(string.format("%.3f",data.payload.data.liveMeasurement.power-data.payload.data.liveMeasurement.powerProduction)))
  self:updateProperty("unit", "Watt")
  self:updateProperty("log", data.payload.data.liveMeasurement.timestamp)
end


function QuickApp:updateLabels() -- Update the labels
  self:logging(3,"updateLabels")

  local labelText = ""
  if debugLevel == 4 then
    labelText = labelText .."SIMULATION MODE" .."\n\n"
  end

  labelText = labelText .."Consumption: " ..string.format("%.0f",data.payload.data.liveMeasurement.power) .." Watt" .."\n"
  labelText = labelText .."Production: " ..string.format("%.0f",data.payload.data.liveMeasurement.powerProduction) .." Watt" .."\n\n"
  
  labelText = labelText .."Hourly Consumption: " ..string.format("%.1f",data.payload.data.liveMeasurement.accumulatedConsumptionLastHour) .." kWh" .."\n"
  labelText = labelText .."Hourly Production: " ..string.format("%.1f",data.payload.data.liveMeasurement.accumulatedProductionLastHour) .." kWh" .."\n\n"

  labelText = labelText .."Todays Consumption:" ..string.format("%.1f",data.payload.data.liveMeasurement.accumulatedConsumption) .." kWh" .."\n"
  labelText = labelText .."Min: " ..string.format("%.1f",data.payload.data.liveMeasurement.minPower) .." Max: " ..string.format("%.1f",data.payload.data.liveMeasurement.maxPower) .." Av: " ..string.format("%.1f",data.payload.data.liveMeasurement.averagePower) .." Watt" .."\n\n"
  
  labelText = labelText .."Todays Production: " ..string.format("%.1f",data.payload.data.liveMeasurement.accumulatedProduction) .." kWh" .."\n"
  labelText = labelText .."Min: " ..string.format("%.1f",data.payload.data.liveMeasurement.minPowerProduction) .." Max: " ..string.format("%.1f",data.payload.data.liveMeasurement.maxPowerProduction).." Watt" .."\n\n"
  
  labelText = labelText .."Todays Cost: " ..string.format("%.2f",data.payload.data.liveMeasurement.accumulatedCost) .." " ..data.payload.data.liveMeasurement.currency .."\n" 
  labelText = labelText .."Reward: " ..string.format("%.2f",tonumber(data.payload.data.liveMeasurement.accumulatedReward)) .." " ..data.payload.data.liveMeasurement.currency .."\n\n" 

  labelText = labelText .."Totals:" .."\n" 
  labelText = labelText .."Consumption: " ..string.format("%.1f",data.payload.data.liveMeasurement.lastMeterConsumption) .." kWh" .."\n" 
  labelText = labelText .."Production: " ..string.format("%.1f",data.payload.data.liveMeasurement.lastMeterProduction) .." kWh" .."\n\n" 
  
  labelText = labelText .."Voltage:" .."\n"
  labelText = labelText .."L1: " ..string.format("%.0f",data.payload.data.liveMeasurement.voltagePhase1) .." - L2: " ..string.format("%.0f",data.payload.data.liveMeasurement.voltagePhase2) .." - L3: " ..string.format("%.0f",data.payload.data.liveMeasurement.voltagePhase3) .." Volt " .."\n\n"
  
  labelText = labelText .."Ampere:" .."\n"
  labelText = labelText .."L1: " ..string.format("%.2f",data.payload.data.liveMeasurement.currentL1) .." - L2: " ..string.format("%.2f",data.payload.data.liveMeasurement.currentL2) .." - L3: " ..string.format("%.2f",data.payload.data.liveMeasurement.currentL3) .." Amp " .."\n\n"
  
  labelText = labelText .."Reactive Consumption: " ..string.format("%.1f",data.payload.data.liveMeasurement.powerReactive) .." kVAr" .."\n"
  labelText = labelText .."Reactive Production: " ..string.format("%.1f",data.payload.data.liveMeasurement.powerProductionReactive) .." kVAr" .."\n"
  labelText = labelText .."Power Factor: " ..string.format("%.3f",data.payload.data.liveMeasurement.powerFactor) .." " .."\n"
  labelText = labelText .."Signal strength: " ..string.format("%.0f",data.payload.data.liveMeasurement.signalStrength) 
  if tonumber(data.payload.data.liveMeasurement.signalStrength) >= 0 then
    labelText = labelText .."%" .."\n"
  else
    labelText = labelText .." dB" .."\n"
  end
  labelText = labelText .."Timestamp: " ..data.payload.data.liveMeasurement.timestamp .."\n"

  self:updateView("label", "text", labelText)
  self:logging(2,"Label: " ..labelText)
end


function QuickApp:getValues() -- Get the values from json file 
  self:logging(3,"getValues")
  local pattern = "(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+).(%d+)+(%d+):(%d+)" --2021-12-23T17:00:00.000+01:00
  local runyear, runmonth, runday, runhour, runminute, runseconds = data.payload.data.liveMeasurement.timestamp:match(pattern)
  local convertedTimestamp = os.time({year = runyear, month = runmonth, day = runday, hour = runhour, min = runminute, sec = runseconds})
  data.payload.data.liveMeasurement.timestamp = os.date("%d-%m-%Y %H:%M:%S", convertedTimestamp)
  
  self:logging(2,"data: " ..json.encode(data))
  data = json.encode(data):gsub("null", '"null"') -- Clean up the response by replacing null with "null"
  data = json.decode(data) 

  -- Check for null values and replace them with previous values
  if data.payload.data.liveMeasurement.voltagePhase1 == "null" or data.payload.data.liveMeasurement.voltagePhase1 == nil or data.payload.data.liveMeasurement.voltagePhase1 == 0 then -- Also replace zeor values for Voltage
    self:logging(3,"Replaced voltagePhase1 " ..data.payload.data.liveMeasurement.voltagePhase1 .." with: " ..prevdata.voltagePhase1)
    data.payload.data.liveMeasurement.voltagePhase1 = tonumber(prevdata.voltagePhase1)
  else
    prevdata.voltagePhase1 = data.payload.data.liveMeasurement.voltagePhase1 
  end
  if data.payload.data.liveMeasurement.voltagePhase2 == "null" or data.payload.data.liveMeasurement.voltagePhase2 == nil or data.payload.data.liveMeasurement.voltagePhase2 == 0 then -- Also replace zeor values for Voltage
    self:logging(3,"Replaced voltagePhase2 " ..data.payload.data.liveMeasurement.voltagePhase2 .." with: " ..prevdata.voltagePhase2)
    data.payload.data.liveMeasurement.voltagePhase2 = tonumber(prevdata.voltagePhase2)
  else
    prevdata.voltagePhase2 = data.payload.data.liveMeasurement.voltagePhase2
  end
  if data.payload.data.liveMeasurement.voltagePhase3 == "null" or data.payload.data.liveMeasurement.voltagePhase3 == nil or data.payload.data.liveMeasurement.voltagePhase3 == 0 then -- Also replace zeor values for Voltage
    self:logging(3,"Replaced voltagePhase3 " ..data.payload.data.liveMeasurement.voltagePhase3 .." with: " ..prevdata.voltagePhase3)
    data.payload.data.liveMeasurement.voltagePhase3 = tonumber(prevdata.voltagePhase3)
  else
    prevdata.voltagePhase3 = data.payload.data.liveMeasurement.voltagePhase3
  end
  
  if data.payload.data.liveMeasurement.currentL1 == "null" or data.payload.data.liveMeasurement.currentL1 == nil then
    self:logging(3,"Replaced currentL1 " ..data.payload.data.liveMeasurement.currentL1 .." with: " ..prevdata.currentL1)
    data.payload.data.liveMeasurement.currentL1 = tonumber(prevdata.currentL1)
  else
    prevdata.currentL1 = data.payload.data.liveMeasurement.currentL1
  end
  if data.payload.data.liveMeasurement.currentL2 == "null" or data.payload.data.liveMeasurement.currentL2 == nil then
    self:logging(3,"Replaced currentL2 " ..data.payload.data.liveMeasurement.currentL2 .." with: " ..prevdata.currentL2)
    data.payload.data.liveMeasurement.currentL2 = tonumber(prevdata.currentL2)
  else
    prevdata.currentL2 = data.payload.data.liveMeasurement.currentL2
  end
  if data.payload.data.liveMeasurement.currentL3 == "null" or data.payload.data.liveMeasurement.currentL3 == nil then
    self:logging(3,"Replaced currentL3 " ..data.payload.data.liveMeasurement.currentL3 .." with: " ..prevdata.currentL3)
    data.payload.data.liveMeasurement.currentL3 = tonumber(prevdata.currentL3)
  else
    prevdata.currentL3 = data.payload.data.liveMeasurement.currentL3
  end
  
  if data.payload.data.liveMeasurement.powerFactor == "null" or data.payload.data.liveMeasurement.powerFactor == nil then
    self:logging(3,"Replaced powerFactor " ..data.payload.data.liveMeasurement.powerFactor .." with: " ..prevdata.powerFactor)
    data.payload.data.liveMeasurement.powerFactor = tonumber(prevdata.powerFactor)
  else
    prevdata.powerFactor = data.payload.data.liveMeasurement.powerFactor 
  end
  if data.payload.data.liveMeasurement.powerReactive == "null" or data.payload.data.liveMeasurement.powerReactive == nil then
    self:logging(3,"Replaced powerReactive " ..data.payload.data.liveMeasurement.powerReactive .." with: " ..prevdata.powerReactive)
    data.payload.data.liveMeasurement.powerReactive = tonumber(prevdata.powerReactive)
  else
    prevdata.powerReactive = data.payload.data.liveMeasurement.powerReactive
  end
  if data.payload.data.liveMeasurement.powerProductionReactive == "null" or data.payload.data.liveMeasurement.powerProductionReactive == nil then
    self:logging(3,"Replaced powerProductionReactive " ..data.payload.data.liveMeasurement.powerProductionReactive .." with: " ..prevdata.powerProductionReactive)
    data.payload.data.liveMeasurement.powerProductionReactive = tonumber(prevdata.powerProductionReactive)
  else
    prevdata.powerProductionReactive = data.payload.data.liveMeasurement.powerProductionReactive
  end
  if data.payload.data.liveMeasurement.signalStrength == "null" or data.payload.data.liveMeasurement.signalStrength == nil then
    self:logging(3,"Replaced signalStrength " ..data.payload.data.liveMeasurement.signalStrength .." with: " ..prevdata.signalStrength)
    data.payload.data.liveMeasurement.signalStrength = tonumber(prevdata.signalStrength)
  else
    prevdata.signalStrength = data.payload.data.liveMeasurement.signalStrength
  end
  
  if data.payload.data.liveMeasurement.accumulatedReward == "null" or data.payload.data.liveMeasurement.accumulatedReward == nil then
    self:logging(3,"Replaced accumulatedReward " ..data.payload.data.liveMeasurement.accumulatedReward .." with: " ..prevdata.accumulatedReward)
    data.payload.data.liveMeasurement.accumulatedReward = tonumber(prevdata.accumulatedReward)
  else
    prevdata.accumulatedReward = data.payload.data.liveMeasurement.accumulatedReward
  end
  if data.payload.data.liveMeasurement.accumulatedCost == "null" or data.payload.data.liveMeasurement.accumulatedCost == nil then
    self:logging(3,"Replaced accumulatedCost " ..data.payload.data.liveMeasurement.accumulatedCost .." with: " ..prevdata.accumulatedCost)
    data.payload.data.liveMeasurement.accumulatedCost = tonumber(prevdata.accumulatedCost)
  else
    prevdata.accumulatedCost = data.payload.data.liveMeasurement.accumulatedCost
  end
  if data.payload.data.liveMeasurement.currency == "null" or data.payload.data.liveMeasurement.currency == nil then
    self:logging(3,"Replaced currency " ..data.payload.data.liveMeasurement.currency .." with: " ..prevdata.currency)
    data.payload.data.liveMeasurement.currency = prevdata.currency
  else
    prevdata.currency = data.payload.data.liveMeasurement.currency
  end
  data = json.encode(data):gsub("null", 0) -- Clean up the response by replacing null with 0
  data = json.decode(data) 

  self:logging(2,"data (without null): " ..json.encode(data))
end


function QuickApp:handleError(error) -- The event is emitted when an error occures
  self:logging(3,"handleError")
  self:error("WebSocket error: ", error)
  if reconnect > 0 then -- re-connect n times
    self:logging(3,"Trying to reconnect ... (" ..tonumber(reconnect) ..")")
    self:getData()
    reconnect = reconnect - 1 
  else -- Never disconnect, retry to re-connect after n seconds
    reconnect = tonumber(self:getVariable("reconnect"))
    self:logging(3,"SetTimeout for re-connect at " ..timeout .." seconds")
    fibaro.setTimeout(timeout*1000, function() 
      self:getData()
    end)
  end
end


function QuickApp:handleDisconnected() -- The event is emitted when either the client or the server closes the socket
  self:logging(3,"handleDisconnected")
  if reconnect > 0 then -- re-connect n times
    self:logging(3,"Trying to reconnect ... (" ..tonumber(reconnect) ..")")
    self:getData()
    reconnect = reconnect - 1 
  else -- Never disconnect, retry to re-connect after n seconds
    reconnect = tonumber(self:getVariable("reconnect"))
    self:logging(3,"SetTimeout for re-connect at " ..timeout .." seconds")
    fibaro.setTimeout(timeout*1000, function() 
      self:getData()
    end)
  end
end


function QuickApp:handleDataReceived(resp) -- The event is emitted when any data is received by the socket
  self:logging(3,"handleDataReceived")
  data = json.decode(resp) -- TODO: json decode should be wrapped in pcall and error handled?

  if data.type == "connection_ack" then -- The initial connection is there, please send the query body
    self:logging(3,"Got connection_ack, making and sending query")
    self:logging(3,"graphql_query_body: " ..graphql_query_body)
    self.sock:send(graphql_query_body)
  elseif data.type == "data" then -- Tibber Live responded with data, let's see what it is
    reconnect = tonumber(self:getVariable("reconnect")) -- Reset reconnect to is initial value
    self:getValues()
    self:updateLabels()
    self:updateProperties()
    
    if os.date("%S") == "00" then -- To reduce CPU load only update Child Devices every whole minute
      self:logging(3,"updateChildDevices")
      self:updateChildDevices() 
    end
    
  else -- Something else is going on 
    self:logging(2,"Data not handled in handleDataReceived: "..data.type)
  end
end


function QuickApp:handleConnected()
  self:logging(3,"handleConnected")
  self.sock:send('{"type": "connection_init", "payload": {}}') -- Only initialize the connection 
end


function QuickApp:simData() -- Offline Simulation Tibber Live
  self:logging(3,"simData")
  local resp = '{"payload": {"data": {"liveMeasurement": {"timestamp": "2022-06-16T16:43:20.000+02:00","accumulatedCost": 1.666866,"accumulatedReward": 0.485687,"accumulatedProduction": 3.793511,"accumulatedConsumption": 11.393055,"accumulatedProductionLastHour": 0.056511,"accumulatedConsumptionLastHour": 0.252055,"currentL1": 1.064,"currentL2": 1.159,"currentL3": 1.089,"powerFactor": 0.919,"powerReactive": 17,"powerProduction": 176,"power": 600,"voltagePhase1": 238.9,"voltagePhase2": 239,"voltagePhase3": 239.2,"signalStrength": -48,"powerProductionReactive": 508,"lastMeterProduction": 3579.144,"lastMeterConsumption": 88094.695,"minPowerProduction": 0,"maxPowerProduction": 5600,"minPower": 0,"averagePower": 681.3,"maxPower": 6665,"currency": "NOK"}}}}'
  
  --status,data = pcall(json.decode,resp)
  --if not status then 
  --  self:error(data)
  --end
  
  data = json.decode(resp) -- Decode the json string from api to lua-table 

  self:getValues()
  self:updateLabels()
  self:updateProperties()
  self:updateChildDevices() 
  
  local interval = 10
  self:logging(3,"SetTimeout " ..interval .." seconds")
  fibaro.setTimeout(interval*1000, function() 
     self:simData()
  end)
end


function QuickApp:getData()
  self:logging(3,"getData")
  self.sock = net.WebSocketClientTls()
  self.sock:addEventListener("connected", function() self:handleConnected() end)
  self.sock:addEventListener("disconnected", function() self:handleDisconnected() end)
  self.sock:addEventListener("error", function(error) self:handleError(error) end)
  self.sock:addEventListener("dataReceived", function(data) self:handleDataReceived(data) end)

  self:logging(3,"Connect: " ..url .." " ..json.encode(headers))
  self.sock:connect(url, headers)
end


function QuickApp:createVariables() -- Create all Variables 
  url = "wss://api.tibber.com/v1-beta/gql/subscriptions" -- Tibber Live webSocket URL
  data = {} -- Table for Tibber response
  prevdata = {} -- Table for previous values to replace null values
  prevdata.voltagePhase1 = 0
  prevdata.voltagePhase2 = 0
  prevdata.voltagePhase3 = 0
  prevdata.currentL1 = 0
  prevdata.currentL2 = 0
  prevdata.currentL3 = 0
  prevdata.powerFactor = 0
  prevdata.powerReactive = 0
  prevdata.signalStrength = 0
  prevdata.powerProductionReactive = 0
  prevdata.accumulatedReward = 0
  prevdata.accumulatedCost = 0
  prevdata.accumulatedConsumption = 0 -- Extra for calculation current price (experimental feature)
  prevdata.accumulatedProduction = 0 -- Extra for calculation current price (experimental feature)
  prevdata.currency = "EUR"
  
  headers = {} -- Headers for authorization and protocol
  headers["Authorization"] = token
  headers["Sec-WebSocket-Protocol"] = "graphql-ws"
  
  local graphql_query = {} -- Query for Subscription Live Measurement
  graphql_query.type = 'start'
  graphql_query.id = "1"
  graphql_query.payload = {}
  graphql_query.payload.query = 'subscription{liveMeasurement(homeId:"' ..homeId ..'"){power maxPower powerProduction maxPowerProduction accumulatedConsumption accumulatedProduction accumulatedCost currency lastMeterConsumption lastMeterProduction voltagePhase1 voltagePhase2 voltagePhase3 currentL1 currentL2 currentL3 accumulatedConsumptionLastHour accumulatedProductionLastHour accumulatedReward minPower averagePower powerReactive powerProductionReactive minPowerProduction powerFactor signalStrength timestamp}}'
  graphql_query_body = json.encode(graphql_query)
end


function QuickApp:getQuickAppVariables() -- Check existence of the mandatory variables, if not, create them with default values
  token = self:getVariable("token")
  homeId = self:getVariable("homeId")
  reconnect = tonumber(self:getVariable("reconnect"))
  timeout = tonumber(self:getVariable("timeout"))
  debugLevel = tonumber(self:getVariable("debugLevel"))

  if debugLevel == "" or debugLevel == nil then
    debugLevel = "1" -- Default debug level
    self:setVariable("debugLevel",debugLevel)
    self:trace("Added QuickApp variable debugLevel")
    debugLevel = tonumber(debugLevel)
  end
  if token == "" or token == nil or token == "0" then
    token = "5K4MVS-OjfWhK_4yrjOlFe1F6kJXPVf7eQYggo8ebAE" -- This token is just an demo/test example, only for demo/test purposes
    self:setVariable("token",token)
    self:trace("Added QuickApp variable with DEMO (!) token. Get your token from the Tibber website and parse it to the quickapp variable")
    debugLevel = 4 -- Offline Simulation Mode due to DEMO token
    self:warning("Switched to Offline Simulation Mode")
  end
  if homeId == "" or homeId == nil or homeId == "0" then
    homeId = "96a14971-525a-4420-aae9-e5aedaa129ff"-- This Home ID is just an demo/test example, only for demo/test purposes
    self:setVariable("homeId",homeId)
    self:trace("Added QuickApp variable with DEMO (!) Home ID. Get your Home ID from the Tibber website and parse it to the quickapp variable")
    debugLevel = 4 -- Offline Simulation Mode due to DEMO Home ID
    self:warning("Switched to Offline Simulation Mode")
  end
  if reconnect == "" or reconnect == nil then
    reconnect = "10" -- Default amount of re-connects 
    self:setVariable("reconnect",reconnect)
    self:trace("Added QuickApp variable reconnect")
    reconnect = tonumber(reconnect)
  end
  if timeout == "" or timeout == nil or timeout == 0 then
    timeout = "300" -- Default timeout after maximum re-connects in seconds
    self:setVariable("timeout",timeout)
    self:trace("Added QuickApp variable timeout")
    timeout = tonumber(timeout)
  end
  if debuglevel == 5 then -- Live Test Mode
    token = "5K4MVS-OjfWhK_4yrjOlFe1F6kJXPVf7eQYggo8ebAE" -- This token is just an demo/test example, only for demo/test purposes
    homeId = "96a14971-525a-4420-aae9-e5aedaa129ff" -- This Home ID is just an demo/test example, only for demo/test purposes
    self:warning("DebugLevel = 5 (Live Test mode): Changed Tibber Token and Home ID to Tibber TEST values")
  end
end


function QuickApp:setupChildDevices() -- Setup Child Devices
  local cdevs = api.get("/devices?parentId="..self.id) or {} -- Pick up all Child Devices
  function self:initChildDevices() end -- Null function, else Fibaro calls it after onInit()...

  if #cdevs == 0 then -- If no Child Devices, create them
    local initChildData = { 
      {className="power", name="Consumption", type="com.fibaro.powerMeter", value=0},
      {className="powerProduction", name="Production", type="com.fibaro.powerMeter", value=0},
      {className="accumulatedConsumption", name="Todays Consumption", type="com.fibaro.energyMeter", value=0},
      {className="accumulatedProduction", name="Todays Production", type="com.fibaro.energyMeter", value=0},
      {className="accumulatedCost", name="Todays Cost", type="com.fibaro.multilevelSensor", value=0},
      {className="accumulatedConsumptionLastHour", name="Hourly Consumption", type="com.fibaro.energyMeter", value=0},
      {className="accumulatedProductionLastHour", name="Hourly Production", type="com.fibaro.energyMeter", value=0},
      {className="lastMeterConsumption", name="Total Consumption", type="com.fibaro.energyMeter", value=0},
      {className="lastMeterProduction", name="Total Production", type="com.fibaro.energyMeter", value=0},
      {className="voltagePhase1", name="Voltage L1", type="com.fibaro.electricMeter", value=0},
      {className="voltagePhase2", name="Voltage L2", type="com.fibaro.electricMeter", value=0},
      {className="voltagePhase3", name="Voltage L3", type="com.fibaro.electricMeter", value=0},
      {className="currentL1", name="Ampere L1", type="com.fibaro.electricMeter", value=0},
      {className="currentL2", name="Ampere L2", type="com.fibaro.electricMeter", value=0},
      {className="currentL3", name="Ampere L3", type="com.fibaro.electricMeter", value=0},
    }
    for _,c in ipairs(initChildData) do
      local ips = UI and self:makeInitialUIProperties(UI or {}) or {}
      local child = self:createChildDevice(
        {name = c.name,
          type=c.type,
          properties = {viewLayout = ips.viewLayout, uiCallbacks = ips.uiCallbacks},
          interfaces = {"quickApp"}, 
        },
        _G[c.className] -- Fetch class constructor from class name
      )
      child:setVariable("className",c.className) -- Save class name so we know when we load it next time
    end   
  else 
    for _,child in ipairs(cdevs) do
      local className = getChildVariable(child,"className") -- Fetch child class name
      local childObject = _G[className](child) -- Create child object from the constructor's name
      self.childDevices[child.id]=childObject
      childObject.parent = self -- Setup parent link to device controller 
    end
  end
end


function QuickApp:onInit()
  __TAG = fibaro.getName(plugin.mainDeviceId) .." ID:" ..plugin.mainDeviceId
  self:debug("onInit") 

  self:setupChildDevices() -- Setup the Child Devices

  if not api.get("/devices/"..self.id).enabled then
    self:warning("Device", fibaro.getName(plugin.mainDeviceId), "is disabled")
    return
  end
  
  self:getQuickAppVariables() 
  self:createVariables()
  
  if tonumber(debugLevel) == 4 then 
    self:simData() -- Offline Simulation Tibber Live
  else
    self:getData() -- Get data from the Tibber Live
  end
end
