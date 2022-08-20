class EESaw : Weapon replaces Chainsaw {
    // Groovy.
    default {
        Weapon.SlotNumber 1;
        Weapon.UpSound "weapons/sawup";
        Weapon.ReadySound "weapons/sawidle";
    }

    states {
        Spawn:
            CSAW A -1;
            Stop;
        
        Select:
            SAWG C 1 A_Raise(15);
            Loop;
        Deselect:
            SAWG C 1 A_Lower(15);
            Loop;
        
        Ready:
            SAWG CCCCDDDD 1 {
                A_WeaponReady();
            }
            Loop;
        
        Fire:
            SAWG AB 3 {
                A_CustomPunch(8,true,CPF_PULLIN,meleesound:"weapons/sawfull",misssound:"weapons/sawhit");
            }
            SAWG ABCD 4 A_Refire();
            Goto Ready;

    }
}