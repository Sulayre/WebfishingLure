extends Node

# MODULES // this is so stinky im so sorry
const _modules = {
	"Patches":	preload("res://mods/Sulayre.Lure/Modules/Patches.gd"),
	"Util":		preload("res://mods/Sulayre.Lure/Modules/Util.gd"),
	"Loader":	preload("res://mods/Sulayre.Lure/Modules/Loader.gd"),
	"Printer":	preload("res://mods/Sulayre.Lure/Modules/Printer.gd"),
	"Mapper":	preload("res://mods/Sulayre.Lure/Modules/Mapper.gd")
}

const prompt = preload("res://mods/Sulayre.Lure/Scenes/MainMenu/BonusContentPrompt.tscn")

var Patches
var Util
var Buffer
var Loader
var Printer
var Mapper

# ENUMS
enum FLAGS {
	SHOP_POSSUM, # THESE
	SHOP_FROG, # ARE
	SHOP_BEACH, # UNUSED !!!!
	FREE_UNLOCK,
	LOCK_AFTER_SHOP_UPDATE,
	VENDING_MACHINE,
}

# don't use this its obsolete its only for old lure mods to work
enum LURE_FLAGS {
	SHOP_POSSUM,
	SHOP_FROG,
	SHOP_BEACH,
	FREE_UNLOCK,
}


enum {
	MOD_NOT_FOUND,
	NEIGHBOR_MOD_NOT_FOUND,
	RESOURCE_PATH_INVALID,
	RESOURCE_NOT_FOUND,
	RESOURCE_UNKNOWN_ERROR,
	RESOURCE_CLASS_INCORRECT,
	PATTERN_TEXTURE_MISSING,
	ALTERNATIVE_MESH_MISSING,
	SPECIES_ANIMATION_MISSING,
	TEXTURE_BUFFER_MISSING_PATTERN_REFERENCE,
	TEXTURE_BUFFER_MISSING_SPECIES_REFERENCE,
	MESH_BUFFER_MISSING_COSMETIC_REFERENCE,
	MESH_BUFFER_MISSING_SPECIES_REFERENCE,
	SPECIES_ANIMATION_UNREGISTERED,
	ASSIGNED_NOT_ANIMATION,
	VOICE_BARK_MISSING,
	VOICE_SECONDARY_MISSING,
	PROPS_SCENE_MISSING,
	ACTION_NODE_NULL,
	ACTION_FUNCTION_MISSING,
	ACTION_MISSING,
	SAVE_UNKNOWN,
	MAP_NOT_FOUND,
	EMOTE_NOT_FOUND,
}

# CONSTANTS
const ID = "Sulayre.Lure"
const MODS_FOLDER = "res://mods"

const OWN_MOD_PREFIX = "mod://"
const PREFIX = "[LURE/MAIN]: "

const VANILLA_SPECIES = ["species_cat","species_dog"]

const vanilla_tables = [
	"none",
	"lake",
	"ocean",
	"deep",
	"prehistoric",
	"bush_bug",
	"shoreline_bug",
	"tree_bug",
	"seashell",
	"trash",
	"water_trash",
	"rain",
	"alien",
	"metal"
]

# SIGNALS
signal main_menu_enter
signal game_enter
signal world_enter
signal _vanilla_saved
signal lurlog(log_id,error)
signal mod_map_loaded

# VARIABLES

var dir = Directory.new()
var bonus_prompt = false

var loaded_cosmetics = []
var loaded_items = []

