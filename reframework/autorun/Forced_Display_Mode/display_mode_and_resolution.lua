local display_mode_and_resolution = {};
local table_helpers;
local config;
local customization_menu;

display_mode_and_resolution.resolution_names = {};
display_mode_and_resolution.resolution_indices = {};

local renderer = nil;
local option_manager = nil;


local renderer_type = sdk.find_type_definition("via.render.Renderer");
local get_window_mode = renderer_type:get_method("get_WindowMode");
local set_window_mode = renderer_type:get_method("set_WindowMode");

local option_manager_type_def = sdk.find_type_definition("snow.StmOptionManager");
--local on_apply_option_value_method = option_manager_type_def:get_method("applyOptionValue(snow.StmOptionDef.StmOptionType)");
local apply_option_value_2_method = option_manager_type_def:get_method("applyOptionValue(snow.StmOptionDef.StmOptionType, System.Int32)");
local get_resolution_infos_method = option_manager_type_def:get_method("getResolutionInfos");

local resolution_info_type_def = sdk.find_type_definition("snow.ResolutionInfo");
local resolution_index_field = resolution_info_type_def:get_field("<ResolutionIndex>k__BackingField");
local resolution_name_field = resolution_info_type_def:get_field("<ResolutionName>k__BackingField");

function display_mode_and_resolution.get_display_mode_id(display_mode_string)
	if display_mode_string == "Borderless Windowed" then
		return 2;
	end

	if display_mode_string == "Fullscreen" then
		return 1;
	end

	return 0;
end

function display_mode_and_resolution.force_display_mode()
	if not config.current_config.forced_display_mode.enabled then
		return;
	end

	if renderer == nil then
		renderer = sdk.get_native_singleton("via.render.Renderer");

		if renderer == nil then
			log.info("[Forced Display Mode] No renderer");
			customization_menu.status = "No renderer";
			return;
		end
	end

	local current_window_mode = get_window_mode:call(renderer);

	if current_window_mode == nil then
		log.error("[Forced Display Mode] Current Window Mode not found");
		customization_menu.status = "Current Window Mode not found";
		return;
	end

	local display_mode_index = display_mode_and_resolution.get_display_mode_id(config.current_config.forced_display_mode.display_mode);

	if current_window_mode ~= display_mode_index then
		set_window_mode:call(renderer, display_mode_index);
	end
end

function display_mode_and_resolution.force_resolution()
	if not config.current_config.forced_resolution.enabled then
		return;
	end

	if option_manager == nil then
		option_manager = sdk.get_managed_singleton("snow.StmOptionManager");
	
		if option_manager == nil then
			log.info("[Forced Display Mode] No Option Manager");
			customization_menu.status = "No Option Manager";
			return;
		end
	end

	local script_resolution_index = table_helpers.find_index(display_mode_and_resolution.resolution_names, config.current_config.forced_resolution.resolution);
	local in_game_resolution_index = display_mode_and_resolution.resolution_indices[script_resolution_index];

	apply_option_value_2_method:call(option_manager, 29, in_game_resolution_index);
end

-- option_type = snow.StmOptionDef.StmOptionType
function display_mode_and_resolution.on_apply_option_value_2(option_type, option_value)
	-- 27 - display mode
	-- 29 - resolution
	--if option_type == 27 or option_type == 29 then
	--	xy = tostring(option_type) .. " " .. tostring(option_value);
	--end
end

function display_mode_and_resolution.populate_resolutions()
	if #display_mode_and_resolution.resolution_names ~= 0 then
		return;
	end

	if option_manager == nil then
		option_manager = sdk.get_managed_singleton("snow.StmOptionManager");
	
		if option_manager == nil then
			log.info("[Forced Display Mode] No Option Manager");
			customization_menu.status = "No Option Manager";
			return;
		end
	end

	local resolution_info_array = get_resolution_infos_method:call(option_manager);
	if resolution_info_array == nil then
		log.info("[Forced Display Mode] No Resolution Info Array");
		customization_menu.status = "No Resolution Info Array";
		return;
	end

	local resolution_info_array_size = resolution_info_array:get_size();
	
	for i = 0, resolution_info_array_size - 1 do
		local resolution_info = resolution_info_array[i];

		local resolution_index = resolution_index_field:get_data(resolution_info);
		local resolution_name = resolution_name_field:get_data(resolution_info)

		if resolution_index ~= nil then
			table.insert(display_mode_and_resolution.resolution_indices, resolution_index);
		end

		if resolution_name ~= nil then
			table.insert(display_mode_and_resolution.resolution_names, resolution_name);
		end
	end
end

function display_mode_and_resolution.init_module()
	config = require("Forced_Display_Mode.config");
	table_helpers = require("Forced_Display_Mode.table_helpers");
	customization_menu = require("Forced_Display_Mode.customization_menu");

	display_mode_and_resolution.populate_resolutions();

	sdk.hook(apply_option_value_2_method, function(args)
		display_mode_and_resolution.on_apply_option_value_2(sdk.to_int64(args[3]), sdk.to_int64(args[4]));
	end, function(retval)
		return retval;
	end);

	display_mode_and_resolution.force_display_mode();
	display_mode_and_resolution.force_resolution();
end

return display_mode_and_resolution;
