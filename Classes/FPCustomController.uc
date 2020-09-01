//-----------------------------------------------------------
// Changes Made:
// VP Will Trigger 100% of the time when an FP is seen
//-----------------------------------------------------------
class FPCustomController extends FleshpoundZombieController;

state ZombieHunt
{
	event SeePlayer(Pawn SeenPlayer)
	{
		if ( !bDoneSpottedCheck && PlayerController(SeenPlayer.Controller) != none )
		{
			// 100% chance of first player to see this Fleshpound saying something
			if ( !KFGameType(Level.Game).bDidSpottedFleshpoundMessage )
			{
				PlayerController(SeenPlayer.Controller).Speech('AUTO', 12, "");
				KFGameType(Level.Game).bDidSpottedFleshpoundMessage = true;
				MutLog("-----|| DEBUG - 1x FP Has Been Spotted ||-----");
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