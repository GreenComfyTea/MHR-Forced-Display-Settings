local display_settings = {};
local table_helpers;
local config;
local customization_menu;

display_settings.display_names = {};
display_settings.display_ids = {};

display_settings.resolution_names = {};
display_settings.resolution_indices = {};

display_settings.refresh_rate_names = {};
display_settings.refresh_rate_indices = {};

display_settings.display_modes = { "Windowed Mode", "Borderless Windowed", "Fullscreen" };
display_settings.aspect_ratios = { "16:9", "21:9" };
display_settings.framerates = { "30", "60", "90", "120", "144", "165", "240", "Unlimited" };

local option_manager = nil;
local save_service = nil;

local force_on_init = true;

local output_display_waiting_for_display_mode_change = false;
local display_mode_waiting_for_output_display_change = false;
local last_window_mode = "Windowed Mode";

local option_manager_type_def = sdk.find_type_definition("snow.StmOptionManager");
local apply_option_value_method = option_manager_type_def:get_method("applyOptionValue(snow.StmOptionDef.StmOptionType)");
local apply_option_value_2_method = option_manager_type_def:get_method("applyOptionValue(snow.StmOptionDef.StmOptionType, System.Int32)");
local get_resolution_infos_method = option_manager_type_def:get_method("getResolutionInfos");
local get_refresh_rate_infos_method = option_manager_type_def:get_method("getRefreshRateInfos");
local get_display_infos_method = option_manager_type_def:get_method("getDisplayInfos");
local option_manager_start_method = option_manager_type_def:get_method("start");

local get_option_data_container_method = option_manager_type_def:get_method("get_StmOptionDataContainer");

local on_display_setting_changed_method = option_manager_type_def:get_method("onDisplaySettingChanged");
local set_and_apply_max_resolution_and_refresh_rate_method = option_manager_type_def:get_method("setAndApplyMaxResolutionAndRefreshRate");
local on_window_mode_changed_method = option_manager_type_def:get_method("onWindowModeChangeEvent");

local option_data_container_type_def = sdk.find_type_definition("snow.StmOptionDataContainer");
local set_option_value_method = option_data_container_type_def:get_method("setOptionValue");
local get_output_display_option_method = option_data_container_type_def:get_method("getOutputDisplayOption");
local get_window_mode_option_method = option_data_container_type_def:get_method("getWindowModeOption");
local get_resolution_option_method = option_data_container_type_def:get_method("getResolutionOption");
local get_refresh_rate_option_method = option_data_container_type_def:get_method("getRefreshRateOption");
local get_aspect_ratio_option_method = option_data_container_type_def:get_method("getAspectRatioOption");
local get_framerate_option_method = option_data_container_type_def:get_method("getFrameRateOption");
local get_vsync_option_method = option_data_container_type_def:get_method("getVSyncOption");

local display_info_type_def = sdk.find_type_definition("snow.DisplayInfo");
local display_id_field = display_info_type_def:get_field("<DisplayId>k__BackingField");
local display_name_field = display_info_type_def:get_field("<DisplayName>k__BackingField");

local resolution_info_type_def = sdk.find_type_definition("snow.ResolutionInfo");
local resolution_index_field = resolution_info_type_def:get_field("<ResolutionIndex>k__BackingField");
local resolution_name_field = resolution_info_type_def:get_field("<ResolutionName>k__BackingField");

local refresh_rate_info_type_def = sdk.find_type_definition("snow.RefreshRateInfo");
local refresh_rate_index_field = refresh_rate_info_type_def:get_field("<RefreshRateIndex>k__BackingField");
local refresh_rate_name_field = refresh_rate_info_type_def:get_field("<RefreshRateName>k__BackingField");

local save_service_type_def = sdk.find_type_definition("snow.SnowSaveService");
local save_system_data_method = save_service_type_def:get_method("saveSystemData");

local system_array_type_def = sdk.find_type_definition("System.Array");
local length_method = system_array_type_def:get_method("get_Length");
local get_value_method = system_array_type_def:get_method("GetValue(System.Int32)");


-- option_type = snow.StmOptionDef.StmOptionType
local option_types = {
	["output_display"] = 25, --24,
	["window_mode"] = 28, --27,
	["hdr"] = 29, --28,
	["resolution"] = 30, --29,
	["refresh_rate"] = 31, -- 30,
	["aspect_ratio"] = 32, --31,
	["framerate"] = 34, --33,
	["vsync"] = 35 --34
}

