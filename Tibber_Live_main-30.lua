-- Tibber Live main


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
  self:logging(3, "buttonEvent()")
  if connection then
    connection = false
    self:disconnectServer() -- Disconnect session
    self:updateView("button", "text", "Click to re-connect")
    self:updateView("label", "text", "Disconnected from Tibber")
    self:updateProperty("log", "Disconnected")
  else 
    connection = true
    self:getData()  -- Re-connect again
    self:updateView("button", "text", "Disconnect")
  end
end


function QuickApp:updateProperties() -- Update the properties
  self:logging(3,"updateProperties() - Update the properties")
  self:updateProperty("value", tonumber(string.format("%.3f",data.payload.data.liveMeasurement.power-data.payload.data.liveMeasurement.powerProduction)))
  self:updateProperty("unit", "Watt")
  self:updateProperty("log", data.payload.data.liveMeasurement.timestamp)
end


function QuickApp:updateLabels() -- Update the labels
  self:logging(3,"updateLabels() - Update the labels")

  local labelText = ""
  if debugLevel == 4 then
    labelText = labelText ..translation["OFFLINE SIMULATION MODE"] .."\n\n"
  end
  if debugLevel == 5 then
    labelText = labelText ..translation["LIVE TEST MODE"] .."\n\n"
  end

  labelText = labelText ..translation["Consumption"] ..": " ..string.format("%.0f",data.payload.data.liveMeasurement.power) .." Watt" .."\n"
  labelText = labelText ..translation["Production"] ..": " ..string.format("%.0f",data.payload.data.liveMeasurement.powerProduction) .." Watt" .."\n\n"
  
  labelText = labelText ..translation["Hourly Consumption"] ..": " ..string.format("%.1f",data.payload.data.liveMeasurement.accumulatedConsumptionLastHour) .." kWh" .."\n"
  labelText = labelText ..translation["Hourly Production"] ..": " ..string.format("%.1f",data.payload.data.liveMeasurement.accumulatedProductionLastHour) .." kWh" .."\n\n"

  labelText = labelText ..translation["Todays Consumption"] ..": " ..string.format("%.1f",data.payload.data.liveMeasurement.accumulatedConsumption) .." kWh" .."\n"
  labelText = labelText ..translation["Min"] ..": " ..string.format("%.1f",data.payload.data.liveMeasurement.minPower) .." - " ..translation["Max"] ..": " ..string.format("%.1f",data.payload.data.liveMeasurement.maxPower) .." - " ..translation["Av"] ..": " ..string.format("%.1f",data.payload.data.liveMeasurement.averagePower) .." Watt" .."\n\n"
  
  labelText = labelText ..translation["Todays Production"] ..": " ..string.format("%.1f",data.payload.data.liveMeasurement.accumulatedProduction) .." kWh" .."\n"
  labelText = labelText ..translation["Min"] ..": " ..string.format("%.1f",data.payload.data.liveMeasurement.minPowerProduction) .." - " .." Max: " ..string.format("%.1f",data.payload.data.liveMeasurement.maxPowerProduction).." Watt" .."\n\n"
  
  labelText = labelText ..translation["Todays Cost"] ..": " ..string.format("%.2f",data.payload.data.liveMeasurement.accumulatedCost) .." " ..data.payload.data.liveMeasurement.currency .."\n" 
  labelText = labelText ..translation["Reward"] ..": " ..string.format("%.2f",tonumber(data.payload.data.liveMeasurement.accumulatedReward)) .." " ..data.payload.data.liveMeasurement.currency .."\n\n" 

  labelText = labelText ..translation["Totals"] ..":" .."\n" 
  labelText = labelText ..translation["Consumption"] ..": " ..string.format("%.1f",data.payload.data.liveMeasurement.lastMeterConsumption) .." kWh" .."\n" 
  labelText = labelText ..translation["Production"] ..": " ..string.format("%.1f",data.payload.data.liveMeasurement.lastMeterProduction) .." kWh" .."\n\n" 
  
  labelText = labelText ..translation["Voltage"] ..":" .."\n"
  labelText = labelText ..translation["L1"] ..": " ..string.format("%.0f",data.payload.data.liveMeasurement.voltagePhase1) .." - " ..translation["L2"] ..": " ..string.format("%.0f",data.payload.data.liveMeasurement.voltagePhase2) .." - " ..translation["L3"] ..": " ..string.format("%.0f",data.payload.data.liveMeasurement.voltagePhase3) .." Volt " .."\n\n"
  
  labelText = labelText ..translation["Ampere"] ..":" .."\n"
  labelText = labelText ..translation["L1"] ..": " ..string.format("%.2f",data.payload.data.liveMeasurement.currentL1) .." - " ..translation["L2"] ..": " ..string.format("%.2f",data.payload.data.liveMeasurement.currentL2) .." - " ..translation["L3"] ..": " ..string.format("%.2f",data.payload.data.liveMeasurement.currentL3) .." Amp " .."\n\n"
  
  labelText = labelText ..translation["Reactive Consumption"] ..": " ..string.format("%.1f",data.payload.data.liveMeasurement.powerReactive) .." kVAr" .."\n"
  labelText = labelText ..translation["Reactive Production"] ..": " ..string.format("%.1f",data.payload.data.liveMeasurement.powerProductionReactive) .." kVAr" .."\n"
  labelText = labelText ..translation["Power Factor"] ..": " ..string.format("%.3f",data.payload.data.liveMeasurement.powerFactor) .." " .."\n"
  labelText = labelText ..translation["Signal strength"] ..": " ..string.format("%.0f",data.payload.data.liveMeasurement.signalStrength) 
  if tonumber(data.payload.data.liveMeasurement.signalStrength) >= 0 then
    labelText = labelText .."%" .."\n"
  else
    labelText = labelText .." dB" .."\n"
  end
  labelText = labelText ..translation["Timestamp"] ..": " ..data.payload.data.liveMeasurement.timestamp .."\n"

  self:updateView("label", "text", labelText)
  self:logging(2,"Label: " ..labelText)
