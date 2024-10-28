using System.Text.Json.Serialization;

namespace Sulayre.Lure;

public class Config
{
    [JsonInclude] public bool bonus_content = false;
	[JsonInclude] public bool bonus_prompt = true;
}
