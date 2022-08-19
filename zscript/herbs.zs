class EEHerbKit : Inventory replaces Soulsphere {
    // This is how you combine herbs into healing.
    default {
        +Inventory.UNDROPPABLE;
        +Inventory.INVBAR;
        +Inventory.KEEPDEPLETED;
        Inventory.Amount 100; // 25 herb units = 1 health block.
        Inventory.MaxAmount 300;
        Inventory.Icon "HKITA0"; // ssh, don't tell anyone--i hid a hakita fumo inside the health kit
        scale 0.3;
    }

    override bool Use(bool pickup) {
        if (!pickup) {
            if (owner.countinv("EEHerbKit") >= 25) {
                HealthBlockHandler h = HealthBlockHandler(EventHandler.Find("HealthBlockHandler"));
                if (owner.health < owner.GetMaxHealth()) {
                    owner.TakeInventory("EEHerbKit",25);
                    int amt = h.ToNextBlock(owner.player);
                    if (amt < h.BlockSize()) {
                        amt += h.BlockSize();
                    }
                    console.printf("Healed "..amt);
                    owner.GiveBody(amt);
                }
            }
        }
        return false;
    }

    states {
        Spawn:
            HKIT A -1;
            Stop;
    }
}

class EEHerb : Inventory abstract {
    int amount;
    Property Amount : amount;

    default {
        +Inventory.AUTOACTIVATE;
        scale 0.3;
    }

    override bool Use(bool pickup) {
        owner.GiveInventory("EEHerbKit",self.amount);
        return true;
    }
}

class EEGreenHerb : EEHerb replaces ArmorBonus {
    default {
        Inventory.PickupMessage "Found a sample of green herbs.";
        EEHerb.amount 2;
    }

    states {
        Spawn:
            HERB A -1;
            Stop;
    }
}

class EEGreenHerb2 : EEGreenHerb replaces HealthBonus {}

class EEBlueHerb : EEHerb replaces Stimpack {
    default {
        Inventory.PickupMessage "Found a sample of blue herbs.";
        EEHerb.amount 10;
    }

    states {
        Spawn:
            HERB B -1;
            Stop;
    }
}

class EERedHerb : EEHerb replaces Medikit {
    default {
        Inventory.PickupMessage "Found a sample of red herbs.";
        EEHerb.amount 20;
    }

    states {
        Spawn:
            HERB C -1;
            Stop;
    }
}