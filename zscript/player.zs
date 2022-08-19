class EEPlayer : DoomPlayer {
    default {
        Player.StartItem "EEPistol";
        Player.StartItem "Clip", 30;
        Player.StartItem "EEHerbKit", 2;
        Player.MaxHealth 150;
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