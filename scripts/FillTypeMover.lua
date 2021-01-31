-- FS-Version:  FS19
-- Title:       FillTypeMover 
-- author:      Farmer_Schubi
-- date:        26.04.2019
-- Version:     1.0.5.1
-- Copyright (©) by Farmer_Schubi
-- 28.04.2019 erweitert um mehrere FillTypes pro Rohstoff und einen zweiten Rohstoff
-- 25.05.2019 Performanceproblem behoben
-- 26.05.2019 Paltzierbares Objekt merken
-- 15.06.2019 Displays bei 2 gleichen Produktionen zeigten bei der 2. nichts an
-- 17.06.2019 LUA-Fehler bei mehreren Produktionen mit identischen Namen behoben
-- 27.06.2019 Sounds ein und ausschalten
-- 28.06.2019 Sounds ausschalten wenn zweiter, dritter oder vierter Input leer ist
local Herstellung = {} 
Herstellung.__index = Herstellung 

function Herstellung.new()
  local self = setmetatable({}, Herstellung)
  self.modxmlname           = ""
  self.ModDirectory         = ""
  self.storename            = ""
  self.modname              = ""
  self.nodeId               = ""
  self.message              = true
  self.litersPerMin         = 100
  self.capacityPerFillType  = 100000
  self.in1                  = {}
  self.in2                  = {}
  self.in3                  = {}
  self.in4                  = {}
  self.percentage_in1       = 100
  self.percentage_in2       = 0
  self.percentage_in3       = 0
  self.percentage_in4       = 0
  self.out1                 = ""
  self.out2                 = ""
  self.percentage_out1      = 100
  self.percentage_out2      = 0
  self.display_out1         = DigitalDisplay:new()
  self.display_out2         = DigitalDisplay:new()
  self.display_in1          = DigitalDisplay:new()
  self.display_in2          = DigitalDisplay:new()
  self.display_in3          = DigitalDisplay:new()
  self.display_in4          = DigitalDisplay:new()
  self.display2_out1        = DigitalDisplay:new()
  self.display2_out2        = DigitalDisplay:new()
  self.display2_in1         = DigitalDisplay:new()
  self.display2_in2         = DigitalDisplay:new()
  self.display2_in3         = DigitalDisplay:new()
  self.display2_in4         = DigitalDisplay:new()
  
  self.display_out1_search  = true
  self.display_out2_search  = true
  self.display_in1_search   = true
  self.display_in2_search   = true
  self.display_in3_search   = true
  self.display_in4_search   = true
  self.display2_out1_search = true
  self.display2_out2_search = true
  self.display2_in1_search  = true
  self.display2_in2_search  = true
  self.display2_in3_search  = true
  self.display2_in4_search  = true 
  self.summe_in1            = 0
  self.summe_in2            = 0
  self.summe_in3            = 0
  self.summe_in4            = 0
  self.SoundNodes           = {}
  self.SoundIds             = {}
  return self
end

function Herstellung.get(self)
  return self
end

function Herstellung.set_modxmlname(self, modxmlname)
  self.modxmlname = modxmlname
end

function Herstellung.get_modxmlname(self)
  return self.modxmlname
end

function Herstellung.set_storename(self, storename)
  self.storename = storename 
end

function Herstellung.set_ModDirectory(self, ModDirectory)
  self.ModDirectory = ModDirectory
end

function Herstellung.set_modname(self, modname)
  self.modname = modname
end

function Herstellung.set_message(self, message_str)
    if message_str == "TRUE" then
        self.message = true
    else
        self.message = false
    end
end

function Herstellung.set_litersPerMin(self, litersPerMin)
    self.litersPerMin = litersPerMin 
end

function Herstellung.set_capacityPerFillType(self, capacityPerFillType)
    self.capacityPerFillType = capacityPerFillType 
end

function Herstellung.set_in1(self, in1)
    for substring in in1:gmatch("%S+") do
       table.insert(self.in1, substring)
    end
end

function Herstellung.set_in2(self, in2)
    for substring in in2:gmatch("%S+") do
       table.insert(self.in2, substring)
    end
end

function Herstellung.set_in3(self, in3)
    for substring in in3:gmatch("%S+") do
        table.insert(self.in3, substring)
    end
end

function Herstellung.set_in4(self, in4)
    for substring in in4:gmatch("%S+") do
        table.insert(self.in4, substring)
    end
end

function Herstellung.set_percentage_in1(self, percentage_in1)
    self.percentage_in1 = percentage_in1 
end

function Herstellung.set_percentage_in2(self, percentage_in2)
    self.percentage_in2 = percentage_in2 
end

function Herstellung.set_percentage_in3(self, percentage_in3)
    self.percentage_in3 = percentage_in3 
end

function Herstellung.set_percentage_in4(self, percentage_in4)
    self.percentage_in4 = percentage_in4
end

function Herstellung.set_out1(self, out1)
    self.out1 = out1
end

function Herstellung.set_out2(self, out2)
    self.out2 = out2
end

function Herstellung.set_percentage_out1(self, percentage_out1)
    self.percentage_out1 = percentage_out1
end

function Herstellung.set_percentage_out2(self, percentage_out2)
    self.percentage_out2 = percentage_out2
end

function Herstellung.add_SoundNode(self, node)
    table.insert(self.SoundNodes, node)
end

function Herstellung.add_SoundId(self, nodeId)
    table.insert(self.SoundIds, nodeId)
end

FillTypeMover = {};

local modDesc = loadXMLFile("modDesc", g_currentModDirectory .. "modDesc.xml");
local updateMs = 60000;
FillTypeMover.version = getXMLString(modDesc, "modDesc.version");
FillTypeMover.modDirectory = g_currentModDirectory;


FillTypeMover.Herst = {}
local i = 0
while true do
    local storageKey = string.format("modDesc.storeItems(0).storeItem(%d)", i)
    if not hasXMLProperty(modDesc, storageKey) then
        break
    end
    local modxmlname1 = Utils.getNoNil(getXMLString(modDesc, storageKey .. "#xmlFilename"), "Unknown");

    local modxml = loadXMLFile("modxml", g_currentModDirectory .. modxmlname1)
    if hasXMLProperty(modxml, "placeable.FillTypeMover") then
        local Herst = Herstellung.new("")
        Herst:set_modxmlname(modxmlname1)
        Herst:set_ModDirectory(g_currentModDirectory)
        local modname = g_currentModDirectory .. modxmlname1
        Herst:set_modname(modname)

        if hasXMLProperty(modxml, "placeable.storeData.name") then
            Herst:set_storename(getXMLString(modxml, "placeable.storeData.name"))
        end
        if hasXMLProperty(modxml, "placeable.Message") then
            Herst:set_message(utf8ToUpper(getXMLString(modxml, "placeable.Message")))
        end
        if hasXMLProperty(modxml, "placeable.litersPerMin") then
            Herst:set_litersPerMin(getXMLInt(modxml, "placeable.litersPerMin"))
        end

        local capacityPerFillTypeKey = string.format("placeable.storages(%d).storage(0)", 0)
        if hasXMLProperty(modxml,"placeable.storages(0).storage(0)" .. "#capacityPerFillType") then
            Herst:set_capacityPerFillType(Utils.getNoNil(getXMLInt(modxml, "placeable.storages(0).storage(0)" .. "#capacityPerFillType"), 0))
        end

        if hasXMLProperty(modxml, "placeable.filltypename_in1") then
            Herst:set_in1(utf8ToUpper(getXMLString(modxml, "placeable.filltypename_in1")));
        end

        if hasXMLProperty(modxml, "placeable.filltypename_in2") then
            Herst:set_in2(utf8ToUpper(getXMLString(modxml, "placeable.filltypename_in2")));
        end

        if hasXMLProperty(modxml, "placeable.filltypename_in3") then
            Herst:set_in3(utf8ToUpper(getXMLString(modxml, "placeable.filltypename_in3")));
        end

        if hasXMLProperty(modxml, "placeable.filltypename_in4") then
            Herst:set_in4(utf8ToUpper(getXMLString(modxml, "placeable.filltypename_in4")));
        end

        if hasXMLProperty(modxml, "placeable.percentage_in1") then
            Herst:set_percentage_in1(Utils.getNoNil(getXMLInt(modxml, "placeable.percentage_in1"), 100));
        end;

        if hasXMLProperty(modxml, "placeable.percentage_in2") then
            Herst:set_percentage_in2(Utils.getNoNil(getXMLInt(modxml, "placeable.percentage_in2"), 0));
        end;

        if hasXMLProperty(modxml, "placeable.percentage_in3") then
            Herst:set_percentage_in3(Utils.getNoNil(getXMLInt(modxml, "placeable.percentage_in3"), 0));
        end;

        if hasXMLProperty(modxml, "placeable.percentage_in4") then
            Herst:set_percentage_in4(Utils.getNoNil(getXMLInt(modxml, "placeable.percentage_in4"), 0));
        end;

        if hasXMLProperty(modxml, "placeable.filltypename_out1") then
            Herst:set_out1(utf8ToUpper(getXMLString(modxml, "placeable.filltypename_out1")));
        end;

        if hasXMLProperty(modxml, "placeable.filltypename_out2") then
            Herst:set_out2(utf8ToUpper(getXMLString(modxml, "placeable.filltypename_out2")));
        end;

        if hasXMLProperty(modxml, "placeable.percentage_out1") then
            Herst:set_percentage_out1(Utils.getNoNil(getXMLInt(modxml, "placeable.percentage_out1"), 100));
        end;

        if hasXMLProperty(modxml, "placeable.percentage_out2") then
            Herst:set_percentage_out2(Utils.getNoNil(getXMLInt(modxml, "placeable.percentage_out2"), 0));
        end;

        local d = 0
        while true do
            local SoundKey = string.format("placeable.SoundNodes(0).Sound(%d)", d)
            if not hasXMLProperty(modxml, SoundKey .. "#baseNode") then
                break
            else
                Herst:add_SoundNode(utf8ToUpper(getXMLString(modxml, SoundKey .. "#baseNode")))
            end	
            d = d + 1
        end
        table.insert(FillTypeMover.Herst, Herst)
    end;
    i = i + 1;
