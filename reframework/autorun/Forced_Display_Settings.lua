local sdk = sdk;
local tostring = tostring;
local pairs = pairs;
local ipairs = ipairs;
local tonumber = tonumber;
local require = require;
local pcall = pcall;
local table = table;
local string = string;
local Vector3f = Vector3f;
local d2d = d2d;
local math = math;
local json = json;
local log = log;
local fs = fs;
local next = next;
local type = type;
local setmetatable = setmetatable;
local getmetatable = getmetatable;
local assert = assert;
local select = select;
local coroutine = coroutine;
local utf8 = utf8;
local re = re;
local imgui = imgui;
local draw = draw;
local Vector2f = Vector2f;
local reframework = reframework;

local table_helpers = require("Forced_Display_Settings.table_helpers");
local config = require("Forced_Display_Settings.config");

local customization_menu = require("Forced_Display_Settings.customization_menu");
local native_customization_menu = require("Forced_Display_Settings.native_customization_menu");

local display_settings = require("Forced_Display_Settings.display_settings");

table_helpers.init_module();
config.init_module();

customization_menu.init_module();

display_settings.init_module();

native_customization_menu.init_module();

log.info("[Forced Display Settings] Loaded.");

re.on_draw_ui(function()
	if imgui.button("Forced Display Settings v" .. config.current_config.version) then
		customization_menu.is_opened = not customization_menu.is_opened;
	end
end);

re.on_frame(function()
	if not reframework:is_drawing_ui() then
		customization_menu.is_opened = false;
	end

	if customization_menu.is_opened then
		pcall(customization_menu.draw);
	end
end);