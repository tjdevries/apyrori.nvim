--- apyrori
-- A module that's based on the pun of a priori
--  We'll just know where you want to import from

package.loaded['luvjob'] = nil
package.loaded['apyrori'] = nil

local luvjob = require('luvjob')
local config_module = require('apyrori.config')

local vim = vim

local function get_max(tbl, key)
  local max_val = nil
  local current_value = nil

  for v, _ in pairs(tbl) do
    if key then
      current_value = key(v)
    else
      current_value = v
    end

    if max_val == nil then
      max_val = current_value
    elseif max_val < current_value then
      max_val = current_value
    end
  end

  return max_val
end


local apyrori = {}

function apyrori.find_matches(text, directory)
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

  local config = config_module.get_default()

  local grepper = luvjob:new({
    command = config.command,
    args = config.args(text),
    cwd = directory,
    on_stdout = on_read,
    on_stderr = on_read,
    on_exit = function(...)
      config.parser(results, counts)
    end,
  })

  grepper:start()
  grepper:wait()

  return counts
end


function apyrori.get_most_likely_match(potential_matches)
  local max_val, key = -math.huge
  for k, v in pairs(potential_matches) do
    if v > max_val then
      max_val, key = v, k
    end
  end

  return key
end

function apyrori.find_and_insert_match(text, directory, choose_most_likely)
  local potential_matches = apyrori.find_matches(text, directory)

  if choose_most_likely == nil then
    choose_most_likely = true
  end

  if choose_most_likely or #potential_matches <= 1 then
    local most_likely_match = apyrori.get_most_likely_match(potential_matches)
    apyrori.insert_match(0, most_likely_match)
  else
    apyrori.choose_match(potential_matches)
  end
end

function apyrori.insert_match(bufnr, text)
  -- TODO: Might want to try and drop this in a better location (considering might have docs at the top)
  -- TODO: If we know that they have, for example, impsort,
  --    we could try and figure out which kind of import it would be and drop it in the right spot
  --    I just tend to let my formatter do that for me though automatically.

  -- HACK: This feels bad to do... since it depends on the cursor, but oh well
  local line_number = vim.fn.search([[^from\|^import]], 'nbW')

  vim.api.nvim_buf_set_lines(bufnr, line_number, line_number, false, {text})
end

function apyrori.choose_match(possible_matches)
  -- TODO: Use my cool floating window stuff, probably need to make a new repo for that
  local buf = vim.fn.nvim_create_buf(false, true)

  local longest_string_len = get_max(possible_matches, string.len)

  local lines = {
    string.rep("=", longest_string_len / 2) .. " Possible Matches " .. string.rep("=", longest_string_len / 2)
  }

  local option_number = 0
  local mapped_options = {}
  for key, freq in pairs(possible_matches) do
    option_number = option_number + 1
    mapped_options[option_number] = key
    table.insert(lines, string.format("%s: (%s) %s", option_number, key, freq))
  end

  vim.fn.nvim_buf_set_lines(buf, 0, 0, false, lines)
  vim.fn.nvim_buf_set_var(buf, 'apyrori_original_buf', vim.fn.nvim_buf_get_number(0))
  vim.fn.nvim_buf_set_var(buf, 'apyrori_possible_matches', mapped_options)

  vim.fn.nvim_buf_set_option(buf, 'buftype', 'prompt')
  vim.fn.prompt_setprompt(buf, 'Option #: ')
  vim.fn.nvim_call_function('apyrori#set_prompt_callback', {buf})

  local opts = {
    relative='cursor',
    width=longest_string_len + 20,
    height=10,
    col=1,
    row=2,
    style='minimal',
  }

  local win = vim.fn.nvim_open_win(buf, 0, opts)

  -- Optionally add the border around the text, to make things nice.
  -- TODO: Make it into a real plugin so other people can use it.
  local has_floating_text, floating_text = pcall(function() return require('custom.floating_text') end)
  local border_win
  if has_floating_text then
    border_win = floating_text.create_window_border(opts)
  end

  vim.fn.nvim_win_set_option(win, 'winhl', 'Normal:MyHighlight')
  vim.fn.nvim_set_current_win(win)

  vim.cmd('autocmd WinLeave <buffer> :call nvim_win_close(0, v:true)')
  if border_win then
    vim.cmd(string.format('autocmd WinLeave <buffer> :call nvim_win_close(%s, v:true)', border_win))
  end
  vim.cmd('startinsert')

  return win
end


function apyrori.prompt_callback(text)
  local possible_matches = vim.fn.nvim_buf_get_var(0, 'apyrori_possible_matches')

  local ok, result = pcall(function() return tonumber(text) end)
  if not ok then
    -- TODO: Warn user that they did this wrong...
    print('Did not work')
  end

  local chosen_match = possible_matches[result]
  if chosen_match == nil then
    print('Chose an invalid value')
  else
    local buf = vim.fn.nvim_buf_get_var(0,'apyrori_original_buf')

    vim.cmd('close')
    apyrori.insert_match(buf, chosen_match)
  end
end


return apyrori
