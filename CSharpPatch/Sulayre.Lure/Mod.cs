using GDWeave;
using Sulayre.Lure.Patches;

namespace Sulayre.Lure;

public class Mod : IMod {
    public Config Config;

    public Mod(IModInterface modInterface) {
        this.Config = modInterface.ReadConfig<Config>();
        modInterface.Logger.Information("Lure's DLL is running!");
        modInterface.RegisterScriptMod(new PatternPatcher());
		modInterface.RegisterScriptMod(new FacePatcher());
		modInterface.RegisterScriptMod(new BarkPatcher());
	}

    public void Dispose() {
        // Cleanup anything you do here
    }
}