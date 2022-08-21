class EEThunderbolt : EEWeapon replaces PlasmaRifle {
    // Brings the thunder, but has a really weird spread pattern.

    default {
        Inventory.PickupMessage "Got a...'Thunderbolt'?";
        Tag "Thunderbolt";
        Weapon.SlotNumber 4;
        Weapon.SlotPriority 0.5;
        EEWeapon.Shot "ThunderZap", 3;
        EEWeapon.Spread 0,3;
        EEWeapon.MagSize 100;
        Weapon.AmmoType1 "ThunderBattery";
        Weapon.AmmoUse1 2;
        Weapon.AmmoType2 "Cell";
        Weapon.AmmoGive2 30;
    }

    override Vector2 Kick() {
        double theta = 2 * (owner.CountInv("ThunderBattery") / 100.) * 360.;
        double x = cos(theta);
        return (x,0);
    }

    states {
        Spawn:
            PLAS A -1;
            Stop;
        
        Select:
            PLSG A 1 A_Raise(30);
            Loop;
        Deselect:
            PLSG A 1 A_Lower(30);
            Loop;
        
        Ready:
            PLSG A 1 A_WeaponReady(WRF_ALLOWRELOAD);
            Loop;
        
        Reload:
            PLSG B 3 A_WeaponOffset(-5,40,WOF_INTERPOLATE);
            PLSG B 12 {
                A_StartSound("weapons/sshotc");
                A_WeaponOffset(-10,38,WOF_INTERPOLATE);
            }
            PLSG B 16 A_WeaponOffset(0,36,WOF_INTERPOLATE);
            PLSG B 6 A_StartSound("misc/i_pkup");
            PLSG B 6 A_WeaponOffset(0,32,WOF_INTERPOLATE);
            PLSG A 3 {
                Load(100);
                A_StartSound("weapons/sshotc");
            }
            Goto Ready;

        Fire:
            PLSG A 0 A_JumpIf(!canfire(),"Click");
            PLSG A 3 {
                A_StartSound("weapons/plasmaf");
                Shoot();
                A_GunFlash();
            }
            PLSG B 15 A_Refire();
            Goto Ready;

        Flash:
            PLSF AB 3 Bright;
            Stop;

        Click:
            PLSG B 1 A_StartSound("misc/i_pkup");
        ClickHold:
            PLSG B 1;
            PLSG A 0 A_Refire("ClickHold");
            Goto Ready;

    }
}

class ThunderBattery : Ammo {
    default {
        Inventory.Amount 1;
        Inventory.MaxAmount 100;
        Ammo.BackpackAmount 0;
        Ammo.BackpackMaxAmount 100;
    }
}

class ThunderZap : EEBullet {
    // A more unpredictable, but potentially more powerful attack.
    default {
        MissileType "ThunderBeam";
        DamageFunction (Random(1,5) * 20);
    }

    states {
        Death:
            PLSE ABCDE 5 Bright;
            Stop;
    }
}

class ThunderBeam : Actor {
    default {
        +NOINTERACTION;
    }
    states {
        Spawn:
            TNT1 A 0;
            TNT1 A 1 A_SpawnParticle("AAAAFF",SPF_FULLBRIGHT,15,4,yoff:frandom(-2,2),zoff:frandom(-2,2));
            Stop;
    }
}