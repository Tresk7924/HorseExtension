ModMap = {} 
local ModMap_mt = Class(ModMap, Mission00)

function ModMap:new(baseDirectory, customMt, missionCollaborators)
    local mt = customMt
    if mt == nil then
        mt = ModMap_mt
    end
    local self = ModMap:superClass():new(baseDirectory, mt, missionCollaborators)
	
	self.terrainDetailHeightTypeNumChannels = self.terrainDetailHeightTypeNumChannels + 2;

    -- Number of additional channels that are used compared to the original setting (2)
    local numAdditionalAngleChannels = 3 -- Winkel Ch. Boden

    self.terrainDetailAngleNumChannels = self.terrainDetailAngleNumChannels + numAdditionalAngleChannels;
    self.terrainDetailAngleMaxValue = (2^self.terrainDetailAngleNumChannels) - 1;

    self.sprayLevelFirstChannel = self.sprayLevelFirstChannel + numAdditionalAngleChannels;

    self.plowCounterFirstChannel = self.plowCounterFirstChannel + numAdditionalAngleChannels;
    self.limeCounterFirstChannel = self.limeCounterFirstChannel + numAdditionalAngleChannels;

    return self
end