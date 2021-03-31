function love.conf(t)
    t.version = "11.3"                  -- The LÖVE version this game was made for (string)
    t.console = true                    -- Attach a console (boolean, Windows only)
    t.audio.mixwithsystem = true        -- Keep background music playing when opening LOVE (boolean, iOS and Android only)
 
    t.window.title = "Pong!"            -- The window title (string)
    t.window.icon = "icon.png"          -- Filepath to an image to use as the window's icon (string)
end