# don't open this you'll regret it
const vanilla_cosmetics = [
	"pattern_spotted",
	"pattern_collie",
	"pattern_calico",
	"pattern_none",
	"pattern_tux",
	"tail_dog_short",
	"tail_none",
	"tail_cat",
	"tail_dog_fluffy",
	"tail_dog_thin",
	"tail_fox",
	"overshirt_flannel_open_yellow",
	"overshirt_vest_olive",
	"overshirt_flannel_open_black",
	"overshirt_sweatshirt_tan",
	"overshirt_sweatshirt_olive",
	"overshirt_sweatshirt_black",
	"overshirt_vest_grey",
	"overshirt_sweatshirt_purple",
	"overshirt_flannel_closed_black",
	"overshirt_overall_grey",
	"overshirt_flannel_closed_white",
	"overshirt_flannel_closed_teal",
	"overshirt_sweatshirt_orange",
	"overshirt_flannel_open_white",
	"overshirt_vest_green",
	"overshirt_flannel_open_salmon",
	"overshirt_vest_tan",
	"overshirt_flannel_closed_red",
	"overshirt_flannel_closed_blue",
	"overshirt_flannel_open_olive",
	"overshirt_flannel_open_red",
	"overshirt_flannel_open_teal",
	"overshirt_flannel_closed_salmon",
	"overshirt_overall_green",
	"overshirt_sweatshirt_teal",
	"overshirt_vest_black",
	"overshirt_overall_brown",
	"overshirt_flannel_open_green",
	"overshirt_sweatshirt_white",
	"overshirt_overall_olive",
	"overshirt_flannel_closed_yellow",
	"overshirt_sweatshirt_blue",
	"overshirt_flannel_closed_olive",
	"overshirt_sweatshirt_green",
	"overshirt_sweatshirt_yellow",
	"overshirt_overall_tan",
	"overshirt_flannel_closed_purple",
	"overshirt_sweatshirt_red",
	"overshirt_flannel_open_blue",
	"overshirt_flannel_open_purple",
	"overshirt_flannel_closed_green",
	"overshirt_overall_yellow",
	"overshirt_sweatshirt_salmon",
	"overshirt_sweatshirt_brown",
	"overshirt_sweatshirt_maroon",
	"overshirt_labcoat",
	"overshirt_trenchcoat",
	"overshirt_sweatshirt_grey",
	"legs_none",
	"overshirt_none",
	"species_dog",
	"shirt_none",
	"species_cat",
	"hat_none",
	"hat_cowboyhat_brown",
	"hat_beanie_blue",
	"hat_beanie_black",
	"hat_baseball_cap_size",
	"hat_crown",
	"hat_cowboyhat_pink",
	"hat_baseball_cap_big",
	"hat_baseball_cap_exclaim",
	"hat_bucket_tan",
	"hat_beanie_yellow",
	"hat_baseball_cap_green",
	"hat_baseball_cap_sports",
	"hat_bucket_green",
	"hat_baseball_cap_pee",
	"hat_cowboyhat_black",
	"hat_baseball_cap_mcd",
	"hat_baseball_cap_missing",
	"hat_tophat",
	"hat_beanie_maroon",
	"hat_beanie_green",
	"hat_baseball_cap_orange",
	"hat_beanie_teal",
	"hat_beanie_white",
	"title_creature",
	"title_musky",
	"title_dude",
	"title_elite",
	"title_king",
	"title_none",
	"title_sharkbait",
	"title_goldenray",
	"title_goober",
	"title_nightcrawler",
	"title_soggy",
	"title_bi",
	"title_cryptid",
	"title_littlelad",
	"title_lamedev_real",
	"title_shithead",
	"title_iscool",
	"title_goodgirl",
	"title_cozy",
	"title_strongestwarrior",
	"title_gay",
	"title_sillyguy",
	"title_goldenbass",
	"title_goodboy",
	"title_special",
	"title_nonbinary",
	"title_queer",
	"title_majestic",
	"title_cadaverdog",
	"title_stupididiotbaby",
	"title_freaky",
	"title_ancient",
	"title_puppy",
	"title_fishpilled",
	"title_pup",
	"title_yapper",
	"title_lesbian",
	"title_bipedalanimaldrawer",
	"title_imnormal",
	"title_ace",
	"title_problematic",
	"title_trans",
	"title_kitten",
	"title_stinkerdinker",
	"title_equalsthree",
	"title_pan",
	"title_straight",
	"title_critter",
	"title_catfisher",
	"title_koiboy",
	"title_pretty",
	"title_lamedev",
	"eye_inverted",
	"eye_lenny",
	"eye_fierce",
	"eye_plead",
	"eye_x",
	"eye_goat",
	"eye_closed",
	"eye_froggy",
	"eye_sassy",
	"eye_glare",
	"eye_sideeye",
	"eye_possessed",
	"eye_scribble",
	"eye_focused",
	"eye_glance",
	"eye_serious",
	"eye_glamor",
	"eye_wings",
	"eye_drained",
	"eye_angry",
	"eye_annoyed",
	"eye_catsoup",
	"eye_almond",
	"eye_dot",
	"eye_tired",
	"eye_haunted",
	"eye_jolly",
	"eye_herbal",
	"eye_spiral",
	"eye_distraught",
	"eye_dreaming",
	"eye_starlight",
	"eye_wobble",
	"eye_halfclosed",
	"eye_alien",
	"eye_sad",
	"eye_squared",
	"eye_bagged",
	"eye_dispondant",
	"eye_harper",
	"legs_pants_short_salmon",
	"legs_pants_short_black",
	"legs_pants_long_black",
	"legs_pants_long_maroon",
	"legs_pants_short_olive",
	"legs_pants_long_white",
	"legs_pants_short_white",
	"legs_pants_long_blue",
	"legs_pants_short_purple",
	"legs_pants_short_orange",
	"legs_pants_short_tan",
	"legs_pants_long_salmon",
	"legs_pants_short_red",
	"legs_pants_long_red",
	"legs_pants_long_green",
	"legs_pants_long_tan",
	"legs_pants_short_green",
	"legs_pants_long_orange",
	"legs_pants_long_teal",
	"legs_pants_long_olive",
	"legs_pants_long_grey",
	"legs_pants_short_teal",
	"legs_pants_short_blue",
	"legs_pants_short_maroon",
	"legs_pants_short_brown",
	"legs_pants_long_purple",
	"legs_pants_long_yellow",
	"legs_pants_long_brown",
	"legs_pants_short_yellow",
	"legs_pants_short_grey",
	"accessory_eyepatch",
	"accessory_watch",
	"accessory_stink_particles",
	"accessory_glasses_round",
	"accessory_collar_bell",
	"accessory_sword",
	"accessory_shades_gold",
	"accessory_monocle",
	"accessory_shades",
	"accessory_antlers",
	"accessory_rain_boots_green",
	"accessory_ring",
	"accessory_shoes",
	"accessory_goldsparkle_particles",
	"accessory_rain_boots_yellow",
	"accessory_heart_particles",
	"accessory_alien_particles",
	"accessory_bandaid",
	"accessory_collar",
	"accessory_sparkle_particles",
	"accessory_cig",
	"accessory_gloves_black",
	"accessory_hook",
	"accessory_glasses",
	"pcolor_blue",
	"pcolor_salmon",
	"pcolor_green",
	"pcolor_orange",
	"pcolor_west",
	"pcolor_brown",
	"pcolor_yellow",
	"pcolor_black",
	"pcolor_red",
	"pcolor_olive",
	"pcolor_white",
	"pcolor_pink_special",
	"pcolor_midnight_special",
	"pcolor_teal",
	"pcolor_purple",
	"pcolor_tan",
	"pcolor_stone_special",
	"pcolor_maroon",
	"pcolor_grey",
	"scolor_red",
	"scolor_midnight_special",
	"scolor_tan",
	"scolor_olive",
	"scolor_purple",
	"scolor_orange",
	"scolor_green",
	"scolor_yellow",
	"scolor_brown",
	"scolor_salmon",
	"scolor_pink_special",
	"scolor_blue",
	"scolor_black",
	"scolor_stone_special",
	"scolor_white",
	"scolor_grey",
	"scolor_teal",
	"scolor_maroon",
	"bobber_default",
	"bobber_ducky",
	"bobber_lilypad",
	"bobber_slip",
	"bobber_bomb",
	"mouth_grimace",
	"mouth_bite",
	"mouth_squiggle",
	"mouth_rabid",
	"mouth_none",
	"mouth_chewing",
	"mouth_dead",
	"mouth_drool",
	"mouth_fangs",
	"mouth_distraught",
	"mouth_happy",
	"mouth_grin",
	"mouth_animal",
	"mouth_stitch",
	"mouth_jaws",
	"mouth_shocked",
	"mouth_braces",
	"mouth_glad",
	"mouth_smirk",
	"mouth_monster",
	"mouth_toothier",
	"mouth_hymn",
	"mouth_sabertooth",
	"mouth_toothy",
	"mouth_fishy",
	"mouth_tongue",
	"mouth_bucktoothed",
	"mouth_default",
	"mouth_aloof",
	"title_rank_1",
	"title_rank_50",
	"title_rank_15",
	"title_rank_35",
	"title_rank_20",
	"title_rank_10",
	"title_rank_30",
	"title_rank_40",
	"title_rank_5",
	"title_rank_45",
	"title_rank_25",
	"nose_nostril",
	"nose_booger",
	"nose_none",
	"nose_pierced",
	"nose_dog",
	"nose_clown",
	"nose_pink",
	"nose_long",
	"nose_button",
	"nose_cat",
	"nose_round",
	"nose_whisker",
	"nose_v",
	"undershirt_graphic_tshirt_anchor",
	"undershirt_tanktop_black",
	"undershirt_tanktop_white",
	"undershirt_graphic_tshirt_burger",
	"undershirt_graphic_tshirt_pan",
	"undershirt_graphic_tshirt_bi",
	"undershirt_graphic_tshirt_hooklite",
	"undershirt_tshirt_tan",
	"undershirt_tanktop_maroon",
	"undershirt_graphic_tshirt_dare",
	"undershirt_tshirt_blue",
	"undershirt_tanktop_orange",
	"undershirt_graphic_tshirt_soscary",
	"undershirt_tanktop_teal",
	"undershirt_graphic_tshirt_trans",
	"undershirt_graphic_tshirt_ace",
	"undershirt_tanktop_green",
	"undershirt_graphic_tshirt_threewolves",
	"undershirt_tshirt_red",
	"undershirt_tshirt_white",
	"undershirt_tanktop_purple",
	"undershirt_tshirt_purple",
	"undershirt_graphic_tshirt_lesbian",
	"undershirt_tshirt_olive",
	"undershirt_tanktop_olive",
	"undershirt_graphic_tshirt_soup",
	"undershirt_tanktop_grey",
	"undershirt_graphic_tshirt_smokemon",
	"undershirt_graphic_tshirt_milf",
	"undershirt_tshirt_salmon",
	"undershirt_graphic_tshirt_mlm",
	"undershirt_graphic_tshirt_goodboy",
	"undershirt_tanktop_tan",
	"undershirt_tshirt_green",
	"undershirt_tshirt_orange",
	"undershirt_tshirt_grey",
	"undershirt_graphic_tshirt_nobait",
	"undershirt_graphic_tshirt_nonbinary",
	"undershirt_tanktop_red",
	"undershirt_tanktop_salmon",
	"undershirt_tanktop_brown",
	"undershirt_tshirt_teal",
	"undershirt_tanktop_blue",
	"undershirt_graphic_tshirt_gay",
	"undershirt_tshirt_maroon",
	"undershirt_tshirt_yellow",
	"undershirt_tshirt_black",
	"undershirt_tshirt_brown",
	"undershirt_tanktop_yellow",
]

