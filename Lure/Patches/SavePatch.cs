using GDWeave.Godot;
using GDWeave.Godot.Variants;
using GDWeave.Modding;

namespace Sulayre.Lure.Patches;

public class SavePatch : IScriptMod
{
    public bool ShouldRun(string path) => path == "res://Scenes/Singletons/UserSave/usersave.gdc";

    public IEnumerable<Token> Modify(string path, IEnumerable<Token> tokens)
    {
        var newlineConsumer = new TokenConsumer(t => t.Type is TokenType.Newline);
        
        // func _save_slot(slot):
        var saveSlotWaiter = new FunctionWaiter("_save_slot");

        // "inventory": PlayerData
        var inventoryWaiter = new MultiTokenWaiter([
            t => t is ConstantToken { Value: StringVariant { Value: "inventory" } },
            t => t is IdentifierToken { Name: "PlayerData" }
        ], allowPartialMatch: true, waitForReady: true);
        
        // "cosmetics_unlocked": PlayerData
        var cosmeticsUnlockedWaiter = new MultiTokenWaiter([
            t => t is ConstantToken { Value: StringVariant { Value: "cosmetics_unlocked" } },
            t => t is IdentifierToken { Name: "PlayerData" }
        ], allowPartialMatch: true, waitForReady: true);
        
        // "cosmetics_equipped": PlayerData
        var cosmeticsEquippedWaiter = new MultiTokenWaiter([
            t => t is ConstantToken { Value: StringVariant { Value: "cosmetics_equipped" } },
            t => t is IdentifierToken { Name: "PlayerData" }
        ], allowPartialMatch: true, waitForReady: true);
        
        // "bait_inv": PlayerData
        var baitInvWaiter = new MultiTokenWaiter([
            t => t is ConstantToken { Value: StringVariant { Value: "bait_inv" } },
            t => t is IdentifierToken { Name: "PlayerData" }
        ], allowPartialMatch: true, waitForReady: true);
        
        // "bait_selected": PlayerData
        var baitSelectedWaiter = new MultiTokenWaiter([
            t => t is ConstantToken { Value: StringVariant { Value: "bait_selected" } },
            t => t is IdentifierToken { Name: "PlayerData" }
        ], allowPartialMatch: true, waitForReady: true);
        
        // "bait_unlocked": PlayerData
        var baitUnlockedWaiter = new MultiTokenWaiter([
            t => t is ConstantToken { Value: StringVariant { Value: "bait_unlocked" } },
            t => t is IdentifierToken { Name: "PlayerData" }
        ], allowPartialMatch: true, waitForReady: true);
        
        // "journal": PlayerData
        var journalWaiter = new MultiTokenWaiter([
            t => t is ConstantToken { Value: StringVariant { Value: "journal" } },
            t => t is IdentifierToken { Name: "PlayerData" }
        ], allowPartialMatch: true, waitForReady: true);
        
        // "lure_selected": PlayerData
        var lureSelectedWaiter = new MultiTokenWaiter([
            t => t is ConstantToken { Value: StringVariant { Value: "lure_selected" } },
            t => t is IdentifierToken { Name: "PlayerData" }
        ], allowPartialMatch: true, waitForReady: true);
        
        // "lure_unlocked": PlayerData
        var lureUnlockedWaiter = new MultiTokenWaiter([
            t => t is ConstantToken { Value: StringVariant { Value: "lure_unlocked" } },
            t => t is IdentifierToken { Name: "PlayerData" }
        ], allowPartialMatch: true, waitForReady: true);
        
        // "saved_aqua_fish": PlayerData
        var savedAquaFishWaiter = new MultiTokenWaiter([
            t => t is ConstantToken { Value: StringVariant { Value: "saved_aqua_fish" } },
            t => t is IdentifierToken { Name: "PlayerData" }
        ], allowPartialMatch: true, waitForReady: true);

        foreach (var token in tokens)
        {
            if (newlineConsumer.Check(token))
            {
                continue;
            }

            if (newlineConsumer.Ready)
            {
                yield return token;
                newlineConsumer.Reset();
            }

            else if (saveSlotWaiter.Check(token))
            {
                yield return token;

                foreach (var waiter in new[]
                         {
                             inventoryWaiter, cosmeticsUnlockedWaiter, cosmeticsEquippedWaiter, baitInvWaiter,
                             baitUnlockedWaiter, journalWaiter, lureUnlockedWaiter, savedAquaFishWaiter
                         })
                {
                    waiter.SetReady();
                }
                
                // var Lure = $"/root/Lure"
                yield return new Token(TokenType.PrVar);
                yield return new IdentifierToken("Lure");
                yield return new Token(TokenType.OpAssign);
                yield return new IdentifierToken("get_node");
                yield return new Token(TokenType.ParenthesisOpen);
                yield return new ConstantToken(new StringVariant("/root/Lure"));
                yield return new Token(TokenType.ParenthesisClose);

                yield return token;
                
                // var LurePatches = load("res://mods/Lure/modules/patches.gd")
                yield return new Token(TokenType.PrVar);
                yield return new IdentifierToken("LurePatches");
                yield return new Token(TokenType.OpAssign);
                yield return new Token(TokenType.BuiltInFunc, (uint?)BuiltinFunction.ResourceLoad);
                yield return new Token(TokenType.ParenthesisOpen);
                yield return new ConstantToken(new StringVariant("res://mods/Lure/modules/patches.gd"));
                yield return new Token(TokenType.ParenthesisClose);

                yield return token;
            }

            else if (inventoryWaiter.Check(token))
            {
                foreach (var t in ScriptTokenizer.Tokenize($"LurePatches.sanitise_array(Lure, PlayerData.inventory),"))
                {
                    yield return t;
                    
                    newlineConsumer.SetReady();
                }
            }
            
            else if (cosmeticsUnlockedWaiter.Check(token))
            {
                foreach (var t in ScriptTokenizer.Tokenize($"LurePatches.sanitise_array(Lure, PlayerData.cosmetics_unlocked),"))
                {
                    yield return t;
                    
                    newlineConsumer.SetReady();
                }
            }
            
            else if (cosmeticsEquippedWaiter.Check(token))
            {
                foreach (var t in ScriptTokenizer.Tokenize($"LurePatches.sanitise_cosmetics_equipped(Lure, PlayerData.cosmetics_equipped),"))
                {
                    yield return t;
                    
                    newlineConsumer.SetReady();
                }
            }
            
            else if (baitInvWaiter.Check(token))
            {
                foreach (var t in ScriptTokenizer.Tokenize($"LurePatches.sanitise_dictionary(Lure, PlayerData.bait_inv),"))
                {
                    yield return t;
                    
                    newlineConsumer.SetReady();
                }
            }
            
            else if (baitSelectedWaiter.Check(token))
            {
                foreach (var t in ScriptTokenizer.Tokenize($"LurePatches.sanitise_string(Lure, PlayerData.bait_selected),"))
                {
                    yield return t;
                    
                    newlineConsumer.SetReady();
                }
            }
            
            else if (baitUnlockedWaiter.Check(token))
            {
                foreach (var t in ScriptTokenizer.Tokenize($"LurePatches.sanitise_array(Lure, PlayerData.bait_unlocked),"))
                {
                    yield return t;
                    
                    newlineConsumer.SetReady();
                }
            }
            
            else if (journalWaiter.Check(token))
            {
                foreach (var t in ScriptTokenizer.Tokenize($"LurePatches.sanitise_dictionary(Lure, PlayerData.journal_logs),"))
                {
                    yield return t;
                    
                    newlineConsumer.SetReady();
                }
            }
            
            else if (lureSelectedWaiter.Check(token))
            {
                foreach (var t in ScriptTokenizer.Tokenize($"LurePatches.sanitise_string(Lure, PlayerData.lure_selected),"))
                {
                    yield return t;
                    
                    newlineConsumer.SetReady();
                }
            }
            
            else if (lureUnlockedWaiter.Check(token))
            {
                foreach (var t in ScriptTokenizer.Tokenize($"LurePatches.sanitise_array(Lure, PlayerData.lure_unlocked),"))
                {
                    yield return t;
                    
                    newlineConsumer.SetReady();
                }
            }

            else if (savedAquaFishWaiter.Check(token))
            {
                foreach (var t in ScriptTokenizer.Tokenize("LurePatches.sanitise_saved_aqua_fish(Lure, PlayerData.saved_aqua_fish),"))
                {
                    yield return t;
                    
                    newlineConsumer.SetReady();
                }
            }

            else
            {
                yield return token;
            }
        }
    }
}