end

for i,Herst in ipairs(FillTypeMover.Herst) do
    local h = Herstellung.get(Herst)
    if h.message then
        print(i .. "  " .. h.modxmlname .. "  " .. h.storename .. "  " .. h.litersPerMin .. "  " .. h.litersPerMin  .. "  " .. h.capacityPerFillType)
        for i2,in1 in ipairs(h.in1) do
            print(i2 .. "  " .. in1)
        end
        print(h.percentage_in1)

        for i2,in2 in ipairs(h.in2) do
            print(i2 .. "  " .. in2)
        end
        print(h.percentage_in2)

        for i2,in3 in ipairs(h.in3) do
            print(i2 .. "  " .. in3)
        end
        print(h.percentage_in3)

        for i2,in4 in ipairs(h.in4) do
            print(i2 .. "  " .. in4)
        end
        print(h.percentage_in4)

        print(h.out1 .. "  " .. h.percentage_out1 .. "  " .. h.out2 .. "  " .. h.percentage_out2)
    end
end


addModEventListener(FillTypeMover);

function FillTypeMover:loadMap()
    print("############################################################");
    print("--- FillTypeMover 1.0.5.1");
    print("############################################################");
end

function FillTypeMover:deleteMap()
end;

function FillTypeMover:update(dt)
    local plus = 0;
    updateMs = updateMs + (dt * g_currentMission.loadingScreen.missionInfo.timeScale);
    if updateMs >= 60000   then
        updateMs = updateMs - 60000;
        for a=1, #g_currentMission.placeables do
            if g_currentMission.placeables[a] ~= nil then
                local object = g_currentMission.placeables[a];
                if object ~= nil and object.nodeId ~= nil then

                    for zz,Herst in ipairs(FillTypeMover.Herst) do
                        local ftm = Herstellung.get(Herst)

                        if object.storages ~= nil and type(object.storages) == "table" and object.loadingStation ~= nil and object.loadingStation.stationName ~= nil  and object.loadingStation.stationName == ftm.storename and
                            object.loadingStation.owningPlaceable.configFileName == ftm.modname then
                        if ftm.nodeId == 0 then
                            ftm.nodeId = object.nodeId
                        end
                        if ftm.nodeId ~= object.nodeId then
                            local found = false
                                for zz3,Herst3 in ipairs(FillTypeMover.Herst) do
                                local ftm3 = Herstellung.get(Herst3)
                                if ftm3.nodeId ~= ftm.nodeId and ftm3.nodeId == object.nodeId then
                                    found = true
                                end
                            end
                            if found == false then
                                local ftm2 = Herstellung.new("")
                                ftm2.nodeId = object.nodeId
                                ftm2.modxmlname           = ftm.modxmlname
                                ftm2.ModDirectory         = ftm.ModDirectory
                                ftm2.modname              = ftm.modname
                                ftm2.storename            = ftm.storename
                                ftm2.message              = ftm.message
                                ftm2.litersPerMin         = ftm.litersPerMin
                                ftm2.capacityPerFillType  = ftm.capacityPerFillType
                                ftm2.in1                  = ftm.in1
                                ftm2.in2                  = ftm.in2
                                ftm2.in3                  = ftm.in3
                                ftm2.in4                  = ftm.in4
                                ftm2.percentage_in1       = ftm.percentage_in1
                                ftm2.percentage_in2       = ftm.percentage_in2
                                ftm2.percentage_in3       = ftm.percentage_in3
                                ftm2.percentage_in4       = ftm.percentage_in4
                                ftm2.out1                 = ftm.out1
                                ftm2.out2                 = ftm.out2
                                ftm2.percentage_out1      = ftm.percentage_out1
                                ftm2.percentage_out2      = ftm.percentage_out2
                                ftm2.display_out1         = DigitalDisplay:new()
                                ftm2.display_out2         = DigitalDisplay:new()
                                ftm2.display_in1          = DigitalDisplay:new()
                                ftm2.display_in2          = DigitalDisplay:new()
                                ftm2.display_in3          = DigitalDisplay:new()
                                ftm2.display_in4          = DigitalDisplay:new()
                                ftm2.display2_out1        = DigitalDisplay:new()
                                ftm2.display2_out2        = DigitalDisplay:new()
                                ftm2.display2_in1         = DigitalDisplay:new()
                                ftm2.display2_in2         = DigitalDisplay:new()
                                ftm2.display2_in3         = DigitalDisplay:new()
                                ftm2.display2_in4         = DigitalDisplay:new()
                                ftm2.display_out1_search  = true
                                ftm2.display_out2_search  = true
                                ftm2.display_in1_search   = true
                                ftm2.display_in2_search   = true
                                ftm2.display_in3_search   = true
                                ftm2.display_in4_search   = true
                                ftm2.display2_out1_search = true
                                ftm2.display2_out2_search = true
                                ftm2.display2_in1_search  = true
                                ftm2.display2_in2_search  = true
                                ftm2.display2_in3_search  = true
                                ftm2.display2_in4_search  = true 
                                ftm2.summe_in1            = 0
                                ftm2.summe_in2            = 0
                                ftm2.summe_in3            = 0
                                ftm2.summe_in4            = 0
                                ftm2.SoundNodes           = ftm.SoundNodes
                                table.insert(FillTypeMover.Herst, ftm2)
                            end
                        end
                        if ftm.nodeId == object.nodeId then
                            if ftm.display_out1.rootNode == nil and ftm.display_out1_search then
                                ftm.display_out1_search  = false
                                local num = getNumOfChildren(object.nodeId)
                                local childId = getChild(object.nodeId, "weightDisplay_out1")
                                if childId ~= 0 then
                                    local childName = getName(childId)
                                    if childName == "weightDisplay_out1" then
                                        local modxml = loadXMLFile("modxml", ftm.ModDirectory .. ftm.modxmlname)
                                        if not ftm.display_out1:load(object.nodeId, modxml, "placeable.display_out1") then
                                            ftm.display_out1 = nil
                                        else
                                            ftm.display_out1:setValue(0)
                                        end
                                    end
                                else
                                    local childId3 = getChild(object.nodeId, "Anzeige")
                                    if childId3 ~= 0 then
                                        local childId = getChild(childId3, "Displays")
                                            if childId ~= 0 then
                                                local childId2 = getChild(childId, "weightDisplay_out1")
                                                if childId2 ~= 0 then
                                                    local childName = getName(childId2)
                                                    if childName == "weightDisplay_out1" then
                                                        local modxml = loadXMLFile("modxml", ftm.ModDirectory .. ftm.modxmlname)
                                                    if not ftm.display_out1:load(object.nodeId, modxml, "placeable.display_out1") then
                                                        ftm.display_out1 = nil
                                                    else
                                                        ftm.display_out1:setValue(0)
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            if ftm.display_out2.rootNode == nil and ftm.display_out2_search then
                                ftm.display_out2_search  = false
                                local num = getNumOfChildren(object.nodeId)
                                local childId = getChild(object.nodeId, "weightDisplay_out2")
                                if childId ~= 0 then
                                    local childName = getName(childId)
                                    if childName == "weightDisplay_out2" then
                                        local modxml = loadXMLFile("modxml", ftm.ModDirectory .. ftm.modxmlname)
                                    if not ftm.display_out2:load(object.nodeId, modxml, "placeable.display_out2") then
                                        ftm.display_out2 = nil
                                    else
                                        ftm.display_out2:setValue(0)
                                    end
                                end
                                else
                                    local childId3 = getChild(object.nodeId, "Anzeige")
                                    if childId3 ~= 0 then
                                        local childId = getChild(childId3, "Displays")
                                        if childId ~= 0 then
                                            local childId2 = getChild(childId, "weightDisplay_out2")
                                            if childId2 ~= 0 then
                                                local childName = getName(childId2)
                                                if childName == "weightDisplay_out2" then
                                                    local modxml = loadXMLFile("modxml", ftm.ModDirectory .. ftm.modxmlname)
                                                    if not ftm.display_out2:load(object.nodeId, modxml, "placeable.display_out2") then
                                                        ftm.display_out2 = nil
                                                    else
                                                        ftm.display_out2:setValue(0)
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            if ftm.display_in1.rootNode == nil and ftm.display_in1_search then
                                ftm.display_in1_search  = false
                                local num = getNumOfChildren(object.nodeId)
                                local childId = getChild(object.nodeId, "weightDisplay_in1")
                                if childId ~= 0 then
                                    local childName = getName(childId)
                                    if childName == "weightDisplay_in1" then
                                        local modxml = loadXMLFile("modxml", ftm.ModDirectory .. ftm.modxmlname)
                                    if not ftm.display_in1:load(object.nodeId, modxml, "placeable.display_in1") then
                                        ftm.display_in1 = nil
                                    else
                                        ftm.display_in1:setValue(0)
                                    end
                                end
                                else
                                    local childId3 = getChild(object.nodeId, "Anzeige")
                                    if childId3 ~= 0 then
                                        local childId = getChild(childId3, "Displays")
                                        if childId ~= 0 then
                                            local childId2 = getChild(childId, "weightDisplay_in1")
                                            if childId2 ~= 0 then
                                                local childName = getName(childId2)
                                                if childName == "weightDisplay_in1" then
                                                    local modxml = loadXMLFile("modxml", ftm.ModDirectory .. ftm.modxmlname)
                                                if not ftm.display_in1:load(object.nodeId, modxml, "placeable.display_in1") then
                                                    ftm.display_in1 = nil
                                                else
                                                    ftm.display_in1:setValue(0)
                                                end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            if ftm.display_in2.rootNode == nil and ftm.display_in2_search then
                                ftm.display_in2_search  = false
                                local num = getNumOfChildren(object.nodeId)
                                local childId = getChild(object.nodeId, "weightDisplay_in2")
                                if childId ~= 0 then
                                    local childName = getName(childId)
                                    if childName == "weightDisplay_in2" then
                                        local modxml = loadXMLFile("modxml", ftm.ModDirectory .. ftm.modxmlname)
                                    if not ftm.display_in2:load(object.nodeId, modxml, "placeable.display_in2") then
                                        ftm.display_in2 = nil
                                    else
                                        ftm.display_in2:setValue(0)
                                    end
                                    end
                                else
                                    local childId3 = getChild(object.nodeId, "Anzeige")
                                    if childId3 ~= 0 then
                                        local childId = getChild(childId3, "Displays")
                                        if childId ~= 0 then
                                            local childId2 = getChild(childId, "weightDisplay_in2")
                                            if childId2 ~= 0 then
                                                local childName = getName(childId2)
                                                if childName == "weightDisplay_in2" then
                                                    local modxml = loadXMLFile("modxml", ftm.ModDirectory .. ftm.modxmlname)
                                                if not ftm.display_in2:load(object.nodeId, modxml, "placeable.display_in2") then
                                                    ftm.display_in2 = nil
                                                else
                                                    ftm.display_in2:setValue(0)
                                                end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            if ftm.display_in3.rootNode == nil and ftm.display_in3_search then
                                ftm.display_in3_search  = false
                                local num = getNumOfChildren(object.nodeId)
                                local childId = getChild(object.nodeId, "weightDisplay_in3")
                                if childId ~= 0 then
                                    local childName = getName(childId)
                                        if childName == "weightDisplay_in3" then
                                            local modxml = loadXMLFile("modxml", ftm.ModDirectory .. ftm.modxmlname)
                                        if not ftm.display_in3:load(object.nodeId, modxml, "placeable.display_in3") then
                                            ftm.display_in3 = nil
                                        else
                                            ftm.display_in3:setValue(0)
                                        end
                                        end
                                    else
                                    local childId3 = getChild(object.nodeId, "Anzeige")
                                        if childId3 ~= 0 then
                                            local childId = getChild(childId3, "Displays")
                                            if childId ~= 0 then
                                                local childId2 = getChild(childId, "weightDisplay_in3")
                                                if childId2 ~= 0 then
                                                    local childName = getName(childId2)
                                                    if childName == "weightDisplay_in3" then
                                                        local modxml = loadXMLFile("modxml", ftm.ModDirectory .. ftm.modxmlname)
                                                    if not ftm.display_in3:load(object.nodeId, modxml, "placeable.display_in3") then
                                                        ftm.display_in3 = nil
                                                    else
                                                        ftm.display_in3:setValue(0)
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            if ftm.display_in4.rootNode == nil and ftm.display_in4_search then
                                    ftm.display_in4_search  = false
                                    local num = getNumOfChildren(object.nodeId)
                                    local childId = getChild(object.nodeId, "weightDisplay_in4")
                                    if childId ~= 0 then
                                        local childName = getName(childId)
                                        if childName == "weightDisplay_in4" then
                                            local modxml = loadXMLFile("modxml", ftm.ModDirectory .. ftm.modxmlname)
                                        if not ftm.display_in4:load(object.nodeId, modxml, "placeable.display_in4") then
                                            ftm.display_in4 = nil
                                        else
                                            ftm.display_in4:setValue(0)
                                        end
                                    end
                                    else
                                    local childId3 = getChild(object.nodeId, "Anzeige")
                                        if childId3 ~= 0 then
                                            local childId = getChild(childId3, "Displays")
                                            if childId ~= 0 then
                                                local childId2 = getChild(childId, "weightDisplay_in4")
                                                if childId2 ~= 0 then
                                                    local childName = getName(childId2)
                                                    if childName == "weightDisplay_in4" then
                                                        local modxml = loadXMLFile("modxml", ftm.ModDirectory .. ftm.modxmlname)
                                                    if not ftm.display_in4:load(object.nodeId, modxml, "placeable.display_in4") then
                                                        ftm.display_in4 = nil
                                                    else
                                                        ftm.display_in4:setValue(0)
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        if ftm.display2_out1.rootNode == nil and ftm.display2_out1_search then
                            ftm.display2_out1_search  = false
                            local num = getNumOfChildren(object.nodeId)
                            local childId3 = getChild(object.nodeId, "Anzeige2")
                            if childId3 ~= 0 then
                                local childId = getChild(childId3, "Displays")
                                if childId ~= 0 then
                                    local childId2 = getChild(childId, "weightDisplay_out1")
                                    if childId2 ~= 0 then
                                        local childName = getName(childId2)
                                        if childName == "weightDisplay_out1" then
                                            local modxml = loadXMLFile("modxml", ftm.ModDirectory .. ftm.modxmlname)
                                        if not ftm.display2_out1:load(object.nodeId, modxml, "placeable.display2_out1") then
                                            ftm.display2_out1 = nil
                                        else
                                            ftm.display2_out1:setValue(0)
                                        end
                                        end
                                    end
                                end
                            end
                        end
                        if ftm.display2_out2.rootNode == nil and ftm.display2_out2_search then
                            ftm.display2_out2_search  = false
                            local num = getNumOfChildren(object.nodeId)
                            local childId3 = getChild(object.nodeId, "Anzeige2")
                            if childId3 ~= 0 then
                                local childId = getChild(childId3, "Displays")
                                if childId ~= 0 then
                                    local childId2 = getChild(childId, "weightDisplay_out2")
                                    if childId2 ~= 0 then
                                        local childName = getName(childId2)
                                        if childName == "weightDisplay_out2" then
                                            local modxml = loadXMLFile("modxml", ftm.ModDirectory .. ftm.modxmlname)
                                        if not ftm.display2_out2:load(object.nodeId, modxml, "placeable.display2_out2") then
                                            ftm.display2_out2 = nil
                                        else
                                            ftm.display2_out2:setValue(0)
                                        end
                                        end
                                    end
                                end
                            end
                        end
                        if ftm.display2_in1.rootNode == nil and ftm.display2_in1_search then
                            ftm.display2_in1_search  = false
                            local num = getNumOfChildren(object.nodeId)
                            local childId3 = getChild(object.nodeId, "Anzeige2")
                            if childId3 ~= 0 then
                                local childId = getChild(childId3, "Displays")
                                if childId ~= 0 then
                                    local childId2 = getChild(childId, "weightDisplay_in1")
                                    if childId2 ~= 0 then
                                        local childName = getName(childId2)
                                        if childName == "weightDisplay_in1" then
                                            local modxml = loadXMLFile("modxml", ftm.ModDirectory .. ftm.modxmlname)
                                        if not ftm.display2_in1:load(object.nodeId, modxml, "placeable.display2_in1") then
                                            ftm.display2_in1 = nil
                                        else
                                            ftm.display2_in1:setValue(0)
                                        end
                                        end
                                    end
                                end
                            end
                        end
                        if ftm.display2_in2.rootNode == nil and ftm.display2_in3_search then
                            ftm.display2_in2_search  = false
                            local num = getNumOfChildren(object.nodeId)
                            local childId3 = getChild(object.nodeId, "Anzeige2")
                            if childId3 ~= 0 then
                                local childId = getChild(childId3, "Displays")
                                if childId ~= 0 then
                                    local childId2 = getChild(childId, "weightDisplay_in2")
                                    if childId2 ~= 0 then
                                        local childName = getName(childId2)
                                        if childName == "weightDisplay_in2" then
                                            local modxml = loadXMLFile("modxml", ftm.ModDirectory .. ftm.modxmlname)
                                        if not ftm.display2_in2:load(object.nodeId, modxml, "placeable.display2_in2") then
                                            ftm.display2_in2 = nil
                                        else
                                            ftm.display2_in2:setValue(0)
                                        end
                                        end
                                    end
                                end
                            end
                        end
                        if ftm.display2_in3.rootNode == nil and ftm.display2_in3_search then
                            ftm.display2_in3_search  = false
                            local num = getNumOfChildren(object.nodeId)
                            local childId3 = getChild(object.nodeId, "Anzeige2")
                            if childId3 ~= 0 then
                                local childId = getChild(childId3, "Displays")
                                if childId ~= 0 then
                                    local childId2 = getChild(childId, "weightDisplay_in3")
                                    if childId2 ~= 0 then
                                        local childName = getName(childId2)
                                        if childName == "weightDisplay_in3" then
                                            local modxml = loadXMLFile("modxml", ftm.ModDirectory .. ftm.modxmlname)
                                        if not ftm.display2_in3:load(object.nodeId, modxml, "placeable.display2_in3") then
                                            ftm.display2_in3 = nil
                                        else
                                            ftm.display2_in3:setValue(0)
                                        end
                                        end
                                    end
                                end
                            end
                        end
                        if ftm.display2_in4.rootNode == nil and ftm.display2_in4_search then
                            ftm.display2_in4_search  = false
                            local num = getNumOfChildren(object.nodeId)
                            local childId3 = getChild(object.nodeId, "Anzeige2")
                            if childId3 ~= 0 then
                                local childId = getChild(childId3, "Displays")
                                if childId ~= 0 then
                                    local childId2 = getChild(childId, "weightDisplay_in4")
                                    if childId2 ~= 0 then
                                        local childName = getName(childId2)
                                                if childName == "weightDisplay_in4" then
                                                    local modxml = loadXMLFile("modxml", ftm.ModDirectory .. ftm.modxmlname)
                                                if not ftm.display2_in4:load(object.nodeId, modxml, "placeable.display2_in4") then
                                                    ftm.display2_in4 = nil
                                                else
                                                    ftm.display2_in4:setValue(0)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                            if  #ftm.SoundIds==0 then
                                for f,SoundNode in pairs(ftm.SoundNodes) do
                                local SoundId = I3DUtil.indexToObject(object.nodeId, SoundNode);
                                    ftm:add_SoundId(SoundId)
                                    setVisibility(SoundId,false);
                            end
                        end

                                found1 = false;
                                found1_1 = false;
                                found1_2 = false;
                                found2 = false;
                                found2_1 = false;
                                found2_2 = false;
                                found3 = false;
                                found3_1 = false;
                                found3_2 = false;
                                found4 = false;
                                found4_1 = false;
                                found4_2 = false;
                                in2 = false;
                                in3 = false;
                                in4 = false;
                                fillType_in = ""
                                fillType_in_stor = ""
                                FillTypeMover.filltypename_in = ""
                                filltypename_in = ""
                                fillType_out1 = ""
                                filltypename_out1 = ""
                                fillType_out2 = ""
                                filltypename_out2 = ""
                                fillType_out2_found = ""
                                ftm.summe_in1 = 0
                                ftm.summe_in2 = 0
                                ftm.summe_in3 = 0
                                ftm.summe_in4 = 0

                                for fillType_in_stor,isAccepted in pairs(object.storages[1].fillTypes) do
                                    local filltypename_in_stor = g_fillTypeManager.indexToName[fillType_in_stor];
                                    for i,filltypename_in,isAccepted in pairs(ftm.in1) do
                                        if filltypename_in_stor == filltypename_in then	
                                            if object.storages[1].fillLevels[fillType_in_stor] > 0 then
                                                ftm.summe_in1 = ftm.summe_in1 + object.storages[1].fillLevels[fillType_in_stor]
                                            end
                                        end
                                    end
                                    for i,filltypename_in,isAccepted in pairs(ftm.in2) do
                                        if filltypename_in_stor == filltypename_in then	
                                            if object.storages[1].fillLevels[fillType_in_stor] > 0 then
                                                ftm.summe_in2 = ftm.summe_in2 + object.storages[1].fillLevels[fillType_in_stor]
                                            end
                                        end
                                    end
                                    for i,filltypename_in,isAccepted in pairs(ftm.in3) do
                                        if filltypename_in_stor == filltypename_in then	
                                            if object.storages[1].fillLevels[fillType_in_stor] > 0 then
                                                ftm.summe_in3 = ftm.summe_in3 + object.storages[1].fillLevels[fillType_in_stor]
                                            end
                                        end
                                    end
                                    for i,filltypename_in,isAccepted in pairs(ftm.in4) do
                                        if filltypename_in_stor == filltypename_in then	
                                            if object.storages[1].fillLevels[fillType_in_stor] > 0 then
                                                ftm.summe_in4 = ftm.summe_in4 + object.storages[1].fillLevels[fillType_in_stor]
                                            end
                                        end
                                    end
                                end

                                if ftm.display_in1 ~= nil then
                                    ftm.display_in1:setValue(ftm.summe_in1)
                                end
                                if ftm.display_in2 ~= nil then
                                    ftm.display_in2:setValue(ftm.summe_in2)
                                end
                                if ftm.display_in3 ~= nil then
                                    ftm.display_in3:setValue(ftm.summe_in3)
                                end
                                if ftm.display_in4 ~= nil then
                                    ftm.display_in4:setValue(ftm.summe_in4)
                                end
                                if ftm.display2_in1 ~= nil then
                                    ftm.display2_in1:setValue(ftm.summe_in1)
                                end
                                if ftm.display2_in2 ~= nil then
                                    ftm.display2_in2:setValue(ftm.summe_in2)
                                end
                                if ftm.display2_in3 ~= nil then
                                    ftm.display2_in3:setValue(ftm.summe_in3)
                                end
                                if ftm.display2_in4 ~= nil then
                                    ftm.display2_in4:setValue(ftm.summe_in4)
                                end
                                for i,filltypename_in,isAccepted in pairs(ftm.in1) do
                                    FillTypeMover.filltypename_in = filltypename_in;
                                    for fillType_in,isAccepted in pairs(object.storages[1].fillTypes) do
                                        local filltypename_in = g_fillTypeManager.indexToName[fillType_in];
                                        if filltypename_in == FillTypeMover.filltypename_in then
                                            if object.storages[1].fillLevels[fillType_in] > 0 then
                                                for fillType_out1,isAccepted in pairs(object.storages[1].fillTypes) do
                                                    local filltypename_out1 = g_fillTypeManager.indexToName[fillType_out1];
                                                     if filltypename_out1 == ftm.out1 then
                                                         if ftm.display_out1 ~= nil then
                                                             ftm.display_out1:setValue(object.storages[1].fillLevels[fillType_out1])
                                                        end
                                                        if ftm.display2_out1 ~= nil then
                                                            ftm.display2_out1:setValue(object.storages[1].fillLevels[fillType_out1])
                                                        end
                                                        if object.storages[1].fillLevels[fillType_in] > (ftm.litersPerMin * ftm.percentage_in1 / 100) then
                                                            plus1 = (ftm.litersPerMin * ftm.percentage_in1 / 100);
                                                            plus1_low = false;
                                                        else
                                                            plus1 =  object.storages[1].fillLevels[fillType_in];
                                                            plus1_low = true;
                                                        end;
                                                        out1 = (object.storages[1].fillLevels[fillType_out1] + (ftm.litersPerMin) * ftm.percentage_out1 / 100);
                                                        if out1 <= ftm.capacityPerFillType then
                                                            fillType_in_found1  = fillType_in;
                                                            fillType_out1_found = fillType_out1;
                                                            found1_1 = true;
                                                        end;
                                                    end;
                                                end;
                                                for fillType_out2,isAccepted in pairs(object.storages[1].fillTypes) do
                                                    local filltypename_out2 = g_fillTypeManager.indexToName[fillType_out2];
                                                    if filltypename_out2 == ftm.out2 then
                                                        if ftm.display_out2 ~= nil then
                                                            ftm.display_out2:setValue(object.storages[1].fillLevels[fillType_out2])
                                                        end
                                                        if ftm.display2_out2 ~= nil then
                                                            ftm.display2_out2:setValue(object.storages[1].fillLevels[fillType_out2])
                                                        end
                                                        if object.storages[1].fillLevels[fillType_in] > (ftm.litersPerMin * ftm.percentage_in1 / 100) then
                                                            plus1 = (ftm.litersPerMin * ftm.percentage_in1 / 100);
                                                            plus1_low = false;
                                                        else
                                                            plus1 =  object.storages[1].fillLevels[fillType_in];
                                                            plus1_low = true;
                                                        end;
                                                        out2 = (object.storages[1].fillLevels[fillType_out2] + (ftm.litersPerMin) * ftm.percentage_out2 / 100);
                                                        if out2 <= ftm.capacityPerFillType then
                                                            fillType_out2_found = fillType_out2;
                                                            found1_2 = true;
                                                        end;
                                                    end;
                                                end;
                                            else
                                                for fillType_out,isAccepted in pairs(object.storages[1].fillTypes) do
                                                    local filltypename_out = g_fillTypeManager.indexToName[fillType_out];
                                                    if filltypename_out == ftm.out1 then
                                                        if ftm.display_out1 ~= nil then
                                                            ftm.display_out1:setValue(object.storages[1].fillLevels[fillType_out])
                                                        end
                                                        if ftm.display2_out1 ~= nil then
                                                            ftm.display2_out1:setValue(object.storages[1].fillLevels[fillType_out])
                                                        end
                                                    end;
                                                    if filltypename_out == ftm.out2 then
                                                        if ftm.display_out2 ~= nil then
                                                            ftm.display_out2:setValue(object.storages[1].fillLevels[fillType_out])
                                                        end
                                                        if ftm.display2_out2 ~= nil then
                                                            ftm.display2_out2:setValue(object.storages[1].fillLevels[fillType_out])
                                                        end
                                                    end;
                                                end;
                                            end;
                                        end;
                                    end;
                                    if fillType_out2_found ~= "" then
                                        if found1_1 and found1_2 then 
                                            found1 = true;
                                            break;
                                        end;
                                    else
                                        if found1_1 then 
                                            found1 = true;
                                            break;
                                        end;
                                    end;
                                end;

                                found2 = false;
                                found2_1 = false;
                                found2_2 = false;
                                found3 = false;
                                found3_1 = false;
                                found3_2 = false;
                                found4 = false;
                                found4_1 = false;
                                found4_2 = false;

                                fillType_in = ""
                                FillTypeMover.filltypename_in = ""
                                fillType_out1 = ""
                                filltypename_out1 = ""
                                fillType_out2 = ""
                                filltypename_out2 = ""
                                for i,filltypename_in,isAccepted in pairs(ftm.in2) do
                                    in2 = true;
                                    FillTypeMover.filltypename_in = filltypename_in;
                                    for fillType_in,isAccepted in pairs(object.storages[1].fillTypes) do
                                        local filltypename_in = g_fillTypeManager.indexToName[fillType_in];
                                        if filltypename_in == FillTypeMover.filltypename_in then
                                            if object.storages[1].fillLevels[fillType_in] > 0 then
                                                if ftm.display_in2 ~= nil then
                                                    ftm.display_in2:setValue(object.storages[1].fillLevels[fillType_in])
                                                end
                                                for fillType_out1,isAccepted in pairs(object.storages[1].fillTypes) do
                                                    local filltypename_out1 = g_fillTypeManager.indexToName[fillType_out1];
                                                    if filltypename_out1 == ftm.out1 then
                                                        if object.storages[1].fillLevels[fillType_in] > (ftm.litersPerMin * ftm.percentage_in2 / 100) then
                                                            plus2 = (ftm.litersPerMin * ftm.percentage_in2 / 100);
                                                            plus2_low = false;
                                                        else
                                                            plus2 =  object.storages[1].fillLevels[fillType_in];
                                                            plus2_low = true;
                                                        end;
                                                        out1 = (object.storages[1].fillLevels[fillType_out1] + (ftm.litersPerMin) * ftm.percentage_out1 / 100);
                                                        if out1 <= ftm.capacityPerFillType then
                                                            fillType_in_found2  = fillType_in;
                                                            fillType_out1_found = fillType_out1;
                                                            found2_1 = true;
                                                        end;
                                                    end;
                                                end;
                                                for fillType_out2,isAccepted in pairs(object.storages[1].fillTypes) do
                                                    local filltypename_out2 = g_fillTypeManager.indexToName[fillType_out2];
                                                    if filltypename_out2 == ftm.out2 then
                                                         if object.storages[1].fillLevels[fillType_in] > (ftm.litersPerMin * ftm.percentage_in2 / 100) then
                                                            plus2 = (ftm.litersPerMin * ftm.percentage_in2 / 100);
                                                            plus2_low = false;
                                                        else
                                                            plus2 =  object.storages[1].fillLevels[fillType_in];
                                                            plus2_low = true;
                                                        end;
                                                        out2 = (object.storages[1].fillLevels[fillType_out2] + (ftm.litersPerMin) * ftm.percentage_out2 / 100);
                                                        if out2 <= ftm.capacityPerFillType then
                                                            fillType_out2_found = fillType_out2;
                                                            found2_2 = true;
                                                        end;
                                                    end;
                                                end;
                                            end;
                                        end;
                                    end;
                                    if fillType_out2_found ~= "" then
                                        if found2_1 and found2_2 then 
                                            found2 = true;
                                            break;
                                        end;
                                    else
                                        if found2_1 then 
                                            found2 = true;
                                            break;
                                        end;
                                    end;
                                end;

                                found3 = false;
                                found3_1 = false;
                                found3_2 = false;
                                found4 = false;
                                found4_1 = false;
                                found4_2 = false;
                                fillType_in = ""
                                FillTypeMover.filltypename_in = ""
                                fillType_out1 = ""
                                filltypename_out1 = ""
                                fillType_out2 = ""
                                filltypename_out2 = ""	

                                for i,filltypename_in,isAccepted in pairs(ftm.in3) do
                                    in3 = true;
                                    FillTypeMover.filltypename_in = filltypename_in;
                                    for fillType_in,isAccepted in pairs(object.storages[1].fillTypes) do
                                        local filltypename_in = g_fillTypeManager.indexToName[fillType_in];
                                        if filltypename_in == FillTypeMover.filltypename_in then
                                            if object.storages[1].fillLevels[fillType_in] > 0 then
                                                for fillType_out1,isAccepted in pairs(object.storages[1].fillTypes) do
                                                    local filltypename_out1 = g_fillTypeManager.indexToName[fillType_out1];
                                                    if filltypename_out1 == ftm.out1 then
                                                        if object.storages[1].fillLevels[fillType_in] > (ftm.litersPerMin * ftm.percentage_in3 / 100) then
                                                            plus3 = (ftm.litersPerMin * ftm.percentage_in3 / 100);
                                                            plus3_low = false;
                                                        else
                                                            plus3 =  object.storages[1].fillLevels[fillType_in];
                                                            plus3_low = true;
                                                        end;
                                                        out1 = (object.storages[1].fillLevels[fillType_out1] + (ftm.litersPerMin) * ftm.percentage_out1 / 100);
                                                        if out1 <= ftm.capacityPerFillType then
                                                            fillType_in_found3  = fillType_in;
                                                            fillType_out1_found = fillType_out1;
                                                            found3_1 = true;
                                                        end;
                                                    end;
                                                end;
                                                for fillType_out2,isAccepted in pairs(object.storages[1].fillTypes) do
                                                    local filltypename_out2 = g_fillTypeManager.indexToName[fillType_out2];
                                                    if filltypename_out2 == ftm.out2 then
                                                        if object.storages[1].fillLevels[fillType_in] > (ftm.litersPerMin * ftm.percentage_in3 / 100) then
                                                            plus3 = (ftm.litersPerMin * ftm.percentage_in3 / 100);
                                                            plus3_low = false;
                                                        else
                                                            plus3 =  object.storages[1].fillLevels[fillType_in];
                                                            plus3_low = true;
                                                        end;
                                                        out2 = (object.storages[1].fillLevels[fillType_out2] + (ftm.litersPerMin) * ftm.percentage_out2 / 100);
                                                        if out2 <= ftm.capacityPerFillType then
                                                            fillType_out2_found = fillType_out2;
                                                            found3_2 = true;
                                                        end;
                                                    end;
                                                end;
                                            end;
                                        end;
                                    end;
                                    if fillType_out2_found ~= "" then
                                        if found3_1 and found3_2 then 
                                            found3 = true;
                                            break;
                                        end;
                                    else
                                        if found3_1 then 
                                            found3 = true;
                                            break;
                                        end;
                                    end;
                                end;


                                found4 = false;
                                found4_1 = false;
                                found4_2 = false;
                                fillType_in = ""
                                FillTypeMover.filltypename_in = ""
                                fillType_out1 = ""
                                filltypename_out1 = ""
                                fillType_out2 = ""
                                filltypename_out2 = ""	

                                for i,filltypename_in,isAccepted in pairs(ftm.in4) do
                                    in4 = true;
                                    FillTypeMover.filltypename_in = filltypename_in;
                                    for fillType_in,isAccepted in pairs(object.storages[1].fillTypes) do
                                        local filltypename_in = g_fillTypeManager.indexToName[fillType_in];
                                        if filltypename_in == FillTypeMover.filltypename_in then
                                            if object.storages[1].fillLevels[fillType_in] > 0 then
                                                for fillType_out1,isAccepted in pairs(object.storages[1].fillTypes) do
                                                    local filltypename_out1 = g_fillTypeManager.indexToName[fillType_out1];
                                                    if filltypename_out1 == ftm.out1 then
                                                        if object.storages[1].fillLevels[fillType_in] > (ftm.litersPerMin * ftm.percentage_in4 / 100) then
                                                            plus4 = (ftm.litersPerMin * ftm.percentage_in4 / 100);
                                                            plus4_low = false;
                                                        else
                                                            plus4 =  object.storages[1].fillLevels[fillType_in];
                                                            plus4_low = true;
                                                        end;
                                                        out1 = (object.storages[1].fillLevels[fillType_out1] + (ftm.litersPerMin) * ftm.percentage_out1 / 100);
                                                        if out1 <= ftm.capacityPerFillType then
                                                            fillType_in_found4  = fillType_in;
                                                            fillType_out1_found = fillType_out1;
                                                            found4_1 = true;
                                                        end;
                                                    end;
                                                end;
                                                for fillType_out2,isAccepted in pairs(object.storages[1].fillTypes) do
                                                    local filltypename_out2 = g_fillTypeManager.indexToName[fillType_out2];
                                                    if filltypename_out2 == ftm.out2 then
                                                        if object.storages[1].fillLevels[fillType_in] > (ftm.litersPerMin * ftm.percentage_in4 / 100) then
                                                            plus4 = (ftm.litersPerMin * ftm.percentage_in4 / 100);
                                                            plus4_low = false;
                                                        else
                                                            plus4 =  object.storages[1].fillLevels[fillType_in];
                                                            plus4_low = true;
                                                        end;
                                                        out2 = (object.storages[1].fillLevels[fillType_out2] + (ftm.litersPerMin) * ftm.percentage_out2 / 100);
                                                        if out2 <= ftm.capacityPerFillType then
                                                            fillType_out2_found = fillType_out2;
                                                            found3_2 = true;
                                                        end;
                                                    end;
                                                end;
                                            end;
                                        end;
                                    end;
                                    if fillType_out2_found ~= "" then
                                        if found4_1 and found4_2 then 
                                            found4 = true;
                                            break;
                                        end;
                                    else
                                        if found4_1 then 
                                            found4 = true;
                                            break;
                                        end;
                                    end;
                                end;


                                if ( found1 == true and found2 == false and in2 == false and found3 == false and in3 == false and found4 == false and in4 == false ) or 
                                    ( found1 == true and found2 == true and found3 == false and in3 == false  and found4 == false and in4 == false ) or
                                    ( found1 and found2 and found3 and found4 == false and in4 == false ) or 
                                    ( found1 and found2 and found3 and found4 ) then
                                    for f,SoundId in pairs(ftm.SoundIds) do
                                    setVisibility(SoundId,true);
                                end
                                else
                                    for f,SoundId in pairs(ftm.SoundIds) do
                                        setVisibility(SoundId,false);
                                    end
                                end

                                if found1 == true and found2 == false and in2 == false and found3 == false and in3 == false and found4 == false and in4 == false then
                                    filltypename_in1  = g_fillTypeManager.indexToName[fillType_in_found1];
                                    filltypename_out1  = g_fillTypeManager.indexToName[fillType_out1_found];
                                    filltypename_out2  = g_fillTypeManager.indexToName[fillType_out2_found];

                                    object.storages[1].fillLevels[fillType_out1_found] = object.storages[1].fillLevels[fillType_out1_found] + (plus1 * ftm.percentage_out1 / 100);
                                    if fillType_out2_found ~= "" then
                                        object.storages[1].fillLevels[fillType_out2_found] = object.storages[1].fillLevels[fillType_out2_found] + (plus1 * ftm.percentage_out2 / 100);
                                    end;
                                    object.storages[1].fillLevels[fillType_in_found1] = object.storages[1].fillLevels[fillType_in_found1] - plus1;
                                    ftm.summe_in1 = ftm.summe_in1 - plus1
                                    if ftm.display_out1 ~= nil then
                                        ftm.display_out1:setValue(object.storages[1].fillLevels[fillType_out1_found])
                                    end
                                    if ftm.display_out2 ~= nil then
                                        ftm.display_out2:setValue(object.storages[1].fillLevels[fillType_out2_found])
                                    end
                                    if ftm.display_in1 ~= nil then
                                        ftm.display_in1:setValue(ftm.summe_in1)
                                    end
                                    if ftm.display2_out1 ~= nil then
                                        ftm.display2_out1:setValue(object.storages[1].fillLevels[fillType_out1_found])
                                    end
                                    if ftm.display2_out2 ~= nil then
                                        ftm.display2_out2:setValue(object.storages[1].fillLevels[fillType_out2_found])
                                    end
                                    if ftm.display2_in1 ~= nil then
                                        ftm.display2_in1:setValue(ftm.summe_in1)
                                    end
                                    if ftm.message then
                                        if fillType_out2_found ~= "" then
                                            print(ftm.storename .. " fillType_in1 " .. filltypename_in1 .. " fillLevels " .. math.floor(object.storages[1].fillLevels[fillType_in_found1]) .. "  fillType_out1 " .. filltypename_out1 .. " " .. math.floor(object.storages[1].fillLevels[fillType_out1_found]) .. "  fillType_out2 " .. filltypename_out2 .. " " .. math.floor(object.storages[1].fillLevels[fillType_out2_found]));
                                        else
                                        print(ftm.storename .. " fillType_in1 " .. filltypename_in1 .. " fillLevels " .. math.floor(object.storages[1].fillLevels[fillType_in_found1]) .. "  fillType_out1 " .. filltypename_out1 .. " " .. math.floor(object.storages[1].fillLevels[fillType_out1_found]));
                                        end;
                                    end;
                                end;

                                if found1 == true and found2 == true and found3 == false and in3 == false  and found4 == false and in4 == false then
                                    filltypename_in1  = g_fillTypeManager.indexToName[fillType_in_found1];
                                    filltypename_in2  = g_fillTypeManager.indexToName[fillType_in_found2];
                                    filltypename_out1  = g_fillTypeManager.indexToName[fillType_out1_found];
                                    if plus1_low then
                                    plus2 = plus2 * (plus1 * 100 / (ftm.litersPerMin * ftm.percentage_in1 / 100)) / 100;
                                    end;
                                    if plus2_low then
                                        plus1 = plus1 * (plus2 * 100 / (ftm.litersPerMin * ftm.percentage_in2 / 100)) / 100;
                                    end;

                                    object.storages[1].fillLevels[fillType_out1_found] = object.storages[1].fillLevels[fillType_out1_found] + ((plus1 + plus2) * ftm.percentage_out1 / 100);
                                    if fillType_out2_found ~= "" then
                                        object.storages[1].fillLevels[fillType_out2_found] = object.storages[1].fillLevels[fillType_out2_found] + ((plus1 + plus2) * ftm.percentage_out2 / 100);
                                    end;
                                    object.storages[1].fillLevels[fillType_in_found1] = object.storages[1].fillLevels[fillType_in_found1] - plus1;
                                    object.storages[1].fillLevels[fillType_in_found2] = object.storages[1].fillLevels[fillType_in_found2] - plus2;
                                    ftm.summe_in1 = ftm.summe_in1 - plus1
                                    ftm.summe_in2 = ftm.summe_in2 - plus2
                                    if ftm.display_out1 ~= nil then
                                        ftm.display_out1:setValue(object.storages[1].fillLevels[fillType_out1_found])
                                    end
                                    if ftm.display_out2 ~= nil then
                                        ftm.display_out2:setValue(object.storages[1].fillLevels[fillType_out2_found])
                                    end
                                    if ftm.display_in1 ~= nil then
                                        ftm.display_in1:setValue(ftm.summe_in1)
                                    end
                                    if ftm.display_in2 ~= nil then
                                        ftm.display_in2:setValue(ftm.summe_in2)
                                    end
                                    if ftm.display2_out1 ~= nil then
                                        ftm.display2_out1:setValue(object.storages[1].fillLevels[fillType_out1_found])
                                    end
                                    if ftm.display2_out2 ~= nil then
                                        ftm.display2_out2:setValue(object.storages[1].fillLevels[fillType_out2_found])
                                    end
                                    if ftm.display2_in1 ~= nil then
                                        ftm.display2_in1:setValue(ftm.summe_in1)
                                    end
                                    if ftm.display2_in2 ~= nil then
                                        ftm.display2_in2:setValue(ftm.summe_in2)
                                    end
                                    if ftm.message then
                                        if fillType_out2_found ~= "" then 
                                            print(ftm.storename .. " fillType_in1 " .. filltypename_in1 .. " fillLevels " .. math.floor(object.storages[1].fillLevels[fillType_in_found1]) .. " fillType_in2 " .. filltypename_in2 .. " " .. math.floor(object.storages[1].fillLevels[fillType_in_found2]) .. "  fillType_out1 " .. filltypename_out1 .. " " .. math.floor(object.storages[1].fillLevels[fillType_out1_found]) .. "  fillType_out2 " .. filltypename_out2 .. " " .. math.floor(object.storages[1].fillLevels[fillType_out2_found]));
                                        else
                                            print(ftm.storename .. " fillType_in1 " .. filltypename_in1 .. " fillLevels " .. math.floor(object.storages[1].fillLevels[fillType_in_found1]) .. " fillType_in2 " .. filltypename_in2 .. " " .. math.floor(object.storages[1].fillLevels[fillType_in_found2]) .. "  fillType_out1 " .. filltypename_out1 .. " " .. math.floor(object.storages[1].fillLevels[fillType_out1_found]));
                                        end;
                                    end;
                                end;

                                if found1 and found2 and found3 and found4 == false and in4 == false then
                                    filltypename_in1  = g_fillTypeManager.indexToName[fillType_in_found1];
                                    filltypename_in2  = g_fillTypeManager.indexToName[fillType_in_found2];
                                    filltypename_in3  = g_fillTypeManager.indexToName[fillType_in_found3];
                                    filltypename_out1  = g_fillTypeManager.indexToName[fillType_out1_found];
                                    if plus1_low then
                                        plus2 = plus2 * (plus1 * 100 / (ftm.litersPerMin * ftm.percentage_in1 / 100)) / 100;
                                        plus3 = plus3 * (plus1 * 100 / (ftm.litersPerMin * ftm.percentage_in1 / 100)) / 100;
                                    end;
                                    if plus2_low then
                                        plus1 = plus1 * (plus2 * 100 / (ftm.litersPerMin * ftm.percentage_in2 / 100)) / 100;
                                        plus3 = plus3 * (plus2 * 100 / (ftm.litersPerMin * ftm.percentage_in2 / 100)) / 100;
                                    end;
                                    if plus3_low then
                                        plus1 = plus1 * (plus3 * 100 / (ftm.litersPerMin * ftm.percentage_in3 / 100)) / 100;
                                        plus2 = plus2 * (plus3 * 100 / (ftm.litersPerMin * ftm.percentage_in3 / 100)) / 100;
                                    end;
                                    object.storages[1].fillLevels[fillType_out1_found] = object.storages[1].fillLevels[fillType_out1_found] + ((plus1 + plus2 + plus3) * ftm.percentage_out1 / 100);
                                    if fillType_out2_found ~= "" then
                                        object.storages[1].fillLevels[fillType_out2_found] = object.storages[1].fillLevels[fillType_out2_found] + ((plus1 + plus2 + plus3) * ftm.percentage_out2 / 100);
                                    end;

                                    object.storages[1].fillLevels[fillType_in_found1] = object.storages[1].fillLevels[fillType_in_found1] - plus1;
                                    object.storages[1].fillLevels[fillType_in_found2] = object.storages[1].fillLevels[fillType_in_found2] - plus2;
                                    object.storages[1].fillLevels[fillType_in_found3] = object.storages[1].fillLevels[fillType_in_found3] - plus3;

                                    ftm.summe_in1 = ftm.summe_in1 - plus1
                                    ftm.summe_in2 = ftm.summe_in2 - plus2
                                    ftm.summe_in3 = ftm.summe_in3 - plus3
                                    if ftm.display_out1 ~= nil then
                                        ftm.display_out1:setValue(object.storages[1].fillLevels[fillType_out1_found])
                                    end
                                    if ftm.display_out2 ~= nil then
                                        ftm.display_out2:setValue(object.storages[1].fillLevels[fillType_out2_found])
                                    end
                                    if ftm.display_in1 ~= nil then
                                        ftm.display_in1:setValue(ftm.summe_in1)
                                    end
                                    if ftm.display_in2 ~= nil then
                                        ftm.display_in2:setValue(ftm.summe_in2)
                                    end
                                    if ftm.display_in3 ~= nil then
                                        ftm.display_in3:setValue(ftm.summe_in3)
                                    end
                                    if ftm.display2_out1 ~= nil then
                                        ftm.display2_out1:setValue(object.storages[1].fillLevels[fillType_out1_found])
                                    end
                                    if ftm.display2_out2 ~= nil then
                                        ftm.display2_out2:setValue(object.storages[1].fillLevels[fillType_out2_found])
                                    end
                                    if ftm.display2_in1 ~= nil then
                                        ftm.display2_in1:setValue(ftm.summe_in1)
                                    end
                                    if ftm.display2_in2 ~= nil then
                                        ftm.display2_in2:setValue(ftm.summe_in2)
                                    end
                                    if ftm.display2_in3 ~= nil then
                                        ftm.display2_in3:setValue(ftm.summe_in3)
                                    end
                                    if ftm.message then
                                        if fillType_out2_found ~= "" then
                                            print(ftm.storename .. " fillType_in1 " .. filltypename_in1 .. " fillLevels " .. math.floor(object.storages[1].fillLevels[fillType_in_found1]) .. " fillType_in2 " .. filltypename_in2 .. " " .. math.floor(object.storages[1].fillLevels[fillType_in_found2])  .. " fillType_in3 " .. filltypename_in3 .. " " .. math.floor(object.storages[1].fillLevels[fillType_in_found3]) .. "  fillType_out1 " .. filltypename_out1 .. " " .. math.floor(object.storages[1].fillLevels[fillType_out1_found]) .. "  fillType_out2 " .. filltypename_out2 .. " " .. math.floor(object.storages[1].fillLevels[fillType_out2_found]));
                                        else
                                            print(ftm.storename .. " fillType_in1 " .. filltypename_in1 .. " fillLevels " .. math.floor(object.storages[1].fillLevels[fillType_in_found1]) .. " fillType_in2 " .. filltypename_in2 .. " " .. math.floor(object.storages[1].fillLevels[fillType_in_found2])  .. " fillType_in3 " .. filltypename_in3 .. " " .. math.floor(object.storages[1].fillLevels[fillType_in_found3]) .. "  fillType_out1 " .. filltypename_out1 .. " " .. math.floor(object.storages[1].fillLevels[fillType_out1_found]));
                                        end;
                                    end;
                                end;

                                if found1 and found2 and found3 and found4 then
                                    filltypename_in1  = g_fillTypeManager.indexToName[fillType_in_found1];
                                    filltypename_in2  = g_fillTypeManager.indexToName[fillType_in_found2];
                                    filltypename_in3  = g_fillTypeManager.indexToName[fillType_in_found3];
                                    filltypename_in4  = g_fillTypeManager.indexToName[fillType_in_found4];
                                    filltypename_out1  = g_fillTypeManager.indexToName[fillType_out1_found];
                                    if plus1_low then
                                        plus2 = plus2 * (plus1 * 100 / (ftm.litersPerMin * ftm.percentage_in1 / 100)) / 100;
                                        plus3 = plus3 * (plus1 * 100 / (ftm.litersPerMin * ftm.percentage_in1 / 100)) / 100;
                                        plus4 = plus4 * (plus1 * 100 / (ftm.litersPerMin * ftm.percentage_in1 / 100)) / 100;
                                    end;
                                    if plus2_low then
                                        plus1 = plus1 * (plus2 * 100 / (ftm.litersPerMin * ftm.percentage_in2 / 100)) / 100;
                                        plus3 = plus3 * (plus2 * 100 / (ftm.litersPerMin * ftm.percentage_in2 / 100)) / 100;
                                        plus4 = plus4 * (plus2 * 100 / (ftm.litersPerMin * ftm.percentage_in2 / 100)) / 100;
                                    end;
                                    if plus3_low then
                                        plus1 = plus1 * (plus3 * 100 / (ftm.litersPerMin * ftm.percentage_in3 / 100)) / 100;
                                        plus2 = plus2 * (plus3 * 100 / (ftm.litersPerMin * ftm.percentage_in3 / 100)) / 100;
                                        plus4 = plus4 * (plus4 * 100 / (ftm.litersPerMin * ftm.percentage_in3 / 100)) / 100;
                                    end;
                                    if plus4_low then
                                        plus1 = plus1 * (plus3 * 100 / (ftm.litersPerMin * ftm.percentage_in4 / 100)) / 100;
                                        plus2 = plus2 * (plus3 * 100 / (ftm.litersPerMin * ftm.percentage_in4 / 100)) / 100;
                                        plus3 = plus3 * (plus3 * 100 / (ftm.litersPerMin * ftm.percentage_in4 / 100)) / 100;
                                    end;
                                    object.storages[1].fillLevels[fillType_out1_found] = object.storages[1].fillLevels[fillType_out1_found] + ((plus1 + plus2 + plus3 + plus4) * ftm.percentage_out1 / 100);
                                    if fillType_out2_found ~= "" then
                                        object.storages[1].fillLevels[fillType_out2_found] = object.storages[1].fillLevels[fillType_out2_found] + ((plus1 + plus2 + plus3 + plus4) * ftm.percentage_out2 / 100);
                                    end;

                                    object.storages[1].fillLevels[fillType_in_found1] = object.storages[1].fillLevels[fillType_in_found1] - plus1;
                                    object.storages[1].fillLevels[fillType_in_found2] = object.storages[1].fillLevels[fillType_in_found2] - plus2;
                                    object.storages[1].fillLevels[fillType_in_found3] = object.storages[1].fillLevels[fillType_in_found3] - plus3;
                                    object.storages[1].fillLevels[fillType_in_found4] = object.storages[1].fillLevels[fillType_in_found4] - plus4;
                                    ftm.summe_in1 = ftm.summe_in1 - plus1
                                    ftm.summe_in2 = ftm.summe_in2 - plus2
                                    ftm.summe_in3 = ftm.summe_in3 - plus3
                                    ftm.summe_in4 = ftm.summe_in4 - plus4
                                    if ftm.display_out1 ~= nil then
                                        ftm.display_out1:setValue(object.storages[1].fillLevels[fillType_out1_found])
                                    end
                                    if ftm.display_out2 ~= nil then
                                        ftm.display_out2:setValue(object.storages[1].fillLevels[fillType_out2_found])
                                    end
                                    if ftm.display_in1 ~= nil then
                                        ftm.display_in1:setValue(ftm.summe_in1)
                                    end
                                    if ftm.display_in2 ~= nil then
                                        ftm.display_in2:setValue(ftm.summe_in2)
                                    end
                                    if ftm.display_in3 ~= nil then
                                        ftm.display_in3:setValue(ftm.summe_in3)
                                    end
                                    if ftm.display_in4 ~= nil then
                                        ftm.display_in4:setValue(ftm.summe_in4)
                                    end
                                    if ftm.display2_out1 ~= nil then
                                        ftm.display2_out1:setValue(object.storages[1].fillLevels[fillType_out1_found])
                                    end
                                    if ftm.display2_out2 ~= nil then
                                        ftm.display2_out2:setValue(object.storages[1].fillLevels[fillType_out2_found])
                                    end
                                    if ftm.display2_in1 ~= nil then
                                        ftm.display2_in1:setValue(ftm.summe_in1)
                                    end
                                    if ftm.display2_in2 ~= nil then
                                        ftm.display2_in2:setValue(ftm.summe_in2)
                                    end
                                    if ftm.display2_in3 ~= nil then
                                        ftm.display2_in3:setValue(ftm.summe_in3)
                                    end
                                    if ftm.display2_in4 ~= nil then
                                        ftm.display2_in4:setValue(ftm.summe_in4)
                                    end
                                    if ftm.message then
                                        if fillType_out2_found ~= "" then
                                            print(ftm.storename .. " fillType_in1 " .. filltypename_in1 .. " fillLevels " .. math.floor(object.storages[1].fillLevels[fillType_in_found1]) .. " fillType_in2 " .. filltypename_in2 .. " " .. math.floor(object.storages[1].fillLevels[fillType_in_found2])  .. " fillType_in3 " .. filltypename_in3 .. " " .. math.floor(object.storages[1].fillLevels[fillType_in_found3])  .. " fillType_in4 " .. filltypename_in4 .. " " .. math.floor(object.storages[1].fillLevels[fillType_in_found4]) .. "  fillType_out1 " .. filltypename_out1 .. " " .. math.floor(object.storages[1].fillLevels[fillType_out1_found]) .. "  fillType_out2 " .. filltypename_out2 .. " " .. math.floor(object.storages[1].fillLevels[fillType_out2_found]));
                                        else
                                            print(ftm.storename .. " fillType_in1 " .. filltypename_in1 .. " fillLevels " .. math.floor(object.storages[1].fillLevels[fillType_in_found1]) .. " fillType_in2 " .. filltypename_in2 .. " " .. math.floor(object.storages[1].fillLevels[fillType_in_found2])  .. " fillType_in3 " .. filltypename_in3 .. " " .. math.floor(object.storages[1].fillLevels[fillType_in_found3])  .. " fillType_in4 " .. filltypename_in4 .. " " .. math.floor(object.storages[1].fillLevels[fillType_in_found4]) .. "  fillType_out1 " .. filltypename_out1 .. " " .. math.floor(object.storages[1].fillLevels[fillType_out1_found]));
                                        end;
                                    end;
                                end;

                            end;
                        end;
                    end
                end;
            end;
        end;
    end;
end; 

function FillTypeMover:draw()

end