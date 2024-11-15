using GDWeave.Godot.Variants;
using GDWeave.Godot;
using GDWeave.Modding;

namespace Lure.Patches;

public class PlayerFacePatch : IScriptMod
{
    public bool ShouldRun(string path) => path == "res://Scenes/Entities/Player/Face/player_face.gdc";

    public IEnumerable<Token> Modify(string path, IEnumerable<Token> tokens)
    {
        // extends
        var waiter = new MultiTokenWaiter([
            t => t.Type is TokenType.PrExtends,
            t => t.Type is TokenType.Newline,
        ], allowPartialMatch: false);
        
        foreach (var token in tokens)
        {
            if (waiter.Check(token))
            {
                yield return token;
            }
            else
            {
                yield return token;
            }
        }
    }
}