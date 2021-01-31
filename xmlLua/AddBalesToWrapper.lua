--[[
AddBalesToWrapper
Specialization for adding bales to bale wrappers
Author:     Ifko[nator] edited by bgo1973
Date:       22.02.2020
Version:    2.4
History:    v1.0 @02.06.2019 - initial implemation in FS 19
            v2.0 @07.11.2019 - read fill types out from modDesc, so you can easy add more fill types
            v2.1 @25.01.2020 - add support for non windrow fill types (isWindrow="false")
            v2.2 @26.01.2020 - add possibility to load extra roundbales for the Kuhn FBP 3135 (kuhnBaleFilename="")
            v2.3 @22.02.2020 - add possibility to load extra roundbales for the Claas Rollant 455 Uniwrap (claasBaleFilename="")
            v2.4 @05.06.2020 - add possibility to load extra roundbales for the Anderson (except x tractor) and Kverneland/Vicon DLC
]]
AddBalesToWrapper = {};
AddBalesToWrapper.currentModDirectory = g_currentModDirectory;
AddBalesToWrapper.debugPriority = 0;

local function printError(errorMessage, isWarning, isInfo)
    local prefix = "::ERROR:: ";

    if isWarning then
        prefix = "::WARNING:: ";
    elseif isInfo then
        prefix = "::INFO:: ";
    end;

    print(prefix .. "from the AddBalesToWrapper.lua: " .. tostring(errorMessage));
end;

local function printDebug(debugMessage, priority, addString)
    if AddBalesToWrapper.debugPriority >= priority then
        local prefix = "";

        if addString then
            prefix = "::DEBUG:: from the AddBalesToWrapper.lua: ";
        end;

        print(prefix .. tostring(debugMessage));
    end;
end;

function AddBalesToWrapper.prerequisitesPresent(specializations)
    return SpecializationUtil.hasSpecialization(BaleWrapper, specializations);
end;

function AddBalesToWrapper.registerEventListeners(vehicleType)
    local functionNames = {
        "onLoad"
    };

    for _, functionName in ipairs(functionNames) do
        SpecializationUtil.registerEventListener(vehicleType, functionName, AddBalesToWrapper);
    end;
end;

