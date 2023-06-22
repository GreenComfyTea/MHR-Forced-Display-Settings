local this = {};

local utils;

local sdk = sdk;
local tostring = tostring;
local pairs = pairs;
local ipairs = ipairs;
local tonumber = tonumber;
local require = require;
local pcall = pcall;
local table = table;
local string = string;
local Vector3f = Vector3f;
local d2d = d2d;
local math = math;
local json = json;
local log = log;
local fs = fs;
local next = next;
local type = type;
local setmetatable = setmetatable;
local getmetatable = getmetatable;
local assert = assert;
local select = select;
local coroutine = coroutine;
local utf8 = utf8;
local re = re;
local imgui = imgui;
local draw = draw;
local Vector2f = Vector2f;
local reframework = reframework;

this.current_config = nil;
this.config_file_name = "Forced Display Settings/config.json";

this.default_config = {};

function this.init()
	this.default_config = {
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

function this.load()
	local loaded_config = json.load_file(this.config_file_name);
	if loaded_config ~= nil then
		log.info("[Forced Display Settings] config.json loaded successfully");
		this.current_config = utils.table.merge(this.default_config, loaded_config);
	else
		log.error("[Forced Display Settings] Failed to load config.json");
		this.current_config = utils.table.deep_copy(this.default_config);
	end
end

function this.save()
	-- save current config to disk, replacing any existing file
	local success = json.dump_file(this.config_file_name, this.current_config);
	if success then
		log.info("[Forced Display Settings] config.json saved successfully");
	else
		log.error("[Forced Display Settings] Failed to save config.json");
	end
end

function this.init_module()
	utils = require("Forced_Display_Settings.utils");

	this.init();
	this.load();
	this.current_config.version = "2.4";
end

return this;
