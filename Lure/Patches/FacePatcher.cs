using GDWeave.Godot.Variants;
using GDWeave.Godot;
using GDWeave.Modding;

namespace Sulayre.Lure.Patches
{
	public class FacePatcher : IScriptMod
	{
		public bool ShouldRun(string path) => path == "res://Scenes/Entities/Player/Face/player_face.gdc";

		// returns a list of tokens for the new script, with the input being the original script's tokens
		public IEnumerable<Token> Modify(string path, IEnumerable<Token> tokens)
		{
			// wait for any newline token after any extends token
			//play("dog_face")
			var waiter = new MultiTokenWaiter([
				t => t is IdentifierToken{Name:"play"},
				t => t.Type is TokenType.ParenthesisOpen,
				t => t is ConstantToken{Value: StringVariant {Value: "dog_face"}},
				t => t.Type is TokenType.ParenthesisClose,
			], allowPartialMatch: false);

			// loop through all tokens in the script
			foreach (var token in tokens)
			{
				if (waiter.Check(token))
				{
					// found our match, return the original newline
					yield return token;

					yield return new Token(TokenType.Newline, 1);

					yield return new IdentifierToken("get_node");
					yield return new Token(TokenType.ParenthesisOpen);
					yield return new ConstantToken(new StringVariant("/root/SulayreLure/Patches"));
					yield return new Token(TokenType.ParenthesisClose);
					yield return new Token(TokenType.Period);
					yield return new IdentifierToken("_custom_species_faces");
					yield return new Token(TokenType.ParenthesisOpen);
					yield return new IdentifierToken("get_node");
					yield return new Token(TokenType.ParenthesisOpen);
					yield return new ConstantToken(new StringVariant("AnimationPlayer"));
					yield return new Token(TokenType.ParenthesisClose);
					yield return new Token(TokenType.Comma);
					yield return new IdentifierToken("data");
					yield return new Token(TokenType.BracketOpen);
					yield return new ConstantToken(new StringVariant("species"));
					yield return new Token(TokenType.BracketClose);
					yield return new Token(TokenType.ParenthesisClose);

					yield return new Token(TokenType.Newline, 1);


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
