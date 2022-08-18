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
        EEWeapon.LaserEdge 2.0;
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
		for(double i = 0; i<data.distance; i += frandom(1*q,2*q) )
		{
			Vector3 newpartpos = (data.HitDir*i);
			owner.A_SpawnParticle(col,SPF_FULLBRIGHT,1,1+(2*(i/dist)),0,newpartpos.x,newpartpos.y,newpartpos.z+zoff,owner.vel.x,owner.vel.y,owner.vel.z,startalphaf:(alpha * ((dist-i)/dist)));
		}
	}

    action void Load(String mag, String ammo, int magsize) {
        while (invoker.owner.CountInv(ammo) > 0 && invoker.owner.CountInv(mag) < magsize) {
            invoker.owner.A_TakeInventory(ammo,1);
            invoker.owner.A_GiveInventory(mag,1);
        }
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
}

class EEBullet : FastProjectile {
    // The basic bullet type.
    default {
        DamageFunction (25);
        Speed 80;
        Radius 4;
        Height 4;
        PROJECTILE;
        MissileType "EEBulletTrail";
        MissileHeight 8;
    }

    states {
        Spawn:
            TNT1 A 1;
            Loop;
        Death:
            PUFF ABCD 3 Bright;
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