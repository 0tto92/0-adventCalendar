FUNCTIONS = {
    ---@param self table
    ---@param lootTable table
    ---@param itemChance integer
    ---@param maxItems table
    ---@return table
    GenerateLoot = function(self, lootTable, itemChance, maxItems)
        local generatedLoot = {}
        if #lootTable < maxItems[2] then
            maxItems[2] = #lootTable
        end

        table.sort(lootTable, function(a, b)
            return a.chance > b.chance
        end)

        local itemCount = math.random(maxItems[1], maxItems[2])
        if not itemChance or SHARED:RandomDecimal(2) >= (itemChance == true and 100.00 or itemChance) then
            return generatedLoot
        end

        for index, data in pairs(lootTable) do
            if SHARED:RandomDecimal(2) <= data.chance then
                local amount = math.random(data.amount[1], data.amount[2])
                generatedLoot[#generatedLoot + 1] = { data.name, amount }
            end

            if #generatedLoot == itemCount then
                break
            end
        end

        if #generatedLoot < itemCount then
            return self:GenerateLoot(lootTable, itemChance, maxItems)
        end

        return generatedLoot
    end,
}