#also this
const vanilla_items = [
	"fish_deep_testc",
	"fish_deep_testb",
	"fish_deep_test",
	"mdl_ring",
	"mdl_piece_hat",
	"mdl_piece_watch",
	"mdl_piece_monocle",
	"mdl_casing",
	"mdl_sodatab",
	"mdl_button",
	"mdl_piece_sword",
	"mdl_coin",
	"fish_rain_heliocoprion",
	"fish_rain_leedsichthys",
	"fish_rain_anomalocaris",
	"fish_rain_horseshoe_crab",
	"potion_bounce",
	"potion_small",
	"potion_catch_big",
	"potion_beer",
	"potion_wine",
	"potion_grow",
	"potion_catch",
	"potion_catch_deluxe",
	"potion_speed",
	"potion_bouncebig",
	"potion_speed_burst",
	"potion_revert",
	"fish_alien_dog",
	"wtrash_diamond",
	"wtrash_branch",
	"wtrash_sodacan",
	"wtrash_drink_rings",
	"wtrash_plastic_bag",
	"wtrash_bone",
	"wtrash_weed",
	"wtrash_boot",
	"fishing_rod_collectors_glistening",
	"fishing_rod_simple",
	"guitar_gradient",
	"fishing_rod_travelers",
	"scratch_off",
	"boxing_glove",
	"guitar_black",
	"fishing_rod_prosperous",
	"metal_detector",
	"fish_trap_ocean",
	"treasure_chest",
	"fishing_rod_collectors_opulent",
	"guitar",
	"guitar_gold",
	"fishing_rod_collectors_shining",
	"fishing_rod_collectors_alpha",
	"fishing_rod_collectors_radiant",
	"tambourine",
	"portable_bait",
	"fish_trap",
	"hand_labeler",
	"boxing_glove_super",
	"fishing_rod_collectors",
	"fishing_rod_skeleton",
	"guitar_stickers",
	"guitar_pink",
	"ringbox",
	"scratch_off_2",
	"scratch_off_3",
	"chalk_eraser",
	"chalk_white",
	"chalk_yellow",
	"chalk_blue",
	"chalk_red",
	"chalk_special",
	"chalk_black",
	"chalk_green",
	"fish_ocean_seahorse",
	"fish_ocean_swordfish",
	"fish_ocean_sawfish",
	"fish_ocean_sunfish",
	"fish_ocean_marlin",
	"fish_ocean_squid",
	"fish_ocean_atlantic_salmon",
	"fish_ocean_krill",
	"fish_ocean_lionfish",
	"fish_ocean_bluefish",
	"fish_ocean_flounder",
	"fish_ocean_clownfish",
	"fish_ocean_manta_ray",
	"fish_ocean_manowar",
	"fish_ocean_wolffish",
	"fish_ocean_whale",
	"fish_ocean_hammerhead_shark",
	"fish_ocean_shrimp",
	"fish_ocean_octopus",
	"fish_ocean_lobster",
	"fish_ocean_tuna",
	"fish_ocean_grouper",
	"fish_ocean_stingray",
	"fish_ocean_oyster",
	"fish_ocean_sea_turtle",
	"fish_ocean_herring",
	"fish_ocean_coalacanth",
	"fish_ocean_dogfish",
	"fish_ocean_eel",
	"fish_ocean_golden_manta_ray",
	"fish_ocean_greatwhiteshark",
	"fish_ocean_angelfish",
	"luck_moneybag",
	"spectral_rib",
	"spectral_spine",
	"net",
	"paint_brush",
	"shovel",
	"spectral_femur",
	"painting",
	"spectral_skull",
	"empty_hand",
	"spectral_humerus",
	"prop_island_tiny",
	"prop_bush",
	"prop_well",
	"prop_boombox",
	"prop_chair",
	"prop_table",
	"prop_therapy_seat",
	"prop_greenscreen",
	"prop_island_big",
	"prop_canvas",
	"prop_rock",
	"prop_beer",
	"prop_whoopie",
	"prop_test",
	"prop_picnic",
	"prop_toilet",
	"prop_campfire",
	"prop_island_med",
	"fish_lake_sturgeon",
	"fish_lake_mooneye",
	"fish_lake_kingsalmon",
	"fish_lake_koi",
	"fish_lake_alligator",
	"fish_lake_rainbowtrout",
	"fish_lake_snail",
	"fish_lake_crayfish",
	"fish_lake_perch",
	"fish_lake_axolotl",
	"fish_lake_turtle",
	"fish_lake_crab",
	"fish_lake_bluegill",
	"fish_lake_walleye",
	"fish_lake_leech",
	"fish_lake_muskellunge",
	"fish_lake_crappie",
	"fish_lake_drum",
	"fish_lake_pike",
	"fish_lake_carp",
	"fish_lake_catfish",
	"fish_lake_gar",
	"fish_lake_bass",
	"fish_lake_frog",
	"fish_lake_pupfish",
	"fish_lake_toad",
	"fish_lake_bullshark",
	"fish_lake_salmon",
	"fish_lake_bowfin",
	"fish_lake_guppy",
	"fish_lake_golden_bass",
	"fish_lake_goldfish",
	"fish_void_voidfish",
]

