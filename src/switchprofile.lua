local qf = require("src.quickfunctions")
local detectDistro = require("src.detectdistro")
local paths = { "/var/cache/lumineau-cache", "/etc/modprobe.d/00-lumineau.conf", "/etc/udev/rules.d/00-lumineau.rules" }

local function rebuildInitramfs()
	local distro = detectDistro()
	local rebuild

	if distro == "void" or distro == "fedora" then
		rebuild = "dracut --force"
	elseif distro == "arch" then
		rebuild = "mkinitcpio -P"
	elseif distro == "debian" or distro == "ubuntu" or distro == "mint" then
		rebuild = "update-initramfs -u"
	else
		qf.err("unsupported\n")
		os.exit(1)
	end

	qf.verb(rebuild .. "\n")
	os.execute(rebuild)
end

local function switchProfile()
	if not Args then
		return 1
	end

	local chosenmode = string.lower(tostring(Args.switch))
	if chosenmode ~= "y" or chosenmode ~= "n" or chosenmode ~= "yes" or chosenmode ~= "no" then
		qf.err("invalid profile [integrated|hybrid]\n")
		os.exit(1)
	end

	if chosenmode == "integrated" or chosenmode == "i" then
		if qf.fileExists(paths[2]) and qf.fileExists(paths[3]) and not Args.force then
			qf.err("system appears to already be using the integrated profile\n")
			os.exit(1)
		end

		qf.std("switching profile to integrated\n")
		local statusFile = io.open(paths[1], "w")
		local modprobeFile = io.open(paths[2], "w")
		local ruleFile = io.open(paths[3], "w")
		if not statusFile or not modprobeFile or not ruleFile then
			qf.err("couldn't open configuration files..\n")
			os.exit(1)
		end

		modprobeFile:write([[
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
    ]])
		qf.verb("wrote to " .. paths[2])
		ruleFile:write([[
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{remove}="1"
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x8c8000", ATTR{remove}="1"
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{remove}="1"
ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", ATTR{remove}="1"
    ]])
		qf.verb("wrote to " .. paths[3])
		statusFile:write("integrated\n")
		statusFile:close()
		modprobeFile:close()
		ruleFile:close()
	elseif chosenmode == "hybrid" or chosenmode == "h" then
		local statusFile = io.open(paths[1], "w")
		if not statusFile then
			qf.err("couldn't open configuration files")
			os.exit(1)
		end
		if not qf.fileExists(paths[2]) and not qf.fileExists(paths[3]) and not Args.force then
			qf.err("system appears to already be using the hybrid profile\n")
			os.exit(1)
		end
		qf.std("switching profile to hybrid\n")

		for i = 2, #paths do
			os.remove(paths[i])
			qf.verb("removed: " .. paths[i] .. "\n")
		end
		statusFile:write("hybrid\n")
		statusFile:close()
	end

	os.execute("udevadm control --reload-rules")
	os.execute("udevadm trigger")
	rebuildInitramfs()
	qf.std("complete, would you like to restart now?\n")
	local userinput
	while userinput ~= "y" and userinput ~= "yes" and userinput ~= "n" and userinput ~= "no" do
		io.stdout:write("[y/n] ")
		userinput = string.lower(tostring(io.stdin:read()))

		if userinput == "y" or userinput == "yes" then
			qf.std("rebooting..")
			os.execute("reboot")
		end
	end
end

return switchProfile
