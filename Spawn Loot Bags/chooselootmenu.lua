if not SimpleMenu then 
	manager.chat:_receive_message(1, "Spawn Bag", "Error: \"SimpleMenu\" class not found", Color.red)
	return
end

first_time_done = first_time_done or false
is_bind_menu = is_bind_menu or false
chosen_loot = chosen_loot or nil
toggle_bind = "right shift"
toggle_unbind = "right ctrl"
loot_menu_index = loot_menu_index or 1

loots_per_menu = 13
local _loot_list = {
	artifact_statue = "Artifact (Statue)",
	black_tablet = "Black Tablet",
	box_unknown = "Unknown Box",
	circuit = "Circuit",
	cloaker_cocaine = "Cloaker Cocaine",
	cloaker_gold = "Cloaker Gold",
	cloaker_money = "Cloaker Money",
	coke = "Cocaine",
	coke_pure = "Pure Cocaine",
	counterfeit_money = "Counterfeit Money",
	cro_loot1 = "Bomb Part (light)",
	cro_loot2 = "Bomb Part (heavy)",
	diamond_necklace = "Diamond Necklace",
	diamonds = "Jewelry",
	drk_bomb_part = "Bomb Part",
	drone_control_helmet = "Drone Control Helmet",
	evidence_bag = "Evidence",
	expensive_vine = "Expensive Vine",
	faberge_egg = "Fabergé Egg",
	gold = "Gold",
	hope_diamond = "The Diamond",
	lost_artifact = "Lost Artifact",
	mad_master_server_value_1 = "Master Server (1)",
	mad_master_server_value_2 = "Master Server (2)",
	mad_master_server_value_3 = "Master Server (3)",
	mad_master_server_value_4 = "Master Server (4)",
	master_server = "Master Server",
	masterpiece_painting = "Masterpiece Painting",
	meth = "Meth",
	meth_half = "Meth (Half)",
	money = "Money",
	mus_artifact = "Diamond Museum Artifact",
	mus_artifact_paint = "Diamond Museum Painting",
	old_wine = "Old Wine",
	ordinary_wine = "Ordinary Wine",
	painting = "Painting",
	present = "Present",
	prototype = "Prototype",
	red_diamond = "Red Diamond",
	robot_toy = "Robot Toy",
	roman_armor = "Roman Armor Piece",
	rubies = "Rubies",
	safe_secure_dummy = "Vlad Safe",
	samurai_suit = "Samurai Armor Piece",
	sandwich = "Sandwich",
	ammo = "Shells",
	toothbrush = "Giant Toothbrush",
	treasure = "Romanov Treasure",
	turret = "Turret Part",
	vr_headset = "VR Headset",
	warhead = "Nuclear Warhead",
	weapon = "Weapon",
	weapon_glock = "Pistols",
	weapon_scar = "Battle Riffles",
	weapons = "Weapons",
	women_shoes = "Women Shoes",
	yayo = "Yayo"
}


-- Callback functions
function spawn_bag(bag_name)
	if not alive (managers.player:player_unit()) then return end
	local camera_ext = managers.player:player_unit():camera()
	if Network:is_client() then
		managers.network:session():send_to_host( "server_drop_carry", bag_name, managers.money:get_bag_value(bag_name), true, true, 1, camera_ext:position(), camera_ext:rotation(), camera_ext:forward(), 100)
	else
		managers.player:server_drop_carry(bag_name, managers.money:get_bag_value(bag_name), true, true, 1, camera_ext:position(), camera_ext:rotation(), camera_ext:forward(), 100)
	end
end

spawn_or_bind = spawn_or_bind or function(data)
	if is_bind_menu then
		chosen_loot = data
	else
		spawn_bag(data)
	end
end

choose_loot_menu = choose_loot_menu or function()
	_loots = {}
	loot_table = {}
	for id, name in pairs(_loot_list) do
		_loots[id] = name
		table.insert(loot_table, id)
	end
	table.sort(loot_table)
	init_menus()
	loot_menus[loot_menu_index]:show()
end

loot_nextpage = loot_nextpage or function()
	loot_menus[loot_menu_index]:hide()
	loot_menu_index = loot_menu_index + 1
	
	-- Preserve focus on next/prev page
	loot_menus[loot_menu_index].dialog_data.focus_button = loots_per_menu + 2
	loot_menus[loot_menu_index]:show()
end
 
