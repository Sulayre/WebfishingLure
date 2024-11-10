using GDWeave.Godot.Variants;
using GDWeave.Godot;
using GDWeave.Modding;

namespace Sulayre.Lure.Patches
{
	public class SavePatcher : IScriptMod
	{
		public bool ShouldRun(string path) => path == "res://Scenes/Singletons/UserSave/usersave.gdc";

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
				t => t is IdentifierToken{Name:"locked_refs"},
				t => t.Type is TokenType.Comma,
				t => t.Type is TokenType.Newline && t.AssociatedData == 1,
				t => t.Type is TokenType.CurlyBracketClose,
				t => t.Type is TokenType.Newline,
			], allowPartialMatch: false);
            
            // loaded_save = _version_key_check(loaded_save, false)
			var waiter_load = new MultiTokenWaiter([
                t => t is IdentifierToken{Name:"loaded_save"},
				t => t.Type is TokenType.Comma,
				t => t is ConstantToken{Value: BoolVariant {Value: false}},
                t => t.Type is TokenType.ParenthesisClose,
                t => t.Type is TokenType.Newline,
			], allowPartialMatch: false);

			// loop through all tokens in the script
			foreach (var token in tokens)
			{
				if (waiter_save.Check(token))
				{
					// found our match, return the original newline
					yield return token;
                    
					// new_save = Lure._filter_save
					yield return new IdentifierToken("new_save");
					yield return new Token(TokenType.OpAssign);
                    yield return new IdentifierToken("get_node");
                    yield return new Token(TokenType.ParenthesisOpen);
                    yield return new ConstantToken(new StringVariant("/root/SulayreLure/Patches"));
                    yield return new Token(TokenType.ParenthesisClose);
					yield return new Token(TokenType.Period);
					yield return new IdentifierToken("_filter_save");
					yield return new Token(TokenType.ParenthesisOpen);
					yield return new IdentifierToken("new_save");
					yield return new Token(TokenType.Comma);
					yield return new IdentifierToken("slot");
					yield return new Token(TokenType.ParenthesisClose);
					
					yield return new Token(TokenType.Newline, 1);


				}
                else if (waiter_load.Check(token))
                {
                    // found our match, return the original newline
                    yield return token;
                    
                    // loaded_save = _filter_load(loaded_save,slot)
                    yield return new IdentifierToken("loaded_save");
                    yield return new Token(TokenType.OpAssign);
                    yield return new IdentifierToken("get_node");
                    yield return new Token(TokenType.ParenthesisOpen);
                    yield return new ConstantToken(new StringVariant("/root/SulayreLure/Patches"));
                    yield return new Token(TokenType.ParenthesisClose);
                    yield return new Token(TokenType.Period);
                    yield return new IdentifierToken("_filter_load");
                    yield return new Token(TokenType.ParenthesisOpen);
                    yield return new IdentifierToken("loaded_save");
                    yield return new Token(TokenType.Comma);
                    yield return new IdentifierToken("slot");
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