const fallback = {
	"species": "species_cat",
	"pattern": "pattern_none",
	"primary_color": "pcolor_white",
	"secondary_color": "scolor_white",
	"hat": "hat_none",
	"undershirt": "shirt_none",
	"overshirt": "overshirt_none",
	"title": "title_none",
	"bobber": "bobber_default",
	"eye": "eye_halfclosed",
	"nose": "nose_cat",
	"mouth": "mouth_default",
	"tail": "tail_none",
	"legs": "legs_none"
}

var texture_buffer = []
var mesh_buffer = []
var animation_buffer = {}

var modded_voices = {}
var modded_actors = {}
var modded_maps = []
var modded_species = []
var modded_emotes = []
var modded_pools = []

const vanilla_tabs:Array = ["body","face","clothes","misc"]
const lure_categories:Array = ["bodies","playable_characters"]

var cosmetic_categories_array:Array = []
var cosmetic_categories:Dictionary = {
	vanilla_tabs[0]: [],
	vanilla_tabs[1]: [],
	vanilla_tabs[2]: [],
	vanilla_tabs[3]: [],
}

#var journal_categories = [\
#	["freshwater", ["lake"]], \
#	["saltwater", ["ocean"]], \
#	["misc", ["water_trash", "deep", "rain", "alien"]],\
#	["modded", []]
#	]

