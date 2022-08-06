local config = {};
local table_helpers;

config.current_config = nil;
config.config_file_name = "Forced Display Mode and Resolution/config.json";

config.default_config = {};

function config.init()
	config.default_config = {
		forced_display_mode = {
			enabled = true,
			display_mode = "Borderless Windowed"
		},

		forced_resolution = {
			enabled = true,
			resolution = "1920x1080"
		}
		
	};
end

function config.load()
	local loaded_config = json.load_file(config.config_file_name);
	if loaded_config ~= nil then
		log.info("[Forced Display Mode and Resolution] config.json loaded successfully");
		config.current_config = table_helpers.merge(config.default_config, loaded_config);
	else
		log.error("[Forced Display Mode and Resolution] Failed to load config.json");
		config.current_config = table_helpers.deep_copy(config.default_config);
	end
end

function config.save()
	-- save current config to disk, replacing any existing file
	local success = json.dump_file(config.config_file_name, config.current_config);
	if success then
		log.info("[Forced Display Mode and Resolution] config.json saved successfully");
	else
		log.error("[Forced Display Mode and Resolution] Failed to save config.json");
	end
end

function config.init_module()
	table_helpers = require("Forced_Display_Mode.table_helpers");

	config.init();
	config.load();
	config.current_config.version = "v2.1";
end

return config;
