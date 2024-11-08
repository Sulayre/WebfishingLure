using GDWeave.Godot.Variants;
using GDWeave.Godot;
using GDWeave.Modding;

namespace Sulayre.Lure.Patches;

public class PlayerPatch : IScriptMod
{
    public bool ShouldRun(string path) => path == "res://Scenes/Entities/Player/player.gdc";

    public IEnumerable<Token> Modify(string path, IEnumerable<Token> tokens)
    {
        // extends
        var extendsWaiter = new MultiTokenWaiter([
            t => t.Type is TokenType.PrExtends,
            t => t.Type is TokenType.Newline,
        ], allowPartialMatch: true);

        // func _update_cosmetics()
        var updateCosmeticsWaiter = new FunctionWaiter("_update_cosmetics");
        
        // if species: ... match
        var matchSpeciesWaiter = new MultiTokenWaiter([
            t => t.Type is TokenType.CfIf,
            t => t is IdentifierToken { Name: "species" },
            t => t.Type is TokenType.Colon,
            t => t.Type is TokenType.CfMatch,
        ], allowPartialMatch: true, waitForReady: true);
        
        // pattern.body_pattern[2])
        var bodyPatternWaiter = new MultiTokenWaiter([
            t => t is IdentifierToken { Name: "pattern" },
            t => t.Type is TokenType.Period,
            t => t is IdentifierToken { Name: "body_pattern" },
            t => t.Type is TokenType.BracketOpen,
            t => t is ConstantToken { Value: IntVariant { Value: 2 } },
            t => t.Type is TokenType.BracketClose,
            t => t.Type is TokenType.ParenthesisClose,
        ], waitForReady: true);

        var consuming = false;

        foreach (var token in tokens)
        {
            if (extendsWaiter.Check(token))
            {
                yield return token;
                
                // const LurePatches = preload("res://mods/Lure/modules/patches.gd")
                yield return new Token(TokenType.PrConst);
                yield return new IdentifierToken("LurePatches");
                yield return new Token(TokenType.OpAssign);
                yield return new Token(TokenType.PrPreload);
                yield return new Token(TokenType.ParenthesisOpen);
                yield return new ConstantToken(new StringVariant("res://mods/Lure/modules/patches.gd"));
                yield return new Token(TokenType.ParenthesisClose);

                yield return token;
            }

            else if (updateCosmeticsWaiter.Check(token))
            {
                matchSpeciesWaiter.SetReady();
                bodyPatternWaiter.SetReady();
            }

            else if (matchSpeciesWaiter.Check(token))
            {
                consuming = true;
            }

            else if (bodyPatternWaiter.Check(token))
            {
                consuming = false;
                
                // LurePatches.override_body_pattern()
                yield return new IdentifierToken("LurePatches");
                yield return new Token(TokenType.Period);
                yield return new IdentifierToken("override_body_pattern");
                yield return new Token(TokenType.ParenthesisOpen);
                yield return new Token(TokenType.ParenthesisClose);
            
                yield return new Token(TokenType.Newline, 2);
            }

            else if (!consuming)
            {
                yield return token;
            }
        }
    }
}