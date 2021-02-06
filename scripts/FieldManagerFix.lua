--[[
FieldManagerFix.lua
Author:     Ifko[nator]
Date:       22.10.2020
Version:    1.0
History:    v1.0 @22.10.2020 - initial implementation in FS 19
]]
FieldManagerFix = {};
function FieldManagerFix:getFruitIndexForField(superFunc, field)
    if field.fieldGrassMission then
        return FruitType.GRASS;
    end;
    return self.availableFruitTypeIndices[math.random(1, table.getn(self.availableFruitTypeIndices))];
end;
FieldManager.getFruitIndexForField = Utils.overwrittenFunction(FieldManager.getFruitIndexForField, FieldManagerFix.getFruitIndexForField);
addModEventListener(FieldManagerFix);