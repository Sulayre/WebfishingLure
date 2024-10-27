using GDWeave.Godot.Variants;
using GDWeave.Godot;
using GDWeave.Modding;

namespace Sulayre.Lure.Patches
{
	public class TitlePatcher : IScriptMod
	{
		public bool ShouldRun(string path) => path == "res://Scenes/Entities/Player/player_label.gdc";

		// returns a list of tokens for the new script, with the input being the original script's tokens
		public IEnumerable<Token> Modify(string path, IEnumerable<Token> tokens)
		{
			// wait for any newline token after any extends token
			//pattern.body_pattern[2]
			var labelwaiter = new MultiTokenWaiter([
				t => t.Type is TokenType.Period,
				t => t is IdentifierToken{Name:"text"},
			], allowPartialMatch: false);

			var titlewaiter = new MultiTokenWaiter([
				t => t.Type is TokenType.OpAssign,
				t => t is IdentifierToken{Name:"title"},
			], allowPartialMatch: false);

			// loop through all tokens in the script
			foreach (var token in tokens)
			{
				if (labelwaiter.Check(token))
				{
					// found our match, return the original newline
					yield return new IdentifierToken("bbcode_text");


				}
				else if (titlewaiter.Check(token))
				{
					// found our match, return the original newline
					yield return new ConstantToken(new StringVariant("[center]"));
					yield return new Token(TokenType.OpAdd);
					yield return new IdentifierToken("title");
					yield return new Token(TokenType.OpAdd);
					yield return new ConstantToken(new StringVariant("[/center]"));


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
