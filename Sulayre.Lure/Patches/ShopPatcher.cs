using GDWeave.Godot.Variants;
using GDWeave.Godot;
using GDWeave.Modding;

namespace Sulayre.Lure.Patches
{
	public class ShopPatcher : IScriptMod
	{
		public bool ShouldRun(string path) => path == "res://Scenes/HUD/Shop/shop.gdc";

		// returns a list of tokens for the new script, with the input being the original script's tokens
		public IEnumerable<Token> Modify(string path, IEnumerable<Token> tokens)
		{
			// wait for any newline token after any extends token
			//pattern.body_pattern[2]
			var waiter = new MultiTokenWaiter([
				t => t.Type is TokenType.PrExtends,
				t => t is IdentifierToken{Name:"Control"},
				t => t.Type is TokenType.Newline,
				t => t.Type is TokenType.Newline,
				t => t.Type is TokenType.PrConst,
			], allowPartialMatch: false);

			// loop through all tokens in the script
			foreach (var token in tokens)
			{
				if (waiter.Check(token))
				{
					yield return new Token(TokenType.PrVar);
				}
				else
				{
					// return the original token
					yield return token;
				}
			}
		}
	}
}
