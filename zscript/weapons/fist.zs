class EEPunch : Weapon {
    // A roundhouse punch that knocks back enemies.

    default {
        +Weapon.WIMPY_WEAPON;
        Weapon.SelectionOrder 9000; // Don't use this unless you absolutely have to!
    }

    override void Tick() {
        Super.Tick();
        if (owner) {
            let wpn = owner.player.readyweapon;
            let psp = owner.player.GetPSprite(PSP_WEAPON);
            if (wpn && wpn == self && wpn.InStateSequence(psp.curstate,wpn.ResolveState("Fire"))) {
                Vector3 oldvel = owner.vel.unit();
                if (owner.vel.length() == 0) { oldvel = (0,0,0);}
                owner.vel = oldvel * clamp(owner.vel.length(),0,4);
            }
        }
    }

    states {
        Select:
            PUNG A 1 {
                A_Raise(70);
            }
            Loop;
        
        Ready:
            PUNG A 5 ; 
        Fire:
            PUNG BC 3;
            PUNG DDD 1 A_WeaponOffset(12,4,WOF_ADD|WOF_INTERPOLATE);
            PUNG D 0 {
                int rad = 160;
                BlockThingsIterator it = BlockThingsIterator.Create(invoker.owner,rad);
                while (it.next()) {
                    if (it.Thing == invoker.owner || it.Thing.bDONTTHRUST || !it.Thing.bSHOOTABLE) { continue; }
                    Vector3 dv = invoker.owner.Vec3To(it.Thing);
                    if (dv.length() > rad) { continue; }
                    dv.z += it.Thing.height / 2.;
                    it.Thing.vel += dv.unit() * 16;
                    it.Thing.A_StartSound("player/male/fist");
                    if (it.Thing.bISMONSTER || it.Thing is "LootSpot") {
                        it.Thing.DamageMobj(invoker.owner,invoker.owner,10 + random(0,invoker.owner.CountInv("PowerSerum")),"Roundhouse");
                    }
                }
                // A_Explode(10 + random(0,invoker.owner.CountInv("PowerSerum")),rad,XF_NOTMISSILE|XF_EXPLICITDAMAGETYPE,fulldamagedistance:rad,damagetype:"Roundhouse");
            }
            PUNG DDD 1 A_WeaponOffset(12,4,WOF_ADD|WOF_INTERPOLATE);
        SwapCheck:
            PUNG D 0 {
                let plr = EEPlayer(invoker.owner);
                if (plr && plr.holster && plr.holster != "") {
                    A_SelectWeapon(plr.holster);
                    plr.holster = "";
                }
            }
            Goto ManualReady;
        Deselect:
            PUNG A 1 A_Lower(70);
            Loop;
        
        ManualReady:
            PUNG A 1 A_WeaponReady();
            Loop;
    }
}

class PowerSerum : Inventory replaces Berserk {
    // Boosts your fist's damage cap.
    default {
        Inventory.PickupMessage "Injected some Power Serum.";
        Inventory.Amount 1;
        Inventory.MaxAmount Int.Max; // If you can find that many berserk packs...good for you, I guess?
    }

    override void DoPickupSpecial(Actor toucher) {
        if (toucher) {
            toucher.GiveBody(50,toucher.GetMaxHealth(true)+50);
        }
        super.DoPickupSpecial(toucher);
    }

    states {
        Spawn:
            SYRN A -1;
            Stop;
    }
}