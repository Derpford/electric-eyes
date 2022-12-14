class EEHerbKit : Inventory {
    // This is how you combine herbs into healing.
    default {
        +Inventory.UNDROPPABLE;
        +Inventory.KEEPDEPLETED;
        +Inventory.PERSISTENTPOWER;
        Inventory.Amount 1; // 25 herb units = 1 health block.
        Inventory.MaxAmount 5;
        Inventory.Icon "HKITA0"; // ssh, don't tell anyone--i hid a hakita fumo inside the health kit
        scale 0.3;
    }

    override void DoEffect() {
        if (owner.countinv("EEHerbCharge") >= 25 && owner.countinv("EEHerbKit") < 5) {
            owner.TakeInventory("EEHerbCharge",25);
            owner.GiveInventory("EEHerbKit",1);
        }
    }

    override bool Use(bool pickup) {
        if (!pickup) {
            if (owner.countinv("EEHerbKit") >= 1) {
                HealthBlockHandler h = HealthBlockHandler(EventHandler.Find("HealthBlockHandler"));
                if (owner.health < owner.GetMaxHealth(true)) {
                    owner.TakeInventory("EEHerbKit",1);
                    int amt = h.ToNextBlock(owner.player);
                    if (amt < h.BlockSize(owner.player)) {
                        amt += h.BlockSize(owner.player);
                    }
                    console.printf("Healed "..amt);
                    owner.A_StartSound("misc/i_pkup");
                    owner.A_SetBlend("AAAAFF",0.5,10);
                    owner.GiveBody(amt);
                } else {
                    // Give the player a slightly bigger healthbar.
                    owner.stamina += 15;
                    console.printf("Boosted max health.");
                    owner.A_SetBlend("FFFFFF",0.5,10);
                    owner.A_StartSound("misc/p_pkup");
                    owner.GiveBody(15);
                    owner.TakeInventory("EEHerbKit",1);
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

class EEHerbCharge : Inventory {
    default {
        Inventory.Amount 1;
        Inventory.MaxAmount 9000;
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
        owner.GiveInventory("EEHerbCharge",self.amount);
        return true;
    }
}

class EEHerbCase : EEHerb replaces SoulSphere {
    default {
        Inventory.PickupMessage "Found a medicine case full of herbs.";
        EEHerb.Amount 25;
    }

    states {
        Spawn:
            HKIT A -1;
            Stop;
    }
}

class EEGreenHerb : EEHerb replaces ArmorBonus {
    default {
        Inventory.PickupMessage "Found a sample of green herbs.";
        EEHerb.amount 1;
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
        EEHerb.amount 5;
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
        EEHerb.amount 10;
    }

    states {
        Spawn:
            HERB C -1;
            Stop;
    }
}