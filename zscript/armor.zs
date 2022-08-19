class EEArmor : ArmorBonus abstract {
    default {
        Armor.SavePercent 50;
        Armor.MaxSaveAmount 300;
        -INVENTORY.ALWAYSPICKUP;
        -COUNTITEM;
    }
}

class EEPlate : EEArmor replaces GreenArmor {
    default {
        Inventory.PickupMessage "Found a nanosteel plate.";
        Armor.SaveAmount 75;
    }

    states {
        Spawn:
            ABON A 20;
            ABON BCDCB 3;
            Loop;
    }
}

class EEVest : EEArmor replaces BlueArmor {
    default {
        Inventory.PickupMessage "Found a plate carrier.";
        Armor.SaveAmount 150;
    }

    states {
        Spawn:
            VEST A -1;
            Stop;
    }
}