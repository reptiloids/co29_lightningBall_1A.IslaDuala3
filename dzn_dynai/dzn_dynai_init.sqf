// **************************
// 	DZN DYNAI v0.9 ZC
//
//	Initialized when:
//	{ !isNil "dzn_dynai_initialized" }
//
//	Server-side initialized when:
//	{ !isNil "dzn_dynai_initialized" && { dzn_dynai_initialized } }
//
// **************************


// **************************
//	SETTINGS
// **************************
call compile preProcessFileLineNumbers "dzn_dynai\Settings.sqf";

dzn_dynai_complexSkill = [ 
	!dzn_dynai_UseSimpleSkill
	, if (dzn_dynai_UseSimpleSkill) then {
		dzn_dynai_overallSkillLevel	
	} else {
		dzn_dynai_complexSkillLevel			
	}
];

// **************************
//	INITIALIZATION
// **************************
// If a player and no Zeus needed - exits script
if (hasInterface && !isServer) exitWith {
	if (dzn_dynai_enableZeusCompatibility) then {
		call compile preProcessFileLineNumbers "dzn_dynai\fn\dzn_dynai_dynaiFunctions.sqf";
		call compile preProcessFileLineNumbers "dzn_dynai\fn\dzn_dynai_controlFunctions.sqf";
		call compile preProcessFileLineNumbers "dzn_dynai\fn\dzn_dynai_behaviourFunctions.sqf";
		call compile preProcessFileLineNumbers "dzn_dynai\fn\dzn_dynai_zeusCompatibility.sqf";
	};
};

dzn_dynai_initialized = false;
waitUntil dzn_dynai_initCondition;

dzn_dynai_pubVars = dzn_dynai_enableZeusCompatibility;

// Initialization of dzn_gear
waitUntil { !isNil "dzn_gear_serverInitDone" || !isNil "dzn_gear_initDone" };

// Initialization of dzn_dynai
dzn_dynai_activatedZones = [];
dzn_dynai_activeGroups = [];
dzn_dynai_zoneProperties = [
	#include "Zones.sqf"
];

call compile preProcessFileLineNumbers "dzn_dynai\fn\dzn_dynai_dynaiFunctions.sqf";
call compile preProcessFileLineNumbers "dzn_dynai\fn\dzn_dynai_controlFunctions.sqf";
call compile preProcessFileLineNumbers "dzn_dynai\fn\dzn_dynai_behaviourFunctions.sqf";
if (dzn_dynai_enableZeusCompatibility) then {
	call compile preProcessFileLineNumbers "dzn_dynai\fn\dzn_dynai_zeusCompatibility.sqf";
};
//	**************	SERVER OR HEADLESS	*****************
if (!isNil "HC") then {if (isServer) exitWith {};};



// **************************
//	DZN DYANI START
// **************************
waitUntil { time > dzn_dynai_preInitTimeout };
call dzn_fnc_dynai_initZones;

waitUntil { time > (dzn_dynai_preInitTimeout + dzn_dynai_afterInitTimeout) };
call dzn_fnc_dynai_startZones;

// **************************
//	GROUP RESPONSES SYSTEM
// **************************

if (dzn_dynai_allowGroupResponse) then { 
	call dzn_fnc_dynai_processUnitBehaviours;
	[] execFSM "dzn_dynai\FSMs\dzn_dynai_reinforcement_behavior.fsm";
};

// **************************
//	CACHING SYSTEM
// **************************
if !(dzn_dynai_enableCaching) exitWith {dzn_dynai_initialized = true; publicVariable "dzn_dynai_initialized";};

waitUntil { time > (dzn_dynai_preInitTimeout + dzn_dynai_afterInitTimeout + dzn_dynai_cachingTimeout) };
call compile preProcessFileLineNumbers "dzn_dynai\fn\dzn_dynai_cacheFunctions.sqf";
[false] execFSM "dzn_dynai\FSMs\dzn_dynai_cache.fsm";


// **************************
//	INITIALIZED
// **************************
dzn_dynai_initialized = true; 
publicVariable "dzn_dynai_initialized";
