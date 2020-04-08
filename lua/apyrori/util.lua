
local util = {}

---
---@param sep string : Optional string separator. Default ":"
---@param max_count number
---@return table
function util.string_split(self, sep, max_count)
  sep = sep or ":"

  local fields =  {}
  local pattern = string.format("([^%s]+)", sep)

  self:gsub(pattern, function(c) fields[#fields+1] = c end, max_count)

  return fields
end


return util
