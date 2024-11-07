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

			var extendswaiter = new MultiTokenWaiter([
				t => t.Type is TokenType.PrExtends,
				t => t.Type is TokenType.Identifier,
				t => t.Type is TokenType.Newline,
			], allowPartialMatch: false);

			var setupwaiter = new MultiTokenWaiter([
				t => t.Type is TokenType.OpAssign,
				t => t is ConstantToken{Value: BoolVariant {Value: false}},
			], allowPartialMatch: false);

			//"[VERSION MISMATCH] " + $Panel / HBoxContainer / Label.bbcode_text
			var mapidwaiter = new MultiTokenWaiter([
				t => t.Type is TokenType.OpOr,
				t => t is IdentifierToken{Name:"dated"},
				t => t.Type is TokenType.OpOr,
				t => t is IdentifierToken{Name:"banned"},
				t => t.Type is TokenType.Newline,
			], allowPartialMatch: false);

			var disabledwaiter = new MultiTokenWaiter([
				t => t is IdentifierToken { Name: "player_count" },
				t => t.Type is TokenType.OpGreaterEqual,
			], allowPartialMatch: false);

			// loop through all tokens in the script
			foreach (var token in tokens)
			{
				if (extendswaiter.Check(token))
				{

					yield return token;

					yield return new Token(TokenType.PrVar);
					yield return new IdentifierToken("lure_on");
					yield return new Token(TokenType.Colon);
					yield return new Token(TokenType.OpAssign);
					yield return new ConstantToken(new BoolVariant(false));
					yield return new Token(TokenType.Newline);
				}
				else if (setupwaiter.Check(token))
				{
					yield return token;

					yield return new Token(TokenType.Comma);
					yield return new IdentifierToken("has_map");
					yield return new Token(TokenType.OpAssign);
					yield return new ConstantToken(new StringVariant(""));
					yield return new Token(TokenType.Comma);
					yield return new IdentifierToken("is_lure");
					yield return new Token(TokenType.OpAssign);
					yield return new ConstantToken(new BoolVariant(false));


				}
				else if (mapidwaiter.Check(token))
				{
					yield return token;

					yield return new Token(TokenType.Newline, 1);

					yield return new IdentifierToken("lure_on");
					yield return new Token(TokenType.OpAssign);
					yield return new IdentifierToken("is_lure");
					

					yield return new Token(TokenType.Newline, 1);

					yield return new IdentifierToken("add_to_group");
					yield return new Token(TokenType.ParenthesisOpen);
					yield return new ConstantToken(new StringVariant("LobbyNode"));
					yield return new Token(TokenType.ParenthesisClose);

					yield return new Token(TokenType.Newline, 1);


					yield return new Token(TokenType.CfIf);
					yield return new Token(TokenType.OpNot);
					yield return new IdentifierToken("has_map");
					yield return new Token(TokenType.Colon);

					yield return new Token(TokenType.Newline, 2);

					yield return new IdentifierToken("get_node");
					yield return new Token(TokenType.ParenthesisOpen);
					yield return new ConstantToken(new StringVariant("Panel/HBoxContainer/Button"));
					yield return new Token(TokenType.ParenthesisClose);
					yield return new Token(TokenType.Period);
					yield return new IdentifierToken("disabled");
					yield return new Token(TokenType.OpAssign);
					yield return new ConstantToken(new BoolVariant(true));

					yield return new Token(TokenType.Newline, 2);

					yield return new IdentifierToken("get_node");
					yield return new Token(TokenType.ParenthesisOpen);
					yield return new ConstantToken(new StringVariant("Panel/HBoxContainer/Button"));
					yield return new Token(TokenType.ParenthesisClose);
					yield return new Token(TokenType.Period);
					yield return new IdentifierToken("text");
					yield return new Token(TokenType.OpAssign);
					yield return new ConstantToken(new StringVariant("MAP MISSING"));

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