loot_prevpage = loot_prevpage or function()
	loot_menus[loot_menu_index]:hide()
	loot_menu_index = loot_menu_index - 1
	
	-- Preserve focus on next/prev page
	loot_menus[loot_menu_index].dialog_data.focus_button = (loot_menu_index > 1 and loot_menu_index < loot_menu_count and loots_per_menu + 3) or loots_per_menu + 2
	loot_menus[loot_menu_index]:show()
end
 
loot_firstpage = loot_firstpage or function()
	loot_menus[loot_menu_index]:hide()
	loot_menu_index = 1
	loot_menus[loot_menu_index]:show()
end
 
loot_lastpage = loot_lastpage or function()
	loot_menus[loot_menu_index]:hide()
	loot_menu_index = loot_menu_count
	loot_menus[loot_menu_index]:show()
end
--//-----------------------------------------------//--


-- Initial population of loot list
_loots = _loots or nil
loot_table = loot_table or {}
--//-----------------------------------------------//--

-- Population of menus
loot_menus = loot_menus or nil
loot_menu_count = loot_menu_count or nil
 
function init_menus()
	loot_menus = {}
	loot_menu_count = math.ceil(#loot_table / loots_per_menu)
	for m_id = 1, loot_menu_count do
		local opts = {}
		local start = (m_id - 1) * loots_per_menu + 1
		local ending = start + loots_per_menu - 1
		for i = start, ending do
			id = loot_table[i]
			if id then
				table.insert(opts, { text = tostring(_loots[id]), callback = spawn_or_bind, data = id })
			end
		end
		
		table.insert(opts, { text = "------------------------------" })
		if m_id < loot_menu_count then table.insert(opts, { text = "Next page", callback = loot_nextpage }) end
		if m_id > 1 then table.insert(opts, { text = "Previous page", callback = loot_prevpage }) end
		table.insert(opts, { text = "------------------------------" })
		if m_id > 1 then table.insert(opts, { text = "First page", callback = loot_firstpage }) end
		if m_id < loot_menu_count then table.insert(opts, { text = "Last page", callback = loot_lastpage }) end
		table.insert(opts, { text = "------------------------------" })
		table.insert(opts, { text = "Cancel", is_cancel_button = true })
		
		loot_menus[m_id] = SimpleMenu:new(m_id, "Secute loot "..tostring(start).." to "..tostring(ending)..", total: "..tostring(#loot_table).." (page "..tostring(m_id).."/"..tostring(loot_menu_count)..")", "Click on any loot to secure them", opts)
	end
end
 
--//-----------------------------------------------//--

-- Show the main menu
if not first_time_done then
	first_time_done = true
	local opts = {}
	table.insert(opts, { text = "DISCLAIMER: This mod is intended for host only use, or when" })
	table.insert(opts, { text = "playing with friends." })
	table.insert(opts, { text = "-------------------------" })
	table.insert(opts, { text = "There are 3 ways to use this mod:" })
	table.insert(opts, { text = "" })
	table.insert(opts, { text = "1) Press the mod key to open the menu, click on any option," })
	table.insert(opts, { text = "it will spawn one of the selected bag." })
	table.insert(opts, { text = "" })
	table.insert(opts, { text = "2) Press the mod key while maintaining the \"Right Shift\"" })
	table.insert(opts, { text = "key to open the menu. Select any option. This will bind the" })
	table.insert(opts, { text = "bag to the mod key, and everytime you will press it again it" })
	table.insert(opts, { text = "will spawn a new bag of the same loot." })
	table.insert(opts, { text = "" })
	table.insert(opts, { text = "3) To release the binding and access the menu again, press" })
	table.insert(opts, { text = "the mod key with the \"Right Ctrl\" key. This will unbind the" })
	table.insert(opts, { text = "loot. Press the mod key again to open the menu." })
	table.insert(opts, { text = "-------------------------" })
	table.insert(opts, { text = "Continue", callback = choose_loot_menu })
	table.insert(opts, { text = "Cancel", is_cancel_button = true })
	first_time_menu = SimpleMenu:new(61912, "DISCLAIMER", "", opts)
	first_time_menu:show()
else
	if not is_bind_menu then
		choose_loot_menu()
		if Input:keyboard():down(toggle_bind:id()) then
			is_bind_menu = true
			managers.chat:_receive_message(1, "Spawn Bag", "Bind mod = true", Color.yellow)
		end
	end

	if is_bind_menu then
		if Input:keyboard():down(toggle_unbind:id())  then
			is_bind_menu = false
			chosen_loot = nil
			managers.chat:_receive_message(1, "Spawn Bag", "Bind mod = false", Color.yellow)
		else
			spawn_bag(chosen_loot)
		end
	end
end