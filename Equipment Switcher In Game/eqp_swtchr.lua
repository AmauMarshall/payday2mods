MAX_OPTIONS_PER_MENU = 15

function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

build_other_list = function(category)
	local generic_list = {}
	local twbm = category == "grenades" and "projectiles" or category
	local search_list = category == "deployables" and tweak_data.blackmarket.deployables or Global.blackmarket_manager[category] 
	for slot, item in pairs(search_list) do
		if (item) then
			table.insert(generic_list, { slot = slot, name = managers.localization:text(tweak_data.blackmarket[twbm][slot].name_id):gsub("\"", "") })
		end
	end
	return generic_list
end

build_wpn_list = function(category)
	local generic_list = {}
	for slot, wpn in pairs(Global.blackmarket_manager.crafted_items[category]) do
		if (wpn) then
			table.insert(generic_list, { slot = slot, name = managers.blackmarket:get_weapon_name_by_category_slot(category, slot):gsub("\"", "") })
		end
	end
	return generic_list
end

equip_other = function(category, slot)
	if category == "melee_weapons" then
		if (managers.player:player_unit()) then
			if slot then
				managers.blackmarket:equip_melee_weapon(slot)
				managers.network:session():send_to_peers_synched("set_unit", managers.player:player_unit(), managers.network:session():local_peer():character(), managers.blackmarket:outfit_string(), managers.network:session():local_peer():outfit_version(), managers.network:session():local_peer():id())
				managers.player:player_unit():_reload_outfit()
				managers.player:player_unit():inventory():set_melee_weapon(managers.blackmarket:equipped_melee_weapon())
			end
		end
	elseif category == "armors" then
		if (managers.player:player_unit()) then
			if slot then
				managers.blackmarket:equip_armor(slot)
				managers.network:session():send_to_peers_synched("set_unit", managers.player:player_unit(), managers.network:session():local_peer():character(), managers.blackmarket:outfit_string(), managers.network:session():local_peer():outfit_version(), managers.network:session():local_peer():id())
				managers.player:player_unit():_reload_outfit()
			end 
		end
	elseif category == "deployables" then
		if managers.hud then
			managers.player:clear_equipment()
			managers.player._equipment.selections = {}
			managers.player:add_equipment({equipment = slot})
		end
	elseif category == "grenades" then
		if (managers.player:player_unit()) then			
			if slot then
				local amount = 3
				managers.blackmarket:equip_grenade(slot)
				managers.network:session():send_to_peers_synched("set_unit", managers.player:player_unit(), managers.network:session():local_peer():character(), managers.blackmarket:outfit_string(), managers.network:session():local_peer():outfit_version(), managers.network:session():local_peer():id())
				managers.player:player_unit():_reload_outfit()
				managers.hud:set_teammate_grenades(HUDManager.PLAYER_PANEL, {amount = amount, icon = tweak_data.blackmarket.projectiles[slot].icon})
				managers.player:set_synced_grenades(managers.network:session():local_peer():id(), slot, amount)
			end
		end
	end
end

equip_weapon = function(category, slot)
	function NewRaycastWeaponBase:set_timer(timer, ...)
		if (alive(self._unit)) then 
			NewRaycastWeaponBase.super.set_timer(self, timer)
			for _,data in ipairs(self._parts) do
				local unit = data.unit
				if (alive(unit)) then
					unit:set_timer(timer)
					unit:set_animation_timer(timer)
				end 
			end 
		end 
	end
	if (managers.player:player_unit()) then
        local weapon = Global.blackmarket_manager.crafted_items[category][slot]
        if weapon then
            managers.blackmarket:equip_weapon(category, slot)
			local wpn = weapon
			local wpn_slot = managers.blackmarket:equipped_weapon_slot(category)
			local texture_switches = managers.blackmarket:get_weapon_texture_switches(category, wpn_slot, wpn)               
		    managers.network:session():send_to_peers_synched("set_unit", managers.player:player_unit(), managers.network:session():local_peer():character(), managers.blackmarket:outfit_string(), managers.network:session():local_peer():outfit_version(), managers.network:session():local_peer():id())
            managers.dyn_resource:load(Idstring("unit"), Idstring(tweak_data.weapon.factory[weapon.factory_id].unit), "packages/dyn_resources", false)
            managers.player:player_unit():inventory():add_unit_by_factory_name(weapon.factory_id, false, false, weapon.blueprint, weapon.cosmetics, weapon.texture_switches )
		end 
	end
end

menu_display = function(menu_to_display)
	if not menu_to_display then
		managers.chat:_receive_message(1, "Epq Swtchr", "Error: no menu to display", Color.red)
		return
	end
	managers.system_menu:show_buttons(menu_to_display)
end

