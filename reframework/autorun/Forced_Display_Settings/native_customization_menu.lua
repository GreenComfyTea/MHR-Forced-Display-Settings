local native_customization_menu = {};

local table_helpers;
local config;
local customization_menu;
local display_settings;


local mod_menu_api_package_name = "ModOptionsMenu.ModMenuApi";
local mod_menu = nil;

local native_UI = nil;

native_customization_menu.display_mode_descriptions = { "Windowed Mode.", "Borderless Windowed Mode.", "Fullscreen Mode." };

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
	local changed = false;
	local output_display_config_changed = false;
	local display_mode_config_changed = false;
	local resolution_config_changed = false;
	local refresh_rate_config_changed = false;
	local aspect_ratio_config_changed = false;
	local framerate_config_changed = false;
	local vsync_config_changed = false;
	local index = false; 

	mod_menu.Label("Created by: <COL RED>GreenComfyTea</COL>", "",
		"Donate: <COL RED>https://streamelements.com/greencomfytea/tip</COL>\nBuy me a tea: <COL RED>https://ko-fi.com/greencomfytea</COL>\nSometimes I stream: <COL RED>twitch.tv/greencomfytea</COL>");
	mod_menu.Label("Version: <COL RED>" .. config.current_config.version .. "</COL>", "",
		"Donate: <COL RED>https://streamelements.com/greencomfytea/tip</COL>\nBuy me a tea: <COL RED>https://ko-fi.com/greencomfytea</COL>\nSometimes I stream: <COL RED>twitch.tv/greencomfytea</COL>");

	if true then -- Forced Output Display
		mod_menu.Header("Forced Output Display");

		changed, config.current_config.forced_output_display.enabled = mod_menu.CheckBox(
			"Enabled", config.current_config.forced_output_display.enabled, "Enable/Disable Forced Output Display.");
			output_display_config_changed = output_display_config_changed or changed;

		changed, index = mod_menu.Options(
			"Output Display Settings",
			config.current_config.forced_output_display.display_id + 1,
			display_settings.display_names,
			native_customization_menu.display_mode_descriptions,
			"Select a display that will show the game screen.\n<COL YEL>(Only configurable for Windows 10 or later,\nand only for multiple-display environments.)</COL>"
		);
		output_display_config_changed = output_display_config_changed or changed;

		if changed then
			config.current_config.forced_output_display.display_id = index - 1;
		end
	end

	if true then -- Forced Screen Mode
		mod_menu.Header("Forced Screen Mode");

		changed, config.current_config.forced_display_mode.enabled = mod_menu.CheckBox(
			"Enabled", config.current_config.forced_display_mode.enabled, "Enable/Disable Forced Screen Mode.");
		display_mode_config_changed = display_mode_config_changed or changed;

		changed, index = mod_menu.Options(
			"Screen Mode",
			table_helpers.find_index(display_settings.display_modes, config.current_config.forced_display_mode.display_mode),
			display_settings.display_modes,
			native_customization_menu.display_mode_descriptions,
			"Configure screen mode."
		);
		display_mode_config_changed = display_mode_config_changed or changed;

		if changed then
			config.current_config.forced_display_mode.display_mode = display_settings.display_modes[index];
		end
	end

	if true then -- Forced Resolution
		mod_menu.Header("Forced Resolution");

		changed, config.current_config.forced_resolution.enabled = mod_menu.CheckBox(
			"Enabled", config.current_config.forced_resolution.enabled, "Enable/Disable Forced Resolution.");
		resolution_config_changed = resolution_config_changed or changed;

		changed, index = mod_menu.Options(
			"Resolution Settings",
			table_helpers.find_index(display_settings.resolution_names, config.current_config.forced_resolution.resolution),
			display_settings.resolution_names,
			display_settings.resolution_names,
			"Change screen resolution."
		);
		resolution_config_changed = resolution_config_changed or changed;

		if changed then
			config.current_config.forced_resolution.resolution = display_settings.resolution_names[index];
		end
	end

	if true then -- Forced Display Frequency
		mod_menu.Header("Forced Display Frequency");

		changed, config.current_config.forced_refresh_rate.enabled = mod_menu.CheckBox(
			"Enabled", config.current_config.forced_refresh_rate.enabled, "Enable/Disable Forced Display Frequency.");
		refresh_rate_config_changed = refresh_rate_config_changed or changed;

		changed, index = mod_menu.Options(
			"Display Frequency",
			table_helpers.find_index(display_settings.refresh_rate_names, config.current_config.forced_refresh_rate.refresh_rate),
			display_settings.refresh_rate_names,
			display_settings.refresh_rate_names,
			"Change display frequency."
		);
		refresh_rate_config_changed = refresh_rate_config_changed or changed;

		if changed then
			config.current_config.forced_refresh_rate.refresh_rate = display_settings.refresh_rate_names[index];
		end
	end

	if true then -- Forced Aspect Ratio
		mod_menu.Header("Forced Aspect Ratio");

		changed, config.current_config.forced_aspect_ratio.enabled = mod_menu.CheckBox(
			"Enabled", config.current_config.forced_aspect_ratio.enabled, "Enable/Disable Forced Aspect Ratio.");
		aspect_ratio_config_changed = aspect_ratio_config_changed or changed;

		changed, index = mod_menu.Options(
			"Aspect Ratio",
			table_helpers.find_index(display_settings.aspect_ratios, config.current_config.forced_aspect_ratio.aspect_ratio),
			display_settings.aspect_ratios,
			display_settings.aspect_ratios,
			"Configure aspect ratio. Defaults to letterbox\nfor monitors other than ultra-wide monitors."
		);
		aspect_ratio_config_changed = aspect_ratio_config_changed or changed;

		if changed then
			config.current_config.forced_aspect_ratio.aspect_ratio = display_settings.aspect_ratios[index];
		end
	end

	if true then -- Forced Framerate Cap
		mod_menu.Header("Forced Framerate Cap");

		changed, config.current_config.forced_framerate.enabled = mod_menu.CheckBox(
			"Enabled", config.current_config.forced_framerate.enabled, "Enable/Disable Forced Framerate Cap.");
		framerate_config_changed = framerate_config_changed or changed;

		changed, index = mod_menu.Options(
			"Framerate Cap",
			table_helpers.find_index(display_settings.framerates, config.current_config.forced_framerate.framerate),
			display_settings.framerates,
			display_settings.framerates,
			"Set a framerate cap."
		);
		framerate_config_changed = framerate_config_changed or changed;

		if changed then
			config.current_config.forced_framerate.framerate = display_settings.framerates[index];
		end
	end

	if true then -- Forced V-Sync
		mod_menu.Header("Forced V-Sync");

		changed, config.current_config.forced_vsync.enabled = mod_menu.CheckBox(
			"Enabled", config.current_config.forced_vsync.enabled, "Enable/Disable Forced V-Sync.");
		vsync_config_changed = vsync_config_changed or changed;

		changed, config.current_config.forced_vsync.vsync = mod_menu.CheckBox(
			"V-Sync", config.current_config.forced_vsync.vsync, "Enable/disable vertical synchronization.");
		vsync_config_changed = vsync_config_changed or changed;
	end

	if output_display_config_changed then
		display_settings.force_output_display();
	end

	if display_mode_config_changed then
		display_settings.force_display_mode();
	end

	if resolution_config_changed then
		display_settings.force_resolution();
	end

	if refresh_rate_config_changed then
		display_settings.force_refresh_rate();
	end

	if aspect_ratio_config_changed then
		display_settings.force_aspect_ratio();
	end

	if framerate_config_changed then
		display_settings.force_framerate();
	end

	if vsync_config_changed then
		display_settings.force_vsync();
	end

	if output_display_config_changed
	or display_mode_config_changed
	or resolution_config_changed 
	or refresh_rate_config_changed
	or aspect_ratio_config_changed
	or framerate_config_changed
	or vsync_config_changed then
		config.save();
	end
end

function native_customization_menu.on_reset_all_settings()
	config.current_config = table_helpers.deep_copy(config.default_config);
end

function native_customization_menu.init_module()
	table_helpers = require("Forced_Display_Settings.table_helpers");
	config = require("Forced_Display_Settings.config");
	customization_menu = require("Forced_Display_Settings.customization_menu");
	display_settings = require("Forced_Display_Settings.display_settings");

	if native_customization_menu.is_module_available(mod_menu_api_package_name) then
		mod_menu = require(mod_menu_api_package_name);
	end

	if mod_menu == nil then
		log.info("[Forced Display Settings] No mod_menu_api API package found. You may need to download it or something.");
		return;
	end

	native_UI = mod_menu.OnMenu(
		"Forced Display Settings",
		"Force Display Mode on Game Launch.",
		native_customization_menu.draw
	);

	native_UI.OnResetAllSettings = native_customization_menu.on_reset_all_settings;

end

return native_customization_menu;