function display_settings.force_output_display()
	if not config.current_config.forced_output_display.enabled then
		display_settings.init();
		return;
	end

	if option_manager == nil then
		option_manager = sdk.get_managed_singleton("snow.StmOptionManager");
	
		if option_manager == nil then
			log.info("[Forced Display Settings] No Option Manager");
			customization_menu.status = "No Option Manager";
			display_settings.init();
			return;
		end
	end

	local option_data_container = get_option_data_container_method:call(option_manager);
	if option_data_container == nil then
		log.info("[Forced Display Settings] No Option Data Container");
		customization_menu.status = "No Option Data Container";
		display_settings.init();
		return;
	end

	local current_output_display = get_output_display_option_method:call(option_data_container);
	if current_output_display == nil then
		log.info("[Forced Display Settings] No Current Output Display");
		customization_menu.status = "No Current Output Display";
		display_settings.init();
		return;
	end

	local next_output_display = config.current_config.forced_output_display.display_id;

	if current_output_display == next_output_display then
		display_settings.init();
		return;
	end

	local current_display_mode = get_window_mode_option_method:call(option_data_container);
	if current_display_mode == nil then
		log.info("[Forced Display Settings] No Current Display Mode");
		customization_menu.status = "No Current Display Mode";
		display_settings.init();
		return;
	end

	local next_display_mode = table_helpers.find_index(display_settings.display_modes, "Windowed Mode");
	next_display_mode = next_display_mode - 1;

	if current_display_mode == next_display_mode then
		output_display_waiting_for_display_mode_change = false;
		display_mode_waiting_for_output_display_change = false;

		local next_output_display = config.current_config.forced_output_display.display_id;

		set_option_value_method:call(option_data_container, option_types.output_display, next_output_display);
		apply_option_value_method:call(option_manager, option_types.output_display);
	else
		output_display_waiting_for_display_mode_change = true;
		last_window_mode = display_settings.display_modes[current_display_mode + 1];
		

		set_option_value_method:call(option_data_container, option_types.window_mode, next_display_mode);
		apply_option_value_method:call(option_manager, option_types.window_mode);

		return;
	end

	display_settings.init();
end

function display_settings.force_display_mode()
	if not config.current_config.forced_display_mode.enabled then
		return;
	end

	if option_manager == nil then
		option_manager = sdk.get_managed_singleton("snow.StmOptionManager");
	
		if option_manager == nil then
			log.info("[Forced Display Settings] No Option Manager");
			customization_menu.status = "No Option Manager";
			return;
		end
	end

	local option_data_container = get_option_data_container_method:call(option_manager);
	if option_data_container == nil then
		log.info("[Forced Display Settings] No Option Data Container");
		customization_menu.status = "No Option Data Container";
		return;
	end

	local current_display_mode = get_window_mode_option_method:call(option_data_container);
	if current_display_mode == nil then
		log.info("[Forced Display Settings] No Current Display Mode");
		customization_menu.status = "No Current Display Mode";
		return;
	end

	local next_display_mode = table_helpers.find_index(display_settings.display_modes, config.current_config.forced_display_mode.display_mode, true);
	if next_display_mode == nil then 
		return;
	end
	
	next_display_mode = next_display_mode - 1;

	if current_display_mode == next_display_mode then
		return;
	end

	set_option_value_method:call(option_data_container, option_types.window_mode, next_display_mode);
	apply_option_value_method:call(option_manager, option_types.window_mode);
end

function display_settings.force_resolution()
	if not config.current_config.forced_resolution.enabled then
		return;
	end

	if option_manager == nil then
		option_manager = sdk.get_managed_singleton("snow.StmOptionManager");
	
		if option_manager == nil then
			log.info("[Forced Display Settings] No Option Manager");
			customization_menu.status = "No Option Manager";
			return;
		end
	end

	local option_data_container = get_option_data_container_method:call(option_manager);
	if option_data_container == nil then
		log.info("[Forced Display Settings] No Option Data Container");
		customization_menu.status = "No Option Data Container";
		return;
	end

	local current_resolution = get_resolution_option_method:call(option_data_container);
	if current_resolution == nil then
		log.info("[Forced Display Settings] No Current Resolution");
		customization_menu.status = "No Current Resolution";
		return;
	end

	local script_resolution_index = table_helpers.find_index(display_settings.resolution_names, config.current_config.forced_resolution.resolution, true);
	if script_resolution_index == nil then
		return;
	end

	local in_game_resolution_index = display_settings.resolution_indices[script_resolution_index];
	if in_game_resolution_index == nil then
		return;
	end

	if current_resolution == in_game_resolution_index then
		return;
	end

	set_option_value_method:call(option_data_container, option_types.resolution, in_game_resolution_index);
	apply_option_value_method:call(option_manager, option_types.resolution);
