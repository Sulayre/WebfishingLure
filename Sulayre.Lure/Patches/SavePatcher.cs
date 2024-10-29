using GDWeave.Godot.Variants;
using GDWeave.Godot;
using GDWeave.Modding;

namespace Sulayre.Lure.Patches
{
	public class SavePatcher : IScriptMod
	{
		public bool ShouldRun(string path) => path == "res://Scenes/Singletons/playerdata.gdc";

		// returns a list of tokens for the new script, with the input being the original script's tokens
		public IEnumerable<Token> Modify(string path, IEnumerable<Token> tokens)
		{
			// wait for any newline token after any extends token
			//play("dog_face")

			//var waiter_ready = new MultiTokenWaiter([
			//	t => t.Type is TokenType.PrFunction,
			//	t => t is IdentifierToken{Name:"_ready"},
			//	t => t.Type is TokenType.ParenthesisOpen,
			//	t => t.Type is TokenType.ParenthesisClose,
			//	t => t.Type is TokenType.Colon,
			//	t => t.Type is TokenType.Newline && t.AssociatedData == 1,
			//], allowPartialMatch: false);

			var waiter_save = new MultiTokenWaiter([
				t => t is IdentifierToken{Name:"voice_speed"},
				t => t.Type is TokenType.Comma,
				t => t.Type is TokenType.Newline && t.AssociatedData == 1,
				t => t.Type is TokenType.CurlyBracketClose,
				t => t.Type is TokenType.Newline,
			], allowPartialMatch: false);

			//var waiter_load = new MultiTokenWaiter([
			//	t => t is ConstantToken{Value: StringVariant {Value: "fullscreen"}},
			//	t => t.Type is TokenType.BracketClose,
			//	t => t.Type is TokenType.OpAssign,
			//	t => t is ConstantToken{Value: IntVariant {Value: 0}},
			//	
			//], allowPartialMatch: false);

			// loop through all tokens in the script
			foreach (var token in tokens)
			{
				if (waiter_save.Check(token))
				{
					// found our match, return the original newline
					yield return token;

					// var Lure = get_node_or_null("/root/SulayreLure/")
					yield return new Token(TokenType.PrVar);
					yield return new IdentifierToken("Lure");
					yield return new Token(TokenType.OpAssign);
					yield return new IdentifierToken("get_node_or_null");
					yield return new Token(TokenType.ParenthesisOpen);
					yield return new ConstantToken(new StringVariant("/root/SulayreLure"));
					yield return new Token(TokenType.ParenthesisClose);

					yield return new Token(TokenType.Newline, 1);

					//yield return new Token(TokenType.BuiltInFunc, (uint?)BuiltinFunction.TextPrintSpaced);
					//yield return new Token(TokenType.ParenthesisOpen);
					//yield return new ConstantToken(new StringVariant("Has method:"));
					//yield return new Token(TokenType.Comma);
					//yield return new IdentifierToken("Lure");
					//yield return new Token(TokenType.Period);
					//yield return new IdentifierToken("has_method");
					//yield return new Token(TokenType.ParenthesisOpen);
					//yield return new ConstantToken(new StringVariant("_filter_save"));
					//yield return new Token(TokenType.ParenthesisClose);
					//yield return new Token(TokenType.ParenthesisClose);

					//yield return new Token(TokenType.Newline, 1);

					////// if Lure:
					yield return new Token(TokenType.CfIf);
					yield return new IdentifierToken("Lure");
					yield return new Token(TokenType.Colon);
					
					yield return new Token(TokenType.Newline,2);
					
					// new_save = Lure._filter_save
					yield return new IdentifierToken("new_save");
					yield return new Token(TokenType.OpAssign);
					yield return new IdentifierToken("Lure");
					yield return new Token(TokenType.Period);
					yield return new IdentifierToken("_filter_save");
					yield return new Token(TokenType.ParenthesisOpen);
					yield return new IdentifierToken("new_save");
					yield return new Token(TokenType.ParenthesisClose);
					
					yield return new Token(TokenType.Newline, 1);


				}
				else
				{
					yield return token;
				}
			}
		}
	}
}
