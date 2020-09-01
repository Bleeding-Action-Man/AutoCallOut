//=============================================================================
// Automatically sends a message to all players that XX has seen/spotted a
// Scrake or a FleshPound
// Written by Vel-San
// for more information, feedback, questions or requests please contact
// https://steamcommunity.com/id/Vel-San/
//=============================================================================

Class KFAutoCallOut extends Mutator config(KFAutoCallOut);

var() config bool bDEBUG;
var bool DEBUG;

replication
{
	unreliable if (Role == ROLE_Authority)
		bDEBUG,
		DEBUG;
}

simulated function PostBeginPlay()
{
	DEBUG = bDEBUG;

  MutLog("-----|| Changing SC & FP Controller ||-----");
  class'ZombieFleshpound'.Default.ControllerClass = Class'FPCustomController';
  class'ZombieScrake'.Default.ControllerClass = Class'SCCustomController';

	SetTimer(1,true);
}

simulated function PostNetBeginPlay()
{
	// Future code goes here if values needed from the server
	TimeStampLog("-----|| Server Vars Replicated ||-----");
	if(DEBUG){
	}
}

static function FillPlayInfo(PlayInfo PlayInfo)
{
	Super.FillPlayInfo(PlayInfo);
  PlayInfo.AddSetting("KFAutoCallOut", "bDEBUG", "DEBUG", 0, 0, "check");
}

static function string GetDescriptionText(string SettingName)
{
	switch(SettingName)
	{
		case "bDEBUG":
			return "Shows some Debugging messages in the LOG. Better to keep off!";
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

function Timer(){
	ApplyMonsterControllerChange();
}

simulated function ApplyMonsterControllerChange(){
  local KFMonster Monster;
  local int i, j;
  // local KFGameType KF;
	// KF = KFGameType(Level.Game);

  foreach DynamicActors(class'KFMonster', Monster){
    if (Monster.isA('ZombieFleshpound')){
        i = i + 1;
        	if(DEBUG){
	          MutLog("-----|| DEBUG - FP Controller: " $Monster.ControllerClass$ " ||-----");
	        }
    }
    if (Monster.isA('ZombieScrake')){
        j = j + 1;
        if(DEBUG){
	          MutLog("-----|| DEBUG - SC Controller: " $Monster.ControllerClass$ " ||-----");
	        }
    }
  }

  if(DEBUG){
	MutLog("-----|| DEBUG - FP Count: " $i$ "x | SC Count: " $j$ "x ||-----");
  }

  // KF.PrepareSpecialSquads();
  // KF.LoadUpMonsterList();

}

/*
/////////////////////////////////////////////////////////////////////////
// BELOW SECTION IS CREDITED FOR ServerAdsKF Mutator | NikC	& DeeZNutZ //

// Send Notification
event BroadcastAd(coerce string Msg)
{
  local PlayerController pc;
  local Controller c;
  local string strTemp;

  //convert color tags to colors
  //and apply to messages
  if(Left(Msg,1)!="#")
    SetColor(Msg);

  for(c = level.controllerList; c != none; c = c.nextController)
  {
    //allow only player controllers
    if(!c.isA('PlayerController'))
      continue;

    pc = PlayerController(c);
    if(pc == none)
      continue;

    if(left(Msg,1)=="#")
    {
      Msg = right(Msg,len(Msg)-1);
      pc.ClearProgressMessages();
      pc.SetProgressTime(iAdminMsgDuration);
      pc.SetProgressMessage(0, Msg, cAdminMsgColor);
      LogD("ServerAdsKF admin line: "$Msg);
      return;
    }

    // remove colors for server log and WebAdmin
    if(pc.PlayerReplicationInfo.PlayerID == 0)
    {
      strTemp = RemoveColor(Msg);
      pc.teamMessage(none, strTemp, 'ServerAdsKF');
      LogD("ServerAdsKF line: "$Msg);
      continue;
    }

    pc.teamMessage(none, Msg, 'ServerAdsKF');
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
*/

defaultproperties
{
	// Mut Vars
  GroupName="KF-AutoCallOut"
  FriendlyName="FP & SC Auto Call Out - v1.0"
  Description="Automatically calls out FPs & SCs as a broadcast message to all players; By Vel-San"
  bAlwaysRelevant=True
  RemoteRole=ROLE_SimulatedProxy
	bNetNotify=True
}