end


function QuickApp:getValues() -- Get the values from json file 
  self:logging(3,"getValues() - Get the values from json file")
  local pattern = "(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+).(%d+)+(%d+):(%d+)" --2021-12-23T17:00:00.000+01:00
  local runyear, runmonth, runday, runhour, runminute, runseconds = data.payload.data.liveMeasurement.timestamp:match(pattern)
  local convertedTimestamp = os.time({year = runyear, month = runmonth, day = runday, hour = runhour, min = runminute, sec = runseconds})
  data.payload.data.liveMeasurement.timestamp = os.date("%d-%m-%Y %H:%M:%S", convertedTimestamp)
  
  self:logging(2,"data: " ..json.encode(data))
  data = json.encode(data):gsub("null", '"null"') -- Clean up the response by replacing null with "null"
  data = json.decode(data) 

  -- Check for null values and replace them with previous values
  if data.payload.data.liveMeasurement.voltagePhase1 == "null" or data.payload.data.liveMeasurement.voltagePhase1 == nil or data.payload.data.liveMeasurement.voltagePhase1 == 0 then -- Also replace zero values for Voltage
    self:logging(3,"Replaced voltagePhase1 " ..data.payload.data.liveMeasurement.voltagePhase1 .." with: " ..prevdata.voltagePhase1)
    data.payload.data.liveMeasurement.voltagePhase1 = tonumber(prevdata.voltagePhase1)
  else
    prevdata.voltagePhase1 = data.payload.data.liveMeasurement.voltagePhase1 
  end
  if data.payload.data.liveMeasurement.voltagePhase2 == "null" or data.payload.data.liveMeasurement.voltagePhase2 == nil or data.payload.data.liveMeasurement.voltagePhase2 == 0 then -- Also replace zero values for Voltage
    self:logging(3,"Replaced voltagePhase2 " ..data.payload.data.liveMeasurement.voltagePhase2 .." with: " ..prevdata.voltagePhase2)
    data.payload.data.liveMeasurement.voltagePhase2 = tonumber(prevdata.voltagePhase2)
  else
    prevdata.voltagePhase2 = data.payload.data.liveMeasurement.voltagePhase2
  end
  if data.payload.data.liveMeasurement.voltagePhase3 == "null" or data.payload.data.liveMeasurement.voltagePhase3 == nil or data.payload.data.liveMeasurement.voltagePhase3 == 0 then -- Also replace zero values for Voltage
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


