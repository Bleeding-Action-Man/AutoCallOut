//=============================================================================
// Automatically sends a message to all players with how many Scrakes &
// FleshPounds are currently spawned
// Written by Vel-San
// for more information, feedback, questions or requests please contact
// https://steamcommunity.com/id/Vel-San/
//=============================================================================

Class AutoCallOut extends Mutator config(AutoCallOut);

var() config bool bDebug;
var() config string sWarningMSG;
var() config int iDelay;


// Colors from Config
struct ColorRecord
{
  var config string ColorName; // Color name, for comfort
  var config string ColorTag; // Color tag
  var config Color Color; // RGBA values
};
var() config array<ColorRecord> ColorList; // Color list

function PostBeginPlay()
{
  if(bDebug)
  {
    MutLog("-----|| Debug - MSG: " $sWarningMSG$ " ||-----");
    MutLog("-----|| Debug - Delay: " $iDelay$ " ||-----");
  }

  SetTimer( iDelay, true);
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
  Super.FillPlayInfo(PlayInfo);
  PlayInfo.AddSetting("AutoCallOut", "sWarningMSG", "Warning Message", 0, 0, "text");
  PlayInfo.AddSetting("AutoCallOut", "iDelay", "MSG Frequency", 0, 0, "text");
  PlayInfo.AddSetting("AutoCallOut", "bDebug", "Debug", 0, 0, "check");
}

static function string GetDescriptionText(string SettingName)
{
  switch(SettingName)
  {
    case "sWarningMSG":
        return "Message to show players about SCs & FPs number. Use %FP for Fleshpounds & %SC for Scrakes";
    case "iDelay":
        return "How often will the warning message be sent out ( in Seconds ) | Preffered 5";
    case "bDebug":
        return "Shows some Debugging messages in the LOG. Keep OFF unless you know what you are doing!";
    default:
        return Super.GetDescriptionText(SettingName);
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

function Timer()
{
  local string tmpMSG, sFP, sSC;;
  local int iFP, iCountFP, iSC, iCountSC;

  iFP = CheckFleshPoundCount(iCountFP);
  iSC = CheckScrakeCount(iCountSC);
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

function int CheckFleshPoundCount(int i){
  local KFMonster Monster;

  foreach DynamicActors(class'KFMonster', Monster){
    if (Monster.isA('ZombieFleshpound'))
    {
      i = i + 1;
    }
  }
  return i;
}

function int CheckScrakeCount(int j){
  local KFMonster Monster;

  foreach DynamicActors(class'KFMonster', Monster){
    if (Monster.isA('ZombieScrake'))
    {
      j = j + 1;
    }
  }
  return j;
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
  Description="Automatically calls out FPs & SCs as a broadcast message to all players [Whitelisted]; By Vel-San"
}
