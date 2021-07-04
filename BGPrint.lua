local expect = require "cc.expect".expect

local module = {}

local w, oldTerm

-- scroll the terminal upwards, but only from the selected line.
local function scrollBackFrom(y)
  local lines = {}
  for i = 2, y do

  end
end

-- Attempt to redirect to an object, then redirect back to the current term.
-- Used for confirming the term object passed is valid.
local function attemptRedirect(termObj)
  local _oldTerm = term.current()

  local ok = pcall(
    function()
      term.redirect(termObj)
    end
  )

  term.redirect(_oldTerm)

  return ok
end

function module.Setup(termObj)
  expect(1, termObj, "table", "nil")
  termObj = termObj or term.current()
  if not attemptRedirect(termObj) then
    error("Invalid argument #1: Expected term object, got whatever the fuck that was.", 2)
  end

  local x, y = termObj.getSize()

  w = window.create(termObj, 1, 1, x, y)

  oldTerm = term.redirect(w)
end

function module.Clean()
  if w then
    w = nil
    term.redirect(old)
    oldTerm = nil
    _G.read = oldRead
  end
end

local function printToWindow(...)
  -- ensure print prints to the proper location.
  local old = term.redirect(w)
  local lines = print(...)
  term.redirect(old)

  return lines
end

function module.PrintMessage(...)
  if not w then error("Call BG.Setup([term_object]) before BG.Run(callback_function)", 2) end
  local args = table.pack(...)

  -- get window information
  local ox, oy = w.getCursorPos()
  local mx, my = w.getSize()
  local oldBlink = w.getCursorBlink()

  -- get the current line.
  local lineText, lineFG, lineBG = w.getLine(oy)

  -- print the data
  w.setCursorPos(1, oy)
  w.clearLine()
  w.setCursorPos(1, oy)
  local linesPrinted = printToWindow(...)

  -- rewrite what was originally there.
  w.setCursorPos(1, (oy + linesPrinted >= my and my or oy + linesPrinted))
  w.blit(lineText, lineFG, lineBG)
  w.setCursorBlink(oldBlink)
  w.setCursorPos(ox, (oy + linesPrinted >= my and my or oy + linesPrinted))

  -- just like print, lets return the amount of lines we printed.
  return linesPrinted
end

function module.Run(runFunction)
  expect(1, runFunction, "function")

  local ok, err = pcall(
    parallel.waitForAny,
    function()
      shell.run("shell")
    end,
    runFunction
  )

  if not ok then
    printError(err)
  end

  error("A main function has stopped.")
end

return module
