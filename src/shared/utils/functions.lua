SHARED = {
    ---@param self table
    ---@param decimals number
    ---@return integer
    RandomDecimal = function(self, decimals)
        return math.random(
            0 * 10 ^ decimals,
            100 * 10 ^ decimals
        ) / 10 ^ decimals
    end,
}
