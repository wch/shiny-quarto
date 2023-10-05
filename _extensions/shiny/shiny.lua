local hasDoneShinySetup = false

-- Try calling `pandoc.pipe('shiny', ...)` and if it fails, print a message
-- about installing shiny.
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


codeCells = {
  schema_version = 1,
  cells = {},
  html_file = ""
}

function CodeBlock(el)
  if el.attr.classes:includes("python") and el.attr.classes:includes("cell-code") then
    table.insert(codeCells.cells, { classes = el.attr.classes, text = el.text })
  end

  if el.attr.classes:includes("hidden") then
    return nil
  end

  return el
end


function Pandoc(doc)
  ensureShinySetup()

  codeCells["html_file"] = pandoc.path.split_extension(
    pandoc.path.filename(quarto.doc.output_file)
  ) .. ".html"

  -- Write the code cells to a temporary file.
  codeCellsOutfile = pandoc.path.split_extension(quarto.doc.input_file) .. "-cells.tmp.json"
  local file = io.open(codeCellsOutfile, "w")
  if file == nil then
    error("Error opening file: " .. codeCellsOutfile .. " for writing.")
  end
  file:write(quarto.json.encode(codeCells))
  file:close()

  -- Convert the json file to an app.py by calling `shiny convert`.
  callPythonShiny(
    { "convert", codeCellsOutfile }
  )

  -- os.remove(codeCellsOutfile)
end
