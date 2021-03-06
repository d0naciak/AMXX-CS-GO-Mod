/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <csgo>
#include <hamsandwich>
#include <fun>
#include <cstrike>
#include <csx>
#include <StripWeapons>

new g_pCvarSzansaNaDropKlucza, g_pCvarSzansaNaDropSkrzynki, g_pCvarFlagaVip, g_pCvarIleHpFrag, g_pCvarIleHpFragHs;
new g_iWymaganaIloscGraczy, g_iIloscRund, g_iIloscSlotow;

public plugin_init() {
	register_plugin("CSGO: VIP", "1.0.0", "d0naciak.pl");
	
	g_pCvarSzansaNaDropKlucza = register_cvar("csgo_szansanadropkluczavip", "100");
	g_pCvarSzansaNaDropSkrzynki = register_cvar("csgo_szansanadropskrzynkivip", "100");
	g_pCvarFlagaVip = register_cvar("csgo_flagavip", "t");
	g_pCvarIleHpFrag = register_cvar("csgo_hpzafragavip", "5");
	g_pCvarIleHpFragHs = register_cvar("csgo_hpzafragahsvip", "10");
	register_cvar("csgo_cenakluczavip", "100");
	register_cvar("csgo_szansalosowanieskrzynki", "3");
	register_cvar("csgo_szansalosowanieskrzynkivip", "4");
	
	register_logevent("ev_PoczatekGry", 2, "1=Game_Commencing");
	register_logevent("ev_KoniecRundy", 2, "1=Round_End");
	
	RegisterHam(Ham_Killed, "player", "fw_Smierc_Post", 1);
	RegisterHam(Ham_Spawn, "player", "fw_Odrodzenie_Post", 1);
	
	register_message(get_user_msgid("SayText"),"msg_SayText");
	register_message(get_user_msgid("ScoreAttrib"), "msg_ScoreAttrib");

	register_clcmd("say /vip", "cmd_VipInfo");
	register_clcmd("say /vips", "cmd_VipyOnline");

	g_iIloscSlotow = get_maxplayers();
	g_iWymaganaIloscGraczy = get_cvar_num("csgo_wymaganailoscgraczygranie");
}

public ev_PoczatekGry() {
	g_iIloscRund = 0;
}

public ev_KoniecRundy() {
	g_iIloscRund ++;
}

public fw_Smierc_Post(id, iAtt, iShGb) {
	if(!is_user_connected(iAtt) || !is_user_vip(iAtt) || get_user_team(id) == get_user_team(iAtt)) {
		return HAM_IGNORED;
	}
	
	new iBonus = get_user_health(iAtt);
	
	if(get_pdata_int(id, 75, 5) == HIT_HEAD) {
		iBonus += get_pcvar_num(g_pCvarIleHpFragHs);
	} else {
		iBonus += get_pcvar_num(g_pCvarIleHpFrag);
	}
	
	set_user_health(iAtt, min(100, iBonus));

	if(get_playersnum() >= g_iWymaganaIloscGraczy) {
		if(random_num(1, get_pcvar_num(g_pCvarSzansaNaDropKlucza)) == 1) {
			csgo_set_user_keys(iAtt, csgo_get_user_keys(iAtt) + 1);
			csgo_print_message(iAtt, "WOW! Udalo Ci sie znalezc^x03 klucz do skrzynek!");
		}
		
		if(random_num(1, get_pcvar_num(g_pCvarSzansaNaDropSkrzynki)) == 1) {
			new iSkrzynka = random_num(1, csgo_get_cratesnum());
			new szSkrzynka[32]; csgo_get_crate_name(iSkrzynka, szSkrzynka, 31);
			
			csgo_set_user_crates(iAtt, iSkrzynka, csgo_get_user_crates(iAtt, iSkrzynka) + 1);
			csgo_print_message(iAtt, "WOW! Udalo Ci sie znalezc^x03 %s!", szSkrzynka);
		}
	}
	
	return HAM_IGNORED;
}

public bomb_planted(id) {
	if(!is_user_vip(id)) {
		return;
	}
	
	cs_set_user_money(id, cs_get_user_money(id) + 200);
}

public bomb_defused(id) {
	if(!is_user_vip(id)) {
		return;
	}
	
	cs_set_user_money(id, cs_get_user_money(id) + 200);
}

public fw_Odrodzenie_Post(id) {
	if(!is_user_vip(id)) {
		return;
	}
	
	new iTeam = get_user_team(id);
	
	if(!(1 <= iTeam <= 2) || !is_user_alive(id)) {
		return;
	}
	
	if(g_iIloscRund >= 3) {
		MenuBroni(id);
	}
	
	cs_set_user_armor(id, 100, CS_ARMOR_KEVLAR);
	
	if(iTeam == 2) {
		cs_set_user_defuse(id, 1);
	}
}

