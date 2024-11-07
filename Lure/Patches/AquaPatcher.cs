using GDWeave.Godot.Variants;
using GDWeave.Godot;
using GDWeave.Modding;

namespace Sulayre.Lure.Patches
{
    public class AquaPatcher : IScriptMod
    {
        public bool ShouldRun(string path) => path == "res://Scenes/Entities/AquaFish/aqua_fish.gdc";

        // returns a list of tokens for the new script, with the input being the original script's tokens
        public IEnumerable<Token> Modify(string path, IEnumerable<Token> tokens)
        {
            // wait for any newline token after any extends token
            //play("dog_face")
            var waiter = new MultiTokenWaiter([
                t => t is IdentifierToken{Name:"texture"},
                t => t.Type is TokenType.OpAssign,
                t => t is ConstantToken{Value: NilVariant },
                t => t.Type is TokenType.Newline,
                t => t.Type is TokenType.CfElse,
                t => t.Type is TokenType.Colon,
                t => t.Type is TokenType.Newline,
            ], allowPartialMatch: false);

            // loop through all tokens in the script
            foreach (var token in tokens)
            {
                if (waiter.Check(token))
                {
                    // found our match, return the original newline
                    yield return token;
                    //fish_lake_carp aquarium fallback
                    yield return new Token(TokenType.CfIf);
                    yield return new Token(TokenType.OpNot);
                    yield return new IdentifierToken("Globals");
                    yield return new Token(TokenType.Period);
                    yield return new IdentifierToken("item_data");
                    yield return new Token(TokenType.Period);
                    yield return new IdentifierToken("keys");
                    yield return new Token(TokenType.ParenthesisOpen);
                    yield return new Token(TokenType.ParenthesisClose);
                    yield return new Token(TokenType.Period);
                    yield return new IdentifierToken("has");
                    yield return new Token(TokenType.ParenthesisOpen);
                    yield return new IdentifierToken("id");
                    yield return new Token(TokenType.ParenthesisClose);
                    yield return new Token(TokenType.Colon);
                    //yield return new Token(TokenType.BuiltInFunc, (uint?)BuiltinFunction.VarToStr);
                    yield return new IdentifierToken("id");
                    yield return new Token(TokenType.OpAssign);
                    yield return new ConstantToken(new StringVariant("fish_lake_carp"));
                    yield return new Token(TokenType.Newline,2);


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