other_menu = function(category)
	other_list = other_list or {}
	other_list[category] = other_list[category] or build_other_list(category)

	other_menus = other_menus or {}
	other_menus[category] = other_menus[category] or nil

	if other_menus and not other_menus[category] then
		other_menus[category] = {}
		number_other_menus = {}
		number_other_menus[category] = math.ceil(#other_list[category] / MAX_OPTIONS_PER_MENU)
		
		for m_id = 1, number_other_menus[category] do
			other_menus[category][m_id] = {    
				title = (category == "melee_weapons" and "melee" or (category == "grenades" and "throwables" or firstToUpper(category))).." Menu "..tostring(m_id).."/"..tostring(number_other_menus[category]),
				text = "Select Option.",
				button_list = {}
			}

			local start = (m_id - 1) * MAX_OPTIONS_PER_MENU + 1
			local ending = start + MAX_OPTIONS_PER_MENU - 1

			for i = start, ending do
				if other_list and other_list[category] and other_list[category][i] then
					table.insert(other_menus[category][m_id].button_list, { text = tostring(other_list[category][i].name), callback_func = function() equip_other(category, other_list[category][i].slot) end })
				end
			end

			table.insert(other_menus[category][m_id].button_list, {})
			if m_id > 1 then table.insert(other_menus[category][m_id].button_list, { text = "First page", callback_func = function() menu_display(other_menus[category][1]) end }) end
			if m_id < number_other_menus[category] then table.insert(other_menus[category][m_id].button_list, { text = "Next page", callback_func = function() menu_display(other_menus[category][m_id+1]) end }) end
			if m_id > 1 then table.insert(other_menus[category][m_id].button_list, { text = "Previous page", callback_func = function() menu_display(other_menus[category][m_id-1]) end }) end
			if m_id < number_other_menus[category] then table.insert(other_menus[category][m_id].button_list, { text = "Last page", callback_func = function() menu_display(other_menus[category][number_other_menus[category]]) end }) end
			table.insert(other_menus[category][m_id].button_list, {})
			table.insert(other_menus[category][m_id].button_list, {text = managers.localization:text("dialog_cancel"), cancel_button = true })
		end
	end

	menu_display(other_menus[category][1])
end

weapon_menu = function(category)
	weapon_list = weapon_list or {}
	weapon_list[category] = weapon_list[category] or build_wpn_list(category)

	weapon_menus = weapon_menus or {}
	weapon_menus[category] = weapon_menus[category] or nil

	if weapon_menus and not weapon_menus[category] then
		weapon_menus[category] = {}
		number_wpn_menus = {}
		number_wpn_menus[category] = math.ceil(#weapon_list[category] / MAX_OPTIONS_PER_MENU)

		for m_id = 1, number_wpn_menus[category] do
			weapon_menus[category][m_id] = {    
				title = firstToUpper(category).." Menu "..tostring(m_id).."/"..tostring(number_wpn_menus[category]),
				text = "Select Weapon (Make sure that "..(category == "primaries" and "secondary" or (category == "secondaries" and "primary")).." is equipped to prevent crash).",
				button_list = {}
			}

			local start = (m_id - 1) * MAX_OPTIONS_PER_MENU + 1
			local ending = start + MAX_OPTIONS_PER_MENU - 1

			for i = start, ending do
				if weapon_list[category][i] then
					table.insert(weapon_menus[category][m_id].button_list, { text = tostring(weapon_list[category][i].name), callback_func = function() equip_weapon(category, weapon_list[category][i].slot) end })
				end
			end

			table.insert(weapon_menus[category][m_id].button_list, {})
			if m_id > 1 then table.insert(weapon_menus[category][m_id].button_list, { text = "First page", callback_func = function() menu_display(weapon_menus[category][1]) end }) end
			if m_id < number_wpn_menus[category] then table.insert(weapon_menus[category][m_id].button_list, { text = "Next page", callback_func = function() menu_display(weapon_menus[category][m_id+1]) end }) end
			if m_id > 1 then table.insert(weapon_menus[category][m_id].button_list, { text = "Previous page", callback_func = function() menu_display(weapon_menus[category][m_id-1]) end }) end
			if m_id < number_wpn_menus[category] then table.insert(weapon_menus[category][m_id].button_list, { text = "Last page", callback_func = function() menu_display(weapon_menus[category][number_wpn_menus[category]]) end }) end
			table.insert(weapon_menus[category][m_id].button_list, {})
			table.insert(weapon_menus[category][m_id].button_list, {text = managers.localization:text("dialog_cancel"), cancel_button = true })
		end
	end
	
	menu_display(weapon_menus[category][1])
end

main_eqp_menu = function()
	local dialog_data = {
		title = "Equipment Switcher",
		text = "Select Option",
		button_list = {}
	}

	local main_menu_table = {
		{ text = "Choose Primary Weapon", callback_func = function() weapon_menu("primaries") end},
		{ text = "Choose Secondary Weapon", callback_func = function() weapon_menu("secondaries") end},
		{ text = "Choose Melee Weapon", callback_func = function() other_menu("melee_weapons") end},
		{ text = "Choose Armor", callback_func = function() other_menu("armors") end},
		{ text = "Choose Deployable", callback_func = function() other_menu("deployables") end},
		{ text = "Choose Throwable", callback_func = function() other_menu("grenades") end}
	}

	for _, stuff in pairs(main_menu_table) do
		table.insert(dialog_data.button_list, stuff)
	end

	table.insert(dialog_data.button_list, {})
	local no_button = {text = "Cancel", cancel_button = true}      
	table.insert(dialog_data.button_list, no_button) 
	menu_display(dialog_data)
end
main_eqp_menu()