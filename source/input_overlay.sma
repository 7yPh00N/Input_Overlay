#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN_NAME "Input Overlay"
#define PLUGIN_VERSION "1.0.0"
#define PLUGIN_AUTHOR "7yPh00N"

new bool:g_KeyDisplayEnabled[33]

public plugin_init()
{
    register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)
    register_forward(FM_PlayerPreThink, "fw_PlayerPreThink")
    register_clcmd("say /mkey", "cmd_toggle_keys")
    register_clcmd("say_team /mkey", "cmd_toggle_keys")
    register_clcmd("say mkey", "cmd_toggle_keys")
    register_clcmd("say_team mkey", "cmd_toggle_keys")
    
    for (new i = 0; i < 33; i++)
    {
        g_KeyDisplayEnabled[i] = true
    }
}

public client_connect(id)
{
    g_KeyDisplayEnabled[id] = true
}

public cmd_toggle_keys(id)
{
    if (!is_user_connected(id)) return PLUGIN_HANDLED;
    g_KeyDisplayEnabled[id] = !g_KeyDisplayEnabled[id];
    client_print_color(id, id, "^4[7yPh00N]^1 Key Display: %s", g_KeyDisplayEnabled[id] ? "^3ON" : "^3OFF");
    return PLUGIN_HANDLED;
}

public fw_PlayerPreThink(id)
{
    if (!is_user_connected(id) || !is_user_alive(id))
        return FMRES_IGNORED;
    
    if (!g_KeyDisplayEnabled[id])
        return FMRES_IGNORED;
    
    new buttons = pev(id, pev_button)
    
    new bool:keyW = !!(buttons & IN_FORWARD)
    new bool:keyS = !!(buttons & IN_BACK)
    new bool:keyA = !!(buttons & IN_MOVELEFT)
    new bool:keyD = !!(buttons & IN_MOVERIGHT)
    new bool:keyC = !!(buttons & IN_DUCK)
    new bool:keyJ = !!(buttons & IN_JUMP)
    
    new key_text[64]
    new top_row[32], bottom_row[32]
    
    if (keyC)
        formatex(top_row, charsmax(top_row), "C")
    else
        formatex(top_row, charsmax(top_row), " ")
    
    if (keyW)
        formatex(top_row, charsmax(top_row), "%s   W", top_row)
    else
        formatex(top_row, charsmax(top_row), "%s   =", top_row)
    
    if (keyJ)
        formatex(top_row, charsmax(top_row), "%s   J", top_row)
    else
        formatex(top_row, charsmax(top_row), "%s    ", top_row)
    
    if (keyA)
        formatex(bottom_row, charsmax(bottom_row), "A")
    else
        formatex(bottom_row, charsmax(bottom_row), "=")
    
    if (keyS)
        formatex(bottom_row, charsmax(bottom_row), "%s   S", bottom_row)
    else
        formatex(bottom_row, charsmax(bottom_row), "%s   =", bottom_row)
    
    if (keyD)
        formatex(bottom_row, charsmax(bottom_row), "%s   D", bottom_row)
    else
        formatex(bottom_row, charsmax(bottom_row), "%s   =", bottom_row)
    
    formatex(key_text, charsmax(key_text), "%s^n%s", top_row, bottom_row)
    
    new hud_r = 255, hud_g = 255, hud_b = 255
    
    new bool:onGround = !!(pev(id, pev_flags) & FL_ONGROUND)
    new bool:noKeysInAir = !keyW && !keyS && !keyA && !keyD
    
    if ((keyA && keyD) || (keyW && keyS) || (!onGround && noKeysInAir))
    {
        hud_r = 255
        hud_g = 0
        hud_b = 0
    }
    
    set_dhudmessage(hud_r, hud_g, hud_b, -1.0, 0.85, 0, 0.0, 0.011, 0.0, 0.0)
    show_dhudmessage(id, key_text)
    
    return FMRES_IGNORED;
}