end

function display_settings.force_refresh_rate()
	if not config.current_config.forced_refresh_rate.enabled then
		return;
	end

	if option_manager == nil then
		option_manager = sdk.get_managed_singleton("snow.StmOptionManager");
	
		if option_manager == nil then
			log.info("[Forced Display Settings] No Option Manager");
			customization_menu.status = "No Option Manager";
			return;
		end
	end

	local option_data_container = get_option_data_container_method:call(option_manager);
	if option_data_container == nil then
		log.info("[Forced Display Settings] No Option Data Container");
		customization_menu.status = "No Option Data Container";
		return;
	end

	local current_refresh_rate = get_refresh_rate_option_method:call(option_data_container);
	if current_refresh_rate == nil then
		log.info("[Forced Display Settings] No Current Refresh Rate");
		customization_menu.status = "No Current Refresh Rate";
		return;
	end

	local script_refresh_rate_index = table_helpers.find_index(display_settings.refresh_rate_names, config.current_config.forced_refresh_rate.refresh_rate, true);
	if script_refresh_rate_index == nil then
		return;
	end

	local in_game_refresh_rate_index = display_settings.refresh_rate_indices[script_refresh_rate_index];
	if in_game_refresh_rate_index == nil then
		return;
	end

	if current_refresh_rate == in_game_refresh_rate_index then
		return;
	end

	set_option_value_method:call(option_data_container, option_types.refresh_rate, in_game_refresh_rate_index);
	apply_option_value_method:call(option_manager, option_types.refresh_rate);
end

function display_settings.force_aspect_ratio()
	if not config.current_config.forced_aspect_ratio.enabled then
		return;
	end

	if option_manager == nil then
		option_manager = sdk.get_managed_singleton("snow.StmOptionManager");
	
		if option_manager == nil then
			log.info("[Forced Display Settings] No Option Manager");
			customization_menu.status = "No Option Manager";
			return;
		end
	end

	local option_data_container = get_option_data_container_method:call(option_manager);
	if option_data_container == nil then
		log.info("[Forced Display Settings] No Option Data Container");
		customization_menu.status = "No Option Data Container";
		return;
	end

	local current_aspect_ratio = get_aspect_ratio_option_method:call(option_data_container);
	if current_aspect_ratio == nil then
		log.info("[Forced Display Settings] No Current Aspect Ratio");
		customization_menu.status = "No Current Aspect Ratio";
		return;
	end

	local next_aspect_ratio = table_helpers.find_index(display_settings.aspect_ratios, config.current_config.forced_aspect_ratio.aspect_ratio);
	next_aspect_ratio = next_aspect_ratio - 1;

	if current_aspect_ratio == next_aspect_ratio then
		return;
	end

	set_option_value_method:call(option_data_container, option_types.aspect_ratio, next_aspect_ratio);
	apply_option_value_method:call(option_manager, option_types.aspect_ratio);
end

function display_settings.force_framerate()
	if not config.current_config.forced_framerate.enabled then
		return;
	end

	if option_manager == nil then
		option_manager = sdk.get_managed_singleton("snow.StmOptionManager");
	
		if option_manager == nil then
			log.info("[Forced Display Settings] No Option Manager");
			customization_menu.status = "No Option Manager";
			return;
		end
	end

	local option_data_container = get_option_data_container_method:call(option_manager);
	if option_data_container == nil then
		log.info("[Forced Display Settings] No Option Data Container");
		customization_menu.status = "No Option Data Container";
		return;
	end

	local current_framerate = get_framerate_option_method:call(option_data_container);
	if current_framerate == nil then
		log.info("[Forced Display Settings] No Current Framerate");
		customization_menu.status = "No Current Framerate";
		return;
	end

	local next_framerate = table_helpers.find_index(display_settings.framerates, config.current_config.forced_framerate.framerate, true);
	if next_framerate == nil then
		return;
	end

	next_framerate = next_framerate - 1;

	if current_framerate == next_framerate then
		return;
	end

	set_option_value_method:call(option_data_container, option_types.framerate, next_framerate);
	apply_option_value_method:call(option_manager, option_types.framerate);
end

