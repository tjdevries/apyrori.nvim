local config = {}

config._saved = {}
config._current = 'rg'

function config.new(name, values, set_default)
  config._saved[name] = {
    command=values.command,
    args=values.args,
    parser=values.parser,
  }

  if set_default then
    config.set_default(name)
  end
end

function config.get_default()
  return config._saved[config._current]
end

function config.set_default(name)
  config._current = name
end


-- Add & set default rg code
config.new(
  'rg',
  {
    command ='rg',

    args    = function(text)
      return {"--vimgrep", "--type", "py", "-w", string.format("import %s", text)}
    end,

    parser  = function(results)
      local counts = {}

      for _, result in ipairs(results) do
        local split_result = require('apyrori.util').string_split(result, ":", 4)
        local value = split_result[4]

        if value ~= nil then
          if counts[value] == nil then
            counts[value] = 0
          end

          counts[value] = counts[value] + 1
        end
      end

      return counts
    end
  },
  true
)


return config