var action_references = {}

var filters = []

var filter_lure:bool
var filter_full:bool
var filter_mismatch:bool
var filter_dedicated:bool

var cosmetic_list:Dictionary = {}
var item_list:Dictionary = {}
var _savewaiter:Thread = Thread.new()
# godot calls

func _init():
	modded_species.append_array(VANILLA_SPECIES)

func _enter_tree():
	_load_modules()

func _ready():
	_signals()
	Network.connect("_instance_actor", self, "_instance_mod_actor")
	if OS.has_feature("editor"):
		_bonus_content_load()
	else:
		_options_check()
	#add_content("Sulayre.Lure","classic_body","res://mods/Sulayre.Lure/Resources/Cosmetics/default_body.tres",[FLAGS.FREE_UNLOCK,custom_category("bodies")])

func loot_table(table_id:String):
	if !modded_pools.has(table_id) and !vanilla_tables.has(table_id): modded_pools.append(table_id.to_lower())
	return "LURE_LOOT_TABLE_"+table_id

func custom_category(cat_id:String):
	return "LURE_COSM_CAT_"+(cat_id.to_lower())

func register_action(mod_id:String,action_id:String,function_holder:Node,function_name:String):
	if Util._validate_paths(mod_id,"res://"):
		if !function_holder:
			Printer.out(ACTION_NODE_NULL,true)
			return
		if !function_holder.has_method(function_name):
			Printer.out(ACTION_FUNCTION_MISSING,true)
		action_references[mod_id+"."+action_id] = [function_holder,function_name]

func new_wardrobe_page(tab_name:String):
	tab_name = tab_name.to_lower()
	if !tab_name.is_valid_identifier():
		print(PREFIX+tab_name+" is not a valid wardrobe page name! (use underscores instead of spaces if that's what you did)")
		return
	if !cosmetic_categories.keys().has(tab_name):
		cosmetic_categories[tab_name] = []
	print(PREFIX,"registered new wardrobe page ",tab_name)

func new_wardrobe_category(cat_name:String,tab_name:String,add_empty:bool=true):
	cat_name = cat_name.to_lower()
	tab_name = tab_name.to_lower()
	if !cosmetic_categories.keys().has(tab_name):
		print(PREFIX+cat_name+" is being added to a page that doesn't exist yet, make the categories last!")
		return
	if !cat_name.is_valid_identifier():
		print(PREFIX+cat_name+"is not a valid wardrobe category name! (use underscores instead of spaces if that's what you did)")
		return
	if cosmetic_categories[tab_name].has(cat_name):
		print(PREFIX+cat_name+"is already a registered category for page "+tab_name)
		return
	cosmetic_categories[tab_name].append([cat_name,add_empty])
	cosmetic_categories_array.append(cat_name)
	print(PREFIX,"registered new wardrobe category ",cat_name," for page ",tab_name)