function QuickApp:handleError(error) -- An error occured
  self:logging(3,"handleError() - An error occured")
  self:error("WebSocket error: ", error)
    self:updateView("label", "text", "WebSocket error: ", error)
  if reconnect > 0 then -- re-connect n times
    self:logging(3,"Trying to reconnect ... (" ..tonumber(reconnect) ..")")
    fibaro.setTimeout(math.random(10,15)*1000, function() -- Random (jitter) reconnection between 10 and 15 seconds
      self:getData()
    end)
    reconnect = reconnect - 1 
  else -- Never disconnect, retry to re-connect after n seconds
    reconnect = tonumber(self:getVariable("reconnect"))
    self:logging(3,"SetTimeout for re-connect about ± " ..timeout .." seconds")
    fibaro.setTimeout((math.random(1,10)+timeout)*1000, function() -- Random (jitter) reconnection interval plus between 1 and 10 seconds
      if timeout < (tonumber(self:getVariable("reconnect"))*10) then -- Check for maximum increase 
        timeout = timeout*1.2 -- Increase the timeout for exponential backoff (increasing delay)
      end
      self:getData()
    end)
  end
end


function QuickApp:handleDisconnected() -- The client or the server closed the socket
  self:logging(3,"handleDisconnected() - The client or the server closed the socket")
  if reconnect > 0 then -- re-connect n times
    self:logging(3,"Trying to reconnect ... (" ..tonumber(reconnect) ..")")
    fibaro.setTimeout(math.random(10,15)*1000, function() -- Random (jitter) reconnection between 10 and 15 seconds
      self:getData()
    end)
    reconnect = reconnect - 1 
  else -- Never disconnect, retry to re-connect after n seconds
    reconnect = tonumber(self:getVariable("reconnect"))
    self:logging(3,"SetTimeout for re-connect about ± " ..timeout .." seconds")
    fibaro.setTimeout((math.random(1,10)+timeout)*1000, function() -- Random (jitter) reconnection interval plus between 1 and 10 seconds
      if timeout < (tonumber(self:getVariable("reconnect"))*10) then -- Check for maximum increase 
        timeout = timeout*1.2 -- Increase the timeout for exponential backoff (increasing delay)
      end
      self:getData()
    end)
  end
end


function QuickApp:disconnectServer() -- Closes the connection to the server
  self:logging(3,"disconnectServer() - Closes the connection to the server")
  self.sock:close()   
  self:logging(1,"Closed the connection with the Tibber server")
end


function QuickApp:handleDataReceived(resp) -- Handle data received by the socket
  self:logging(3,"handleDataReceived() - Handle data received by the socket")
  data = json.decode(resp) 

  if not connection then 
    -- Do nothing, the connection should be closed
    self:logging(1,"Tibber tries to re-connect: " ..data.type) -- Ignore the re-connect from Tibber
  elseif data.type == "connection_ack" then -- The initial connection is there, please send the query body
    self:logging(3,"Got connection_ack, making and sending query")
    self:logging(3,"graphql_query_body: " ..graphql_query_body)
    self.sock:send(graphql_query_body)
  elseif data.type == "next" then -- Tibber Live responded with next (new Tibber response)
    reconnect = tonumber(self:getVariable("reconnect")) -- Reset reconnect to is initial value
    self:getValues()
    self:updateLabels()
    self:updateProperties()

    if os.date("%M") ~= (timer or "99") then -- Update the child devices only every minute (to minimize CPU load)
      self:logging(3,"updateChildDevices")
      self:updateChildDevices() 
      timer = os.date("%M")
    end
  else -- Something else is going on 
    self:logging(2,"Data not handled in handleDataReceived: "..data.type) -- Maybe change due to disconnectServer()
  end
