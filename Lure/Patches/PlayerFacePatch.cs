using GDWeave.Godot;
using GDWeave.Godot.Variants;
using GDWeave.Modding;

namespace Lure.Patches;

public class PlayerFacePatch : IScriptMod
{
    public bool ShouldRun(string path) => path == "res://Scenes/Entities/Player/Face/player_face.gdc";

    public IEnumerable<Token> Modify(string path, IEnumerable<Token> tokens)
    {
        var waiter = new FunctionWaiter("_setup_face");

        foreach (var token in tokens)
        {
            yield return token;

            if (!waiter.Check(token)) continue;
            
            //  if $AnimationPlayer.has_animation(data["species"]):
            //      $AnimationPlayer.play(data["species"])
            foreach (var t in ScriptTokenizer.Tokenize("if $\"AnimationPlayer\".has_animation(data[\"species\"]):",1))
            {
                yield return t;
            }
            
            foreach (var t in ScriptTokenizer.Tokenize("$\"AnimationPlayer\".play(data[\"species\"])",2))
            {
                yield return t;
            }
            
            yield return new Token(TokenType.Newline, 1);
        }
    }
}