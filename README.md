# Karma Punishments

This is an alternative to TTT's autokick karma system, where players with low enough karma are kicked from the server.\
This is a fine system for public TTT servers, but not so appropriate for small games with friends!\
\
So, introducing the Karma Punishments mod!\
\
This mod applies a random "punishment" effect to players below a certain threshold of karma at the beginning of each round (similar to a randomat).\
This threshold can be adjusted with the *ttt_kp_low_karma_threshold* convar (by default 800).\
\
These effects are meant to make the game harder, but not impossible to play for a punished player.\
They automatically reset once the player dies, re-apply if they respawn, and are completely removed once the round ends.

## Settings/Options

**Use the in-game F1 menu tab to adjust this mod's settings**
There you will find a list of all the karma punishments in the game, and the ability to enable/disable any of them, and adjust an punishments's individual settings if it has any. This menu of course is only available to admins!\
\
\
Alternatively, if you know what you're doing, add the below convars to your server's *server.cfg* or *listenserver.cfg* for peer-to-peer hosted games:\
\
*ttt_kp_low_karma_threshold* - Default: 800 - The amount of karma below which players start receiving punishments.

## Punishments that need other mods to work

Some punishments require another mod to be installed to work! Here is the complete list:

### Forced Railgun

Requires: [Lykrast's TTT Weapon Collection](https://steamcommunity.com/sharedfiles/filedetails/?id=337994500)\
(Or some other mod that adds the Lykrast railgun like: [[TTT] Classic Weapons Remade](https://steamcommunity.com/sharedfiles/filedetails/?id=3573096208))

### No Sprinting

Requires: [TTT Sprint](https://steamcommunity.com/sharedfiles/filedetails/?id=933056549)\
(Or some other mod that adds sprinting)

## Credits

"Reverse Controls" and "Less Ammo" punishments use code from Malivil's "Opposite day" and "Wasteful!" randomat events:\
<https://steamcommunity.com/sharedfiles/filedetails/?id=2055805086>\

## Steam Workshop Link

<https://steamcommunity.com/sharedfiles/filedetails/?id=2256515054>

## The Great Giant List of Karma Punishments

*Italics* indicate convars for any karma punishment listed below.

### Backwards Movement

Forces you to move backwards only, very quickly\
Can stop in place by holding the forwards key\
\
*ttt_kp_backwards* - Default: 1 - Whether this punishment is enabled\
*kp_backwards_speed* - Default: 440 - Backwards movement speed

### Butterfingers

Forces you to drop your weapon every 5 seconds\
\
*ttt_kp_butter* - Default: 1 - Whether this punishment is enabled\
*kp_butter_seconds* - Default: 5 - Seconds between dropping weapons

### Crab Walk

Forward and backward movement is disabled, you can only walk sideways\
\
*ttt_kp_crabwalk* - Default: 1 - Whether this punishment is enabled

### Foggy Vision

Puts a fog effect on your screen, which limits how far you can see\
\
*ttt_kp_fog* - Default: 1 - Whether this punishment is enabled\
*kp_fog_mult* - Default: 1 - Fog distance multiplier

### Forced Railgun

Forces the you to use a railgun (Different punishment for jesters!)\
\
*ttt_kp_railgun* - Default: 1 - Whether this punishment is enabled\
*kp_railgun_seconds* - Default: 3 - Seconds between being given a railgun

### H.U.G.E. Problem

Forces you to use only a H.U.G.E.\
\
*ttt_kp_huge* - Default: 1 - Whether this punishment is enabled\
*kp_huge_seconds* - Default: 10 - Seconds between being given a H.U.G.E.

### Less Ammo

Guns use more ammo per shot\
\
*ttt_kp_ammo* - Default: 1 - Whether this punishment is enabled\
*kp_ammo_wasted_bullets* - Default: 2 - No. of extra bullets wasted

### Less Health

Sets your health lower (Different punishment for jesters!)\
\
*ttt_kp_health* - Default: 1 - Whether this punishment is enabled\
*kp_health_amount* - Default: 1 - Amount of health you are set to

### No Sprinting

Your sprinting is disabled\
\
*ttt_kp_sprinting* - Default: 1 - Whether this punishment is enabled

### Random Rotation

Rotates your view randomly every few seconds\
\
*ttt_kp_rotate* - Default: 1 - Whether this punishment is enabled\
*kp_rotate_seconds* - Default: 5 - Seconds between being randomly rotated

### Reverse Controls

Reverses many controls like moving backwards,\
shooting <-> reloading or crouching <-> jumping
\
*ttt_kp_reverse* - Default: 1 - Whether this punishment is enabled

### Random Sensitivity

Randomly changes your mouse sensitivity every few seconds\
\
*ttt_kp_sensitive* - Default: 1 - Whether this punishment is enabled\
*kp_sensitive_seconds* - Default: 5 - Seconds between sensitivity changes

### Slow Movement

You move more slowly\
\
*ttt_kp_slow* - Default: 1 - Whether this punishment is enabled\
*kp_slow_mult* - Default: 0.5 - Speed multiplier

### Third-person

You are forced to use a third-person view\
\
*ttt_kp_thirdperson* - Default: 1 - Whether this punishment is enabled

## Steam Workshop Link

<https://steamcommunity.com/sharedfiles/filedetails/?id=2256515054>
