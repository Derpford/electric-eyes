class EEPlayer : DoomPlayer {
    String holster; // What weapon did we just put away for punching?
    default {
        Player.StartItem "EEPistol";
        Player.StartItem "EEPunch";
        Player.StartItem "Clip", 30;
        Player.StartItem "EEHerbKit", 2;
        Player.StartItem "EEPowderKit";
        Player.MaxHealth 150;
        DamageFactor 1.75; // Fragile!
        Health 150;
    }

    override void Tick() {
        Super.Tick();
        int btn = GetPlayerInput(INPUT_BUTTONS);
        int oldbtn = GetPlayerInput(INPUT_OLDBUTTONS);

        if ((btn & BT_USER1) && !(oldbtn & BT_USER1)) {
            let herb = EEHerbKit(FindInventory("EEHerbKit"));
            if (herb) {
                herb.Use(false);
            }
        }
    }
}