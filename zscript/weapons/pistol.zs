class EEPistol : EEWeapon {
    // Your basic pistol.
    // Handles well.
    default {

    }

    override Vector2 Kick() {
        double x1 = -2 * linstep(-3,3,laseraim.x);
        double x2 = 2 * linstep(3,-3,laseraim.x);
        double x = frandom(x1,x2);
        double y = 2 * linstep(4,0,laseraim.y);
        return (x, -y);
    }

    states {
        Select:
            PISG A 1 A_Raise();
            Loop;
        Deselect:
            PISG A 1 A_Lower();
            Loop;
        
        Ready:
            PISG A 1 A_WeaponReady();
            Loop;
        
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