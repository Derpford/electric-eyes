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

    void DrawFullscreenStuff() {
        let plr = EEPlayer(CPlayer.mo);

        int lbarflags = DI_SCREEN_LEFT_BOTTOM|DI_ITEM_LEFT_BOTTOM|DI_TEXT_ALIGN_LEFT;
        int rbarflags = DI_SCREEN_RIGHT_BOTTOM|DI_ITEM_RIGHT_BOTTOM|DI_TEXT_ALIGN_RIGHT;

        if (plr) {
            double hp = plr.health;
            double maxhp = plr.GetMaxHealth();
            double arm = GetAmount("BasicArmor");
            double maxarm = 300;

            double hpperc = hp / maxhp;
            double hptheta = (10 * (1 - hpperc)) * plr.GetAge();
            double hpnoise = abs(sin(360 * sin(hptheta)));
            double alph = max(hpperc**2, hpnoise);

            let wpn = CPlayer.ReadyWeapon;
            int mag = plr.CountInv(wpn.AmmoType1.GetClassName());
            int ammo = plr.CountInv(wpn.AmmoType2.GetClassName());
            
            double herbcharge = plr.CountInv("EEHerbCharge");
            double healcount = plr.CountInv("EEHerbKit");

            // Draw health.
            String hbar = "HBARB0";
            if (hp <= 100) { hbar = "HBARC0"; }
            if (hp <= 50) { hbar = "HBARD0"; }
            DrawBar(hbar,"HBARE0",hp,maxhp,(80,-40),0,0,lbarflags,alph);

            // And armor.
            DrawBar("ABARA0","HBARE0",arm,maxarm,(80,-40),0,0,lbarflags,alph);
            
            // Draw the herb kit status.
            DrawBar("HRBBA0","HRBBB0",herbcharge,25.,(80,-34),0,0,lbarflags,alph);
            for (int i = 0; i < healcount; i++) {
                double xofs = i * 18;
                DrawImage("CROSA0",(178+xofs,-40),lbarflags,alph);
            }

            // Draw ammunition.
            DrawString(mNumberFont,String.format("%03d",mag),(80,-72),lbarflags,Font.CR_WHITE,alph);
            DrawString(mConFont,String.format("%03d",ammo),(112,-72),lbarflags,Font.CR_WHITE,alph);

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
                    DrawImage(keySprites[i],(80+(16*i),-16),lbarflags,alph,scale:(2,2)); 
				}
			}
        }
    }
}