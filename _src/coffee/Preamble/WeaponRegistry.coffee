{Enum} = require "../common"

{Weapon} = require "../asc"

class WeaponRegistry extends Enum

  getInitialWeapon: (type) ->
    switch type
      when Weapon.Type.AUTOMATIC_RIFLE then return @INITIAL_AR
      when Weapon.Type.MARKSMAN_RIFLE then return @INITIAL_MR
      when Weapon.Type.MINIGUN then return @INITIAL_MINIGUN
      when Weapon.Type.ROCKET_LAUNCHER then return @INITIAL_ROCKET_LAUNCHER

module.exports = registry = new WeaponRegistry()