MenuBroni(id) {
	new iMenu = menu_create("Wybierz bron", "MenuBroni_Handler");
	
	menu_additem(iMenu, "M4A1 + Deagle");
	menu_additem(iMenu, "AK47 + Deagle");
	menu_additem(iMenu, "AWP + Deagle");
	
	menu_display(id, iMenu);
}

public MenuBroni_Handler(id, iMenu, iItem) {
	if(!is_user_alive(id) || iItem == MENU_EXIT) {
		menu_destroy(iMenu);
		return PLUGIN_CONTINUE;
	}
	
	if(iItem < 0) {
		return PLUGIN_CONTINUE;
	}
	
	StripWeapons(id, Primary);
	StripWeapons(id, Secondary);
	
	give_item(id, "weapon_deagle");
	cs_set_user_bpammo(id, CSW_DEAGLE, 35);
	
	switch(iItem) {
		case 0: {
			give_item(id, "weapon_m4a1");
			cs_set_user_bpammo(id, CSW_M4A1, 90);
		}
		
		case 1: {
			give_item(id, "weapon_ak47");
			cs_set_user_bpammo(id, CSW_AK47, 90);
		}
		
		case 2: {
			give_item(id, "weapon_awp");
			cs_set_user_bpammo(id, CSW_AWP, 30);
		}
	}
	
	menu_destroy(iMenu);
	return PLUGIN_CONTINUE;
}

public msg_SayText(msgId,msgDest,msgEnt){	
	
	new id = get_msg_arg_int(1);
	
	if(!is_user_connected(id) || !is_user_vip(id))      return PLUGIN_CONTINUE;
	
	new szTmp[192], szTmp2[192];
	get_msg_arg_string(2, szTmp, charsmax(szTmp));
	
	new szPrefix[64];
	formatex(szPrefix, 63, "^x04[VIP]");
	
	if(!equal(szTmp,"#Cstrike_Chat_All")){
		add(szTmp2, charsmax(szTmp2), "^x01");
		add(szTmp2, charsmax(szTmp2), szPrefix);
		add(szTmp2, charsmax(szTmp2), " ");
		add(szTmp2, charsmax(szTmp2), szTmp);
	}
	else{
		new szPlayerName[64];
		get_user_name(id, szPlayerName, charsmax(szPlayerName));
		
		get_msg_arg_string(4, szTmp, charsmax(szTmp)); //4. argument zawiera treść wysłanej wiadomości
		set_msg_arg_string(4, ""); //Musimy go wyzerować, gdyż gra wykorzysta wiadomość podwójnie co może skutkować crash'em 191+ znaków.
		
		add(szTmp2, charsmax(szTmp2), "^x01");
		add(szTmp2, charsmax(szTmp2), szPrefix);
		add(szTmp2, charsmax(szTmp2), "^x03 ");
		add(szTmp2, charsmax(szTmp2), szPlayerName);
		add(szTmp2, charsmax(szTmp2), "^x01 :  ");
		add(szTmp2, charsmax(szTmp2), szTmp)
	}
	
	set_msg_arg_string(2, szTmp2);
	
	return PLUGIN_CONTINUE;
}


public msg_ScoreAttrib(){
	new id=get_msg_arg_int(1);
	if(is_user_alive(id) && is_user_vip(id)){
		set_msg_arg_int(2, ARG_BYTE, get_msg_arg_int(2)|4);
	}
}

public cmd_VipInfo(id) {
	show_motd(id, "addons/amxmodx/configs/sklepsms/vip.txt", "Opis VIPa");
	return PLUGIN_HANDLED;
}

public cmd_VipyOnline(id) {
	new szNick[32], szWiadomosc[512], iLen;
	
	iLen = formatex(szWiadomosc, 511, "\yVIPy Online:^n");
	
	for(new i = 1; i <= g_iIloscSlotow; i++) {
		if(!is_user_connected(i) || !is_user_vip(i)) {
			continue;
		}
		
		get_user_name(i, szNick, 31);
		iLen += formatex(szWiadomosc[iLen], 511 - iLen, "\r* \w%s^n", szNick);
	}
	
	if(!strlen(szNick)) {
		iLen += formatex(szWiadomosc[iLen], 511 - iLen, "\rnie ma zadnego VIPa!");
	}
	
	show_menu(id, 1023, szWiadomosc);
	return PLUGIN_HANDLED;
}

stock is_user_vip(id) {
	static iFlagi;
	
	if(!iFlagi) {
		new szFlagi[32];
		get_pcvar_string(g_pCvarFlagaVip, szFlagi, 31);
		iFlagi = read_flags(szFlagi);
	}
	
	if(get_user_flags(id) & iFlagi) {
		return 1;
	}
	
	return 0;
}