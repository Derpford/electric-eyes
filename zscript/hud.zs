class EEHud : BaseStatusBar {
    HUDFont mConFont;
    HUDFont mBigFont;
    HUDFont mNumberFont;


    override void Init() {
        Super.Init();
        SetSize(0,320,240);
        Font cf = Font.FindFont("CONFONT");
        Font bf = Font.FindFont("BIGFONT");
        mConFont = HUDFont.Create("CONFONT");
        mBigFont = HUDFont.Create("BIGFONT");
        mNumberFont = HUDFont.Create("BIGFONT",bf.GetCharWidth("0"),true);
    }

    override void Draw(int state, double ticfrac) {
        Super.Draw(state, ticfrac);

        BeginHUD();
        DrawFullscreenStuff();
    }

    double FlickerAlpha(double hpperc, double offset) {
            double age = CPlayer.mo.GetAge();
            double hptheta = 10 * (1 - hpperc) * age;
            double hpnoise = abs(sin(hptheta + offset) * cos(360 * sin(hptheta + offset)));
            double alph = max(hpperc**2, hpnoise);
            return alph;

    }

    void DrawFullscreenStuff() {
        let plr = EEPlayer(CPlayer.mo);

        int lbarflags = DI_SCREEN_LEFT_BOTTOM|DI_ITEM_LEFT_BOTTOM|DI_TEXT_ALIGN_LEFT;
        int rbarflags = DI_SCREEN_RIGHT_BOTTOM|DI_ITEM_RIGHT_BOTTOM|DI_TEXT_ALIGN_RIGHT;

        if (plr) {
            double hp = plr.health;
            double maxhp = plr.GetMaxHealth(true);
            double arm = GetAmount("BasicArmor");
            double maxarm = 300;

            double hpperc = hp / maxhp;

            let wpn = CPlayer.ReadyWeapon;
            int mag; int ammo;
            if (wpn.AmmoType1) {
                mag = plr.CountInv(wpn.AmmoType1.GetClassName());
                ammo = plr.CountInv(wpn.AmmoType2.GetClassName());
            }
            
            double herbcharge = plr.CountInv("EEHerbCharge");
            double healcount = plr.CountInv("EEHerbKit");

            // Draw health.
            String hbar = "HBARB0";
            if (hp <= maxhp * (2. / 3.)) { hbar = "HBARC0"; }
            if (hp <= maxhp * (1. / 3.)) { hbar = "HBARD0"; }
            DrawBar(hbar,"HBARE0",hp,maxhp,(80,-40),0,0,lbarflags,FlickerAlpha(hpperc,0));

            // And armor.
            DrawBar("ABARA0","HBARE0",arm,maxarm,(80,-40),0,0,lbarflags,FlickerAlpha(hpperc,0));
            
            // Draw the herb kit status.
            DrawBar("HRBBA0","HRBBB0",herbcharge,25.,(80,-34),0,0,lbarflags,FlickerAlpha(hpperc,45));
            for (int i = 0; i < healcount; i++) {
                double xofs = i * 18;
                DrawImage("CROSA0",(178+xofs,-40),lbarflags,FlickerAlpha(hpperc,i * 30));
            }

            // Draw ammunition.
            DrawString(mNumberFont,String.format("%03d",mag),(80,-72),lbarflags,Font.CR_WHITE,FlickerAlpha(hpperc,60));
            DrawString(mConFont,String.format("%03d",ammo),(112,-72),lbarflags,Font.CR_WHITE,FlickerAlpha(hpperc,75));

            // keys
			String keySprites[6] =
			{
				"STKEYS2",
				"STKEYS0",
				"STKEYS1",
				"STKEYS5",
				"STKEYS3",
				"STKEYS4"
			};

			for(int i = 0; i < 6; i++)
			{
				if(plr.CheckKeys(i+1,false,true)) { 
                    DrawImage(keySprites[i],(80+(16*i),-16),lbarflags,FlickerAlpha(hpperc,15*i),scale:(2,2)); 
				}
			}
        }
    }
}