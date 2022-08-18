class EEP90 : EEWeapon replaces Chaingun {
    // A fast-firing weapon with lower kick, but it takes longer for it to recover and it drifts further over time.
    default {
        Weapon.SlotNumber 4;
        Weapon.AmmoType1 "SMGMag";
        Weapon.AmmoUse1 1;
        Weapon.AmmoGive1 0;
        Weapon.AmmoType2 "Clip";
        Weapon.AmmoUse2 0;
        Weapon.AmmoGive2 20;
        EEWeapon.MagSize 50;
    }

    override Vector2 Kick() {
        double x1 = -1.5 * linstep(-7,7,laseraim.x);
        double x2 = 1.5 * linstep(7,-7,laseraim.x);
        double x = frandom(x1,x2);
        double y1 = -0.75 * linstep(-4,0,laseraim.y);
        double y2 = 0.5 * linstep(-2,-4,laseraim.y);
        double y = frandom(y1,y2);
        return (x, y);
    }

    states {
        Spawn:
            WP90 A -1;
            Stop;
        
        Select:
            FN90 A 1 A_Raise(20);
            Loop;
        Deselect:
            FN90 A 1 A_Lower(20);
            Loop;
        
        Ready:
            FN90 A 1 A_WeaponReady(WRF_ALLOWRELOAD);
            Loop;

        Reload:
            FN90 C 12 A_WeaponOffset(0,48,WOF_INTERPOLATE);
            FN90 C 8 {
                A_WeaponOffset(12,52,WOF_INTERPOLATE);
                A_StartSound("weapons/sshoto");
            }
            FN90 C 6 A_WeaponOffset(4,50,WOF_INTERPOLATE);
            FN90 C 10 {
                A_WeaponOffset(12,54,WOF_INTERPOLATE);
                A_StartSound("weapons/sshotc");
            }
            FN90 C 12 A_WeaponOffset(0,32,WOF_INTERPOLATE);
            FN90 C 0 {
                Load(50);
            }
            Goto Ready;
        
        Fire:
            FN90 B 2 Bright {
                Shoot();
                A_StartSound("weapons/pistol");
            }
            FN90 D 2 Bright {
                Shoot();
                A_StartSound("weapons/pistol");
            }
            FN90 C 1;
            FN90 C 4 A_Refire();
            Goto Ready;
    }
}

class SMGMag : Ammo {
    default {
        Inventory.Amount 1;
        Inventory.MaxAmount 50;
        Ammo.BackpackAmount 0;
        Ammo.BackpackMaxAmount 50;
    }
}