# Stores a voice bank for a specific modded species.
func assign_species_voice(mod_id:String,species_id:String,bark_path:String,growl_path:String="",whine_path:String=""):
	if Util._validate_paths(mod_id,bark_path):
		var real_bark = Util._mod_path_converter(mod_id,bark_path)
		var real_growl = real_bark
		var real_whine = real_bark
		if Util._validate_paths(mod_id,growl_path):
			real_growl = Util._mod_path_converter(mod_id,growl_path)
		if Util._validate_paths(mod_id,whine_path):
			real_whine = Util._mod_path_converter(mod_id,whine_path)
		if real_growl == real_bark or real_whine == real_bark:
			Printer.out(VOICE_SECONDARY_MISSING)
		var bark_res = load(real_bark)
		var growl_res = load(real_growl)
		var whine_res = load(real_whine)
		modded_voices[species_id] = {
			"bark": bark_res,
			"growl": growl_res,
			"whine": whine_res
		}
		#print(modded_voices)
	else:
		Printer.out(VOICE_BARK_MISSING,true)


	

# Adds a new map into the map selector
func add_map(mod_id:String,map_id:String,scene_path:String,map_name:String=""):
	if Util._validate_paths(mod_id,scene_path):
		var real_path = Util._mod_path_converter(mod_id,scene_path)
		var map:PackedScene = load(real_path)
		if !map:
			Printer.out(MAP_NOT_FOUND,true)
			return
		var final_id = mod_id+"."+map_id
		if map_name == "": map_name = final_id
		modded_maps.append(
			{
				"id":final_id,
				"scene":map,
				"name":map_name
			}
		)
		print(PREFIX+"Map with ID ",map_id," has been added successfully!")

func add_emote(mod_id:String,emote_id:String,animation_path:String,icon_path:String,emotion_name:=""):
	if Util._validate_paths(mod_id,animation_path):
		var emote:Animation = load(Util._mod_path_converter(mod_id,animation_path))
		var icon:Texture = load(Util._mod_path_converter(mod_id,icon_path))
		if !emote:
			Printer.out(EMOTE_NOT_FOUND,true)
			return
		var final_id = mod_id+"."+emote_id
		modded_emotes.append(
			{
				"id":final_id,
				"animation":emote,
				"icon":icon,
				"emotion":emotion_name,
			}
		)
		print(PREFIX+"Emote with ID ",emote_id," has been added successfully!")

# Stores face animation data for a specific modded species.
func assign_face_animation(mod_id:String,species_id:String,animation_path:String):
	if Util._validate_paths(mod_id,animation_path):
		var real_path = Util._mod_path_converter(mod_id,animation_path)
		var animation:Animation = load(real_path)
		if !animation:
			Printer.out(SPECIES_ANIMATION_MISSING,true)
			return
		animation_buffer[species_id] = animation

# stores an alternative mesh for a cosmetic and dynamically sets it up so you can have custom patterns
# for both vanila and modded species
# (you can add meshes for other people's modded species btw!)
func assign_cosmetic_mesh(mod_id:String,cosmetic_id:String,species_id:String,mesh_path:String):
	if Util._validate_paths(mod_id,mesh_path):
		var real_path = Util._mod_path_converter(mod_id,mesh_path)
		var mesh:Mesh = load(real_path)
		if !mesh:
			Printer.out(ALTERNATIVE_MESH_MISSING,true)
			return
		mesh_buffer.append(
			{
				"cosmetic":cosmetic_id,
				"species":species_id,
				"mesh":mesh
			}
		)
		#print(PREFIX+"buffered alternative mesh for cosmetic "+ cosmetic_id + " for species "+species_id)

# stores a texture and dynamically sets it up so you can have custom patterns
# for both vanila and modded species
# (you can add textures for other people's modded species btw!)
func assign_pattern_texture(mod_id:String,pattern_id:String,species_id:String,texture_path:String):
	if Util._validate_paths(mod_id,texture_path):
		var real_path = Util._mod_path_converter(mod_id,texture_path)
		var texture:Texture = load(real_path)
		if !texture:
			Printer.out(PATTERN_TEXTURE_MISSING,true)
			return
		texture_buffer.append(
			{
				"pattern":pattern_id,
				"species":species_id,
				"texture":texture
			}
		)
		#print(PREFIX+"buffered texture for pattern "+pattern_id + " and species "+species_id)
		#_refresh_patterns()

func register_prop(mod_id:String,identifier:String,scene_path:String):
	print(PREFIX+"Mod with ID ",mod_id," is calling the register_props function which is obsolete, use add_actor instead!")
	add_actor(mod_id,identifier,scene_path)

func add_actor(mod_id:String,identifier:String,scene_path:String,host_only:=false,max_allowed:=1):
	var scene:PackedScene = load(Util._mod_path_converter(mod_id,scene_path))
	if scene:
		modded_actors[mod_id+"."+identifier] = [scene,host_only,max_allowed]
	else:
		Printer.out(PROPS_SCENE_MISSING,true)
		return
	#print(modded_props)

func add_content(mod_id:String,resource_id:String,resource_path:String, flags:Array=[FLAGS.LOCK_AFTER_SHOP_UPDATE]):
	var data = {
		"mod":	mod_id,
		"id":	resource_id,
		"file":	resource_path,
		"flags":[]
	}
	data.mod = mod_id
	data.item = resource_id
	data.file = resource_path
	data.flags = flags
	
	if Util._validate_paths(mod_id,resource_path):
		Loader._register_resource(data)

