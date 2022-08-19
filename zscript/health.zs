class HealthBlockHandler : EventHandler {
    Array<int> timers;
    int hbtick; // how many ticks between heals
    int hbdelay; // how long after damage to not heal
    int hbsize; // the size of a health block
    int hbamount; // how much to heal each time
    bool hbover; // Give health bonuses so that you can overheal?
    
    override void OnRegister() {
        timers.resize(MAXPLAYERS); // one array per player
        // negative = waiting on damage
        // positive = ticking toward heals

        // If it has been hblock_delay tics since the last source of damage:
        // Every hblock_tick tics, if our health % hblock_size is not 0, heal either hblock_amount or up to the next hblock_size increment.
        hbtick = 10;
        hbdelay = 105;
        hbsize = 50;
        hbamount = 1;
        hbover = false;
    }

    int BlockSize() {
        return hbsize;
    }

    int ToNextBlock(PlayerInfo plr) {
        int hp = plr.mo.health;
        int block = BlockSize();
        int delta = block - (hp % block);
        return delta;
    }

    int ToPrevBlock(PlayerInfo plr) {
        int hp = plr.mo.health;
        int block = BlockSize();
        int delta = (hp % block);
        return delta;

    }

    override void WorldTick() {
        for (int i = 0; i < MAXPLAYERS; i++) {
            if (playeringame[i]) {
                timers[i] += 1;
                if (timers[i] >= hbtick) {
                    PlayerInfo plr = players[i];
                    int delta = ToPrevBlock(plr);
                    if (delta != 0) {
                        // We're not sitting on a breakpoint. Heal up!
                        int maxhp = plr.mo.SpawnHealth();
                        if (hbover) { maxhp = int.max; }
                        plr.mo.GiveBody(min(ToNextBlock(plr), hbamount),maxhp);
                    }
                    timers[i] = min(timers[i],0);
                }
            }
        }
    }

    override void WorldThingDamaged(WorldEvent e) {
        if (e.Thing is "PlayerPawn") {
            timers[e.Thing.PlayerNumber()] = hbdelay * -1;
            // console.printf("PNum: "..e.Thing.PlayerNumber());
        }
    }
}