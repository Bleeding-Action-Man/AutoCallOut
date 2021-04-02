//=============================================================================
// Automatically sends a message & sound effect to all players with how many Scrakes &
// FleshPounds are currently spawned
// for more information, feedback, questions or requests please contact
// https://steamcommunity.com/id/Vel-San/
//=============================================================================

Class AutoCallOut extends Mutator config(AutoCallOut_Config);

#exec OBJ LOAD FILE=ACO_SNDS.uax

// Config Vars
var config bool bDebug, bPlaySoundFP, bPlaySoundSC;
var config string sWarningMSG, sFleshSND, sScrakeSND;
var config int iDelay, iDelayFP, iDelaySC;

// Colors from Config
struct ColorRecord
{
  var config string ColorName; // Color name, for comfort
  var config string ColorTag; // Color tag
  var config Color Color; // RGBA values
};
var config array<ColorRecord> ColorList; // Color list

// Mut Vars
var KFGameType KFGT;
var bool bPlayFP, bPlaySC;
var int iFP, iSC, iLastPlayedAtFP, iLastPlayedAtSC, tmpFP, tmpSC;

function PostBeginPlay()
{
  // Var init
  KFGT = KFGameType(Level.Game);
  bPlayFP = false;
  bPlaySC = false;
  iFP = 0;
  iSC = 0;
  iLastPlayedAtFP = 0;
  iLastPlayedAtSC = 0;
  tmpFP = 0;
  tmpSC = 0;

  // Force client to download SoundPack
  AddToPackageMap("ACO_SNDS.uax");

  if(bDebug)
  {
    MutLog("-----|| Debug - MSG: " $sWarningMSG$ " ||-----");
    MutLog("-----|| Debug - FP Sound: " $sFleshSND$ " ||-----");
    MutLog("-----|| Debug - SC Sound: " $sScrakeSND$ " ||-----");
    MutLog("-----|| Debug - Delay: " $iDelay$ " ||-----");
    MutLog("-----|| Debug - Flesh Pound Sound Delay: " $iDelayFP$ " ||-----");
    MutLog("-----|| Debug - Scrake Sound Delay: " $iDelaySC$ " ||-----");
  }

  SetTimer(iDelay, true);
}

function tick(float Deltatime)
{
  if (KFGT.bWaveInProgress && !KFGT.IsInState('PendingMatch') && !KFGT.IsInState('GameEnded'))
  {
    // Always gather count of FPs & SCs
    iFP = CheckFleshPoundCount();
    iSC = CheckScrakeCount();

    // Play FP Sound
    if (bPlaySoundFP && bPlayFP && (tmpFP < iFP) && (iLastPlayedAtFP < Level.TimeSeconds))
    {
      tmpFP = iFP;
      PlaySoundFP(sFleshSND);
    }

    // Play FP Sound
    if (bPlaySoundSC && bPlaySC && (tmpSC < iSC) && (iLastPlayedAtSC < Level.TimeSeconds))
    {
      tmpSC = iSC;
      PlaySoundSC(sScrakeSND);
    }
  }
}

function Timer()
{
  if (KFGT.bWaveInProgress && !KFGT.IsInState('PendingMatch') && !KFGT.IsInState('GameEnded'))
  {
    CallOut();
  }
}

function CallOut()
{
  local string tmpMSG, sFP, sSC;

  sFP = string(iFP);
  sSC = string(iSC);
  tmpMSG = sWarningMSG;

  ReplaceText(tmpMSG, "%FP", sFP);
  ReplaceText(tmpMSG, "%SC", sSC);

  if (iFP != 0 || iSC != 0)
  {
    BroadcastMSG(tmpMSG);
  }

  if(bDebug)
  {
    MutLog("-----|| Debug - FP Count: " $iFP$ "x | SC Count: " $iSC$ "x ||-----");
    MutLog("-----|| Debug - WarningMSG: " $tmpMSG$ " ||-----");
  }
}

