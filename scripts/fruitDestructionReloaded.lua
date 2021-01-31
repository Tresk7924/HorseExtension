function onLoadMapFinished(mission, node)
	local modififruits = {"WHEAT","BARLEY","OAT","RYE","SPELT","TRITICALE","SOYBEAN","CANOLA"}
	g_currentMission.fruitDestructionReloadedlist = {}
	local fruitDestructionReloadedlist = {}
    for index, fruit in pairs(g_currentMission.fruits) do
		for _, fruitname in pairs(modififruits) do
			if g_fruitTypeManager:getFruitTypeByIndex(index).name == fruitname then
				fruitDestructionReloadedlist[index]=fruit
				

			end
		end
	end
	g_currentMission.fruitDestructionReloadedlist = modififruits
	g_currentMission.densityMapModifiers.updateWheelDestructionArea.newfilter=false
end

function updateWheelDestructionArea(x0,z0, x1,z1, x2,z2)
	local modifiers = g_currentMission.densityMapModifiers.updateWheelDestructionArea
	local modifier = modifiers.modifier
	if modifiers.filter3 == nil then
		modifiers.filter3 = DensityMapFilter:new(modifier)
	end
	local newfilter = g_currentMission.densityMapModifiers.updateWheelDestructionArea.newfilter
	local multiModifier = modifiers.multiModifier
	local filter3 = modifiers.filter3
	if multiModifier ~=nil and not newfilter then
		for index, fruit in pairs(g_currentMission.fruits) do
			for _, fruitname in pairs(g_currentMission.fruitDestructionReloadedlist) do						
				local fruitDesc = g_fruitTypeManager:getFruitTypeByIndex(index)
				if fruitDesc.name == fruitname then	
				if fruitDesc.destruction.onlyOnField then
					onlyOnFieldFilter = modifiers.filter2
				end
					local destruction = {}
					destruction.filterStart2 = 3
					destruction.filterEnd2 = 4
					destruction.state2 = 2 
					modifier:resetDensityMapAndChannels(fruit.id, fruitDesc.startStateChannel, fruitDesc.numStateChannels)
					filter3:resetDensityMapAndChannels(fruit.id, fruitDesc.startStateChannel, fruitDesc.numStateChannels)
					filter3:setValueCompareParams("between", destruction.filterStart2, destruction.filterEnd2)
					multiModifier:addExecuteSet(destruction.state2, modifier, filter3, nil)
					g_currentMission.densityMapModifiers.updateWheelDestructionArea.newfilter = true
				end	
			end		
		end
	end
end

function updateLimeArea(startWorldX,SuperFunc, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ, groundType)
	
	local numPixels, totalNumPixels = SuperFunc(startWorldX, startWorldZ, widthWorldX, widthWorldZ, heightWorldX, heightWorldZ, groundType)
	local modifiers = g_currentMission.densityMapModifiers.updateLimeArea
	local modifier = modifiers.modifier
	local filter1 = modifiers.filter1
	local filter2 = modifiers.filter2
	local detailId = g_currentMission.terrainDetailId
	local limeCounterFirstChannel = g_currentMission.limeCounterFirstChannel
	local limeCounterNumChannels = g_currentMission.limeCounterNumChannels
	local limeCounterMaxValue = g_currentMission.limeCounterMaxValue
	for index, entry in pairs(g_currentMission.fruits) do
		local desc = g_fruitTypeManager:getFruitTypeByIndex(index)

		if desc.weed == nil then

			filter1:resetDensityMapAndChannels(entry.id, desc.startStateChannel, desc.numStateChannels)
			filter1:setValueCompareParams("equal", desc.cutState + 2)
			modifier:resetDensityMapAndChannels(detailId, g_currentMission.sprayFirstChannel, g_currentMission.sprayNumChannels)
			
			local _, _, _ = modifier:executeSet(groundType, filter1)
			
			modifier:resetDensityMapAndChannels(detailId, limeCounterFirstChannel, limeCounterNumChannels)
			
			local _, numP, _ = modifier:executeSet(limeCounterMaxValue, filter1, filter2)
			numPixels = numPixels + numP
		end
	end

	return numPixels, totalNumPixels
end


FSBaseMission.loadMapFinished = Utils.appendedFunction(FSBaseMission.loadMapFinished, onLoadMapFinished)
FSDensityMapUtil.updateWheelDestructionArea = Utils.prependedFunction(FSDensityMapUtil.updateWheelDestructionArea, updateWheelDestructionArea)
FSDensityMapUtil.updateLimeArea = Utils.overwrittenFunction(FSDensityMapUtil.updateLimeArea, updateLimeArea)