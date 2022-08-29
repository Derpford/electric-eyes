class EEShotgun : EEWeapon replaces Shotgun {
    // Accurate. Powerful. Kicks like a mule.
    default {
        Inventory.PickupMessage "Got a shotgun.";
        Tag "Shotgun";
        Weapon.SlotNumber 3;
        Weapon.SelectionOrder 4000;
        EEWeapon.Spread 1.5,1;
        EEWeapon.Shot "EEPellet", 5;
        EEWeapon.AimFreeze 45; // Slightly longer than the SMG.
        EEWeapon.LaserEdge 4; // Wider aim cone for the laser.
        Weapon.AmmoType1 "ShotgunMag";
        Weapon.AmmoUse1 1;
        Weapon.AmmoType2 "Shell";
        Weapon.AmmoGive2 3;
        EEWeapon.MagSize 5;
        EEWeapon.AimShake 0.2, 5;
    }

    override Vector2 Kick() {
        double x1 = -5.0 * linstep(-7,7,laseraim.x);
        double x2 = 5.0 * linstep(7,-7,laseraim.x);
        double x = frandom(x1,x2);
        double y1 = -6 * linstep(-8,0,laseraim.y);
        double y2 = 3 * linstep(-4,-8,laseraim.y);
        double y = frandom(y1,y2);
        return (x, y);
    }

    states {
        Spawn:
            SHOT A -1;
            Stop;
        
        Select:
            SHTG B 1 A_Raise(15);
            Loop;
        Deselect:
            SHTG B 1 A_Lower(15);
            Loop;
        
        Ready:
            SHTG A 1 A_WeaponReady(WRF_ALLOWRELOAD);
            Loop;

        Reload:
            SHTG B 6 A_StartSound("weapons/sshotc");
            SHTG C 5;
            SHTG D 4 {
                if (canload()) {
                    return ResolveState(null);
                } else {
                    return ResolveState("ReloadCheck");
                }
            }
        ReloadLoop:
            SHTG D 5 A_WeaponOffset(0,36,WOF_INTERPOLATE);
            SHTG D 4 {
                A_WeaponOffset(0,48,WOF_INTERPOLATE);
                A_StartSound("weapons/sshotl");
                Load(1);
            }
            SHTG D 8 {
                A_WeaponOffset(0,32,WOF_INTERPOLATE);
                A_Refire("ReloadEnd");
            }
            SHTG D 0 {
                if (!canload()) {
                    return ResolveState("ReloadEnd");
                } else {
                    return ResolveState(null);
                }
            }
            Loop;
        ReloadCheck:
            SHTG D 10;
        ReloadEnd:
            SHTG C 5;
            SHTG B 5 A_StartSound("weapons/sshoto");
            Goto Ready;
        
        Fire:
            SHTG A 0 A_JumpIf(!canfire(), "Click");
            SHTG A 6 {
                Shoot();
                A_GunFlash();
                A_WeaponOffset(0,48,WOF_INTERPOLATE);
                A_StartSound("weapons/shotgf");
            }
        Pump:
            SHTG BC 5 A_WeaponOffset(0,32,WOF_INTERPOLATE);
            SHTG D 4;
            SHTG CB 5;
        Hold:
            SHTG A 1;
            SHTG A 0 A_Refire();
            SHTG A 3;
            Goto Ready;
        Click:
            SHTG A 1 A_StartSound("weapons/sshoto");
            Goto Hold;

        Flash:
            SHTF A 3 Bright;
            SHTF B 2 Bright;
            Stop;
    }
}

class EEPellet : EEBullet {
    default {
        DamageFunction (20);
    }
}

class ShotgunMag : Ammo {
    default {
        Inventory.Amount 1;
        Inventory.MaxAmount 5;
        Ammo.BackpackAmount 0;
        Ammo.BackpackMaxAmount 5;
    }
}