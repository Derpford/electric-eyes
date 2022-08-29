class TrashTosser : EventHandler {
    // Responsible for dropping miscellaneous gore and items around the level.

    bool finished; // Has the level existed for long enough?
    int ticks; // How many ticks has it been?

    void TossDrops(Actor host) {
        static const String drops[] = { // TODO: Make some generic trash objects.
            "EERedPowder",
            "EERedPowder",
            "EEGoldPowder",
            "EEGreenHerb"
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
        if (finished || e.Thing.bACTLIKEBRIDGE || e.Thing.bISMONSTER || e.Thing is "LootSpot") { return; }
        if (e.Thing is "DeadMarine" || e.Thing.bSOLID) {
            // TossDrops(e.Thing);
            if (frandom(0,1) < 0.3) {
                e.Thing.Spawn("LootSpot",e.Thing.pos);
            }
        }
    }

    override void WorldThingDied(WorldEvent e) {
        if (e.Thing.bISMONSTER && frandom(0,1) < 0.3) {
            e.Thing.Spawn("LootSpot",e.Thing.pos);
        }
    }
}

class LootSpot : Actor {
    mixin Randoms;
    // Drops some random stuff.
    default {
        +SHOOTABLE;
        Radius 1;
        Height 1;
        Health 1;
        // DropItem "EEGreenHerb", 128;
        // DropItem "EEGreenHerb", 64;
        // DropItem "EEBlueHerb", 24;
        // DropItem "EERedPowder", 128;
        // DropItem "EERedPowder", 32;
        // DropItem "EEGoldPowder", 64;
        // DropItem "EEBluePowder", 16;
    }

    override int DamageMobj(Actor inf, Actor src, int dmg, Name type, int flags, double ang) {
        // Can only be broken by damage from your fists.
        if (type == "Roundhouse") {
            target = src;
            return super.DamageMobj(inf,src,dmg,type,flags,ang);
        } else {
            return 0;
        }
    }

    action void DropStuff() {
        Dictionary loot = Dictionary.FromString(
            "{
                \"EEGreenHerb\":\"0.8\",
                \"EEBlueHerb\":\"0.2\",
                \"EERedPowder\":\"1.0\",
                \"EEGoldPowder\":\"0.3\",
                \"EEBluePowder\":\"0.2\"
            }");
        int i = random(0,3);
        while (i > 0) {
            string result = invoker.WRDict(loot);
            Vector3 offs = (frandom(-i,i),frandom(-i,i),0);
            let it = invoker.Spawn(result,invoker.pos);
            if (it && target) {
                it.VelIntercept(target,10);
            }
            i--;
        }
    }

    states {
        Spawn:
            TNT1 A 1 A_SpawnParticle("FFFFFF",SPF_FULLBRIGHT|SPF_RELATIVE,35,6,angle:GetAge()*10,xoff:16,velz:1,startalphaf:2.0,fadestepf:-(1./35.));
            Loop;
        Death:
            TNT1 A 5 {
                A_StartSound("player/male/fist",1);
                A_StartSound("misc/lootopen");
                for (int i = 0; i < 16; i++) {
                    A_SpawnParticle("FFFFFF",SPF_FULLBRIGHT|SPF_RELATIVE,15,8,angle:frandom(0,360),velx:4,velz:frandom(1,5));
                }
            }
            TNT1 A 1 DropStuff();
            Stop;
    }
}