-- init.lua

local function log(fmt, ...)
  hs.printf("[hs] " .. fmt, ...)
end

local lastApp = nil

local config = {
  terminalApp = "Ghostty",
  launch = {
    delayBetweenApps = 5,  -- seconds between app launches
    delayForFullscreen = 3,  -- initial wait before trying fullscreen
    windowRetryCount = 20,  -- number of retries
    windowRetryInterval = 0.25  -- seconds between retries
  },
  alertDuration = 2
}

local workspaceApps = {
  "com.microsoft.VSCode",
  "com.mitchellh.ghostty",
  "Safari",
  -- "Horse",
  "Mail",
}

local function isBundleID(s)
  return s:find("%.") ~= nil
end

-- Resolve an app regardless of bundle ID or name.
local function resolveApp(appNameOrBundle)
  if isBundleID(appNameOrBundle) then
    -- log("resolveApp: resolving bundleID %s", appNameOrBundle)  -- LOG
    return hs.application.get(appNameOrBundle)
  end
  
  -- log("resolveApp: resolving bundleID %s", appNameOrBundle)  -- LOG
  return hs.appfinder.appFromName(appNameOrBundle)
end

-- Launch with bundle-aware logic.
local function launchApp(appNameOrBundle)
  -- log("launchApp: %s", appNameOrBundle)  -- LOG
  if isBundleID(appNameOrBundle) then
    hs.application.launchOrFocusByBundleID(appNameOrBundle)
  else
    hs.application.launchOrFocus(appNameOrBundle)
  end
end

-- Try repeatedly to get a window (for electron apps, etc.)
local function waitForMainWindow(appNameOrBundle, callback)
  -- log("waitForMainWindow: start for %s", appNameOrBundle)  -- LOG
  local retries = config.launch.windowRetryCount

  local function attempt()
    local app = resolveApp(appNameOrBundle)
    if not app then
      -- log("waitForMainWindow: app not found (%s), retries left=%d", appNameOrBundle, retries)  -- LOG
      retries = retries - 1
      if retries > 0 then
        hs.timer.doAfter(config.launch.windowRetryInterval, attempt)
      end
      return
    end

    local win = app:mainWindow()
    if win then
      -- log("waitForMainWindow: got main window for %s", appNameOrBundle)  -- LOG
      callback(win)
      return
    end

    -- log("waitForMainWindow: no windows yet for %s, retries left=%d", appNameOrBundle, retries)  -- LOG
    retries = retries - 1
    if retries > 0 then
      hs.timer.doAfter(config.launch.windowRetryInterval, attempt)
    end
  end

  attempt()
end

---------------------------------------------------------------------------
-- Hotkeys for workspace apps
---------------------------------------------------------------------------



