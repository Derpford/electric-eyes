class EEPowderKit : Inventory {
    // Converts Red Powder into clips, Gold Powder into shells, and Blue Powder into rockets.
    void Convert(String ing, int amt, String outp, int amt2) {
        // Converts amt items of type in, into amt2 items of type out.
        if (owner.CountInv(ing) >= amt && (owner.CountInv(outp) + amt2) < owner.GetAmmoCapacity(outp)) {
            owner.TakeInventory(ing,amt);
            owner.GiveInventory(outp,amt2);
        }
    }

    override void DoEffect() {
        Convert("EERedPowder",2,"Clip",5);
        Convert("EEGoldPowder",2,"Shell",3);
        Convert("EEBluePowder",3,"RocketAmmo",1);
    }
}
class EEGunpowder : Inventory Abstract {
    default {
        Inventory.Amount 1;
        Inventory.MaxAmount 20;
        Scale 0.2;
    }
}

class EERedPowder : EEGunpowder replaces Clip {
    default {
        Inventory.PickupMessage "Found some +P gunpowder.";
    }

    states {
        Spawn:
            PWDR A -1;
            Stop;
    }
}

class EEGoldPowder : EEGunpowder replaces Shell {
    default {
        Inventory.PickupMessage "Found some shotgun-grade gunpowder.";
    }

    states {
        Spawn:
            PWDR B -1;
            Stop;
    }
}

class EEBluePowder : EEGunpowder replaces RocketAmmo {
    default {
        Inventory.PickupMessage "Found some high-explosive powder.";
    }

    states {
        Spawn:
            PWDR C -1;
            Stop;
    }
}

// And replace the big pickups with regular ammo.
class Mag : Clip replaces ClipBox {
    default {
        Inventory.PickupMessage "Picked up an SMG mag.";
        Inventory.Amount 15;
    }
}

class ShellPack : Shell replaces ShellBox {
    default {
        Inventory.PickupMessage "Picked up some shotgun shells.";
    }
}

class GrenadeAmmo : RocketAmmo replaces RocketBox {
    default {
        Inventory.PickupMessage "Picked up a sticky grenade.";
        Inventory.Amount 1;
    }

    states {
        Spawn:
            SGRN A -1;
            Stop;
    }
}