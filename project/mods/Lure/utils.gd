extends Reference


# Convert bbcode tags to ANSI escape codes and print to the terminal
# Supports [b], [i], [u], [s], [color]/[fgcolor], and [bgcolor]
static func pretty_print(message: String) -> void:
	var editor := OS.has_feature("editor")
	var csi := PoolByteArray([0x1b]).get_string_from_ascii() + "["  # \e[
	var reset := csi + "m"  # \e[m
	var formatted_message := message

	var bbcode_regex := RegEx.new()
	# /\[(?<tag>\/?\w+)=?(?<options>[#\w]*\]/g
	bbcode_regex.compile("\\[(?<tag>\\/?\\w+)=?(?<options>[#\\w]*)\\]")
	var hex_regex := RegEx.new()
	hex_regex.compile("#?(?<hex_code>[0-9a-fA-F]{6}|[0-9a-fA-F]{3})")

	for result in bbcode_regex.search_all(message):
		var bbcode: String = result.get_string()

		if editor:
			formatted_message = formatted_message.replace(bbcode, "")
			continue

		var tag: String = result.get_string("tag")
		var options: String = result.get_string("options")
		var control_sequence := csi
		var closing := tag.begins_with("/")
		tag.lstrip("/")

		match tag:
			"b":
				control_sequence += "1" if !closing else "22"
			"i":
				control_sequence += "3" if !closing else "23"
			"u":
				control_sequence += "4" if !closing else "24"
			"s":
				control_sequence += "9" if !closing else "29"
			"color", "fgcolor":
				if !closing:
					if hex_regex.sub(options, "") != "":
						continue

					options.lstrip("#")
					var rgb := hex_to_rgb(options) as PoolStringArray

					control_sequence += "38;2;%s" % rgb.join(";")
				else:
					control_sequence += "39"
			"bgcolor":
				if !closing:
					if hex_regex.sub(options, "") != "":
						continue

					options.lstrip("#")
					var rgb := hex_to_rgb(options) as PoolStringArray

					control_sequence += "48;2;%s" % rgb.join(";")
				else:
					control_sequence += "49"

		control_sequence += "m"
		formatted_message = formatted_message.replace(bbcode, control_sequence)

	if !editor:
		formatted_message += reset

	print(formatted_message)


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
		hex_code.substr(0, int(length / 3.0)),
		hex_code.substr(int(length / 3.0), int(length / 3.0)),
		hex_code.substr(int(length / 3.0) * 2, int(length / 3.0))
	]

	for i in range(3):
		if codes[i].length() == 1:
			codes[i] += str(codes[i])

		var hex: String = "0x" + codes[i]
		channels.append(hex.hex_to_int())

	return channels
