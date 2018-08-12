state("Omensight")
{
	int day : 0x3782860, 0x60, 0x1A0, 0x4F0, 0x140, 0x3C;
	float energy : 0x376D500, 0x30, 0x8A8, 0x58, 0x78, 0x9D0;
	int loading : 0x376D500, 0x30, 0x8A8, 0x58;
	float ludo : 0x335B7C0, 0xE8, 0x408, 0xA0, 0xB0, 0x9CC;
	int ludodeath : 0x335B7C0, 0xE8, 0x408, 0xA0, 0xB0;
	int voidenter : 0x376D500, 0x30, 0x6D8, 0xB0, 0x390;
	float voden : 0x37CF040, 0x8, 0x48, 0x20, 0x78, 0x9CC;
	float health : 0x376D500, 0x30, 0x6D8, 0xB0, 0x390, 0x9CC;
}

init
{
	int voidloader;
	int vodenfight;
}

isLoading
{
	if (current.loading == 0) {
		return true;
	} else {
		return false;
	}
}

startup
{
	settings.Add("option1", true, "Extra split after Ludomir fight");
}

start
{
	if (current.energy == 0 && current.health == 100 && current.loading != 0) {
		return true;
	}
	vars.voidloader = 0;
	vars.vodenfight = 0;
}

split
{
	// first days are pretty straightforward
	if (current.day == 1 && old.day == 0) {
		return true;
	}
	if (current.day == 2 && old.day == 1) {
		return true;
	}
	if (current.day == 3 && old.day == 2) {
		return true;
	}
	if (current.day == 4 && old.day == 3) {
		return true;
	}
	if (current.day == 5 && old.day == 4) {
		return true;
	}
	if (current.day == 6 && old.day == 5) {
		return true;
	}
	if (current.day == 7 && old.day == 6) {
		return true;
	}
	//This splits Ludo for you, if you have the setting turned on
	if (settings["option1"] && current.ludo == 0 && old.ludo > 0 && current.day == 7 && current.ludodeath != 0) {
		return true;
	}
	if (current.day == 8 && old.day == 7) {
		vars.vodenfight = 1;
		return true;
	}
	//Checks for the enter void split, should be correct
	if (current.voidenter == 0 && current.day == 8 && old.voidenter > 0) {
		if (vars.voidloader == 0) {
			vars.voidloader = 1;
		} else if (vars.voidloader == 1 && current.health != 0) {
			vars.voidloader = 2;
		} else if (vars.voidloader == 2 && current.health != 0) {
			vars.voidloader = 3;
			return true;
		}
	}
	//Different Vodenfights same health address Dx. Hard to code but here it is
	if (vars.vodenfight > 0) {
		if (vars.vodenfight == 1) {
			if (current.health != 0 && current.voden != current.health && current.voden < 161 && current.voden > 20 && old.voden > 160 && (old.voden - current.voden) < 90) {
				vars.vodenfight = 2;
				return true;
			}
		} else if (vars.vodenfight == 2) {
			if (current.health != 0 && current.voden != current.health && current.voden < 81 && current.voden > 10 && old.voden > 80 && (old.voden - current.voden) < 90) {
				vars.vodenfight = 3;
				return true;
			}
		} else if (vars.vodenfight == 3) {
            if (current.health != 0 && current.voden != current.health && current.voden == 0 && old.voden > 0 && (old.voden - current.voden) < 90) {
        		vars.vodenfight = 4;
        		vars.vodenSplitTime = timer.CurrentTime.RealTime.Value.TotalSeconds;
        	}
        	//Adds the offset for the sword to hit
        } else if (vars.vodenfight == 4) {
        	if(vars.vodenSplitTime != 0 && timer.CurrentTime.RealTime.Value.TotalSeconds - vars.vodenSplitTime >= 4.4) {
        		vars.vodenfight = 0;
        		vars.vodenSplitTime = 0;
        		return true;
        	} else if (vars.vodenSplitTime == 0) {
        		vars.vodenfight = 0;
        	}
        }
	}
}