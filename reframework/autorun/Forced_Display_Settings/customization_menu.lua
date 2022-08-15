local customization_menu = {};

local table_helpers;
local config;
local display_settings;

customization_menu.is_opened = false;
customization_menu.status = "OK";

customization_menu.window_position = Vector2f.new(480, 200);
customization_menu.window_pivot = Vector2f.new(0, 0);
customization_menu.window_size = Vector2f.new(500, 550);
customization_menu.window_flags = 0x10120;

customization_menu.color_picker_flags = 327680;
customization_menu.decimal_input_flags = 33;

function customization_menu.init()
end

function customization_menu.draw()
	imgui.set_next_window_pos(customization_menu.window_position, 1 << 3, customization_menu.window_pivot);
	imgui.set_next_window_size(customization_menu.window_size, 1 << 3);

	customization_menu.is_opened = imgui.begin_window(
		"Forced Display Settings v" .. config.current_config.version, customization_menu.is_opened, customization_menu.window_flags);

	if not customization_menu.is_opened then
		imgui.end_window();
		return;
	end

	imgui.text("Status: " .. tostring(customization_menu.status));

	local changed = false;
	local output_display_config_changed = false;
	local display_mode_config_changed = false;
	local resolution_config_changed = false;
	local refresh_rate_config_changed = false;
	local aspect_ratio_config_changed = false;
	local framerate_config_changed = false;
	local vsync_config_changed = false;
	local index = 1;

	if imgui.tree_node("Forced Output Display") then
		changed, config.current_config.forced_output_display.enabled = imgui.checkbox("Enabled", config.current_config.forced_output_display.enabled);
		output_display_config_changed = output_display_config_changed or changed;
		
		changed, index = imgui.combo("Output Display", config.current_config.forced_output_display.display_id + 1, display_settings.display_names);
		output_display_config_changed = output_display_config_changed or changed;

		if changed then
			config.current_config.forced_output_display.display_id = index - 1;
		end

		imgui.tree_pop();
	end

	if imgui.tree_node("Forced Screen Mode") then
		changed, config.current_config.forced_display_mode.enabled = imgui.checkbox("Enabled", config.current_config.forced_display_mode.enabled);
		display_mode_config_changed = display_mode_config_changed or changed;

		changed, index = imgui.combo("Screen Mode", table_helpers.find_index(display_settings.display_modes, config.current_config.forced_display_mode.display_mode), display_settings.display_modes);
		display_mode_config_changed = display_mode_config_changed or changed;

		if changed then
			config.current_config.forced_display_mode.display_mode = display_settings.display_modes[index];
		end

		imgui.tree_pop();
	end

	if imgui.tree_node("Forced Resolution") then
		changed, config.current_config.forced_resolution.enabled = imgui.checkbox("Enabled", config.current_config.forced_resolution.enabled);
		resolution_config_changed = resolution_config_changed or changed;

		changed, index = imgui.combo("Resolution", table_helpers.find_index(display_settings.resolution_names, config.current_config.forced_resolution.resolution), display_settings.resolution_names);
		resolution_config_changed = resolution_config_changed or changed;

		if changed then
			config.current_config.forced_resolution.resolution = display_settings.resolution_names[index];
		end

		imgui.tree_pop();
	end

	if imgui.tree_node("Forced Display Frequency") then
		changed, config.current_config.forced_refresh_rate.enabled = imgui.checkbox("Enabled", config.current_config.forced_refresh_rate.enabled);
		refresh_rate_config_changed = refresh_rate_config_changed or changed;

		changed, index = imgui.combo("Display Frequency", table_helpers.find_index(display_settings.refresh_rate_names, config.current_config.forced_refresh_rate.refresh_rate), display_settings.refresh_rate_names);
		refresh_rate_config_changed = refresh_rate_config_changed or changed;

		if changed then
			config.current_config.forced_refresh_rate.refresh_rate = display_settings.refresh_rate_names[index];
		end

		imgui.tree_pop();
	end

	if imgui.tree_node("Forced Aspect Ratio") then
		changed, config.current_config.forced_aspect_ratio.enabled = imgui.checkbox("Enabled", config.current_config.forced_aspect_ratio.enabled);
		aspect_ratio_config_changed = aspect_ratio_config_changed or changed;

		changed, index = imgui.combo("Aspect Ratio", table_helpers.find_index(display_settings.aspect_ratios, config.current_config.forced_aspect_ratio.aspect_ratio), display_settings.aspect_ratios);
		aspect_ratio_config_changed = aspect_ratio_config_changed or changed;

		if changed then
			config.current_config.forced_aspect_ratio.aspect_ratio = display_settings.aspect_ratios[index];
		end

		imgui.tree_pop();
	end

	if imgui.tree_node("Forced Framerate Cap") then
		changed, config.current_config.forced_framerate.enabled = imgui.checkbox("Enabled", config.current_config.forced_framerate.enabled);
		framerate_config_changed = framerate_config_changed or changed;

		changed, index = imgui.combo("Framerate Cap", table_helpers.find_index(display_settings.framerates, config.current_config.forced_framerate.framerate), display_settings.framerates);
		framerate_config_changed = framerate_config_changed or changed;

		if changed then
			config.current_config.forced_framerate.framerate = display_settings.framerates[index];
		end

		imgui.tree_pop();
	end

	if imgui.tree_node("Forced V-Sync") then
		changed, config.current_config.forced_vsync.enabled = imgui.checkbox("Enabled", config.current_config.forced_vsync.enabled);
		vsync_config_changed = vsync_config_changed or changed;

		changed, config.current_config.forced_vsync.vsync = imgui.checkbox("V-Sync", config.current_config.forced_vsync.vsync);
		vsync_config_changed = vsync_config_changed or changed;

		imgui.tree_pop();
	end

	imgui.end_window();

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

function customization_menu.init_module()
	table_helpers = require("Forced_Display_Settings.table_helpers");
	config = require("Forced_Display_Settings.config");
	display_settings = require("Forced_Display_Settings.display_settings");

	customization_menu.init();
end

return customization_menu;
