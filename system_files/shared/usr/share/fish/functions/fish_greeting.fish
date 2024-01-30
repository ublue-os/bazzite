function fish_greeting
	if test -d "$HOME"
		if test ! -e "$HOME"/.config/no-show-user-motd
			if test -x "/usr/libexec/ublue-motd"
				/usr/libexec/ublue-motd
			end
		end
	end

	if set -q fish_private_mode
		echo "fish is running in private mode, history will not be persisted."
	end
end
