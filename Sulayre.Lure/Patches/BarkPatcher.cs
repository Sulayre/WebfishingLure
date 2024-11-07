using GDWeave.Godot.Variants;
using GDWeave.Godot;
using GDWeave.Modding;

namespace Sulayre.Lure.Patches
{
	public class BarkPatcher : IScriptMod
	{
		public bool ShouldRun(string path) => path == "res://Scenes/Entities/Player/player.gdc";

		// returns a list of tokens for the new script, with the input being the original script's tokens
		
		// this one also takes care of patching animations cus im not gonna bother making a new patch file for 1 function call
		
		public IEnumerable<Token> Modify(string path, IEnumerable<Token> tokens)
		{
			// wait for any newline token after any extends token
			//play("dog_face")
			var waiter_ready = new MultiTokenWaiter([
				t => t.Type is TokenType.PrFunction,
				t => t is IdentifierToken{Name:"_ready"},
				t => t.Type is TokenType.ParenthesisOpen,
				t => t.Type is TokenType.ParenthesisClose,
				t => t.Type is TokenType.Colon,
			], allowPartialMatch: false);

			var waiter_bark = new MultiTokenWaiter([
				t => t.Type is TokenType.BracketOpen,
				t => t is IdentifierToken{Name:"PlayerData"},
				t => t.Type is TokenType.Period,
				t => t is IdentifierToken{Name:"cosmetics_equipped"},
				t => t.Type is TokenType.Period,
				t => t is IdentifierToken{Name:"species"},
				t => t.Type is TokenType.BracketClose,
			], allowPartialMatch: false);
			
			var waiter_fallback = new MultiTokenWaiter([
				t => t is IdentifierToken{Name:"valid"},
				t => t.Type is TokenType.OpAssign,
				t => t is ConstantToken{Value: BoolVariant {Value: true}},
				t => t.Type is TokenType.Newline,
			], allowPartialMatch: false);

			// loop through all tokens in the script
			foreach (var token in tokens)
			{
				if (waiter_ready.Check(token))
				{
					// found our match, return the original newline
					yield return token;

					yield return new Token(TokenType.Newline, 1);

					yield return new IdentifierToken("get_node");
					yield return new Token(TokenType.ParenthesisOpen);
					yield return new ConstantToken(new StringVariant("/root/SulayreLure/Patches"));
					yield return new Token(TokenType.ParenthesisClose);
					yield return new Token(TokenType.Period);
					yield return new IdentifierToken("_instance_species_voices");
					yield return new Token(TokenType.ParenthesisOpen);
					yield return new IdentifierToken("sound_manager");
					yield return new Token(TokenType.ParenthesisClose);

					yield return new Token(TokenType.Newline, 1);
					
					yield return new IdentifierToken("get_node");
					yield return new Token(TokenType.ParenthesisOpen);
					yield return new ConstantToken(new StringVariant("/root/SulayreLure/Patches"));
					yield return new Token(TokenType.ParenthesisClose);
					yield return new Token(TokenType.Period);
					yield return new IdentifierToken("_load_emotes");
					yield return new Token(TokenType.ParenthesisOpen);
					yield return new IdentifierToken("get_node");
					yield return new Token(TokenType.ParenthesisOpen);
					yield return new ConstantToken(new StringVariant("body/player_body/AnimationPlayer"));
					yield return new Token(TokenType.ParenthesisClose);
					yield return new Token(TokenType.ParenthesisClose);

					yield return new Token(TokenType.Newline, 1);



				}
				else if (waiter_bark.Check(token))
				{
					yield return token;

					yield return new Token(TokenType.Newline, 1);

					yield return new IdentifierToken("bark_id");
					yield return new Token (TokenType.OpAssign);
					yield return new IdentifierToken("get_node");
					yield return new Token(TokenType.ParenthesisOpen);
					yield return new ConstantToken(new StringVariant("/root/SulayreLure/Patches"));
					yield return new Token(TokenType.ParenthesisClose);
					yield return new Token(TokenType.Period);
					yield return new IdentifierToken("_get_voice_bundle");
					yield return new Token(TokenType.ParenthesisOpen);
					yield return new IdentifierToken("PlayerData");
					yield return new Token(TokenType.Period);
					yield return new IdentifierToken("cosmetics_equipped");
					yield return new Token(TokenType.Period);
					yield return new IdentifierToken("species");
					yield return new Token(TokenType.ParenthesisClose);

					yield return new Token(TokenType.Newline, 1);
				}
				else if (waiter_fallback.Check(token))
				{
					yield return token;
					//data = get_node("/root/SulayreLure/Patches")._improved_fallback(data)
					yield return new IdentifierToken("data");
					yield return new Token(TokenType.OpAssign);
					yield return new IdentifierToken("get_node");
					yield return new Token(TokenType.ParenthesisOpen);
					yield return new ConstantToken(new StringVariant("/root/SulayreLure/Patches"));
					yield return new Token(TokenType.ParenthesisClose);
					yield return new Token(TokenType.Period);
					yield return new IdentifierToken("_improved_fallback");
					yield return new Token(TokenType.ParenthesisOpen);
					yield return new IdentifierToken("data");
					yield return new Token(TokenType.ParenthesisClose);
					yield return token;
				}
				else
				{
					yield return token;
				}
			}
		}
	}
}
