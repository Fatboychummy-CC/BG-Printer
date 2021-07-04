local BG = require "backgroundSystem"

if ... then -- if called with arguments...
  local args = table.pack(...)
  os.queueEvent("CHATTER_MESSAGE", string.format("> %s: %s", "You", table.concat(args, ' ')))
else -- otherwise run the background program
  -- also protect against running multiple times.
  if _G._BGRUNNER and _G._BGRUNNER.RUNNING then
    error("Already running, unless you meant to do " .. shell.getRunningProgram() .. " <message> ?")
  end

  _G._BGRUNNER = {}
  _G._BGRUNNER.RUNNING = true


  local chats = { -- chats with "%" in them require the user to say something before it will continue.
    "Hello!",
    "Hi!",
    "How are you today?",
    "I'm good, thanks!",
    "%Glad to hear it!", -- "I'm good as well!"
    "%Oh I'm just fucking dying", -- "What are you guys doing?"
    "That's not good, why are you dying?",
    "Oh you know, trying to code this weird thing for ComputerCraft",
    "Ahh. I see.",
    "Anyways, I've gotta go.",
    "Yeah, me too!",
    "%See ya!" -- "Bye!"
  }
  local names = {
    "Johnny",
    "Billy"
  }

  local charsWritePerSecond = 9
  local charsReadPerSecond = 5

  local function chatterino()
    BG.PrintMessage("> You joined the chat.")
    BG.PrintMessage("> There are currently 2 users online:")
    BG.PrintMessage(">   - Johnny")
    BG.PrintMessage(">   - Billy")
    os.sleep(3)

    local i = 0
    parallel.waitForAny(
      function()
        while true do
          i = i + 1
          local chat = chats[i]
          local n

          if chat then
            chat, n = chat:gsub("%%", "") -- Check if we need to wait for the user to say something before continuing.
            if n > 0 then
              -- wait for user to chat.
              os.pullEvent("CHATTER_MESSAGE")
            end
            os.sleep(#(chats[i - 1] or "") / charsReadPerSecond)
            os.sleep(#chat / charsWritePerSecond)
            BG.PrintMessage(string.format("> %s: %s", names[i % 2 + 1], chat))
          else
            os.sleep(0.5)
            BG.PrintMessage("> Johnny left the chat.")
            os.sleep(0.5)
            BG.PrintMessage("> Billy left the chat.")
            return
          end
        end
      end,
      function()
        while true do
          local _, message = os.pullEvent("CHATTER_MESSAGE")
          BG.PrintMessage(message)
        end
      end
    )
  end


  BG.Setup()
  pcall(BG.Run, chatterino)
  _G._BGRUNNER.RUNNING = false
end
