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