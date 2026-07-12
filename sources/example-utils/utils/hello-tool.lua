-- hello-tool: a minimal example utils tool
-- Demonstrates the ezmk Lua API for utils package authors.

local name = ezmk.project_name()
local root = ezmk.project_root()

ezmk.info("Hello from " .. name .. "!")
ezmk.info("Project root: " .. root)
ezmk.info("This is an example utils tool. Replace with real functionality.")
