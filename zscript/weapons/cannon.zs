class EEAssaultCannon : EEWeapon replaces SuperShotgun {
    // Burns through shells *fast*, but shreds enemies up close. The panic button.
    default {
        Inventory.PickupMessage "Got a riot-grade Assault Cannon.";
        Tag "Assault Cannon";
        EEWeapon.SlotNumber 3;
        EEWeapon.Shot "EEPellet", 5;
        EEWeapon.Spread 2,1.5;
        EEWeapon.LaserEdge 4; // Wide aim cone, like the Shotgun.
        Weapon.AmmoType1 "CannonMag";
        Weapon.AmmoUse1 1;
        Weapon.AmmoType2 "Shell";
        Weapon.AmmoGive2 4;
        EEWeapon.MagSize 6;
    }

    override Vector2 Kick() {
        double x1 = -2.5 * linstep(-7,7,laseraim.x);
        double x2 = 2.5 * linstep(7,-7,laseraim.x);
        double x = frandom(x1,x2);
        double y1 = -6 * linstep(-10,-4,laseraim.y);
        double y2 = 2 * linstep(-4,-8,laseraim.y);
        double y = frandom(y1,y2);
        return (x, y);
    }

    states {
        Spawn:
            MGUN A -1;
            Stop;
        
        Select:
            CHGG AAAABBBB 1 A_Raise(5);
            Loop;
        Deselect:
            CHGG AAAABBBB 1 A_Lower(5);
            Loop;
        
        Ready:
            CHGG A 1 A_WeaponReady(WRF_ALLOWRELOAD);
            Loop;
        
        
        Reload:
            CHGG A 6 A_StartSound("weapons/sshotc");
            CHGG B 5;
            CHGG B 4 {
                if (canload()) {
                    return ResolveState(null);
                } else {
                    return ResolveState("ReloadCheck");
                }
            }
        ReloadLoop:
            CHGG A 5 A_WeaponOffset(0,36,WOF_INTERPOLATE);
            CHGG B 4 {
                A_WeaponOffset(0,48,WOF_INTERPOLATE);
                A_StartSound("weapons/sshotl");
                Load(1);
            }
            CHGG B 14 {
                A_WeaponOffset(0,32,WOF_INTERPOLATE);
                A_Refire("ReloadEnd");
            }
            CHGG B 0 {
                if (!canload()) {
                    return ResolveState("ReloadEnd");
                } else {
                    return ResolveState(null);
                }
            }
            Loop;
        ReloadCheck:
            CHGG B 10;
        ReloadEnd:
            CHGG B 5;
            CHGG A 5 A_StartSound("weapons/sshoto");
            Goto Ready;
        
        Fire:
            CHGG A 0 A_JumpIf(!canfire(),"Click");
            CHGG A 4 {
                A_GunFlash();
                Shoot();
                A_StartSound("weapons/sshotf");
                A_WeaponOffset(0,40,WOF_INTERPOLATE);
            }
            CHGG B 4 A_WeaponOffset(0,36,WOF_INTERPOLATE);
            CHGG A 3 A_WeaponOffset(0,32,WOF_INTERPOLATE);
            CHGG A 5 A_Refire();
            Goto Ready;

        Flash:
            CHGF AB 3 Bright;
            Stop;

        Click:
            CHGG A 1 A_StartSound("weapons/sshoto");
        ClickHold:
            CHGG A 1;
            CHGG A 0 A_Refire("ClickHold");
            Goto Ready;
    }
}

class CannonMag : Ammo {
    default {
        Inventory.Amount 1;
        Inventory.MaxAmount 6;
        Ammo.BackpackAmount 0;
        Ammo.BackpackMaxAmount 6;
    }
}