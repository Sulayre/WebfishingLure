﻿using System.Text.Json.Serialization;

namespace Sulayre.Lure;

public class Config {
    [JsonInclude] public bool SomeSetting = true;
}