end


function QuickApp:handleConnected() -- Initialize the connection 
  self:logging(3,"handleConnected() - Initialize the connection")
  self.sock:send('{"type": "connection_init", "payload": {}}') -- Only initialize the connection 
end


function QuickApp:simData() -- Offline Simulation Tibber Live
  self:logging(3,"simData() - Offline Simulation Tibber Live")
  local resp = '{"id":"1","payload":{"data":{"liveMeasurement":{"currency":"SEK","averagePower":4574,"minPowerProduction":0,"lastMeterConsumption":36768.038,"powerFactor":0.878,"signalStrength":0,"lastMeterProduction":6411.939,"powerProduction":0,"voltagePhase3":231.5,"voltagePhase2":229.2,"maxPowerProduction":0,"powerReactive":0,"timestamp":"20-11-2022T12:11:24","powerProductionReactive":1496,"maxPower":8431,"currentL3":4.1,"accumulatedConsumptionLastHour":0.674,"voltagePhase1":229.4,"currentL2":4.3,"currentL1":6.6,"power":2746,"accumulatedConsumption":55.77,"accumulatedReward":0,"accumulatedProductionLastHour":0,"accumulatedCost":151.588522,"accumulatedProduction":0,"minPower":1558}}},"type":"next"}' -- New Tibber response

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


function QuickApp:getData() -- Get the data from Tibber
  self:logging(3,"getData() - Get the data from Tibber")
  self.sock = net.WebSocketClientTls()
  self.sock:addEventListener("connected", function() self:handleConnected() end)
  self.sock:addEventListener("disconnected", function() self:handleDisconnected() end)
  self.sock:addEventListener("error", function(error) self:handleError(error) end)
  self.sock:addEventListener("dataReceived", function(next) self:handleDataReceived(next) end) -- New Tibber Returning message type

  self:logging(3,"Connect: " ..url .." " ..json.encode(headers))
  self.sock:connect(url, headers)
end


function QuickApp:checkEnabled() -- Check realTimeConsumptionEnabled at Tibber
  self:logging(3,"checkEnabled() - Check realTimeConsumptionEnabled at Tibber")
  data = os.date("*t")
  local url = "https://api.tibber.com/v1-beta/gql"
  --local requestBody = '{viewer {home(id: "96a14971-525a-4420-aae9-e5aedaa129ff") {features {realTimeConsumptionEnabled}}}}'
  local requestBody = '{"query": "{viewer {homes{features{realTimeConsumptionEnabled}}}}"}'

  self:logging(3,"requestBody: " ..requestBody)

  http:request(url, {
    options = {
      data = requestBody,
      method = "POST",
      headers = {
        ["Content-Type"] = "application/json",
        ["Accept"] = "application/json",
        ["Authorization"] = "Bearer " ..token,
        ["User-Agent"] = "Tibber_Live/2.4 Fibaro/HC3 Firmware/" ..api.get("/settings/info").softVersion -- Tibber user-agent
      }
    },
    success = function(response) 
        self:logging(3,"response status: " ..response.status)
        self:logging(3,"headers: " ..response.headers["Content-Type"])
        self:logging(3,"Response data: " ..response.data)

        if response.data == nil or response.data == "" or response.data == "[]" or response.status > 200 or (os.date("%H:%M") <= "00:05") then -- Check for empty result or skip for midnight empty results
          if os.date("%H:%M") < "00:05" then
            self:warning("No production data from Tibber Monitor between 00:00 and 00:05")
          else
            self:warning("Temporarily no production data from Tibber")
          end
          return
        end

        response.data = response.data:gsub("null", "0") -- clean up the response.data by replacing null with 0
        --self:logging(3,"Response data without null: " ..response.data)
        
        -- response = {"data":{"viewer":{"homes":[{"features":{"realTimeConsumptionEnabled":true}}]}}}

        jsonTable = json.decode(response.data) -- JSON decode from api to lua-table
        self:logging(3,"jsonTable" ..json.encode(jsonTable))
        realTimeConsumptionEnabled = (jsonTable.data.viewer.homes[homeNr].features.realTimeConsumptionEnabled) or "empty"
      end,
      error = function(error)
        self:error("error: " ..json.encode(error))
        self:updateProperty("log", "error: " ..json.encode(error))
      end
    }) 
  self:logging(3,"SetTimeout 5 seconds")
  fibaro.setTimeout(5*1000, function() 
    if realTimeConsumptionEnabled then
      print("realTimeConsumptionEnabled = true")
    else
      print("realTimeConsumptionEnabled = false")
    end
  end)
