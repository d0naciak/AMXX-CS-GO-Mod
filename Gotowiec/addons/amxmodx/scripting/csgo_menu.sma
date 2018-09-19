/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <csgo>

native is_user_logged(id);
native csgo_open_trade(id);
native csgo_open_hud(id);

public plugin_init() {
	register_plugin("CSGO Mod: Menu", "1.0", "d0naciak");
	
	register_clcmd("say /menu", "cmd_Menu");
	register_clcmd("say /skiny", "cmd_Skiny");
	register_clcmd("say /skrzynki", "cmd_SkrzynkiKlucze");
	register_clcmd("say /klucze", "cmd_SkrzynkiKlucze");
}

public cmd_Menu(id) {
	if(!is_user_logged(id)) {
		return PLUGIN_HANDLED;
	}
	
	new iMenu = menu_create("Glowne menu", "Menu_Handler");
	
	menu_additem(iMenu, "Rangi");
	menu_additem(iMenu, "Misje^n");
	menu_additem(iMenu, "Skiny");
	menu_additem(iMenu, "Skrzynki \r& \wKlucze");
	menu_additem(iMenu, "Wymiana^n");
	menu_additem(iMenu, "HUD");
	menu_additem(iMenu, "\rPomoc");
	menu_additem(iMenu, "\rKomendy");
	
	menu_translatetopolish(iMenu);
	menu_display(id, iMenu);
	return PLUGIN_HANDLED;
}

public Menu_Handler(id, iMenu, iItem) {
	switch(iItem) {
		case 0: csgo_open_rankslist(id);
			case 1: csgo_open_missions(id);
			case 2: cmd_Skiny(id);
			case 3: cmd_SkrzynkiKlucze(id);
			case 4: csgo_open_trade(id);
			case 5: csgo_open_hud(id);
			case 6: csgo_open_help(id);
			case 7: csgo_open_commands(id);
		}
	
	menu_destroy(iMenu);
}

public cmd_Skiny(id) { 
	if(!is_user_logged(id)) {
		return PLUGIN_HANDLED;
	}
	
	new iMenu = menu_create("Skiny", "Skiny_Handler");
	
	menu_additem(iMenu, "Moje skiny");
	menu_additem(iMenu, "Lista skinow");
	
	menu_translatetopolish(iMenu);
	menu_display(id, iMenu);
	return PLUGIN_HANDLED;
}

public Skiny_Handler(id, iMenu, iItem) {
	switch(iItem) {
		case 0: csgo_open_myskins(id);
		case 1: csgo_open_skinslist(id);
	}
	
	menu_destroy(iMenu);
}

public cmd_SkrzynkiKlucze(id) {
	if(!is_user_logged(id)) {
		return PLUGIN_HANDLED;
	}
	
	new iCena;
	static pCvarCenaKlucza[3], iFlagaVip[2], iRodzajeVip;
	
	if(!iRodzajeVip) {
		new szFlaga[4], pCvarFlagaVip[2];
		
		iRodzajeVip |= (1<<1); //sprawdzono
		
		pCvarFlagaVip[0] = get_cvar_pointer("csgo_flagavip");
		pCvarFlagaVip[1] = get_cvar_pointer("csgo_flagasvip");
		
		if(pCvarFlagaVip[0]) {
			iRodzajeVip |= (1<<2); //jest VIP
			pCvarCenaKlucza[0] = get_cvar_pointer("csgo_cenakluczavip");
			
			get_pcvar_string(pCvarFlagaVip[0], szFlaga, 3);
			iFlagaVip[0] = read_flags(szFlaga);
		}
		
		if(pCvarFlagaVip[1]) {
			iRodzajeVip |= (1<<3); //jest SVIP
			pCvarCenaKlucza[1] = get_cvar_pointer("csgo_cenakluczasvip");
			
			get_pcvar_string(pCvarFlagaVip[1], szFlaga, 3);
			iFlagaVip[1] = read_flags(szFlaga);
		}
		
		pCvarCenaKlucza[2] = get_cvar_pointer("csgo_cenaklucza");
	}
	
	if(iRodzajeVip & (1<<2) && get_user_flags(id) & iFlagaVip[0]) {
		iCena = get_pcvar_num(pCvarCenaKlucza[0]);
	}
	else if(iRodzajeVip & (1<<3) && get_user_flags(id) & iFlagaVip[1]) {
		iCena = get_pcvar_num(pCvarCenaKlucza[1]);
	}
	else if(!iCena) {
		iCena = get_pcvar_num(pCvarCenaKlucza[2]);
	}
	
	new iMenu = menu_create("Skrzynki & Klucze", "SkrzynkiKlucze_Handler");
	new szItem[128], szCena[32];
	
	menu_additem(iMenu, "Sprawdz swoje \yskrzynki");
	menu_additem(iMenu, "Lista \yskrzynek^n");
	
	csgo_format_euro(iCena, szCena, 31);
	formatex(szItem, 127, "Kup \yklucz do skrzynki \wza \y%s Euro \d(posiadasz \r%d szt.\d)", szCena, csgo_get_user_keys(id));
	menu_additem(iMenu, szItem);
	
	menu_translatetopolish(iMenu);
	menu_display(id, iMenu);
	return PLUGIN_HANDLED;
}

public SkrzynkiKlucze_Handler(id, iMenu, iItem) {
	switch(iItem) {
		case 0: csgo_open_mycrates(id);
		case 1: csgo_open_crateslist(id);
		case 2: csgo_buy_key(id);
	}
	
	menu_destroy(iMenu);
}

stock menu_translatetopolish(iMenu) {
	menu_setprop(iMenu, MPROP_BACKNAME, "Cofnij");
	menu_setprop(iMenu, MPROP_NEXTNAME, "Dalej");
	menu_setprop(iMenu, MPROP_EXITNAME, "Wyjscie");
}
