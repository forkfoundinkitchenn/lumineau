local qf = require("src.quickfunctions")

local function switchProfile()
	if not qf then
		return
	end

	local chosenmode = string.lower(Args and Args.switch or "")
	local paths =
		{ "/var/cache/lumineau-cache", "/etc/modprobe.d/00-lumineau.conf", "/etc/udev/rules.d/00-lumineau.rules" }

	local function rebuildInitramfs()
		local id
		local rebuild

		for line in io.lines("/etc/os-release") do
			id = line:match('^ID="?([%w_-]+)"?')

			if id then
				qf.verb(id .. "\n")
				break
			end
		end

		if id == "void" or id == "fedora" then
			rebuild = "dracut --force"
		elseif id == "arch" then
			rebuild = "mkinitcpio -P"
		elseif id == "debian" or id == "ubuntu" then
			rebuild = "update-initramfs"
		else
			qf.err("unsupported distro\n")
			for path = 1, #paths do
				os.remove(paths[path])
			end
			os.exit(1)
		end

		qf.verb(rebuild .. "\n")
		os.execute(rebuild)
	end

	local statusFile = io.open(paths[1], "w+")
	if not statusFile then
		qf.err("couldn't open status file\n")
		os.exit(1)
	end

	local modprobeFile = io.open(paths[2], "w+")
	if not modprobeFile then
		qf.err("couldn't open modprobe file\n")
		os.exit(1)
	end

	local udevRule = io.open(paths[3], "w+")
	if not udevRule then
		qf.err("couldn't open udev rule file\n")
		os.exit(1)
	end

	if chosenmode == "integrated" or chosenmode == "i" then
		if qf.fileExists(paths[1]) and qf.fileExists(paths[2]) and qf.fileExists(paths[3]) and not Args.force then
			qf.err("system already seems to be using the integrated profile\n")
			os.exit(1)
		end

		qf.std("switching profile to integrated\n")
		modprobeFile:write([=[
blacklist nvidia
blacklist nvidia_drm
blacklist nvidia_uvm
blacklist nvidia_modeset
blacklist nvidia_current
blacklist nvidia_current_drm
blacklist nvidia_current_uvm 
blacklist nvidia_current_modeset
blacklist i2c_nvidia_gpu
blacklist nova_core
blacklist nova_drm 
blacklist nouveau
alias nvidia off
alias nvidia_drm off
alias nvidia_uvm off
alias nvidia_modeset off
alias nvidia_current off
alias nvidia_current_drm off
alias nvidia_current_uvm off
alias nvidia_current_modeset off
alias i2c_nvidia_gpu off
alias nova_core off
alias nova_drm off
alias nouveau off
]=])
		udevRule:write([=[
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{remove}="1"
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x8c8000", ATTR{remove}="1"
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{remove}="1"
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", ATTR{remove}="1"
]=])
		qf.std("donezo\n")
		statusFile:write("integrated")
	elseif chosenmode == "hybrid" or chosenmode == "h" then
		if
			not qf.fileExists(paths[1])
			and not qf.fileExists(paths[2])
			and not qf.fileExists(paths[3])
			and not Args.force
		then
			qf.std("system already seems to be using the hybrid profile\n")
			os.exit(1)
		end

		for path = 1, #paths do
			os.remove(paths[path])
		end
	end

	statusFile:close()
	modprobeFile:close()
	udevRule:close()
	os.execute("udevadm control --reload-rules")
	os.execute("udevadm trigger")
	rebuildInitramfs()
	qf.std("prompt user here\n")
end

return switchProfile
