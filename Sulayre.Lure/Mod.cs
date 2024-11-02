using GDWeave;
using Sulayre.Lure.Patches;

namespace Sulayre.Lure;

public class Mod : IMod {
    public Config Config;

    public Mod(IModInterface modInterface) {
        this.Config = modInterface.ReadConfig<Config>();
        modInterface.Logger.Information("\n88     88   88 88\"\"Yb 888888 \r\n88     88   88 88__dP 88__   \r\n88  .o Y8   8P 88\"Yb  88\"\"   \r\n88ood8 `YbodP' 88  Yb 888888 ");
		modInterface.RegisterScriptMod(new GlobalPatcher());
		modInterface.RegisterScriptMod(new PatternPatcher());
		modInterface.RegisterScriptMod(new FacePatcher());
		modInterface.RegisterScriptMod(new BarkPatcher());
        modInterface.RegisterScriptMod(new PropPatcher());
		modInterface.RegisterScriptMod(new ItemPatcher());
		modInterface.RegisterScriptMod(new SavePatcher());
		modInterface.RegisterScriptMod(new TitlePatcher());
		modInterface.RegisterScriptMod(new NetworkPatcher());
        modInterface.RegisterScriptMod(new MainMenuPatcher());
		modInterface.RegisterScriptMod(new ServerButtonPatcher());
		modInterface.RegisterScriptMod(new JournalPatcher());
	}

    public void Dispose() {
        // Cleanup anything you do here
    }
}