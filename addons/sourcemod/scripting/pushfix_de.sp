#include "sourcemod"
#include "sdktools"
#include "sdkhooks"

#define SNAME "[PushFix DE] "

#define MEMUTILS_PLUGINENDCALL
#include "glib/memutils"

public Plugin myinfo = 
{
    name = "PushFix - Definitive Edition",
    author = "Original idea xutaxkamay | Implementation GAMMACASE",
    description = "Fixes trigger_push prediction issues in an engine friendly way aswell as removes m_vecBaseVelocity clamping",
    version = "1.0.0",
    url = "https://steamcommunity.com/id/_GAMMACASE_/"
};

int gPreviousSendTableCRC;
Address g_SendTableCRC;

int gPreviousFlagsBitsValue;
Address m_fFlags_bits;

int gPreviousBaseVelocityFlags;
Address m_vecBaseVelocity_flags;

PatchHandler gPlayerFlagBitsPatch;

#define SPROP_NOSCALE (1 << 2)

public void OnPluginStart()
{
	ConVar sv_sendtables = FindConVar("sv_sendtables");
	ASSERT_MSG(sv_sendtables, "Failed to find \"sv_sendtables\" cvar.");
	sv_sendtables.SetBool(true);
	sv_sendtables.AddChangeHook(SendTablesCvar_Hook);
	
	GameData gd = new GameData("pushfix_de.games");
	ASSERT_MSG(gd, "Failed to open gamedata file \"pushfix_de.games.txt\".");
	
	SetupPatches(gd);
	
	delete gd;
}

public void SendTablesCvar_Hook(ConVar convar, const char[] oldValue, const char[] newValue)
{
	convar.SetBool(true);
}

void SetupPatches(GameData gd)
{
	// Getting the addresses first to ensure validity of the gamedata as if something
	// is outdated the plugin would patch half way through which isn't a good thing
	g_SendTableCRC = gd.GetAddress("g_SendTableCRC");
	ASSERT_MSG(g_SendTableCRC != Address_Null, "Failed to retrieve \"g_SendTableCRC\" address.");
	
	int offs = gd.GetOffset("m_nBits");
	m_fFlags_bits = gd.GetAddress("m_fFlags") + offs;
	ASSERT_MSG(offs != -1, "Failed to retrieve \"m_nBits\" offset.");
	ASSERT_MSG(m_fFlags_bits != Address_Null, "Failed to retrieve \"m_fFlags\" address.");
	ASSERT_MSG(LoadFromAddress(m_fFlags_bits, NumberType_Int32) == 11, "Invalid or outdated \"m_fFlags\" + offset address.");
	
	offs = gd.GetOffset("m_Flags");
	m_vecBaseVelocity_flags = gd.GetAddress("m_vecBaseVelocity") + offs;
	ASSERT_MSG(offs != -1, "Failed to retrieve \"m_Flags\" offset.");
	ASSERT_MSG(m_vecBaseVelocity_flags != Address_Null, "Failed to retrieve \"m_vecBaseVelocity\" address.");
	ASSERT_MSG(LoadFromAddress(m_vecBaseVelocity_flags, NumberType_Int32) == 0, "Invalid or outdated \"m_vecBaseVelocity\" + offset address.");
	
	Address addr = gd.GetAddress("PLAYER_FLAG_BITS");
	ASSERT_MSG(addr != Address_Null, "Failed to retrieve \"PLAYER_FLAG_BITS\" address.");
	ASSERT_MSG(LoadFromAddress(addr, NumberType_Int32) == ((1 << 11) - 1), "Invalid or outdated \"PLAYER_FLAG_BITS\" address.");
	
	//PLAYER_FLAG_BITS patch
	gPlayerFlagBitsPatch = PatchHandler(addr);
	gPlayerFlagBitsPatch.Save(4);
	StoreToAddress(addr, 0xFFFFFFFF, NumberType_Int32);
	
	//m_vecBaseVelocity patch
	gPreviousBaseVelocityFlags = LoadFromAddress(m_vecBaseVelocity_flags, NumberType_Int32);
	StoreToAddress(m_vecBaseVelocity_flags, SPROP_NOSCALE, NumberType_Int32);
	
	//m_fFlags patch
	gPreviousFlagsBitsValue = LoadFromAddress(m_fFlags_bits, NumberType_Int32);
	StoreToAddress(m_fFlags_bits, 32, NumberType_Int32);
	
	//g_SendTableCRC patch
	gPreviousSendTableCRC = LoadFromAddress(g_SendTableCRC, NumberType_Int32);
	StoreToAddress(g_SendTableCRC, 1234, NumberType_Int32);
}

public void OnPluginEnd()
{
	StoreToAddress(g_SendTableCRC, gPreviousSendTableCRC, NumberType_Int32);
	StoreToAddress(m_fFlags_bits, gPreviousFlagsBitsValue, NumberType_Int32);
	StoreToAddress(m_vecBaseVelocity_flags, gPreviousBaseVelocityFlags, NumberType_Int32);
}