function int CheckFleshPoundCount()
{
  local KFMonster Monster;
  local int i;

  foreach DynamicActors(class'KFMonster', Monster){
    if (Monster.isA('ZombieFleshpound'))
    {
      i = i + 1;
    }
  }
  if (i >= 1) bPlayFP = true;
  else bPlayFP = false;
  return i;
}

function int CheckScrakeCount()
{
  local KFMonster Monster;
  local int j;

  foreach DynamicActors(class'KFMonster', Monster){
    if (Monster.isA('ZombieScrake'))
    {
      j = j + 1;
    }
  }
  if (j >= 1) bPlaySC = true;
  else bPlaySC = false;
  return j;
}

function PlaySoundFP(string Sound)
{
  local Controller C;
  local sound SoundEffect;

  SoundEffect = sound(DynamicLoadObject(Sound, class'Sound'));
  for( C = Level.ControllerList; C != None; C = C.nextController )
	{
		if( C.IsA('PlayerController') && PlayerController(C).PlayerReplicationInfo.PlayerID != 0)
		{
			PlayerController(C).ClientPlaySound(SoundEffect, true, 20);
      iLastPlayedAtFP = Level.TimeSeconds + iDelayFP;
		}
	}
}

function PlaySoundSC(string Sound)
{
  local Controller C;
  local sound SoundEffect;

  SoundEffect = sound(DynamicLoadObject(Sound, class'Sound'));
  for( C = Level.ControllerList; C != None; C = C.nextController )
	{
		if( C.IsA('PlayerController') && PlayerController(C).PlayerReplicationInfo.PlayerID != 0)
		{
			PlayerController(C).ClientPlaySound(SoundEffect, true, 20);
      iLastPlayedAtSC = Level.TimeSeconds + iDelaySC;
		}
	}
}

simulated function TimeStampLog(coerce string s)
{
  log("["$Level.TimeSeconds$"s]" @ s, 'AutoCallOut');
}

simulated function MutLog(string s)
{
  log(s, 'AutoCallOut');
}

/////////////////////////////////////////////////////////////////////////
// BELOW SECTION IS CREDITED FOR ServerAdsKF Mutator | NikC	& DeeZNutZ //

// Send MSG to Players
event BroadcastMSG(coerce string Msg)
{
  local PlayerController pc;
  local Controller c;
  local string strTemp;

  // Apply Colors to MSG
  SetColor(Msg);

  for(c = level.controllerList; c != none; c = c.nextController)
  {
  // Allow only player controllers
  if(!c.isA('PlayerController'))
    continue;

  pc = PlayerController(c);
  if(pc == none)
    continue;

  // Remove colors for server log and WebAdmin
  if(pc.PlayerReplicationInfo.PlayerID == 0)
  {
    strTemp = RemoveColor(Msg);
    pc.teamMessage(none, strTemp, 'AutoCallOut');
    continue;
  }

  pc.teamMessage(none, Msg, 'AutoCallOut');
  }
}

// Apply Color Tags To Message
function SetColor(out string Msg)
{
  local int i;
  for(i=0; i<ColorList.Length; i++)
  {
    if(ColorList[i].ColorTag!="" && InStr(Msg, ColorList[i].ColorTag)!=-1)
    {
      ReplaceText(Msg, ColorList[i].ColorTag, FormatTagToColorCode(ColorList[i].ColorTag, ColorList[i].Color));
    }
  }
}

// Format Color Tag to ColorCode
function string FormatTagToColorCode(string Tag, Color Clr)
{
  Tag=Class'GameInfo'.Static.MakeColorCode(Clr);
  Return Tag;
}

function string RemoveColor(string S)
{
  local int P;
  P=InStr(S,Chr(27));
  While(P>=0)
  {
    S=Left(S,P)$Mid(S,P+4);
    P=InStr(S,Chr(27));
  }
  Return S;
}
//////////////////////////////////////////////////////////////////////


defaultproperties
{
  // Mut Vars
  GroupName="KF-AutoCallOut"
  FriendlyName="FP & SC Auto Call Out - v1.1"
  Description="Prints number of SC & FP Globally, and plays Spawn sound effects like KF2 [Whitelisted]; By Vel-San"
}
