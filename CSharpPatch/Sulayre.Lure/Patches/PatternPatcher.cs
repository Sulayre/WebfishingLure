using GDWeave.Godot.Variants;
using GDWeave.Godot;
using GDWeave.Modding;

namespace Sulayre.Lure.Patches
{
	public class PatternPatcher : IScriptMod
	{
		public bool ShouldRun(string path) => path == "res://Scenes/Entities/Player/player.gdc";

		// returns a list of tokens for the new script, with the input being the original script's tokens
		public IEnumerable<Token> Modify(string path, IEnumerable<Token> tokens)
		{
			// wait for any newline token after any extends token
			//pattern.body_pattern[2]
			var waiter = new MultiTokenWaiter([
				t => t is IdentifierToken{Name:"pattern"},
				t => t.Type is TokenType.Period,
				t => t is IdentifierToken{Name:"body_pattern"},
				t => t.Type is TokenType.BracketOpen,
				t => t is ConstantToken{Value: IntVariant {Value: 2}},
				t => t.Type is TokenType.BracketClose,
				t => t.Type is TokenType.ParenthesisClose,
			], allowPartialMatch: false);

			// loop through all tokens in the script
			foreach (var token in tokens)
			{
				if (waiter.Check(token))
				{
					// found our match, return the original newline
					yield return token;

					yield return new Token(TokenType.Newline, 2);
					yield return new Token(TokenType.BuiltInFunc, (uint?)BuiltinFunction.TextPrint);
					yield return new Token(TokenType.ParenthesisOpen);
					yield return new ConstantToken(new StringVariant("test"));
					yield return new Token(TokenType.ParenthesisClose); 
					yield return new Token(TokenType.Newline, 2);

					yield return new IdentifierToken("get_node");
					yield return new Token(TokenType.ParenthesisOpen);
					yield return new ConstantToken(new StringVariant("/root/SulayreLure"));
					yield return new Token(TokenType.ParenthesisClose);
					yield return new Token(TokenType.Period);
					yield return new IdentifierToken("custom_species_patterns");
					yield return new Token(TokenType.ParenthesisOpen);
					yield return new IdentifierToken("species");
					yield return new Token(TokenType.Comma);
					yield return new IdentifierToken("pattern");
					yield return new Token(TokenType.Comma);
					yield return new IdentifierToken("data");
					yield return new Token(TokenType.BracketOpen);
					yield return new ConstantToken(new StringVariant("species"));
					yield return new Token(TokenType.BracketClose);
					yield return new Token(TokenType.ParenthesisClose);

					////var index = Lure.modded_species.find(data["species"])
					//yield return new Token(TokenType.PrVar);
					//yield return new IdentifierToken("index");
					//yield return new Token(TokenType.OpAssign);
					//yield return new IdentifierToken("Lure");
					//yield return new Token(TokenType.Period);
					//yield return new IdentifierToken("modded_species");
					//yield return new Token(TokenType.Period);
					//yield return new IdentifierToken("find");
					//yield return new Token(TokenType.ParenthesisOpen);
					//yield return new IdentifierToken("data");
					//yield return new Token(TokenType.BracketOpen);
					//yield return new ConstantToken(new StringVariant("species"));
					//yield return new Token(TokenType.BracketClose);
					//yield return new Token(TokenType.ParenthesisClose);
					//yield return new Token(TokenType.Newline, 3);
					//
					////if index > 2:
					//yield return new Token(TokenType.CfIf);
					//yield return new IdentifierToken("index");
					//yield return new Token(TokenType.OpGreater);
					//yield return new ConstantToken(new IntVariant(2));
					//yield return new Token(TokenType.Newline, 4);
					//
					////var variant = pattern.body_pattern[index]
					//yield return new Token(TokenType.PrVar);
					//yield return new IdentifierToken("variant");
					//yield return new Token(TokenType.OpAssign);
					//yield return new IdentifierToken("pattern");
					//yield return new Token(TokenType.Period);
					//yield return new IdentifierToken("body_pattern");
					//yield return new Token(TokenType.BracketOpen);
					//yield return new IdentifierToken("index");
					//yield return new Token(TokenType.BracketClose);
					//yield return new Token(TokenType.Newline, 4);
					//
					////if variant:
					//yield return new Token(TokenType.CfIf);
					//yield return new IdentifierToken("variant");
					//yield return new Token(TokenType.Colon);
					//yield return new Token(TokenType.Newline, 5);
					//
					////species.material_override.set_shader_param("texture_albedo", variant)
					//yield return new IdentifierToken("species");
					//yield return new Token(TokenType.Period);
					//yield return new IdentifierToken("material_override");
					//yield return new Token(TokenType.Period);
					//yield return new IdentifierToken("set_shader_param");
					//yield return new Token(TokenType.ParenthesisOpen);
					//yield return new ConstantToken(new StringVariant("texture_albedo"));
					//yield return new Token(TokenType.Comma);
					//yield return new IdentifierToken("variant");
					//yield return new Token(TokenType.ParenthesisClose);
					//yield return new Token(TokenType.Newline, 4);
					//
					//yield return new Token(TokenType.BuiltInFunc, (uint?)BuiltinFunction.TextPrint);
					//yield return new Token(TokenType.ParenthesisOpen);
					//yield return new ConstantToken(new StringVariant("assigned custom variant"));
					//yield return new Token(TokenType.ParenthesisClose); 
					//yield return new Token(TokenType.Newline, 2);
					//
					////else:
					//yield return new Token(TokenType.CfElse);
					//yield return new Token(TokenType.Colon);
					//yield return new Token(TokenType.Newline, 5);
					//
					//yield return new IdentifierToken("species");
					//yield return new Token(TokenType.Period);
					//yield return new IdentifierToken("material_override");
					//yield return new Token(TokenType.Period);
					//yield return new IdentifierToken("set_shader_param");
					//yield return new Token(TokenType.ParenthesisOpen);
					//yield return new ConstantToken(new StringVariant("texture_albedo"));
					//yield return new Token(TokenType.Comma);
					//yield return new IdentifierToken("variant");
					//yield return new Token(TokenType.ParenthesisClose);
					yield return new Token(TokenType.Newline, 2);


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
