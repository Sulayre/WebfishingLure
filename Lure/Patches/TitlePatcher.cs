using GDWeave.Godot.Variants;
using GDWeave.Godot;
using GDWeave.Modding;

namespace Sulayre.Lure.Patches
{
	public class TitlePatcher : IScriptMod
	{
		public bool ShouldRun(string path) => path == "res://Scenes/Entities/Player/player_label.gdc";

		// returns a list of tokens for the new script, with the input being the original script's tokens
		public IEnumerable<Token> Modify(string path, IEnumerable<Token> tokens)
		{
			// wait for any newline token after any extends token
			//pattern.body_pattern[2]

			var readywaiter = new MultiTokenWaiter([
				t => t is IdentifierToken{Name:"title"},
				t => t.Type is TokenType.OpAssign,
				t => t is ConstantToken{Value: StringVariant {Value: ""}},
				t => t.Type is TokenType.Newline,
			], allowPartialMatch: false);

			var labelwaiter = new MultiTokenWaiter([
				t => t.Type is TokenType.Period,
				t => t is IdentifierToken{Name:"text"},
			], allowPartialMatch: false);

			var titlewaiter = new MultiTokenWaiter([
				t => t.Type is TokenType.OpAssign,
				t => t is IdentifierToken{Name:"title"},
			], allowPartialMatch: false);

			// loop through all tokens in the script
			foreach (var token in tokens)
			{
				if (readywaiter.Check(token))
				{
					yield return token;

					//func _ready():
					yield return new Token(TokenType.PrFunction);
					yield return new IdentifierToken("_enter_tree");
					yield return new Token(TokenType.ParenthesisOpen);
					yield return new Token(TokenType.ParenthesisClose);
					yield return new Token(TokenType.Colon);

					yield return new Token(TokenType.Newline, 1);

					//	var new_label = RichTextLabel.new()
					yield return new Token(TokenType.PrVar);
					yield return new IdentifierToken("new_label");
					yield return new Token(TokenType.OpAssign);
					yield return new IdentifierToken("RichTextLabel");
					yield return new Token(TokenType.Period);
					yield return new IdentifierToken("new");
					yield return new Token(TokenType.ParenthesisOpen);
					yield return new Token(TokenType.ParenthesisClose);

					yield return new Token(TokenType.Newline, 1);

					//	new_label.bbcode_enabled = true
					yield return new IdentifierToken("new_label");
					yield return new Token(TokenType.Period);
					yield return new IdentifierToken("bbcode_enabled");
					yield return new Token(TokenType.OpAssign);
					yield return new ConstantToken(new BoolVariant(true));

					yield return new Token(TokenType.Newline, 1);

					//	new_label.fit_content_height = true
					yield return new IdentifierToken("new_label");
					yield return new Token(TokenType.Period);
					yield return new IdentifierToken("fit_content_height");
					yield return new Token(TokenType.OpAssign);
					yield return new ConstantToken(new BoolVariant(true));

					yield return new Token(TokenType.Newline, 1);

					// new_label.add_font_override("normal_font",prel
					yield return new IdentifierToken("new_label");
					yield return new Token(TokenType.Period);
					yield return new IdentifierToken("add_font_override");
					yield return new Token(TokenType.ParenthesisOpen);
					yield return new ConstantToken(new StringVariant("normal_font"));
					yield return new Token(TokenType.Comma);
					yield return new Token(TokenType.BuiltInFunc, (uint?)BuiltinFunction.ResourceLoad);
					yield return new Token(TokenType.ParenthesisOpen);
					yield return new ConstantToken(new StringVariant("res://mods/Lure/Assets/Fonts/title_font.tres"));
					yield return new Token(TokenType.ParenthesisClose);
					yield return new Token(TokenType.ParenthesisClose);

					yield return new Token(TokenType.Newline, 1);


					//	var old_label = $VBoxContainer/Label2
					yield return new Token(TokenType.PrVar);
					yield return new IdentifierToken("old_label");
					yield return new Token(TokenType.OpAssign);
					yield return new IdentifierToken("get_node");
					yield return new Token(TokenType.ParenthesisOpen);
					yield return new ConstantToken(new StringVariant("VBoxContainer/Label2"));
					yield return new Token(TokenType.ParenthesisClose);

					yield return new Token(TokenType.Newline, 1);

					//	old_label.queue_free()
					yield return new IdentifierToken("old_label");
					yield return new Token(TokenType.Period);
					yield return new IdentifierToken("free");
					yield return new Token(TokenType.ParenthesisOpen);
					yield return new Token(TokenType.ParenthesisClose);


					yield return new Token(TokenType.Newline, 1);

					//	$VBoxContainer.add_child(new_label)
					yield return new IdentifierToken("get_node");
					yield return new Token(TokenType.ParenthesisOpen);
					yield return new ConstantToken(new StringVariant("VBoxContainer"));
					yield return new Token(TokenType.ParenthesisClose);
					yield return new Token(TokenType.Period);
					yield return new IdentifierToken("add_child");
					yield return new Token(TokenType.ParenthesisOpen);
					yield return new IdentifierToken("new_label");
					yield return new Token(TokenType.ParenthesisClose);

					yield return new Token(TokenType.Newline, 1);

					//	new_label.name = "Label2"
					yield return new IdentifierToken("new_label");
					yield return new Token(TokenType.Period);
					yield return new IdentifierToken("name");
					yield return new Token(TokenType.OpAssign);
					yield return new ConstantToken(new StringVariant("Label2"));

					yield return new Token(TokenType.Newline);

				}
				else if (labelwaiter.Check(token))
				{
					// found our match, return the original newline
					yield return new IdentifierToken("bbcode_text");


				}
				else if (titlewaiter.Check(token))
				{
					// found our match, return the original newline
					yield return new ConstantToken(new StringVariant("[center]"));
					yield return new Token(TokenType.OpAdd);
					yield return new IdentifierToken("title");
					yield return new Token(TokenType.OpAdd);
					yield return new ConstantToken(new StringVariant("[/center]"));


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