function display_settings.force_vsync()
	if not config.current_config.forced_vsync.enabled then
		return;
	end

	if option_manager == nil then
		option_manager = sdk.get_managed_singleton("snow.StmOptionManager");
	
		if option_manager == nil then
			log.info("[Forced Display Settings] No Option Manager");
			customization_menu.status = "No Option Manager";
			return;
		end
	end

	local option_data_container = get_option_data_container_method:call(option_manager);
	if option_data_container == nil then
		log.info("[Forced Display Settings] No Option Data Container");
		customization_menu.status = "No Option Data Container";
		return;
	end

	local current_vsync = get_vsync_option_method:call(option_data_container);
	if current_vsync == nil then
		log.info("[Forced Display Settings] No Current V-Sync");
		customization_menu.status = "No Current V-Sync";
		return;
	end

	local next_vsync = 1;
	if config.current_config.forced_vsync.vsync then
		next_vsync = 0;
	end

	if current_vsync == next_vsync then
		return;
	end

	set_option_value_method:call(option_data_container, option_types.vsync, next_vsync);
	apply_option_value_method:call(option_manager, option_types.vsync);
end

function display_settings.save()
	if save_service == nil then
		save_service = sdk.get_managed_singleton("snow.SnowSaveService");
	
		if save_service == nil then
			log.info("[Forced Display Settings] No Save Service");
			customization_menu.status = "No Save Service";
			return;
		end
	end

	save_system_data_method:call(save_service);
end

function display_settings.populate_resolutions()
	if option_manager == nil then
		option_manager = sdk.get_managed_singleton("snow.StmOptionManager");
	
		if option_manager == nil then
			log.info("[Forced Display Settings] No Option Manager");
			customization_menu.status = "No Option Manager";
			return;
		end
	end

	local resolution_info_array = get_resolution_infos_method:call(option_manager);
	if resolution_info_array == nil then
		log.info("[Forced Display Settings] No Resolution Info Array");
		customization_menu.status = "No Resolution Info Array";
		return;
	end

	local resolution_info_array_length = length_method:call(resolution_info_array);
	if resolution_info_array_length == nil then
		log.info("[Forced Display Settings] No Resolution Info Array Length");
		customization_menu.status = "No Resolution Info Array Length";
		return;
	end

	local resolution_indices = {};
	local resolution_names = {};

	for i = 0, resolution_info_array_length - 1 do
		local resolution_info = get_value_method:call(resolution_info_array, i);
		if resolution_info == nil then
			goto continue
		end
		
		local resolution_index = resolution_index_field:get_data(resolution_info);
		local resolution_name = resolution_name_field:get_data(resolution_info)

		if resolution_index ~= nil then
			table.insert(resolution_indices, resolution_index);
		end

		if resolution_name ~= nil then
			table.insert(resolution_names, resolution_name);
		end

		::continue::
	end

	display_settings.resolution_indices = resolution_indices;
	display_settings.resolution_names = resolution_names;
end

function display_settings.populate_refresh_rates()
	if option_manager == nil then
		option_manager = sdk.get_managed_singleton("snow.StmOptionManager");
	
		if option_manager == nil then
			log.info("[Forced Display Settings] No Option Manager");
			customization_menu.status = "No Option Manager";
			return;
		end
	end

	local refresh_rate_info_array = get_refresh_rate_infos_method:call(option_manager);
	if refresh_rate_info_array == nil then
		log.info("[Forced Display Settings] No Resolution Info Array");
		customization_menu.status = "No Resolution Info Array";
		return;
	end

	local refresh_rate_info_array_length = length_method:call(refresh_rate_info_array);
	if refresh_rate_info_array_length == nil then
		log.info("[Forced Display Settings] No Refrash Rate Info Array Length");
		customization_menu.status = "No Refrash Rate Info Array Length";
		return;
	end

	local refresh_rate_indices = {};
	local refresh_rate_names = {};

	for i = 0, refresh_rate_info_array_length - 1 do
		local refresh_rate_info = get_value_method:call(refresh_rate_info_array, i);
		if refresh_rate_info == nil then
			goto continue
		end

		local resolution_index = refresh_rate_index_field:get_data(refresh_rate_info);
		local resolution_name = refresh_rate_name_field:get_data(refresh_rate_info)

		if resolution_index ~= nil then
			table.insert(refresh_rate_indices, resolution_index);
		end

		if resolution_name ~= nil then
			table.insert(refresh_rate_names, resolution_name);
		end

		::continue::
	end

	display_settings.refresh_rate_indices = refresh_rate_indices;
	display_settings.refresh_rate_names = refresh_rate_names;
end

