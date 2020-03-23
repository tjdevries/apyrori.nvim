--- apyrori
-- A module that's based on the pun of a priori
--  We'll just know where you want to import from

package.loaded['luvjob'] = nil
package.loaded['apyrori'] = nil

local luvjob = require('luvjob')

local vim = vim
local api = vim.api

local function string_split(self, sep, max_count)
  sep = sep or ":"

  local fields =  {}
  local pattern = string.format("([^%s]+)", sep)

  self:gsub(pattern, function(c) fields[#fields+1] = c end, max_count)

  return fields
end

local apyrori = {}

function apyrori.find_matches(text, directory)
  local command = string.format('rg --vimgrep "import %s"', text)

  if directory == nil then
    directory = vim.fn.getcwd()
  end

  local results = {}
  local counts = {}

  local on_read = function(err, data)
    if err then
      vim.api.nvim_err_writeln("APYRORI ERROR: " .. vim.inspect(err))
      return
    end

    if data == nil then
      return
    end

    for _, line in ipairs(vim.fn.split(data, "\n")) do
      table.insert(results, line)
    end
  end

  local grepper = luvjob:new({
    command = "rg",
    args = {"--vimgrep", "-w", string.format("import %s", text)},
    cwd = directory,
    on_stdout = on_read,
    on_stderr = on_read,
    on_exit = function(...)
      print('results:', vim.inspect(results))
      for _, result in ipairs(results) do
        local split_result = string_split(result, ":", 4)
        local value = split_result[4]

        if counts[value] == nil then
          counts[value] = 0
        end

        counts[value] = counts[value] + 1
      end
    end,
  })

  grepper:start()
  grepper:wait()

  return counts
end

function apyrori.get_most_likely_match(text, directory)
  local counts = apyrori.find_matches(text, directory)

  local max_val, key = -math.huge
  for k, v in pairs(counts) do
    if v > max_val then
      max_val, key = v, k
    end
  end

  return key
end

function apyrori.insert_match(text, directory)
  local most_likely_match = apyrori.get_most_likely_match(text, directory)

  vim.api.nvim_buf_set_lines(0, 0, 0, false, {most_likely_match})
end


return apyrori
