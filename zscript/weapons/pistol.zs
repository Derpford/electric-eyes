class EEPistol : EEWeapon {
    // Your basic pistol.
    // Handles well.
    int mag;
    default {
        Weapon.SlotNumber 2;
        Weapon.AmmoType1 "PistolMag";
        Weapon.AmmoUse1 1;
        Weapon.AmmoGive1 0;
        Weapon.AmmoType2 "Clip";
        Weapon.AmmoUse2 0;
        Weapon.AmmoGive2 20;
        EEWeapon.AimFreeze 18;
    }

    override Vector2 Kick() {
        double x1 = -2 * linstep(-3,3,laseraim.x);
        double x2 = 2 * linstep(3,-3,laseraim.x);
        double x = frandom(x1,x2);
        double y = -2 * linstep(-4,0,laseraim.y);
        return (x, y);
    }

    states {
        Select:
            PISG A 1 A_Raise();
            Loop;
        Deselect:
            PISG A 1 A_Lower();
            Loop;
        
        Ready:
            PISG A 1 A_WeaponReady(WRF_ALLOWRELOAD);
            Loop;
        
        Reload:
            PISG B 5 A_WeaponOffset(-5,40,WOF_INTERPOLATE);
            PISG C 8 {
                A_StartSound("weapons/sshotc");
                A_WeaponOffset(-10,38,WOF_INTERPOLATE);
            }
            PISG C 12 A_WeaponOffset(0,36,WOF_INTERPOLATE);
            PISG C 6 A_StartSound("weapons/sshotl");
            PISG C 6 A_WeaponOffset(0,32,WOF_INTERPOLATE);
            PISG A 3 {
                Load("PistolMag","Clip",10);
                A_StartSound("weapons/sshotc");
            }
            Goto Ready;

        
        Fire:
            PISG B 2 {
                Shoot();
                A_StartSound("weapons/pistol");
            }
            PISG C 3;
        Hold:
            PISG A 1;
            PISG A 0 A_Refire();
            Goto Ready;
    }
}

class PistolMag : Ammo {
    default {
        Inventory.Amount 1;
        Inventory.MaxAmount 10;
        Ammo.BackpackAmount 0;
        Ammo.BackpackMaxAmount 10;
    }
}