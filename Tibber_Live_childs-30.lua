-- Tiber Live Classes Child Devices


class 'power'(QuickAppChild)
function power:__init(dev)
  QuickAppChild.__init(self,dev)
end
function power:updateValue(data) 
  self:updateProperty("value", tonumber(string.format("%.3f",data.payload.data.liveMeasurement.power)))
  self:updateProperty("power", tonumber(string.format("%.3f",data.payload.data.liveMeasurement.power)))
  self:updateProperty("unit", "Watt")
  self:updateProperty("log", translation["Max"] .." " ..data.payload.data.liveMeasurement.maxPower .." Watt")
end

class 'powerProduction'(QuickAppChild)
function powerProduction:__init(dev)
  QuickAppChild.__init(self,dev)
end
function powerProduction:updateValue(data) 
  self:updateProperty("value", tonumber(string.format("%.3f",data.payload.data.liveMeasurement.powerProduction)))
  self:updateProperty("power", tonumber(string.format("%.3f",data.payload.data.liveMeasurement.powerProduction)))
  self:updateProperty("unit", "Watt")
  self:updateProperty("log", translation["Max"] .." " ..data.payload.data.liveMeasurement.maxPowerProduction .." Watt")
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

-- EOF