function bindAppHotkeys()
  -- log("bindAppHotkeys: binding %d workspace apps", #workspaceApps)  -- LOG
  for i, appName in ipairs(workspaceApps) do
    hs.hotkey.bind({"alt", "shift"}, tostring(i), function()
      -- log("hotkey: alt+shift+%d → %s", i, appName)  -- LOG
      local front = hs.application.frontmostApplication()
      if front then
        lastApp = front:name()
        -- log("hotkey: saving lastApp → %s", lastApp)  -- LOG
      end
      launchApp(appName)
    end)
  end
  
  hs.alert.show("App hotkeys re-bound", config.alertDuration)
end

bindAppHotkeys()

---------------------------------------------------------------------------
-- Stores bundleID when available
---------------------------------------------------------------------------

for i, appName in ipairs(workspaceApps) do
  hs.hotkey.bind({"alt", "shift"}, tostring(i), function()
    -- log("hotkey: alt+shift+%d → %s", i, appName)  -- LOG
    local front = hs.application.frontmostApplication()
    if front then
      local frontBundle = front:bundleID()
      if frontBundle and frontBundle ~= "" then
        lastApp = frontBundle
        -- log("hotkey: saving lastApp (bundle) → %s", lastApp)  -- LOG
      else
        lastApp = front:name()
        -- log("hotkey: saving lastApp (name) → %s", lastApp)  -- LOG
      end
    end
    launchApp(appName)
  end)
end

---------------------------------------------------------------------------
-- Option+Esc toggle for terminal ↔ last app
---------------------------------------------------------------------------

-- hs.hotkey.bind({"alt"}, "escape", function()
--   local current = hs.application.frontmostApplication()
--   local bundle = current and current:bundleID()
--   -- log("alt+esc: current bundle=%s lastApp=%s", tostring(bundle), tostring(lastApp))  -- LOG

--     -- If currently in the terminal (bundle) and we have a lastApp, restore it
--   if bundle == "com.mitchellh.ghostty" and lastApp then
--     -- log("alt+esc: switching back to %s", lastApp)  -- LOG
--     if isBundleID(lastApp) then
--       hs.application.launchOrFocusByBundleID(lastApp)
--     else
--       hs.application.launchOrFocus(lastApp)
--     end
--     lastApp = nil
--     return
--   end

--     -- Save current as bundle ID when available (so later we can restore reliably)
--   if bundle and bundle ~= "" then
--     lastApp = bundle
--     -- log("alt+esc: saving lastApp (bundle) = %s", lastApp)  -- LOG
--   else
--     local name = current and current:name()
--     lastApp = name
--     -- log("alt+esc: saving lastApp (name) = %s", tostring(lastApp))  -- LOG
--   end

--   -- Switch to terminal by bundle ID (deterministic)
--   -- log("alt+esc: switching to terminal bundle=com.mitchellh.ghostty")  -- LOG
--   hs.application.launchOrFocusByBundleID("com.mitchellh.ghostty")
-- end)

---------------------------------------------------------------------------
-- Sequential workspace launcher (with fullscreen + retries)
---------------------------------------------------------------------------

function launchWorkspace()
  -- log("launchWorkspace: starting sequence")  -- LOG
  local total = (#workspaceApps * config.launch.delayBetweenApps)
  hs.alert.show("Launching workspace...", total)

  for i, appName in ipairs(workspaceApps) do
    local delay = (i - 1) * config.launch.delayBetweenApps
    -- log("launchWorkspace: scheduling %s at +%ds", appName, delay)  -- LOG

    hs.timer.doAfter(delay, function()
      -- log("launchWorkspace: launching %s", appName)  -- LOG
      launchApp(appName)

      hs.timer.doAfter(config.launch.delayForFullscreen, function()
        -- log("launchWorkspace: fullscreen attempt → %s", appName)  -- LOG
        waitForMainWindow(appName, function(win)
          if win and win:isStandard() then
            -- log("launchWorkspace: fullscreen ok → %s", appName)  -- LOG
            win:setFullScreen(true)
          else
            log("launchWorkspace: window not standard or missing for %s", appName)  -- LOG
          end
        end)
      end)
    end)
  end
end

---------------------------------------------------------------------------
-- Manual triggers
---------------------------------------------------------------------------

-- Launch workspace and bind app hotkeys
hs.hotkey.bind({"ctrl", "cmd", "alt"}, "w", function()
  launchWorkspace()
  bindAppHotkeys()
end)

-- Re-bind app hotkeys
hs.hotkey.bind({"ctrl", "cmd", "alt"}, "r", function()
  bindAppHotkeys()
end)

hs.hotkey.bind({"ctrl", "cmd", "alt"}, "c", function()
  hs.reload()  -- reload the Hammerspoon configuration
end)

-- -- Finder: Open Downloads folder
-- hs.hotkey.bind({"alt", "cmd"}, "l", function()
--   hs.execute('open -a Finder "$HOME/Downloads"', true)
-- end)


---------------------------------------------------------------------------
-- Show confirmation alert on load
---------------------------------------------------------------------------
hs.alert.show("Hammerspoon configuration (re)loaded", config.alertDuration)