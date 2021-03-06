/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <cstrike>
#include <csgo>
#include <hamsandwich>
#include <fakemeta>
#include <nvault>

new g_iHudGracza[33];
new g_iHud, g_iVault;

public plugin_init() {
	new const szNazwyBroni[][] = {
		"weapon_scout", "weapon_mac10", "weapon_aug", "weapon_ump45", 
		"weapon_sg550", "weapon_galil", "weapon_famas", "weapon_awp", 
		"weapon_mp5navy", "weapon_m249", "weapon_m4a1", "weapon_tmp", 
		"weapon_g3sg1", "weapon_sg552", "weapon_ak47", "weapon_p90",
		"weapon_p228", "weapon_hegrenade", "weapon_xm1014",
		"weapon_smokegrenade", "weapon_elite", "weapon_fiveseven", "weapon_usp",
		"weapon_glock18", "weapon_flashbang", "weapon_deagle", "weapon_knife"
	}

	register_plugin("CSGO: HUD", "1.0", "d0naciak.pl");
	
	register_clcmd("say /hud", "cmd_HUD");
	register_event("ResetHUD", "ev_ResetHUD", "b");
	
	for(new i = 0; i < sizeof szNazwyBroni; i++) {
		RegisterHam(Ham_Item_Deploy, szNazwyBroni[i], "fw_WybralBron_Post", 1);
	}

	g_iHud = CreateHudSyncObj();

	g_iVault = nvault_open("CSGO_Hud");
	nvault_prune(g_iVault, 0, get_systime()-(86400*28));
}

public plugin_end() {
	nvault_close(g_iVault);
}

public plugin_natives() {
	register_native("csgo_open_hud", "cmd_HUD", 1);
	register_native("csgo_get_user_hud", "nat_PobierzOpcjeHudGracza", 1);
}

public nat_PobierzOpcjeHudGracza(id) {
	return g_iHudGracza[id];
}

public client_authorized(id) {
	new szNick[32];

	get_user_name(id, szNick, 31);
	g_iHudGracza[id] = nvault_get(g_iVault, szNick);
}

public client_putinserver(id) {
	set_task(1.0, "task_HUD", id, _, _, "b");
}

public client_disconnect(id) {
	remove_task(id);
}

public cmd_HUD(id) {
	new iMenu = menu_create("Opcje HUD", "HUD_Handler");
	
	menu_additem(iMenu, "Na srodku");
	menu_additem(iMenu, "Pod radarem");
	menu_additem(iMenu, "Wylacz HUD");
	
	menu_setprop(iMenu, MPROP_EXITNAME, "Wyjscie");
	menu_display(id, iMenu);
	
	return PLUGIN_HANDLED;
}

public HUD_Handler(id, iMenu, iItem) {
	switch(iItem) {
		case 0..2: {
			if((g_iHudGracza[id] = iItem) == 2) {
				remove_task(id);
				ClearSyncHud(id, g_iHud);
			} else {
				task_HUD(id);
				set_task(1.0, "task_HUD", id, _, _, "b");
			}
			
			new szNick[32], szDane[4];
			get_user_name(id, szNick, 31);
			num_to_str(iItem, szDane, 3);
			nvault_set(g_iVault, szNick, szDane);
			
			menu_display(id, iMenu);
		}
		
		case MENU_EXIT: {
			menu_destroy(iMenu);
		}
	}
}

public ev_ResetHUD(id) {
	if(g_iHudGracza[id] != 2) {
		return;
	}

	new iSmierci = csgo_get_user_deaths(id),
	iFragi = csgo_get_user_frags(id),
	Float:fStosunek = float(iFragi)/float((iSmierci ? iSmierci : 1)),
	szRanga[32];
	csgo_get_rank_name(csgo_get_user_rank(id), szRanga, 31);
	
	csgo_print_message(id, "Ranga:^x03 %s", szRanga);
	csgo_print_message(id, "Statystyki:^x03 %d/%d (%.1f)", iFragi, iSmierci, fStosunek);
}

public fw_WybralBron_Post(iEnt) {
	if(!pev_valid(iEnt)) {
		return HAM_IGNORED;
	}
	
	new id = pev(iEnt, pev_owner);
	
	if(!is_user_alive(id) || g_iHudGracza[id] == 2) {
		return HAM_IGNORED;
	}
	
	static iIloscSlotow;
	
	if(!iIloscSlotow) {
		iIloscSlotow = get_maxplayers();
	}
	
	set_task(0.1, "task_HUD", id);
	
	for(new i = 1; i <= iIloscSlotow; i++) {
		if(!is_user_connected(i) || is_user_alive(i) || pev(i, pev_iuser2) != id) {
			continue;
		}
		
		set_task(0.1, "task_HUD", i);
	}
	
	return HAM_IGNORED;
}

