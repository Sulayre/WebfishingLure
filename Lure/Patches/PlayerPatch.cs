using GDWeave.Godot.Variants;
using GDWeave.Godot;
using GDWeave.Modding;

namespace Lure.Patches;

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
        
        // @1921 cosm.material_override =
        var overrideWaiter = new MultiTokenWaiter([
            t => t is IdentifierToken { Name: "cosm" },
            t => t.Type is TokenType.Period,
            t => t is IdentifierToken { Name: "material_override" },
            t => t.Type is TokenType.OpAssign,
        ]);
        
        var shaderPreloadConsumer = new TokenConsumer(t => t.Type is TokenType.Period);
        
        var consuming = false;

        foreach (var token in tokens)
        {
            if (shaderPreloadConsumer.Check(token)) continue;
            
            if (extendsWaiter.Check(token))
            {
                yield return token;
                
                // onready var LurePatch = load("res://mods/Lure/patches/player.gd")
                foreach (var t in ScriptTokenizer.Tokenize("onready var LurePatch = load(\"res://mods/Lure/patches/player.gd\")"))
                {
                    yield return t;
                }

                yield return token;
            }
            
            else if (matchSpeciesWaiter.Check(token) || barkIdWaiter.Check(token)) consuming = true;

            else if (updateCosmeticsWaiter.Check(token))
            {
                yield return token;
                
                matchSpeciesWaiter.SetReady();
                bodyPatternWaiter.SetReady();
            }

            else if (bodyPatternWaiter.Check(token))
            {
                // LurePatch.override_body_pattern(data["species"], species, pattern)
                foreach (var t in ScriptTokenizer.Tokenize("LurePatch.override_body_pattern(data[\"species\"], species, pattern)"))
                {
                    yield return t;
                }
                
                consuming = false;
            }
            
            else if (barkWaiter.Check(token))
            {
                yield return token;
                
                equippedSpeciesWaiter.SetReady();
                barkIdWaiter.SetReady();
            }
            
            else if (equippedSpeciesWaiter.Check(token))
            {
                // bark_id = LurePatch.get_bark_id(self, PlayerData.cosmetics_equipped.species)
                foreach (var t in ScriptTokenizer.Tokenize("bark_id = LurePatch.get_bark_id(self, PlayerData.cosmetics_equipped.species)"))
                {
                    yield return t;
                }
                
                consuming = false;
            }
            
            else if (overrideWaiter.Check(token))
            {
                yield return token;
                yield return new IdentifierToken("LurePatches");
                yield return new Token(TokenType.Period);
                yield return new IdentifierToken("CustomBodyShader");
                shaderPreloadConsumer.SetReady();
            }
            
            else if (!consuming)
            {
                yield return token;
            }
        }
    }
}