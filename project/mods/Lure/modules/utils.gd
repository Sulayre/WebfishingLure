extends Reference


# Convert bbcode color tags to ANSI escape codes and print to the terminal
static func pretty_print(message: String) -> void:
	if (OS.has_feature("editor")):
		print(message)
		return
	
	var formatted_message := message
	
	var colour_tag_regex := RegEx.new()
	colour_tag_regex.compile("\\[color=#?(?<hex_code>[0-9a-fA-F]{6}|[0-9a-fA-F]{3})\\]")
	var valid_tags := colour_tag_regex.search_all(message)
	
	var escape_code := PoolByteArray([0x1b]).get_string_from_ascii()
	
	for tag in valid_tags:
		var rgb := hex_to_rgb(tag.get_string("hex_code")) as PoolStringArray
		var colour_code: String = "%s[38;2;%sm" % [escape_code, rgb.join(";")]
		
		formatted_message = formatted_message.replace(tag.get_string(), colour_code)
	
	var reset_colour = escape_code + "[38;5;7m"
	formatted_message = formatted_message.replace("[/color]", reset_colour)
	
	print(formatted_message + reset_colour)


# Convert a hex code to an array of ints representing r, g, and b
static func hex_to_rgb(hex_code: String) -> Array:
	hex_code = hex_code.lstrip("#")
	var length := hex_code.length()
	
	var hex_regex := RegEx.new()
	hex_regex.compile("[0-9a-fA-F]{6}|[0-9a-fA-F]{3}")
	if hex_regex.sub(hex_code, "") != "":
		push_warning("Invalid hex code provided")
		return []
	
	var channels: Array = []
	
	var codes := [
		hex_code.substr(0, length / 3),
		hex_code.substr(length / 3, length / 3),
		hex_code.substr(length / 3 * 2, length / 3)
	]
	
	for i in range(3):
		if codes[i].length() == 1:
			codes[i] += str(codes[i])
		
		var hex: String = "0x" + codes[i]
		channels.append(str(hex.hex_to_int()))
	
	return channels
