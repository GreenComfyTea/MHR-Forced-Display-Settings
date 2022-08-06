local customization_menu = {};

local table_helpers;
local config;
local display_mode_and_resolution;

customization_menu.is_opened = false;
customization_menu.status = "OK";

customization_menu.window_position = Vector2f.new(480, 200);
customization_menu.window_pivot = Vector2f.new(0, 0);
customization_menu.window_size = Vector2f.new(500, 480);
customization_menu.window_flags = 0x10120;

customization_menu.color_picker_flags = 327680;
customization_menu.decimal_input_flags = 33;

customization_menu.display_modes = { "Windowed Mode", "Fullscreen", "Borderless Windowed" };

function customization_menu.init()
end

function customization_menu.draw()
	imgui.set_next_window_pos(customization_menu.window_position, 1 << 3, customization_menu.window_pivot);
	imgui.set_next_window_size(customization_menu.window_size, 1 << 3);

	customization_menu.is_opened = imgui.begin_window(
		"Forced Display Mode and Resolution " .. config.current_config.version, customization_menu.is_opened, customization_menu.window_flags);

	if not customization_menu.is_opened then
		imgui.end_window();
		return;
	end

	display_mode_and_resolution.populate_resolutions();

	imgui.text("Status: " .. tostring(customization_menu.status));

	local changed = false;
	local config_changed = false;
	local index = 1;

	
	if imgui.tree_node("Forced Display Mode") then
		local display_mode_config_changed = false;

		changed, config.current_config.forced_display_mode.enabled = imgui.checkbox("Enabled", config.current_config.forced_display_mode.enabled);
		config_changed = config_changed or changed;
		display_mode_config_changed = display_mode_config_changed or changed;

		changed, index = imgui.combo("Display Mode", table_helpers.find_index(customization_menu.display_modes, config.current_config.forced_display_mode.display_mode), customization_menu.display_modes);
		config_changed = config_changed or changed;
		display_mode_config_changed = display_mode_config_changed or changed;

		if changed then
			config.current_config.forced_display_mode.display_mode = customization_menu.display_modes[index];
		end

		if display_mode_config_changed then
			display_mode_and_resolution.force_display_mode();
		end

		imgui.tree_pop();
	end

	if imgui.tree_node("Forced Resolution") then
		local resolution_config_changed = false;

		changed, config.current_config.forced_resolution.enabled = imgui.checkbox("Enabled", config.current_config.forced_resolution.enabled);
		config_changed = config_changed or changed;
		resolution_config_changed = resolution_config_changed or changed;

		changed, index = imgui.combo("Resolution", table_helpers.find_index(display_mode_and_resolution.resolution_names, config.current_config.forced_resolution.resolution), display_mode_and_resolution.resolution_names);
		config_changed = config_changed or changed;
		resolution_config_changed = resolution_config_changed or changed;

		if changed then
			config.current_config.forced_resolution.resolution = display_mode_and_resolution.resolution_names[index];
		end

		if resolution_config_changed then
			display_mode_and_resolution.force_resolution();
		end

		imgui.tree_pop();
	end


	

	imgui.end_window();

	if config_changed then
		
		config.save();
	end
end

function customization_menu.init_module()
	table_helpers = require("Forced_Display_Mode.table_helpers");
	config = require("Forced_Display_Mode.config");
	display_mode_and_resolution = require("Forced_Display_Mode.display_mode_and_resolution");

	customization_menu.init();
end

return customization_menu;
