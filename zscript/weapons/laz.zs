class EELazarus : EEWeapon replaces BFG9000 {
    // The Lazarus Device.
    default {
        Inventory.PickupMessage "The Lazarus Device.";
        Tag "Lazarus Device";
        Weapon.SlotNumber 5;
        Weapon.AmmoType1 "LazBattery";
        Weapon.AmmoUse1 1;
        Weapon.AmmoType2 "Cell";
        Weapon.AmmoGive2 50;
        EEWeapon.AimFreeze 0;
        EEWeapon.AimVel 0.01, 1.0;
        EEWeapon.Shot "LazarusBeam",1;
        EEWeapon.MagSize 105;
    }

    override Vector2 Kick() {
        double theta = 3 * (owner.CountInv("LazBattery") / 105.) * 360;
        double x = cos(theta);
        double y = sin(theta);
        return (x, y);
    }

    states {
        Spawn:
            BFUG A -1;
            Stop;
        
        Select:
            BFGG B 1 A_Raise(5);
            Loop;
        Deselect:
            BFGG B 1 A_Lower(5);
            Loop;
        
        Ready:
            BFGG A 1 A_WeaponReady(WRF_ALLOWRELOAD);
            Loop;
        
        Reload:
            BFGG B 5 A_WeaponOffset(-5,40,WOF_INTERPOLATE);
            BFGG B 8 {
                A_StartSound("weapons/sshotc");
                A_WeaponOffset(-10,38,WOF_INTERPOLATE);
            }
            BFGG B 12 A_WeaponOffset(0,36,WOF_INTERPOLATE);
            BFGG B 6 A_StartSound("misc/i_pkup");
            BFGG B 6 A_WeaponOffset(0,32,WOF_INTERPOLATE);
            BFGG A 3 {
                Load(105);
                A_StartSound("weapons/sshotc");
            }
            Goto Ready;
        
        Fire:
        Hold:
            BFGG A 0 A_JumpIf(!canfire(),"Click");
            BFGG B 1 {
                Shoot();
                A_GunFlash();
                A_StartSound("weapons/plasmaf");
            }
            BFGG B 0 A_Refire();
            Goto Ready;

        Click:
            BFGG A 1;
            BFGG A 0 A_Refire("Click");
            Goto Ready;
        
        Flash:
            BFGF A 3 Bright;
            BFGF B 2 Bright;
            Stop;
    }
}

class LazBattery : Ammo {
    default {
        inventory.Amount 1;
        inventory.MaxAmount 105;
        ammo.BackpackAmount 0;
        ammo.BackpackMaxAmount 105;
    }
}

class LazarusBeam : Actor {
    int timer;
    default {
        PROJECTILE;
        Speed 60;
        RenderStyle "Add";
        Radius 15;
        Height 30;
        DamageFunction (32);
    }

    states {
        Spawn:
            BFS1 AAABBB 1 Bright {
                timer += 1;
                if (timer > 70) {
                    return ResolveState("Death");
                } else {
                    return ResolveState(null);
                }
            }
            Loop;
        Death:
            BFE1 ABCDE 3 Bright A_Explode(256,256,0);
            Stop;
    }
}