local hasDoneShinySetup = false

-- Try calling `pandoc.pipe('shinylive', ...)` and if it fails, print a message
-- about installing shinylive python package.
function callPythonShiny(args)
  local res
  local status, err = pcall(
    function()
      res = pandoc.pipe("shiny", args, "")
    end
  )

  if not status then
    print(err)
    error("Error running 'shiny' command. Perhaps you need to install the 'shiny' Python package?")
  end

  return res
end



function getShinyDeps()
  -- Relative path from the current page to the root of the site. This is needed
  -- to find out where shinylive-sw.js is, relative to the current page.
  -- if quarto.project.offset == nil then
  --   error("The shiny extension must be used in a Quarto project directory (with a _quarto.yml file).")
  -- end
  local depJson = callPythonShiny(
    { "get-shiny-deps" }
  )

  local deps = quarto.json.decode(depJson)
  return deps
end



-- Do one-time setup.
function ensureShinySetup()
  if hasDoneShinySetup then
    return
  end
  hasDoneShinySetup = true


  local baseDeps = getShinyDeps()
  for idx, dep in ipairs(baseDeps) do
    quarto.doc.add_html_dependency(dep)
  end
end

ensureShinySetup()

-- -- Reformat all heading text
-- function Header(el)
--   el.content = pandoc.Emph(el.content)
--   return el
-- end

-- function CodeBlock(el)
--   -- el.text = string.upper(el.text)
--   el.text = "--- Modified by extension ---\n" .. el.text
--   return el
-- end
