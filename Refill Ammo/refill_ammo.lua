local _old_fire = NewRaycastWeaponBase.fire
function NewRaycastWeaponBase:fire( ... )
	local result = _old_fire( self, ... )
	if managers.player:player_unit() == self._setup.user_unit then
		if self:get_ammo_total() <= 0 then
			local player_inv = managers.player:player_unit():inventory()
			for id, weapon in pairs( player_inv:available_selections() ) do
				if alive(weapon.unit) and weapon.unit == player_inv:equipped_unit() then
					local w_base = weapon.unit:base()
					local to_add = w_base:get_ammo_max() - w_base:get_ammo_total()
					w_base:add_ammo_to_pool(to_add, id)
				end
			end
		end
	end
	return result
end