public task_HUD(id) {
	new iTarget, iCzyZywy = is_user_alive(id);
	
	if(!iCzyZywy) {
		iTarget = pev(id, pev_iuser2);
	} else {
		iTarget = id;
	}
	
	if(iTarget) {
		new iSmierci = csgo_get_user_deaths(iTarget),
		iFragi = csgo_get_user_frags(iTarget),
		iMisja = csgo_get_user_active_mission(iTarget),
		iBron = get_user_weapon(iTarget),
		iSkin = csgo_get_user_default_skin(iTarget, iBron),
		szEuro[16], szNazwaMisji[32], szRanga[32], szBron[32], szSkin[32], szSkinInfo[128], szKonto[32];
		new Float:fStosunek = float(iFragi)/float((iSmierci ? iSmierci : 1));
		csgo_format_euro(csgo_get_user_euro(iTarget), szEuro, 15);
		csgo_get_rank_name(csgo_get_user_rank(iTarget), szRanga, 31);
		csgo_get_mission_name(iMisja, szNazwaMisji, 31);
		
		if(iBron) {
			csgo_get_short_weaponname(iBron, szBron, 31);
			csgo_get_skin_name(iBron, iSkin, szSkin, 31);

			format(szSkinInfo, 127, "%s - %s", szBron, szSkin);
		} else {
			copy(szSkinInfo, 127, "Brak");
		}
		
		if(is_user_svip(iTarget)) {
			copy(szKonto, 31, "Super VIP");
		} else if(is_user_vip(iTarget)) {
			copy(szKonto, 31, "VIP");
		} else {
			copy(szKonto, 31, "Zwykle");
		}
		
		switch(g_iHudGracza[id]) {
			case 0: {
				if(!iCzyZywy) {
					set_hudmessage(255, 255, 255, -1.0, 0.18, 0, 0.2, 2.5, 0.1, 0.1, 2);
				} else {
					set_hudmessage(255, 255, 0, -1.0, 0.02, 0, 0.2, 2.5, 0.1, 0.1, 2);
				}
				
				ShowSyncHudMsg(id, g_iHud, "[Ranga: %s | Staty: %d/%d (%.1f)]^n[Skin: %s | Stan konta: %s Euro]^n[Konto: %s | Misja: %s (%d/%d)]",
				szRanga, iFragi, iSmierci, fStosunek, szSkinInfo, szEuro, szKonto, szNazwaMisji, csgo_get_user_mission_progress(iTarget), csgo_get_req_mission_progress(iMisja));
			}

			case 1: {
				set_hudmessage(255, 255, 0, 0.01, 0.2, 0, 0.2, 2.5, 0.1, 0.1, 2);
				ShowSyncHudMsg(id, g_iHud, "[Ranga: %s]^n[Staty: %d/%d (%.1f)]^n[Skin: %s]^n[Stan konta: %s Euro]^n[Konto: %s]^n[Misja: %s (%d/%d)]",
					szRanga, iFragi, iSmierci, fStosunek, szSkinInfo, szEuro, szKonto, szNazwaMisji, csgo_get_user_mission_progress(iTarget), csgo_get_req_mission_progress(iMisja));
			}
		}
	}
}


stock is_user_vip(id) {
	static iFlagi;
	
	if(!iFlagi) {
		new szFlagi[32];
		get_cvar_string("csgo_flagavip", szFlagi, 31);
		iFlagi = read_flags(szFlagi);
		
		if(!iFlagi) {
			iFlagi = -1;
			return 0;
		}
	} else if(iFlagi == -1) {
		return 0;
	}
	
	if(get_user_flags(id) & iFlagi) {
		return 1;
	}
	
	return 0;
}


stock is_user_svip(id) {
	static iFlagi;
	
	if(!iFlagi) {
		new szFlagi[32];
		get_cvar_string("csgo_flagasvip", szFlagi, 31);
		iFlagi = read_flags(szFlagi);
		
		if(!iFlagi) {
			iFlagi = -1;
			return 0;
		}
	} else if(iFlagi == -1) {
		return 0;
	}
	
	if(get_user_flags(id) & iFlagi) {
		return 1;
	}
	
	return 0;
}