function AddBalesToWrapper:onLoad(savegame)
    local modDesc = loadXMLFile("modDesc", AddBalesToWrapper.currentModDirectory .. "modDesc.xml");

    AddBalesToWrapper.debugPriority = Utils.getNoNil(getXMLInt(modDesc, "modDesc.addBalesToWrapper#debugPriority"), AddBalesToWrapper.debugPriority);

    local specBaleWarpper = self.spec_baleWrapper;
    local baleNumber = 0;

    while true do
        local baleKey = "modDesc.addBalesToWrapper.addBale(" .. tostring(baleNumber) .. ")";

        if not hasXMLProperty(modDesc, baleKey) then
            break;
        end;

        local fillType = Utils.getNoNil(getXMLString(modDesc, baleKey .. "#fillType"), "");
        local isWindrow = Utils.getNoNil(getXMLBool(modDesc, baleKey .. "#isWindrow"), true);

        if fillType ~= "" then
            if not string.find(fillType, "_windrow") and isWindrow then
                fillType = fillType .. "_windrow";
            end;

            if g_fillTypeManager:getFillTypeIndexByName(fillType) ~= nil then
                local baleFilename = Utils.getNoNil(getXMLString(modDesc, baleKey .. "#baleFilename"), "");
                local kuhnBaleFilename = Utils.getNoNil(getXMLString(modDesc, baleKey .. "#kuhnBaleFilename"), "");
                local claasBaleFilename = Utils.getNoNil(getXMLString(modDesc, baleKey .. "#claasBaleFilename"), "");
                local andersonBaleFilename = Utils.getNoNil(getXMLString(modDesc, baleKey .. "#andersonBaleFilename"), "");
                local viconBaleFilename = Utils.getNoNil(getXMLString(modDesc, baleKey .. "#viconBaleFilename"), "");

                if baleFilename ~= "" then
                    local wrapperBaleFilename = Utils.getFilename(baleFilename, AddBalesToWrapper.currentModDirectory);

                    if fileExists(wrapperBaleFilename) then
                        local fillTypeIndex = g_fillTypeManager:getFillTypeIndexByName(fillType);
                        local fillTypeIndexCheck = g_fillTypeManager:getFillTypeIndexByName("grass_windrow");

                        local isRoundbale = Utils.getNoNil(getXMLBool(modDesc, baleKey .. "#isRoundbale"), false);
                        local minBaleWidth = Utils.getNoNil(getXMLFloat(modDesc, baleKey .. "#minBaleWidth"), 1.1); 
                        local maxBaleWidth = Utils.getNoNil(getXMLFloat(modDesc, baleKey .. "#maxBaleWidth"), 1.3);
                        local minBaleHeight = Utils.getNoNil(getXMLFloat(modDesc, baleKey .. "#minBaleHeight"), 0.75);
                        local maxBaleHeight = Utils.getNoNil(getXMLFloat(modDesc, baleKey .. "#maxBaleHeight"), 0.85);
                        local minBaleLength = Utils.getNoNil(getXMLFloat(modDesc, baleKey .. "#minBaleLength"), 2.35);
                        local maxBaleLength = Utils.getNoNil(getXMLFloat(modDesc, baleKey .. "#maxBaleLength"), 2.45);
                        local minBaleDiameter = Utils.getNoNil(getXMLFloat(modDesc, baleKey .. "#minBaleDiameter"), 1.1); 
                        local maxBaleDiameter = Utils.getNoNil(getXMLFloat(modDesc, baleKey .. "#maxBaleDiameter"), 1.3); 

                        if isRoundbale then
                            if string.find(self.configFileName, "kuhnFBP3135") and kuhnBaleFilename ~= "" then
                                wrapperBaleFilename = Utils.getFilename(kuhnBaleFilename, AddBalesToWrapper.currentModDirectory);

                                printDebug("found Kuhn FBP 3135! Change wrapperBaleFilename to " .. tostring(wrapperBaleFilename), 1, true);
                            end;

                            if string.find(self.configFileName, "rollant455Uniwrap") and claasBaleFilename ~= "" then
                                wrapperBaleFilename = Utils.getFilename(claasBaleFilename, AddBalesToWrapper.currentModDirectory);

                                printDebug("found Claas Rollant 455 Uniwrap! Change wrapperBaleFilename to " .. tostring(wrapperBaleFilename), 1, true);
                            end;

                            if string.find(self.configFileName, "fastbale") and viconBaleFilename ~= "" then
                                wrapperBaleFilename = Utils.getFilename(viconBaleFilename, AddBalesToWrapper.currentModDirectory);

                                printDebug("found Vicon Fastbale! Change wrapperBaleFilename to " .. tostring(wrapperBaleFilename), 1, true);
                            end;

                            if specBaleWarpper.roundBaleWrapper.allowedBaleTypes[fillTypeIndexCheck] ~= nil then
                                specBaleWarpper.roundBaleWrapper.allowedBaleTypes[fillTypeIndex] = {};

                                table.insert(specBaleWarpper.roundBaleWrapper.allowedBaleTypes[fillTypeIndex], {
                                    fillType = fillTypeIndex,
                                    wrapperBaleFilename = wrapperBaleFilename,
                                    minBaleDiameter = minBaleDiameter,
                                    maxBaleDiameter = maxBaleDiameter,
                                    minBaleWidth = minBaleWidth, 
                                    maxBaleWidth = maxBaleWidth
                                });

                                printDebug("added " .. fillType .. " round bale to " .. self.configFileName, 1, true);
                            end;
                        else
                            if specBaleWarpper.squareBaleWrapper.allowedBaleTypes[fillTypeIndexCheck] ~= nil then
                                specBaleWarpper.squareBaleWrapper.allowedBaleTypes[fillTypeIndex] = {};

                                table.insert(specBaleWarpper.squareBaleWrapper.allowedBaleTypes[fillTypeIndex], {
                                    fillType = fillTypeIndex,
                                    wrapperBaleFilename = wrapperBaleFilename,
                                    minBaleWidth = minBaleWidth,
                                    maxBaleWidth = maxBaleWidth,
                                    minBaleHeight = minBaleHeight,
                                    maxBaleHeight = maxBaleHeight,
                                    minBaleLength = minBaleLength,
                                    maxBaleLength = maxBaleLength
                                });

                                printDebug("added " .. fillType .. " square bale to " .. self.configFileName, 1, true);
                            end;
                        end;
                    else
                    printError("The baleFilename '" .. wrapperBaleFilename .. "' for bale number '" .. baleNumber + 1 .. "' does not exists! Skipping this entry!", false, false);
                    end;
                else
                    printError("Missing 'baleFilename' Attribute for bale number '" .. baleNumber + 1 .. "'! Skipping this entry!", false, false);
                end;
            else
                printError("The fillType '" .. fillType .. "' for bale number '" .. baleNumber + 1 .. "' does not exists! Register this fillType first! Skipping this entry!", false, false);
            end;
        else
            printError("Missing 'fillType' Attribute for bale number '" .. baleNumber + 1 .. "'! Skipping this entry!", false, false);
        end;

        baleNumber = baleNumber + 1;
    end;
end;