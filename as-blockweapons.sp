#pragma semicolon 1 

#include <sourcemod>
#include <tf2>
#include <tf2_stocks>
#include <tf2items>
#include <tf2items_giveweapon>

#define AUTOLOAD_EXTENSIONS
#define REQUIRE_EXTENSIONS

public Plugin:myinfo = 
{
	name = "Block Weapons",
	author = "Anarchy Steven",
	description = "Blocks weapons. Duh.",
	version = "1.0",
	url = "www.steveh.org.uk"
}

public OnPluginStart()
{
	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("post_inventory_application", Event_PlayerRegenerated, EventHookMode_Post);
}

public Event_PlayerSpawn(Handle:event,const String:name[],bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	if (IsClientInGame(client) && !IsFakeClient(client))
	{
		// Need a timer here because if we do it too early, our changes won't take effect
		CreateTimer(0.1, Timer_WeaponCheck, client);
	}
}

public Event_PlayerRegenerated(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	if (IsClientInGame(client) && !IsFakeClient(client))
	{
		CreateTimer(0.1, Timer_WeaponCheck, client);
	}
}

public Action:Timer_WeaponCheck(Handle:timer, any:client)
{
	if (client > 0 && client <= MaxClients && IsClientInGame(client)) 
	{
		new TFClassType:playerClass = TF2_GetPlayerClass(client);

		switch (playerClass)
		{
			case TFClass_Scout: 
			{
				if (Weapon_IsBlocked(client, 0))
				{
					// If blocked, remove weapon slot (Primary) and give Scattergun instead.
					TF2_RemoveWeaponSlot(client, 0);
					TF2Items_GiveWeapon(client, 13);
				}
			}

			case TFClass_Engineer:
			{
				if (Weapon_IsBlocked(client, 1))
				{
					// If blocked, remove weapon slot (Secondary) and give Pistol instead.
					TF2_RemoveWeaponSlot(client, 1);
					TF2Items_GiveWeapon(client, 22);
				}
			}
		}
	}
}

stock bool:Weapon_IsBlocked(client, slot)
{
	SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", GetPlayerWeaponSlot(client, slot));

	new currentWeapon = GetEntDataEnt2(client, FindSendPropOffs("CTFPlayer", "m_hActiveWeapon"));
	if (IsValidEntity(currentWeapon))
	{
		switch (GetEntProp(currentWeapon, Prop_Send, "m_iItemDefinitionIndex"))
		{
			case 528, 772: return true;
		}
	}

	return false;
}