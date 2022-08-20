class TrashTosser : EventHandler {
    // Responsible for dropping miscellaneous gore and items around the level.

    bool finished; // Has the level existed for long enough?
    int ticks; // How many ticks has it been?

    void TossDrops(Actor host) {
        static const String drops[] = {
            "EERedPowder",
            "EERedPowder",
            "EEGoldPowder",
            "EEGreenHerb",
        };
        if (random(0,2) == 0) {
            for (int i = random(1,3); i > 0; i--) {
                let it = host.Spawn(drops[random(0,drops.size()-1)],host.pos);
                if (it) {
                    it.vel += (frandom(-5,5),frandom(-5,5),frandom(0,12));
                }
            }
        }
    }

    override void WorldTick() {
        if (!finished) {
            ticks += 1;
            if (ticks > 35) {
                finished = true;
            }
        }
    }

    override void WorldThingSpawned(WorldEvent e) {
        if (finished || e.Thing.bACTLIKEBRIDGE) { return; }
        if (e.Thing.bISMONSTER || e.Thing is "DeadMarine" || e.Thing.bSOLID) {
            TossDrops(e.Thing);
        }
    }
}