end


function QuickApp:createVariables() -- Create all Variables 
  self:logging(3,"createVariables() - Create all Variables ")
  url = "wss://websocket-api.tibber.com/v1-beta/gql/subscriptions" -- New Tibber Live webSocket URL
  data = {} -- Table for Tibber response
  connection = true
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
  headers["Sec-WebSocket-Protocol"] = "graphql-transport-ws" -- New Tibber header protocol
  headers["User-Agent"] = "Tibber_Live/2.4 Fibaro/HC3 Firmware/" ..api.get("/settings/info").softVersion -- New Tibber mandatory user-agent
  
  local graphql_query = {} -- Query for Subscription Live Measurement
  graphql_query.type = "subscribe" -- New Tibber graphql_query.type
  graphql_query.id = "1"
  graphql_query.payload = {}
  graphql_query.payload.query = 'subscription{liveMeasurement(homeId:"' ..homeId ..'"){power maxPower powerProduction maxPowerProduction accumulatedConsumption accumulatedProduction accumulatedCost currency lastMeterConsumption lastMeterProduction voltagePhase1 voltagePhase2 voltagePhase3 currentL1 currentL2 currentL3 accumulatedConsumptionLastHour accumulatedProductionLastHour accumulatedReward minPower averagePower powerReactive powerProductionReactive minPowerProduction powerFactor signalStrength timestamp}}'
  graphql_query_body = json.encode(graphql_query)
  translation = i18n:translation(string.lower(self:getVariable("language"))) -- Initialise the translation
end


function QuickApp:getQuickAppVariables() -- Check existence of the mandatory variables, if not, create them with default values
  token = self:getVariable("token")
  homeId = self:getVariable("homeId")
  homeNr = tonumber(self:getVariable("homeNr"))
  local language = string.lower(self:getVariable("language"))
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
  if homeNr == "" or homeNr == nil then
    homeNr = "1"
    self:setVariable("homeNr",homeNr)
    self:trace("Added QuickApp variable homeNr")
    homeNr = tonumber(homeNr)
  end
  if language == "" or language == nil or type(i18n:translation(string.lower(self:getVariable("language")))) ~= "table" then
    language = "en" 
    self:setVariable("language",language)
    self:trace("Added QuickApp variable language")
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


local function getChildVariable(child,varName)
  for _,v in ipairs(child.properties.quickAppVariables or {}) do
    if v.name==varName then return v.value end
  end
  return ""
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


function QuickApp:onInit() -- Initialise the QuickApp
  __TAG = fibaro.getName(plugin.mainDeviceId) .." ID:" ..plugin.mainDeviceId
  self:debug("onInit() - Initialise the QuickApp") 

  self:setupChildDevices() -- Setup the Child Devices

  if not api.get("/devices/"..self.id).enabled then
    self:warning("Device", fibaro.getName(plugin.mainDeviceId), "is disabled")
    return
  end

  self:getQuickAppVariables() 
  self:createVariables()
  
  http = net.HTTPClient({timeout=5*1000}) -- To check home.features.realTimeConsumptionEnabled

  --self:checkEnabled() 

  if tonumber(debugLevel) == 4 then 
    self:simData() -- Offline Simulation Tibber Live
  else
    self:getData() -- Get data from the Tibber Live
  end
end
 
 -- EOF