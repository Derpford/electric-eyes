// The base weapon class.
class EEWeapon : Weapon abstract {

    // Weapons have laser sights, usually.
    bool nolaser;
    Property NoLaser : nolaser;
    // They tend to fire their projectiles super-accurately...
    double spreadx,spready;
    Property Spread : spreadx, spready;
    // ...at the laser, which drifts away from center when the owner's moving or when firing.
    Vector2 laseraim; // X is angle, Y is pitch
    Vector2 aimvel;
    double aimmaxspd;
    double aimaccel;
    Property AimVel : aimaccel,aimmaxspd;
    double aimshake;
    int shaketics;
    Property AimShake: aimshake, shaketics;
    // In addition, firing freezes the 'gravity' of the pointer for a bit.
    int aimfreeze;
    int aimfreezemax;
    Property AimFreeze : aimfreezemax;
    // That laser also dims slightly on firing.
    double laseralpha;
    double laseredge;
    Property LaserEdge : laseredge;
    
    // Set a specific projectile, if needed. Also, the number of shots produced by each attack.
    String shot;
    int numshots;
    Property Shot : shot, numshots;

    int magsize;
    Property MagSize : magsize;

    default {
        EEWeapon.NoLaser false;
        EEWeapon.Spread 0,0;
        EEWeapon.Shot "EEBullet",1;
        EEWeapon.AimFreeze 35;
        EEWeapon.AimVel 0.05, 1.0;
        EEWeapon.AimShake 0.1, 3;
        EEWeapon.LaserEdge 2.0;
        +WEAPON.AMMO_CHECKBOTH;
        Weapon.MinSelectionAmmo2 1;
    }

	void SpawnLaser(Vector2 aim,double alpha,String col = "FF1111")
	{
		FLineTraceData data;
		double dist = 512;
        double zoff = 28;
		owner.LineTrace(owner.angle+aim.x,dist,owner.pitch+aim.y,offsetz:zoff,data:data);
		Vector3 spawnpos = owner.pos;
		int q = 4;
		spawnpos.z += zoff;
		for(double i = 0; i<data.distance; i += frandom(1,2) * q )
		{
			Vector3 newpartpos = (data.HitDir*i);
            double fa = 0.5 * alpha * ((dist-i)/dist);
			owner.A_SpawnParticle(col,SPF_FULLBRIGHT,1,1+(2*(i/dist)),0,newpartpos.x,newpartpos.y,newpartpos.z+zoff,owner.vel.x,owner.vel.y,owner.vel.z,startalphaf:fa);
		}
        Vector3 hitp = (data.HitDir * (data.Distance - 1));
        owner.A_SpawnParticle(col,SPF_FULLBRIGHT,1,4,0,hitp.x,hitp.y,hitp.z+zoff,owner.vel.x,owner.vel.y,owner.vel.z,startalphaf:alpha);
	}

    action void Load(int amount) {
        String mag = invoker.AmmoType1.GetClassName();
        String ammo = invoker.AmmoType2.GetClassName();
        while (invoker.owner.CountInv(ammo) > 0 && invoker.owner.CountInv(mag) < invoker.magsize && amount > 0) {
            invoker.owner.A_TakeInventory(ammo,1);
            invoker.owner.A_GiveInventory(mag,1);
            amount -= 1;
        }
    }

    action bool CanLoad() {
        String mag = invoker.AmmoType1.GetClassName();
        String ammo = invoker.AmmoType2.GetClassName();
        return (invoker.owner.CountInv(mag) < invoker.magsize) && (invoker.owner.countinv(ammo) > 0);
    }

    action bool CanFire() {
        String mag = invoker.AmmoType1.GetClassName();
        return (invoker.owner.CountInv(mag) >= invoker.AmmoUse1);
    }

    double linstep(double low,double high,double x) {
        return clamp(((x - low) / (high - low)), 0.0, 1.0);
    }

    abstract Vector2 Kick(); // Returns the amount to add to aimvel.

    override void Tick() {
        Super.Tick();

        if (owner && owner.player.readyweapon == self) {
            SpawnLaser(laseraim,laseralpha);
        }

        laseraim += aimvel;
        aimvel = aimvel * (1.0 - cos(aimvel.length() / aimmaxspd));

        if (GetAge() % shaketics == 0) {
            double shakeang = frandom(0,360);
            double mult = 1.;
            if (owner) { mult += (owner.vel.length() / 10.); }
            aimvel += AngleToVector(shakeang,(aimshake * mult));
        }

        if (aimfreeze > 0) {
            aimfreeze -= 1;
        } else {
            double dxv = laseraim.x*(-aimaccel);
            double dyv = laseraim.y*(-aimaccel);
            aimvel += (dxv,dyv);
        }

        laseralpha = clamp(linstep(laseredge*2,laseredge,laseraim.length()),0.3,1);

    }

    override void AttachToOwner(Actor other) {
        super.AttachToOwner(other);
        owner.GiveInventory(AmmoType1.GetClassName(),magsize);
    }


    action void Shoot() {
        // Fire the correct number of shots with the correct spread.
        if (invoker.owner.CountInv(invoker.AmmoType1) >= invoker.AmmoUse1) {
            invoker.aimvel += invoker.Kick();
            invoker.aimfreeze = invoker.aimfreezemax;
            invoker.owner.TakeInventory(invoker.AmmoType1,invoker.AmmoUse1);
            for (int i = invoker.numshots; i > 0; i--) {
                double ang = frandom(-invoker.spreadx,invoker.spreadx) + invoker.laseraim.x;
                double pit = frandom(-invoker.spready,invoker.spready) + invoker.laseraim.y;
                A_FireProjectile(invoker.shot,ang,false,flags:FPF_NOAUTOAIM,pitch:pit);
            }
        }
    }

    action void Punch() {
        // Switches to the fist.
        let plr = EEPlayer(invoker.owner);
        if (plr) {
            plr.A_SelectWeapon("EEPunch",SWF_SELECTPRIORITY);
            plr.holster = invoker.GetClassName();
        }
    }

    states {
        AltFire:
            #### # 1 Punch();
        AltDeselectLoop:
            #### # 1 A_Lower(35);
            Loop;
    }
}

class EEBullet : FastProjectile {
    // The basic bullet type.
    default {
        DamageFunction (40);
        Speed 120;
        Radius 4;
        Height 4;
        PROJECTILE;
        +HITTRACER;
        MissileType "EEBulletTrail";
        Decal "BulletChip";
        MissileHeight 8;
    }

    action void SpawnBlood() {
        if (!tracer) {return;}
        Vector3 bv = -1 * (Vec3To(tracer).unit() + (frandom(-1,1), frandom(-1,1), frandom(-1,1)));
        A_SpawnItemEX("Blood",xvel:bv.x,yvel:bv.y,zvel:bv.z);
    }

    states {
        Spawn:
            TNT1 A 1;
            Loop;
        Death:
        Crash:
            PUFF ABCD 3 Bright;
            Stop;
        XDeath:
            BLUD CBA 2 SpawnBlood();
            Stop;
        }
}

class EEBulletTrail : Actor {
    // Spawns a single particle.
    default {
        +NOINTERACTION;
    }

    states {
        Spawn:
            TNT1 A 0;
            TNT1 A 1 A_SpawnParticle("FFFFDD",SPF_FULLBRIGHT,15,4);
            Stop;
    }
}