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
				t => t is ConstantToken{Value: StringVariant {Value: "[VERSION MISMATCH] "}},
				t => t.Type is TokenType.OpAdd,
				t => t.Type is TokenType.Dollar,
				t => t is IdentifierToken{Name:"Panel"},
				t => t.Type is TokenType.OpDiv,
				t => t is IdentifierToken{Name:"HBoxContainer"},
				t => t.Type is TokenType.OpDiv,
				t => t is IdentifierToken{Name:"Label"},
				t => t.Type is TokenType.Period,
				t => t is IdentifierToken{Name:"bbcode_text"},
				t => t.Type is TokenType.Newline,
			], allowPartialMatch: false);

			var disabledwaiter = new MultiTokenWaiter([
				t => t is IdentifierToken{Name:"player_count"},
				t => t.Type is TokenType.OpGreaterEqual,
			], allowPartialMatch: false);

			var textwaiter = new MultiTokenWaiter([
				t => t is ConstantToken{Value: StringVariant {Value: "/"}},
				t => t.Type is TokenType.OpAdd,
				t => t.Type is TokenType.BuiltInFunc,
				t => t.Type is TokenType.ParenthesisOpen,
			], allowPartialMatch: false);

			var closeconsumer = new TokenConsumer(t => t.Type is TokenType.ParenthesisClose);
			var nlconsumer = new TokenConsumer(t => t.Type is TokenType.Newline);

			// loop through all tokens in the script
			foreach (var token in tokens)
			{
				if (closeconsumer.Check(token) || nlconsumer.Check(token))
				{
					continue;
				}
				else if (extendswaiter.Check(token))
				{

					yield return token;

					yield return new Token(TokenType.PrVar);
					yield return new IdentifierToken("lure_on");
					yield return new Token(TokenType.Colon);
					yield return new Token(TokenType.OpAssign);
					yield return new ConstantToken(new BoolVariant(false));
					yield return new Token(TokenType.Newline);

					yield return new Token(TokenType.PrVar);
					yield return new IdentifierToken("is_full");
					yield return new Token(TokenType.Colon);
					yield return new Token(TokenType.OpAssign);
					yield return new ConstantToken(new BoolVariant(false));
					yield return new Token(TokenType.Newline);

					yield return new Token(TokenType.PrVar);
					yield return new IdentifierToken("filter");
					yield return new Token(TokenType.Colon);
					yield return new Token(TokenType.OpAssign);
					yield return new ConstantToken(new StringVariant(""));
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
					yield return new IdentifierToken("max_players");
					yield return new Token(TokenType.OpAssign);
					yield return new ConstantToken(new IntVariant(12));
					yield return new Token(TokenType.Comma);
					yield return new IdentifierToken("is_lure");
					yield return new Token(TokenType.OpAssign);
					yield return new ConstantToken(new BoolVariant(false));
					yield return new Token(TokenType.Comma);
					yield return new IdentifierToken("lobby_filter");
					yield return new Token(TokenType.OpAssign);
					yield return new ConstantToken(new StringVariant(""));


				}
				else if (mapidwaiter.Check(token))
				{
					yield return token;

					yield return new Token(TokenType.Newline, 1);

					yield return new IdentifierToken("lure_on");
					yield return new Token(TokenType.OpAssign);
					yield return new IdentifierToken("is_lure");

					yield return new Token(TokenType.Newline, 1);

					yield return new IdentifierToken("is_full");
					yield return new Token(TokenType.OpAssign);
					yield return new IdentifierToken("player_count");
					yield return new Token(TokenType.OpEqual);
					yield return new IdentifierToken("max_players");

					yield return new Token(TokenType.Newline, 1);

					yield return new IdentifierToken("filter");
					yield return new Token(TokenType.OpAssign);
					yield return new IdentifierToken("lobby_filter");

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
				else if (textwaiter.Check(token))
				{
					yield return token;

					yield return new IdentifierToken("max_players");

					closeconsumer.SetReady();
				}
				else if (disabledwaiter.Check(token))
				{
					yield return token;

					yield return new IdentifierToken("max_players");

					nlconsumer.SetReady();
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
