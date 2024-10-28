using GDWeave.Godot.Variants;
using GDWeave.Godot;
using GDWeave.Modding;

namespace Sulayre.Lure.Patches
{
	public class GlobalPatcher : IScriptMod
	{
		public bool ShouldRun(string path) => path == "res://Scenes/Singletons/globals.gdc";

		// returns a list of tokens for the new script, with the input being the original script's tokens
		public IEnumerable<Token> Modify(string path, IEnumerable<Token> tokens)
		{
			// wait for any newline token after any extends token
			//play("dog_face")
			var waiter = new MultiTokenWaiter([
				t => t is IdentifierToken{Name:"GAME_VERSION"},
				t => t.Type is TokenType.OpAssign,
				t => t is ConstantToken,
				t => t.Type is TokenType.Newline,
			], allowPartialMatch: false);

			// loop through all tokens in the script
			foreach (var token in tokens)
			{
				if (waiter.Check(token))
				{
					// found our match, return the original newline
					yield return token;

					yield return new Token(TokenType.PrVar);
					yield return new IdentifierToken("GAME_VERSION_LURE");
					yield return new Token(TokenType.OpAssign);
					//yield return new Token(TokenType.BuiltInFunc, (uint?)BuiltinFunction.VarToStr);
					yield return new IdentifierToken("str");
					yield return new Token(TokenType.ParenthesisOpen);
					yield return new IdentifierToken("GAME_VERSION");
					yield return new Token(TokenType.ParenthesisClose);
					yield return new Token(TokenType.Newline);


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