# gives you the res:// path of another mod using the relative path
func get_other_mod_asset_path(path:String):
	if !path.begins_with("mods/"): return null
	var slice = path.get_slice("/",1)
	var id = slice.get_slice("://",0)
	return path.replace("mods/"+id+"://",MODS_FOLDER.plus_file(id)+"/")

#module loader
func _load_modules():
	var listing = "[/root/"+name+"]"
	for k in _modules.keys():
		var code = _modules[k]
		var node = code.new()
		node.name = k
		add_child(node)
		listing += "\n\tL[/"+k+"]"
		set(k,node)
		node.set("Lure",self)
		prints(get(k),node.name)
	print(PREFIX+"Modules loaded.")
	connect("lurlog",Printer,"out")
	print(listing)

# := <t&&arg> typehint default value
# = <arg> default value, nullable/variant
# :<t> obligatory argument, typehint
# if you set a variable as optional all the ones to the right must also be optional

# extra shit
func _options_check():
	var file = File.new()
	print(PREFIX+"searching for gdweave options json")
	if file.open(OS.get_executable_path().get_base_dir().plus_file("GDWeave/configs/Sulayre.Lure.json"),File.READ) == OK:
		var p = JSON.parse(file.get_as_text())
		file.close()
		var result = p.result
		if typeof(result) == TYPE_DICTIONARY:
			print(PREFIX+"checking options")
			if result["bonus_prompt"]:
				print(PREFIX+"bonus content prompt")
				bonus_prompt = true
			elif result["bonus_content"]:
				print(PREFIX+"bonus content on")
				_bonus_content_load()

func _bonus_content_load():
	new_wardrobe_page("test")
	new_wardrobe_category("placeholder","test")
	
	add_map("Sulayre.Lure","test_map","res://mods/Sulayre.Lure/Scenes/Maps/example_map.tscn","Lure Example Map")
	
	add_content("Sulayre.Lure","kade_shirt","mod://Resources/Cosmetics/undershirt_graphic_tshirt_kade.tres")
#	add_content("Sulayre.Lure","custom_cosmetic","res://mods/Sulayre.Lure/Resources/Cosmetics/test_resource.tres",[FLAGS.FREE_UNLOCK,custom_category("placeholder")])
	add_content("Sulayre.Lure","misname_title","mod://Resources/Cosmetics/title_misname.tres")
	add_content("Sulayre.Lure","sun_hat","res://mods/Sulayre.Lure/Resources/Cosmetics/hat_emil.tres")

# 3.5 sucks ass
func _filter_save(new_save:Dictionary) -> Dictionary:
	if Patches:
		if Patches.has_method("_filter_save"):
			return Patches._filter_save(new_save)
		#printerr(PREFIX+"The save filtering method was not found dude this shit makes no sense")
	#printerr(PREFIX+"The patches node was not found for whatever reason.")
	return new_save

# Signal Calls

func _signals():
	get_tree().root.connect("child_entered_tree",self,"_on_enter",[],CONNECT_DEFERRED)
	connect("main_menu_enter",self,"_load_and_link_saves",[],CONNECT_ONESHOT)
	connect("world_enter",Mapper,"_load_map")

func _on_enter(node:Node):
	if node.name == "main_menu":
		if bonus_prompt: node.add_child(prompt.instance())
		Mapper.selected_map = null
		
		var btn:Button = get_tree().get_current_scene().get_node_or_null("save_select_button")
		if btn:
			btn.connect("pressed",self,"_assign_load_save",[],CONNECT_DEFERRED)
		# first we setup the map selector and the max player selector
		var mainmenu = get_tree().get_current_scene()
		
		var buttonbundle = preload("res://mods/Sulayre.Lure/Scenes/MainMenu/LobbySettings.tscn").instance()
		
		var options:OptionButton = buttonbundle.get_node("map")

		var container:HBoxContainer = mainmenu.get_node("lobby_browser/Panel/Panel/VBoxContainer/topbar")
		container.add_child(buttonbundle)

		options.connect("item_selected",Mapper,"_swap_map")
		options.add_item("Original Map")
		var maps = modded_maps
		for map_data in maps:
			options.add_item(map_data["name"])
		# then we setup the lobby filters
