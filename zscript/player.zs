class EEPlayer : DoomPlayer {
    default {
        Player.StartItem "EEPistol";
        Player.StartItem "Clip", 30;
        Player.StartItem "EEHerbKit", 2;
        Player.MaxHealth 150;
        Health 150;
    }
}