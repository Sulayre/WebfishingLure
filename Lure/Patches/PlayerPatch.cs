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
        
        // body_pattern[2])
        var bodyPatternWaiter = new MultiTokenWaiter([
            t => t is IdentifierToken { Name: "body_pattern" },
            t => t.Type is TokenType.BracketOpen,
            t => t is ConstantToken { Value: IntVariant { Value: 2 } },
            t => t.Type is TokenType.BracketClose,
            t => t.Type is TokenType.ParenthesisClose,
        ], allowPartialMatch: true, waitForReady: true);

        // func _bark()
        var barkWaiter = new FunctionWaiter("_bark");

        // var bark_id
        var barkIdWaiter = new TokenWaiter(t => t is IdentifierToken { Name: "bark_id" }, waitForReady: true);

        // [PlayerData.cosmetics_equipped.species]
        var equippedSpeciesWaiter = new MultiTokenWaiter([
            t => t.Type is TokenType.BracketOpen,
            t => t is IdentifierToken { Name: "PlayerData" },
            t => t.Type is TokenType.Period,
            t => t is IdentifierToken { Name: "cosmetics_equipped" },
            t => t.Type is TokenType.Period,
            t => t is IdentifierToken { Name: "species" },
            t => t.Type is TokenType.BracketClose,
        ], allowPartialMatch: true, waitForReady: true);
        
        var consuming = false;

        foreach (var token in tokens)
        {
            if (extendsWaiter.Check(token))
            {
                yield return token;
                
                // onready var LurePatches = load("res://mods/Lure/modules/patches.gd")
                yield return new Token(TokenType.PrOnready);
                yield return new Token(TokenType.PrVar);
                yield return new IdentifierToken("LurePatches");
                yield return new Token(TokenType.OpAssign);
                yield return new Token(TokenType.BuiltInFunc, (uint?)BuiltinFunction.ResourceLoad);
                yield return new Token(TokenType.ParenthesisOpen);
                yield return new ConstantToken(new StringVariant("res://mods/Lure/modules/patches.gd"));
                yield return new Token(TokenType.ParenthesisClose);

                yield return token;
            }
            
            else if (matchSpeciesWaiter.Check(token) || barkIdWaiter.Check(token))
            {
                consuming = true;
            }

            else if (updateCosmeticsWaiter.Check(token))
            {
                yield return token;
                
                matchSpeciesWaiter.SetReady();
                bodyPatternWaiter.SetReady();
            }

            else if (bodyPatternWaiter.Check(token))
            {
                consuming = false;
                
                // LurePatches.override_body_pattern(data["species"],species,pattern)
                yield return new IdentifierToken("LurePatches");
                yield return new Token(TokenType.Period);
                yield return new IdentifierToken("override_body_pattern");
                yield return new Token(TokenType.ParenthesisOpen);
                yield return new IdentifierToken("data");
                yield return new Token(TokenType.BracketOpen);
                yield return new ConstantToken(new StringVariant("species"));
                yield return new Token(TokenType.BracketClose);
                yield return new Token(TokenType.Comma);
                yield return new IdentifierToken("species");
                yield return new Token(TokenType.Comma);
                yield return new IdentifierToken("pattern");
                yield return new Token(TokenType.ParenthesisClose);
            }
            
            else if (barkWaiter.Check(token))
            {
                yield return token;
                
                equippedSpeciesWaiter.SetReady();
                barkIdWaiter.SetReady();
            }
            
            else if (equippedSpeciesWaiter.Check(token))
            {
                consuming = false;
                
                // bark_id = LurePatches.get_bark_id(self, PlayerData.cosmetics_equipped.species)
                yield return new IdentifierToken("bark_id");
                yield return new Token(TokenType.OpAssign);
                yield return new IdentifierToken("LurePatches");
                yield return new Token(TokenType.Period);
                yield return new IdentifierToken("get_bark_id");
                yield return new Token(TokenType.ParenthesisOpen);
                yield return new Token(TokenType.Self);
                yield return new Token(TokenType.Comma);
                yield return new IdentifierToken("PlayerData");
                yield return new Token(TokenType.Period);
                yield return new IdentifierToken("cosmetics_equipped");
                yield return new Token(TokenType.Period);
                yield return new IdentifierToken("species");
                yield return new Token(TokenType.ParenthesisClose);
            }

            else if (!consuming)
            {
                yield return token;
            }
        }
    }
}