function display_settings.populate_output_displays()
	if option_manager == nil then
		option_manager = sdk.get_managed_singleton("snow.StmOptionManager");
	
		if option_manager == nil then
			log.info("[Forced Display Settings] No Option Manager");
			customization_menu.status = "No Option Manager";
			return;
		end
	end

	local display_info_array = get_display_infos_method:call(option_manager);
	if display_info_array == nil then
		log.info("[Forced Display Settings] No Display Info Array");
		customization_menu.status = "No Display Info Array";
		return;
	end

	local display_info_array_length = length_method:call(display_info_array);
	if display_info_array_length == nil then
		log.info("[Forced Display Settings] No Display Info Array Length");
		customization_menu.status = "No Display Info Array Length";
		return;
	end

	local display_ids = {};
	local display_names = {};

	for i = 0, display_info_array_length - 1 do
		local display_info = get_value_method:call(display_info_array, i);
		if display_info == nil then
			goto continue
		end
		
		local display_index = display_id_field:get_data(display_info);
		local display_name = display_name_field:get_data(display_info)

		if display_index ~= nil then
			table.insert(display_ids, display_index);
		end

		if display_name ~= nil then
			if display_name == "" then
				table.insert(display_names, "DISPLAY " .. tostring(display_index + 1));
			end
			table.insert(display_names, display_name);
		end

		::continue::
	end

	display_settings.display_ids = display_ids;
	display_settings.display_names = display_names;
end

function display_settings.on_display_setting_changed()
	display_settings.populate_resolutions();
	display_settings.populate_refresh_rates();

	if not display_mode_waiting_for_output_display_change then
		return;
	end

	display_mode_waiting_for_output_display_change = false;

	if option_manager == nil then
		option_manager = sdk.get_managed_singleton("snow.StmOptionManager");
	
		if option_manager == nil then
			log.info("[Forced Display Settings] No Option Manager");
			customization_menu.status = "No Option Manager";
			display_settings.init();
			return;
		end
	end

	local option_data_container = get_option_data_container_method:call(option_manager);
	if option_data_container == nil then
		log.info("[Forced Display Settings] No Option Data Container");
		customization_menu.status = "No Option Data Container";
		display_settings.init();
		return;
	end

	local next_display_mode = table_helpers.find_index(display_settings.display_modes, last_window_mode, true);
	if next_display_mode == nil then 
		display_settings.init();
		return;
	end
	
	next_display_mode = next_display_mode - 1;

	set_option_value_method:call(option_data_container, option_types.window_mode, next_display_mode);
	apply_option_value_method:call(option_manager, option_types.window_mode);

	display_settings.init()
end

function display_settings.on_window_mode_changed()
	if not output_display_waiting_for_display_mode_change then
		return;
	end

	output_display_waiting_for_display_mode_change = false;

	if option_manager == nil then
		option_manager = sdk.get_managed_singleton("snow.StmOptionManager");
	
		if option_manager == nil then
			log.info("[Forced Display Settings] No Option Manager");
			customization_menu.status = "No Option Manager";
			display_settings.init();
			return;
		end
	end

	local option_data_container = get_option_data_container_method:call(option_manager);
	if option_data_container == nil then
		log.info("[Forced Display Settings] No Option Data Container");
		customization_menu.status = "No Option Data Container";
		display_settings.init();
		return;
	end

	local next_output_display = config.current_config.forced_output_display.display_id;

	display_mode_waiting_for_output_display_change = true;

	set_option_value_method:call(option_data_container, option_types.output_display, next_output_display);
	apply_option_value_method:call(option_manager, option_types.output_display);
end

function display_settings.init()
	if force_on_init then
		force_on_init = false;

		display_settings.populate_resolutions();
		display_settings.populate_refresh_rates();

		display_settings.force_display_mode();
		display_settings.force_resolution();
		display_settings.force_refresh_rate();
		display_settings.force_aspect_ratio();
		display_settings.force_framerate();
		display_settings.force_vsync();
	end
end

function display_settings.init_module()
	config = require("Forced_Display_Settings.config");
	table_helpers = require("Forced_Display_Settings.table_helpers");
	customization_menu = require("Forced_Display_Settings.customization_menu");

	sdk.hook(on_display_setting_changed_method, function(args) end, function(retval)
		display_settings.on_display_setting_changed();
		return retval;
	end);

	sdk.hook(on_window_mode_changed_method, function(args) end, function(retval)
		display_settings.on_window_mode_changed();
		return retval;
	end);

	option_manager = sdk.get_managed_singleton("snow.StmOptionManager");

	if option_manager == nil then
		sdk.hook(option_manager_start_method, function(args) end, function(retval)
			display_settings.populate_output_displays();
			display_settings.force_output_display();
			return retval;
		end);
	else
		display_settings.populate_output_displays();
		display_settings.force_output_display();
	end
end

return display_settings;
