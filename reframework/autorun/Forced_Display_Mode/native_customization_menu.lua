local native_customization_menu = {};

local table_helpers;
local config;
local customization_menu;
local display_mode_and_resolution;


local mod_menu_api_package_name = "ModOptionsMenu.ModMenuApi";
local mod_menu = nil;

local native_UI = nil;

native_customization_menu.display_mode_descriptions = { "Windowed Mode.", "Fullscreen Mode.", "Borderless Windowed Mode." };

--no idea how this works but google to the rescue
--can use this to check if the api is available and do an alternative to avoid complaints from users
function native_customization_menu.is_module_available(name)
	if package.loaded[name] then
		return true;
	else
		for _, searcher in ipairs(package.searchers or package.loaders) do
			local loader = searcher(name);

			if type(loader) == 'function' then
				package.preload[name] = loader;
				return true;
			end
		end

		return false;
	end
end

function native_customization_menu.draw()
	display_mode_and_resolution.populate_resolutions();

	local changed = false;
	local config_changed = false;
	local index = false; 

	mod_menu.Label("Created by: <COL RED>GreenComfyTea</COL>", "",
		"Donate: <COL RED>https://streamelements.com/greencomfytea/tip</COL>\nBuy me a tea: <COL RED>https://ko-fi.com/greencomfytea</COL>\nSometimes I stream: <COL RED>twitch.tv/greencomfytea</COL>");

	mod_menu.Header("Forced Display Mode");

	changed, config.current_config.forced_display_mode.enabled = mod_menu.CheckBox(
		"Enabled", config.current_config.forced_display_mode.enabled, "Enable/Disable Forced Display Mode.");
	config_changed = config_changed or changed;

	changed, index = mod_menu.Options(
		"Display Mode",
		table_helpers.find_index(customization_menu.display_modes, config.current_config.forced_display_mode.display_mode),
		customization_menu.display_modes,
		native_customization_menu.display_mode_descriptions,
		"Configure screen mode."
	);
	config_changed = config_changed or changed;

	if changed then
		config.current_config.forced_display_mode.display_mode = customization_menu.display_modes[index];
	end

	mod_menu.Header("Forced Resolution");

	changed, config.current_config.forced_resolution.enabled = mod_menu.CheckBox(
		"Enabled", config.current_config.forced_resolution.enabled, "Enable/Disable Forced Resolution.");
	config_changed = config_changed or changed;

	changed, index = mod_menu.Options(
		"Resolution",
		table_helpers.find_index(display_mode_and_resolution.resolution_names, config.current_config.forced_resolution.resolution),
		display_mode_and_resolution.resolution_names,
		display_mode_and_resolution.resolution_names,
		"Change screen resolution."
	);
	config_changed = config_changed or changed;

	if changed then
		config.current_config.forced_resolution.resolution = display_mode_and_resolution.resolution_names[index];
	end

	if config_changed then
		display_mode_and_resolution.force_display_mode();
		config.save();
	end
end

function native_customization_menu.on_reset_all_settings()
	config.current_config = table_helpers.deep_copy(config.default_config);
end

function native_customization_menu.init_module()
	table_helpers = require("Forced_Display_Mode.table_helpers");
	config = require("Forced_Display_Mode.config");
	customization_menu = require("Forced_Display_Mode.customization_menu");
	display_mode_and_resolution = require("Forced_Display_Mode.display_mode_and_resolution");

	if native_customization_menu.is_module_available(mod_menu_api_package_name) then
		mod_menu = require(mod_menu_api_package_name);
	end

	if mod_menu == nil then
		log.info("[Forced Display Mode and Resolution] No mod_menu_api API package found. You may need to download it or something.");
		return;
	end

	native_UI = mod_menu.OnMenu(
		"Forced Display Mode and Resolution",
		"Force Display Mode and Resolution on Game Launch.",
		native_customization_menu.draw
	);

	native_UI.OnResetAllSettings = native_customization_menu.on_reset_all_settings;

end

return native_customization_menu;
