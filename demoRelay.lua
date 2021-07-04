local BG = require "BGPrint"

if ... then -- if called with arguments...
  local args = table.pack(...) -- the user wants to send a message
  os.queueEvent("CHATTER_MESSAGE", string.format("> %s: %s", "You", table.concat(args, ' '))) -- so send it.
else -- otherwise run the background program
  if _G._BGRUNNER and _G._BGRUNNER.RUNNING then -- also protect against running multiple times.
    error("Already running, unless you meant to do " .. shell.getRunningProgram() .. " <message> ?")
  end

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
    -- print fake join message
    BG.PrintMessage("> You joined the chat.")
    BG.PrintMessage("> There are currently 2 users online:")
    BG.PrintMessage(">   - Johnny")
    BG.PrintMessage(">   - Billy")
    os.sleep(3) -- artificial wait to similate people realizing "oh a person joined!"

    local i = 0
    parallel.waitForAny(
      function() -- main function - run the logic of the """AI"""
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

            -- Wait for the amount of time it takes the AI to read the last message
            os.sleep(#(chats[i - 1] or "") / charsReadPerSecond)
            -- Wait for the amount of time it takes the AI to write the next message.
            os.sleep(#chat / charsWritePerSecond)
            -- show the next message
            BG.PrintMessage(string.format("> %s: %s", names[i % 2 + 1], chat))
          else

            -- Once we've gone through all the messages, everyone leaves.
            os.sleep(0.5)
            BG.PrintMessage("> Johnny left the chat.")
            os.sleep(0.5)
            BG.PrintMessage("> Billy left the chat.")
            return
          end
        end
      end,
      function() -- secondary function to print messages from the user.
        while true do
          local _, message = os.pullEvent("CHATTER_MESSAGE")
          BG.PrintMessage(message)
        end
      end
    )
  end


  -- Setup the workspace
  _G._BGRUNNER = {}
  _G._BGRUNNER.RUNNING = true
  BG.Setup()

  -- Run the program
  local ok, err = pcall(BG.Run, chatterino)
  if not ok then
    printError(err)
  end

  -- clean up the workspace.
  _G._BGRUNNER.RUNNING = false
  BG.Clean()
end
