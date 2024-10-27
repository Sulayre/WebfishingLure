using GDWeave.Godot.Variants;
using GDWeave.Godot;
using GDWeave.Modding;

namespace Sulayre.Lure.Patches
{
	public class ItemPatcher : IScriptMod
	{
		public bool ShouldRun(string path) => path == "res://Scenes/Entities/Player/player.gdc";

		// returns a list of tokens for the new script, with the input being the original script's tokens
		public IEnumerable<Token> Modify(string path, IEnumerable<Token> tokens)
		{
			var waiter_use = new MultiTokenWaiter([
				//func _use_item():
				t => t.Type is TokenType.PrFunction,
				t => t is IdentifierToken{Name:"_use_item"},
				t => t.Type is TokenType.ParenthesisOpen,
				t => t.Type is TokenType.ParenthesisClose,
				t => t.Type is TokenType.Colon,
				t => t.Type is TokenType.Newline & t.AssociatedData is 1,
					//if held_item.empty(): return
					t => t.Type is TokenType.CfIf,
					t => t is IdentifierToken{Name:"held_item"},
					t => t.Type is TokenType.Period,
					t => t is IdentifierToken{Name:"empty"},
					t => t.Type is TokenType.ParenthesisOpen,
					t => t.Type is TokenType.ParenthesisClose,
					t => t.Type is TokenType.Colon,
					t => t.Type is TokenType.CfReturn,
					t => t.Type is TokenType.Newline & t.AssociatedData is 1,
						//var item_data = Globals.item_data[held_item["id"]]["file"]
						t => t.Type is TokenType.PrVar,
						t => t is IdentifierToken{Name:"item_data"},
						t => t.Type is TokenType.OpAssign,
						t => t is IdentifierToken{Name:"Globals"},
						t => t.Type is TokenType.Period,
						t => t is IdentifierToken{Name:"item_data"},
						t => t.Type is TokenType.BracketOpen,
						t => t is IdentifierToken{Name:"held_item"},
						t => t.Type is TokenType.BracketOpen,
						t => t is ConstantToken{Value: StringVariant {Value: "id"}},
						t => t.Type is TokenType.BracketClose,
						t => t.Type is TokenType.BracketClose,
						t => t.Type is TokenType.BracketOpen,
						t => t is ConstantToken{Value: StringVariant {Value: "file"}},
						t => t.Type is TokenType.BracketClose,
						t => t.Type is TokenType.Newline,
			], allowPartialMatch: false)
			{

			};
			var waiter_release = new MultiTokenWaiter([
				t => t.Type is TokenType.PrFunction,
				t => t is IdentifierToken{Name:"_release_item"},
				t => t.Type is TokenType.ParenthesisOpen,
				t => t.Type is TokenType.ParenthesisClose,
				t => t.Type is TokenType.Colon,
				t => t.Type is TokenType.Newline & t.AssociatedData is 1,
					//if held_item.empty(): return
					t => t.Type is TokenType.CfIf,
					t => t is IdentifierToken{Name:"held_item"},
					t => t.Type is TokenType.Period,
					t => t is IdentifierToken{Name:"empty"},
					t => t.Type is TokenType.ParenthesisOpen,
					t => t.Type is TokenType.ParenthesisClose,
					t => t.Type is TokenType.Colon,
					t => t.Type is TokenType.CfReturn,
					t => t.Type is TokenType.Newline & t.AssociatedData is 1,
						//var item_data = Globals.item_data[held_item["id"]]["file"]
						t => t.Type is TokenType.PrVar,
						t => t is IdentifierToken{Name:"item_data"},
						t => t.Type is TokenType.OpAssign,
						t => t is IdentifierToken{Name:"Globals"},
						t => t.Type is TokenType.Period,
						t => t is IdentifierToken{Name:"item_data"},
						t => t.Type is TokenType.BracketOpen,
						t => t is IdentifierToken{Name:"held_item"},
						t => t.Type is TokenType.BracketOpen,
						t => t is ConstantToken{Value: StringVariant {Value: "id"}},
						t => t.Type is TokenType.BracketClose,
						t => t.Type is TokenType.BracketClose,
						t => t.Type is TokenType.BracketOpen,
						t => t is ConstantToken{Value: StringVariant {Value: "file"}},
						t => t.Type is TokenType.BracketClose,
						t => t.Type is TokenType.Newline,
			], allowPartialMatch: false);

			// loop through all tokens in the script
			foreach (var token in tokens)
			{
				if (waiter_use.Check(token))
				{
					yield return token;

					// if get_node("/root/SulayreLure")._call_action(item_data.action,item_data.action_params): return
					yield return new Token(TokenType.CfIf);

					yield return new IdentifierToken("get_node");
					yield return new Token(TokenType.ParenthesisOpen);
					yield return new ConstantToken(new StringVariant("/root/SulayreLure/Patches"));
					yield return new Token(TokenType.ParenthesisClose);
					yield return new Token(TokenType.Period);
					yield return new IdentifierToken("_call_action");
					yield return new Token(TokenType.ParenthesisOpen);
					yield return new IdentifierToken("item_data");
					yield return new Token(TokenType.Period);
					yield return new IdentifierToken("action");
					yield return new Token(TokenType.Comma);
					yield return new IdentifierToken("item_data");
					yield return new Token(TokenType.Period);
					yield return new IdentifierToken("action_params");
					yield return new Token(TokenType.ParenthesisClose);
					yield return new Token(TokenType.Colon);

					yield return new Token(TokenType.CfReturn);

					yield return new Token(TokenType.Newline, 1);


				}
				else if (waiter_release.Check(token))
				{
					yield return token;

					yield return new Token(TokenType.Newline, 1);

					// if get_node("/root/SulayreLure")._call_action(item_data.action): return
					yield return new Token(TokenType.CfIf);
					yield return new IdentifierToken("get_node_or_null");
					yield return new Token(TokenType.ParenthesisOpen);
					yield return new ConstantToken(new StringVariant("/root/SulayreLure/Patches"));
					yield return new Token(TokenType.ParenthesisClose);
					yield return new Token(TokenType.Period);
					yield return new IdentifierToken("_call_release");
					yield return new Token(TokenType.ParenthesisOpen);
					yield return new IdentifierToken("item_data");
					yield return new Token(TokenType.Period);
					yield return new IdentifierToken("release_action");
					yield return new Token(TokenType.ParenthesisClose);
					yield return new Token(TokenType.Colon);

					yield return new Token(TokenType.CfReturn);

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
