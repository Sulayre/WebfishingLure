using GDWeave.Godot.Variants;
using GDWeave.Godot;
using GDWeave.Modding;

namespace Sulayre.Lure.Patches
{
	public class JournalPatcher : IScriptMod
	{
		public bool ShouldRun(string path) => path == "res://Scenes/HUD/journal.gdc";

		// returns a list of tokens for the new script, with the input being the original script's tokens
		public IEnumerable<Token> Modify(string path, IEnumerable<Token> tokens)
		{
			// wait for any newline token after any extends token
			//play("dog_face")

			var extendswaiter = new MultiTokenWaiter([
				t => t.Type is TokenType.PrExtends,
				t => t.Type is TokenType.Identifier,
				t => t.Type is TokenType.Newline,
			], allowPartialMatch: false);

			var inwaiter = new MultiTokenWaiter([
				t => t is IdentifierToken{Name:"category"},
				t => t.Type is TokenType.OpIn,
			], allowPartialMatch: false);

			var consumer = new TokenConsumer(t => t.Type is TokenType.Colon);

			// loop through all tokens in the script
			foreach (var token in tokens)
			{
				if (consumer.Check(token) || consumer.Check(token))
				{
					continue;
				}
				else if (extendswaiter.Check(token))
				{
					// found our match, return the original newline
					yield return token;

					//onready var ready_categories = get_node("/root/SulayreLure").journal_categories
					yield return new Token(TokenType.PrOnready);
					yield return new Token(TokenType.PrVar);
					yield return new IdentifierToken("ready_categories");
					yield return new Token(TokenType.OpAssign);
					yield return new IdentifierToken("get_node");
					yield return new Token(TokenType.ParenthesisOpen);
					yield return new ConstantToken(new StringVariant("/root/SulayreLure"));
					yield return new Token(TokenType.ParenthesisClose);
					yield return new Token(TokenType.Period);
					yield return new IdentifierToken("journal_categories");
				}
				else if (inwaiter.Check(token))
				{
					// found our match, return the original newline
					yield return token;

					yield return new IdentifierToken("ready_categories");
					consumer.SetReady();
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
