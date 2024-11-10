using GDWeave;
using Sulayre.Lure.Patches;

namespace Sulayre.Lure;

public class Mod : IMod {
    public Config Config;

    public Mod(IModInterface modInterface)
    {
        this.Config = modInterface.ReadConfig<Config>();
        modInterface.Logger.Information("\n88     88   88 88\"\"Yb 888888 \r\n88     88   88 88__dP 88__   \r\n88  .o Y8   8P 88\"Yb  88\"\"   \r\n88ood8 `YbodP' 88  Yb 888888 ");
        // res://Scenes/Entities/Player/player.gdc
		modInterface.RegisterScriptMod(new PlayerPatch());
        // res://Scenes/Singletons/UserSave/usersave.gdc
        modInterface.RegisterScriptMod(new SavePatch());
	}

    public void Dispose() {
        // Cleanup anything you do here
    }
}