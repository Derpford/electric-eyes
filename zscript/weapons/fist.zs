class EEPunch : Weapon {
    // A roundhouse punch that knocks back enemies.

    default {
        +Weapon.WIMPY_WEAPON;
        Weapon.SlotNumber 1;
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
                A_RadiusThrust(1600,320,RTF_NOTMISSILE,160);
                A_RadiusThrust(200,320,RTF_NOTMISSILE|RTF_THRUSTZ,160);
            }
            PUNG DDD 1 A_WeaponOffset(12,4,WOF_ADD|WOF_INTERPOLATE);
        SwapCheck:
            PUNG D 0 {
                let plr = EEPlayer(invoker.owner);
                if (plr) {
                    A_SelectWeapon(plr.holster);
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