#		if !OS.has_feature("editor"):
#			var filterbundle = preload("res://mods/Sulayre.Lure/Scenes/MainMenu/LobbyFilters.tscn").instance()
#			mainmenu.get_node("lobby_browser/Panel").add_child(filterbundle)
#			filterbundle.get_node("%LureOnly").connect("toggled",self,"_filter_lure")
#			filterbundle.get_node("%ShowFull").connect("toggled",self,"_filter_full")
#			filterbundle.get_node("%ShowMismatch").connect("toggled",self,"_filter_mismatch")
#			filterbundle.get_node("%DedicatedOnly").connect("toggled",self,"_filter_dedicated")
		emit_signal("main_menu_enter")
	if node.name == "world":
		node.get_node("Viewport/main/entities").connect("child_entered_tree",Mapper,"_refresh_players")
		emit_signal("world_enter")
	if node.name == "playerhud":
		#var extended_outfit = preload("res://mods/Sulayre.Lure/Scenes/HUD/extended_outfitter.tscn").instance()
		#var old_outfit = node.get_node("main/menu/tabs/outfit")
		#node.get_node("main/menu/tabs").add_child_below_node(old_outfit,extended_outfit)
		#old_outfit.free()
		#extended_outfit.name = "outfit"
		#extended_outfit.visible = false
		var extended_wheel = preload("res://mods/Sulayre.Lure/Scenes/HUD/extended_emote_wheel.tscn").instance()
		var old_wheel = node.get_node("main/emote_wheel")
		node.get_node("main").add_child_below_node(old_wheel,extended_wheel)
		node.emote_wheel = extended_wheel
		old_wheel.free()
		extended_wheel.name = "emote_wheel"
		extended_wheel.connect("_play_emote",node,"_play_emote")
		print("HUD IS LOADED")

func _load_and_link_saves():
	Loader._load_modded_save_data(UserSave.current_loaded_slot)
	
	
func _assign_load_save():
	var vbox = get_tree().get_current_scene().get_node_or_null("save_select/Panel/VBoxContainer")
	if !vbox: return
	print("b")
	for i in vbox.get_children().size():
		print_stack()
		vbox.get_child(i).connect("_pressed", Loader, "_load_modded_save_data", [i],CONNECT_DEFERRED)
		
func _filter_full(active):
	filter_full = !active
	_refresh_filters()
func _filter_lure(active):
	filter_lure = active
	_refresh_filters()

func _filter_mismatch(active):
	filter_mismatch = !active
	_refresh_filters()
	
func _filter_dedicated(active):
	filter_dedicated = active
	_refresh_filters()

func _refresh_filters():
	if OS.has_feature("editor"): return
	for lobby_node in get_tree().get_nodes_in_group("LobbyNode"):
		var btn = lobby_node.get_node("Panel/HBoxContainer/Button")
		var lbl = lobby_node.get_node("Panel/HBoxContainer/Label")
		var valid_mismatch_lobby = btn.disabled and lbl.text.begins_with("[VERSION MISMATCH] ")
		var filtering_full = lobby_node.is_full and filter_full
		var filtering_mismatch = valid_mismatch_lobby and filter_mismatch
		var filtering_lure = !lobby_node.lure_on and filter_lure
		var dedicated_find = lobby_node.filter.findn("dedicated") != -1
		var filtering_dedicated = !dedicated_find and filter_dedicated
		lobby_node.visible = !(filtering_lure or filtering_full or filtering_mismatch or filtering_dedicated)

func _swap_count(count):
	Network.MAX_PLAYERS_LURE = count

func _instance_mod_actor(dict, network_sender = - 1):
	var world = get_node_or_null("/root/world")
	if !world: return
	if not Network._validate_packet_information(dict, ["actor_type", "at", "zone", "actor_id", "creator_id", "rot", "zone_owner"], [TYPE_STRING, TYPE_VECTOR3, TYPE_STRING, TYPE_INT, TYPE_INT, TYPE_VECTOR3, TYPE_INT]):
		print("INVALID ACTOR DATA")
		return 
	
	var actor_type = dict["actor_type"]
	var pos = dict["at"]
	var rot = dict["rot"]
	var zone = dict["zone"]
	var zone_owner = dict["zone_owner"]
	var actor_id = dict["actor_id"]
	var owner_id = dict["creator_id"] if network_sender == - 1 else network_sender
	
	if not modded_actors.keys().has(actor_type): return 
	
	var BANK_DATA = modded_actors[actor_type]
	var host_only = BANK_DATA[1]
	var max_allowed = BANK_DATA[2]
	
	
	
	if network_sender != - 1 and Network.STEAM_LOBBY_ID <= 0:
		if host_only and Steam.getLobbyOwner(Network.STEAM_LOBBY_ID) != network_sender:
			print("Actor Instance Canceled, trying to spawn host-only actor as non-host.")
			return 
		
		var count = 0
		for actor in get_tree().get_nodes_in_group("actor"):
			if actor.owner_id == network_sender and actor.actor_type == actor_type:
				count += 1
		if count > max_allowed:
			print("Actor Instance Cancelled, too many active of type for owner id.")
			return 
	
	var actor = BANK_DATA[0].instance()
	actor.visible = false
	actor.global_transform.origin = pos
	actor.rotation = rot
	actor.actor_id = actor_id
	actor.owner_id = owner_id
	actor.current_zone = zone
	actor.current_zone_owner = zone_owner
	actor.actor_type = actor_type
	actor.world = world
	
	world.entities.add_child(actor)
	actor.global_transform.origin = pos
	
	print("created modded actor, ", actor_type, " w owner id ", owner_id)
	if owner_id == Network.STEAM_ID:
		Network.OWNED_ACTORS.append(actor)
		actor.add_to_group("owned_actor")

# Actions
func _test_action(arg1):
	print("action pressed + ",arg1)

func _test_release():
	print("action released")
