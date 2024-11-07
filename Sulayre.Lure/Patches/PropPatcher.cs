using GDWeave.Godot.Variants;
using GDWeave.Godot;
using GDWeave.Modding;

namespace Sulayre.Lure.Patches
{
	public class PropPatcher : IScriptMod
	{
		public bool ShouldRun(string path) => path == "res://Scenes/World/world.gdc";

		// returns a list of tokens for the new script, with the input being the original script's tokens
		public IEnumerable<Token> Modify(string path, IEnumerable<Token> tokens)
		{
			// wait for any newline token after any extends token
			//play("dog_face")

			var datadictwaiter = new MultiTokenWaiter([
				t => t is IdentifierToken{Name:"dict"},
				t => t.Type is TokenType.BracketOpen,
				t => t is ConstantToken{Value: StringVariant {Value: "actor_type"}},
				t => t.Type is TokenType.BracketClose,
				t => t.Type is TokenType.Newline,
			], allowPartialMatch: false);

			var actortypewaiter = new MultiTokenWaiter([
				t => t.Type is TokenType.ParenthesisOpen,
				t => t is IdentifierToken{Name:"actor_type"},
				t => t.Type is TokenType.ParenthesisClose,
				t => t.Type is TokenType.Colon,
			], allowPartialMatch: false);

			var instancewaiter = new MultiTokenWaiter([
				// ACTOR_BANK[actor_type]
				t => t is IdentifierToken { Name: "ACTOR_BANK" },
				t => t.Type is TokenType.BracketOpen,
				t => t is IdentifierToken { Name: "actor_type" },
				t => t.Type is TokenType.BracketClose,
			], allowPartialMatch: false);

			foreach (var token in tokens)
			{
				if (datadictwaiter.Check(token))
				{
					yield return token;

					// var Lure = get_node("/root/SulayreLure")
					yield return new Token(TokenType.PrVar);
					yield return new IdentifierToken("Lure");
					yield return new Token(TokenType.OpAssign);
					yield return new IdentifierToken("get_node_or_null");
					yield return new Token(TokenType.ParenthesisOpen);
					yield return new ConstantToken(new StringVariant("/root/SulayreLure"));
					yield return new Token(TokenType.ParenthesisClose);
					yield return new Token(TokenType.Newline, 1);
					//var modprops = {}
					yield return new Token(TokenType.PrVar);
					yield return new IdentifierToken("modactors");
					yield return new Token(TokenType.OpAssign);
					yield return new Token(TokenType.CurlyBracketOpen);
					yield return new Token(TokenType.CurlyBracketClose);
					yield return new Token(TokenType.Newline, 1);
					// if Lure:
					yield return new Token(TokenType.CfIf);
					yield return new IdentifierToken("Lure");
					yield return new Token(TokenType.Colon);
					yield return new Token(TokenType.Newline, 2);

					yield return new IdentifierToken("modactors");
					yield return new Token(TokenType.OpAssign);
					yield return new IdentifierToken("Lure");
					yield return new Token(TokenType.Period);
					yield return new IdentifierToken("get");
					yield return new Token(TokenType.ParenthesisOpen);
					yield return new ConstantToken(new StringVariant("modded_actors"));
					yield return new Token(TokenType.ParenthesisClose);

					//yield return new Token(TokenType.BuiltInFunc, (uint?)BuiltinFunction.TextPrint);
					//yield return new Token(TokenType.ParenthesisOpen);
					//yield return new IdentifierToken("modprops");
					//yield return new Token(TokenType.ParenthesisClose);

					yield return new Token(TokenType.Newline, 1);
				}
				else if (actortypewaiter.Check(token))
				{
					// ...and not modprop.keys().has(actor_type):
					yield return new Token(TokenType.OpAnd);
					yield return new Token(TokenType.OpNot);
					yield return new IdentifierToken("modactors");
					yield return new Token(TokenType.Period);
					yield return new IdentifierToken("keys");
					yield return new Token(TokenType.ParenthesisOpen);
					yield return new Token(TokenType.ParenthesisClose);
					yield return new Token(TokenType.Period);
					yield return new IdentifierToken("has");
					yield return new Token(TokenType.ParenthesisOpen);
					yield return new IdentifierToken("actor_type");
					yield return new Token(TokenType.ParenthesisClose);

					yield return new Token(TokenType.Colon);

					yield return new Token(TokenType.Newline, 2);
				}

				else if (instancewaiter.Check(token))
				{
					//ACTOR_BANK[actor_type]
					yield return token;
					//if
					yield return new Token(TokenType.CfIf);
					//ACTOR_BANK.keys().has(actor_type)
					yield return new IdentifierToken("ACTOR_BANK");
					yield return new Token(TokenType.Period);
					yield return new IdentifierToken("keys");
					yield return new Token(TokenType.ParenthesisOpen);
					yield return new Token(TokenType.ParenthesisClose);
					yield return new Token(TokenType.Period);
					yield return new IdentifierToken("has");
					yield return new Token(TokenType.ParenthesisOpen);
					yield return new IdentifierToken("actor_type");
					yield return new Token(TokenType.ParenthesisClose);
					//else
					yield return new Token(TokenType.CfElse);
					//modactors.get(actor_type,ACTOR_BANK["rock"]
					yield return new IdentifierToken("modactors");
					yield return new Token(TokenType.Period);
					yield return new IdentifierToken("get");
					yield return new Token(TokenType.ParenthesisOpen);
					yield return new IdentifierToken("actor_type");
					yield return new Token(TokenType.Comma);
					yield return new IdentifierToken("ACTOR_BANK");
					yield return new Token(TokenType.BracketOpen);
					yield return new ConstantToken(new StringVariant("rock"));
					yield return new Token(TokenType.BracketClose);
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
