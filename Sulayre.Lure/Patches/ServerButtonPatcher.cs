using GDWeave.Godot.Variants;
using GDWeave.Godot;
using GDWeave.Modding;

namespace Sulayre.Lure.Patches
{
	public class ServerButtonPatcher : IScriptMod
	{
		public bool ShouldRun(string path) => path == "res://Scenes/Menus/Main Menu/ServerButton/server_button.gdc";

		// returns a list of tokens for the new script, with the input being the original script's tokens
		public IEnumerable<Token> Modify(string path, IEnumerable<Token> tokens)
		{
			// wait for any newline token after any extends token
			//pattern.body_pattern[2]
			var setupwaiter = new MultiTokenWaiter([
				t => t.Type is TokenType.OpAssign,
				t => t is ConstantToken{Value: BoolVariant {Value: false}},
			], allowPartialMatch: false);

			var mapidwaiter = new MultiTokenWaiter([
				t => t.Type is TokenType.OpOr,
				t => t is IdentifierToken{Name:"dated"},
				t => t.Type is TokenType.Newline,
			], allowPartialMatch: false);

			// loop through all tokens in the script
			foreach (var token in tokens)
			{
				if (setupwaiter.Check(token))
				{
					yield return token;

					yield return new Token(TokenType.Comma);
					yield return new IdentifierToken("map_id");
					yield return new Token(TokenType.OpAssign);
					yield return new ConstantToken(new StringVariant(""));

				}
				else if (mapidwaiter.Check(token))
				{
					yield return token;

					yield return new Token(TokenType.CfIf);
					yield return new IdentifierToken("map_id");
					yield return new Token(TokenType.OpNotEqual);
					yield return new ConstantToken(new StringVariant(""));
					yield return new Token(TokenType.Colon);

					yield return new Token(TokenType.Newline, 2);

					yield return new Token(TokenType.BuiltInFunc, (uint?)BuiltinFunction.TextPrint);
					yield return new Token(TokenType.ParenthesisOpen);
					yield return new ConstantToken(new StringVariant("found a modded lobby!"));
					yield return new Token(TokenType.ParenthesisClose);

					yield return new Token(TokenType.Newline, 2);

					yield return new Token(TokenType.CfIf);
					yield return new Token(TokenType.OpNot);
					yield return new IdentifierToken("get_node");
					yield return new Token(TokenType.ParenthesisOpen);
					yield return new ConstantToken(new StringVariant("/root/SulayreLure/Util"));
					yield return new Token(TokenType.ParenthesisClose);
					yield return new Token(TokenType.Period);
					yield return new IdentifierToken("map_exists");
					yield return new Token(TokenType.ParenthesisOpen);
					yield return new IdentifierToken("map_id");
					yield return new Token(TokenType.ParenthesisClose);
					yield return new Token(TokenType.Colon);

					yield return new Token(TokenType.Newline, 3);

					yield return new IdentifierToken("get_node");
					yield return new Token(TokenType.ParenthesisOpen);
					yield return new ConstantToken(new StringVariant("Panel/HBoxContainer/Button"));
					yield return new Token(TokenType.ParenthesisClose);
					yield return new Token(TokenType.Period);
					yield return new IdentifierToken("disabled");
					yield return new Token(TokenType.OpAssign);
					yield return new ConstantToken(new BoolVariant(true));

					yield return new Token(TokenType.Newline, 3);

					yield return new IdentifierToken("get_node");
					yield return new Token(TokenType.ParenthesisOpen);
					yield return new ConstantToken(new StringVariant("Panel/HBoxContainer/Button"));
					yield return new Token(TokenType.ParenthesisClose);
					yield return new Token(TokenType.Period);
					yield return new IdentifierToken("text");
					yield return new Token(TokenType.OpAssign);
					yield return new ConstantToken(new StringVariant("MAP MISSING"));

					yield return new Token(TokenType.Newline,1);
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
