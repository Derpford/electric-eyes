class EEGrenadeLauncher : EEWeapon replaces RocketLauncher {
    // Powerful. Ammunition's scarce, though.

    default {
        Inventory.PickupMessage "Got a sticky grenade launcher.";
        Tag "Grenade Launcher";
        Weapon.SlotNumber 5;
        +Weapon.NOAUTOFIRE;
        Weapon.SelectionOrder 8000;
        Weapon.AmmoType "GrenadeMag";
        Weapon.AmmoUse1 1;
        Weapon.AmmoType2 "RocketAmmo";
        Weapon.AmmoUse2 0;
        Weapon.AmmoGive2 1;
        EEWeapon.MagSize 3;
        EEWeapon.Shot "EEStickyGrenade",1;
    }

    override Vector2 Kick() {
        double x1 = -0.5 * linstep(-3,3,laseraim.x);
        double x2 = 0.5 * linstep(3,-3,laseraim.x);
        double x = frandom(x1,x2);
        double y1 = -3.75 * linstep(-8,0,laseraim.y);
        double y = frandom(y1,y1/2.);
        return (x, y);
    }

    states {
        Spawn:
            LAUN A -1;
            Stop;
        
        Select:
            MISG A 1 A_Raise(10);
            Loop;
        Deselect:
            MISG A 1 A_Lower(10);
            Loop;
        
        Ready:
            MISG A 1 A_WeaponReady(WRF_ALLOWRELOAD);
            Loop;
        
        Reload:
            MISG B 11 {
                A_StartSound("weapons/sshotc");
                A_WeaponOffset(0,40,WOF_INTERPOLATE);
            }
            MISG B 0 {
                if (canload()) {
                    return ResolveState(null);
                } else {
                    return ResolveState("ReloadCheck");
                }
            }
        ReloadLoop:
            MISG B 5 A_WeaponOffset(0,36,WOF_INTERPOLATE);
            MISG B 4 {
                A_WeaponOffset(0,48,WOF_INTERPOLATE);
                A_StartSound("weapons/sshotl");
                Load(1);
            }
            MISG B 8 {
                A_WeaponOffset(0,32,WOF_INTERPOLATE);
                A_Refire("ReloadEnd");
            }
            MISG B 0 {
                if (!canload()) {
                    return ResolveState("ReloadEnd");
                } else {
                    return ResolveState(null);
                }
            }
            Loop;
        ReloadCheck:
            MISG B 10;
        ReloadEnd:
            MISG B 5;
            MISG B 5 A_StartSound("weapons/sshoto");
            Goto Ready;
        
        Fire:
            MISG A 0 A_JumpIf(!canfire(), "Click");
            MISG B 8 {
                A_GunFlash();
                Shoot();
                A_StartSound("weapons/rocklf");
            }
        Hold:
            MISG B 1;
            MISG B 0 A_Refire();
            MISG B 1 A_StartSound("weapons/sshoto",0);
            Goto Ready;

        Click:
            MISG B 1 A_StartSound("weapons/sshoto");
            Goto Hold;
        
        Flash:
            MISF ABCD 2 Bright;
            Stop;
    }
}

class GrenadeMag : Ammo {
    default {
        Inventory.Amount 1;
        Inventory.MaxAmount 3;
        Ammo.BackpackAmount 0;
        Ammo.BackpackMaxAmount 3;
    }
}

class EEStickyGrenade : Actor {
    // Detonates after 3s of rest or sticking to an enemy.
    int timer;
    default {
        PROJECTILE;
        Speed 70;
        DamageFunction (48);
        BounceType "Doom";
        -NOGRAVITY;
        -NOTELEPORT;
        +HITTRACER;
        -ALLOWBOUNCEONACTORS
        BounceFactor 0.5;
    }

    states {
        Spawn:
            SGRN A 1 Bright;
            Loop;
        
        Death:
            SGRN A 1;
            SRGN A 0 {
                if (tracer) { Warp(tracer,zofs:tracer.height/2.); }

                timer += 1;
                if (timer % 35 == 0) {
                    A_StartSound("misc/i_pkup");
                }

                if (timer > 105) {
                    return ResolveState("Explode");
                } else {
                    return ResolveState(null);
                }
            }
            Loop;
        
        Explode:
            MISL B 0 A_StartSound("weapons/rocklx");
            MISL BCD 4 Bright A_Explode(192,128,fulldamagedistance:64);
            Stop;
    }
}