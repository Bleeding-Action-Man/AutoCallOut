//-----------------------------------------------------------
// Changes Made:
// VP Will Trigger 100% of the time when an SC is seen
//-----------------------------------------------------------
class SCCustomController extends SawZombieController;

state ZombieHunt
{
	event SeePlayer(Pawn SeenPlayer)
	{
		if ( !bDoneSpottedCheck && PlayerController(SeenPlayer.Controller) != none )
		{
			// 100% chance of first player to see this Scrake saying something
			if ( !KFGameType(Level.Game).bDidSpottedScrakeMessage )
			{
				PlayerController(SeenPlayer.Controller).Speech('AUTO', 14, "");
				KFGameType(Level.Game).bDidSpottedScrakeMessage = true;
				MutLog("-----|| DEBUG - 1x SC Has Been Spotted ||-----");
			}

			bDoneSpottedCheck = true;
		}

		super.SeePlayer(SeenPlayer);
	}
}

simulated function MutLog(string s)
{
  log(s, 'AutoCallOut');
}