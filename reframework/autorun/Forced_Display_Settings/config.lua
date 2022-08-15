local config = {};
local table_helpers;

config.current_config = nil;
config.config_file_name = "Forced Display Settings/config.json";

config.default_config = {};

function config.init()
	config.default_config = {
		forced_output_display = {
			enabled = false,
			display_id = 0
		},

		forced_display_mode = {
			enabled = false,
			display_mode = "Borderless Windowed"
		},

		forced_resolution = {
			enabled = false,
			resolution = "1920x1080"
		},

		forced_refresh_rate = {
			enabled = false,
			refresh_rate = "60.00Hz"
		},

		forced_aspect_ratio = {
			enabled = false,
			aspect_ratio = "16:9"
		},

		forced_framerate = {
			enabled = false,
			framerate = "Unlimited"
		},

		forced_vsync = {
			enabled = false,
			vsync = true
		},
	};
end

function config.load()
	local loaded_config = json.load_file(config.config_file_name);
	if loaded_config ~= nil then
		log.info("[Forced Display Settings] config.json loaded successfully");
		config.current_config = table_helpers.merge(config.default_config, loaded_config);
	else
		log.error("[Forced Display Settings] Failed to load config.json");
		config.current_config = table_helpers.deep_copy(config.default_config);
	end
end

function config.save()
	-- save current config to disk, replacing any existing file
	local success = json.dump_file(config.config_file_name, config.current_config);
	if success then
		log.info("[Forced Display Settings] config.json saved successfully");
	else
		log.error("[Forced Display Settings] Failed to save config.json");
	end
end

function config.init_module()
	table_helpers = require("Forced_Display_Settings.table_helpers");

	config.init();
	config.load();
	config.current_config.version = "2.2";
end

return config;
