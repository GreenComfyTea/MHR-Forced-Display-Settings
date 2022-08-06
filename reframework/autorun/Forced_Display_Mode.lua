local table_helpers = require("Forced_Display_Mode.table_helpers");
local config = require("Forced_Display_Mode.config");

local customization_menu = require("Forced_Display_Mode.customization_menu");
local native_customization_menu = require("Forced_Display_Mode.native_customization_menu");

local display_mode_and_resolution = require("Forced_Display_Mode.display_mode_and_resolution");

table_helpers.init_module();
config.init_module();

customization_menu.init_module();

display_mode_and_resolution.init_module();

native_customization_menu.init_module();

log.info("[Forced Display Mode] Loaded.");

re.on_draw_ui(function()
	if imgui.button("Forced Display Mode and Resolution " .. config.current_config.version) then
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