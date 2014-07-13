Nuke mod by ShadowNinja
=======================

Nuke is a fast explosives mod for Minetest 0.4.  It adds several variands of
TNT, and a (very unpolished) missile.  It is also configurable and usable on
servers, due to it's optional privilege requirements.

Configuration
-------------

Nuke stores it's configuration in `nuke.conf` in the world directory.
It contains the following settings:

  * `mese_radius` (24) - Explosion radius of mese TNT.
  * `iron_radius` (12) - Explosion radius of iron TNT.
  * `tnt_radius` (3) - Explosion radius of TNT.
  * `missile_radius` (16) - Explosion radius of the missile.
  * `missile_misfire_radius` (5) - The explosion radius of the missile when it
	misfires (hits something before reaching it's max altitude).
  * `fancy` (true) - Boolean flag enabling fancy effects like particles.
  * `unprivileged_detonation` (false) - Boolean flag for whether detonation is
	allowed without the `pyrotechnic` privilege.  Allows activating nukes
	with mesecons and burning nodes (fire, lava).

Licenses
--------

  * Code: LGPLv3+ by ShadowNinja.
  * Sounds: Unknown
  * Iron and mese TNT textures: CC-BY-SA 3.0 by sfan5
  * Missile model and texture: WTFPL by Jordach
  * Everything else: CC-BY-SA 4.0 by ShadowNinja

