local function detectDistro()
	local id
	for line in io.lines("/etc/os-release") do
		id = string.match(line, "^ID=(.+)")
		if id then
			id = string.gsub(id, "['\"]", "")
			break
		end
	end

	return id
end

return detectDistro
