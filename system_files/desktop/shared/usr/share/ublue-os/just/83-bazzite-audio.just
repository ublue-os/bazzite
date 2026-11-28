# vim: set ft=make :

# Add virtual audio channels/sinks named Game, Voice, Browser and Music which you can split audio to using qpwgraph, Helvum, Carla or other PipeWire patchbays for use in OBS and other use cases
[group("audio")]
setup-virtual-channels ACTION="":
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    CONFIG_FILE="$HOME/.config/pipewire/pipewire.conf.d/virtual-channels.conf"
    get_status_token() {
      if [[ -f "$CONFIG_FILE" ]]; then
        echo "create"
      else
        echo "remove"
      fi
    }
    get_current_status() {
      if [[ "$(get_status_token)" == "create" ]]; then
        echo "Enabled"
      else
        echo "Disabled"
      fi
    }
    OPTION="{{ ACTION }}"
    if [ "$OPTION" == "help" ]; then
      echo "Usage: ujust setup-virtual-channels <option>"
      echo "  <option>: Specify the quick option to skip the prompt"
      echo "  Use 'status' to print the current portal token"
      echo "  Use 'create' to select Create Virtual Audio Channels"
      echo "  Use 'remove' to select Remove Virtual Audio Channels"
      exit 0
    elif [ "$OPTION" == "status" ]; then
      get_status_token
      exit 0
    elif [ "$OPTION" == "" ]; then
      echo "${bold}Virtual Audio Channels configuration${normal}"
      echo "Current status: $(get_current_status)"
      OPTION=$(ugum choose "Create Virtual Audio Channels" "Remove Virtual Audio Channels" "Exit without changes")
    fi
    if [[ "${OPTION,,}" =~ ^create ]]; then
      IMAGE_INFO="/usr/share/ublue-os/image-info.json"
      IMAGE_NAME=$(jq -r '."image-name"' < $IMAGE_INFO)
      # Set default props, for deck images make sure default output is valves virtual-sink
      PROPS='node.name      = "playback.game_output"
                    audio.position = [ FL FR ]
                    node.passive   = true'
      if [[ "$IMAGE_NAME" =~ deck ]]; then
        PROPS='node.name      = "playback.game_output"
                    audio.position = [ FL FR ]
                    node.passive   = true
                    target.object = "input.virtual-sink"'
      fi
      mkdir -p ~/.config/pipewire/pipewire.conf.d
      PLAYBACK_PROPS=$PROPS bash -c 'cat << EOL > ~/.config/pipewire/pipewire.conf.d/virtual-channels.conf
    context.modules = [
        { name = libpipewire-module-loopback
            args = {
                node.description = "Game"
                capture.props = {
                    node.name      = "game_output"
                    media.class    = "Audio/Sink"
                    audio.position = [ FL FR ]
                }
                playback.props = {
                    $PLAYBACK_PROPS
                }
            }
        }
        { name = libpipewire-module-loopback
            args = {
                node.description = "Voice"
                capture.props = {
                    node.name      = "voice_output"
                    media.class    = "Audio/Sink"
                    audio.position = [ FL FR ]
                }
                playback.props = {
                    $PLAYBACK_PROPS
                }
            }
        }
        { name = libpipewire-module-loopback
            args = {
                node.description = "Browser"
                capture.props = {
                    node.name      = "browser_output"
                    media.class    = "Audio/Sink"
                    audio.position = [ FL FR ]
                }
                playback.props = {
                    $PLAYBACK_PROPS
                }
            }
        }
        { name = libpipewire-module-loopback
            args = {
                node.description = "Music"
                capture.props = {
                    node.name      = "music_output"
                    media.class    = "Audio/Sink"
                    audio.position = [ FL FR ]
                }
                playback.props = {
                    $PLAYBACK_PROPS
                }
            }
        }
    ]
    EOL'
      echo "Next time you log in, you will have audio channels for Game, Voice, Browser, Music that you can route game audio to"
      echo "using programs like Pulseaudio volume control, coppwr, qpwgraph, helvum or carla."
      echo "You can also add these channels to OBS audio mixer for separate audio control for yourself and your viewers."
      echo "NOTE: It is recommended to mute the virtual channels so you do not have to listen to them twice if you are not exclusively routing the audio through said channel instead of splitting audio to them."
    elif [[ "${OPTION,,}" =~ ^remove ]]; then
      rm -f "$CONFIG_FILE"
      echo "Virtual audio channels config removed, the channels will be removed next time you login."
    fi

# Setup a virtual 7.1 surround sink for headphones using the PipeWire spatializer module
[group("audio")]
setup-virtual-surround ACTION="":
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    CONFIG_FILE="$HOME/.config/pipewire/pipewire.conf.d/spatializer-7.1.conf"
    LEGACY_CONFIG_FILE="$HOME/.config/pipewire/pipewire.conf.d/virtual-surround-71.conf"
    HRTF_FILE="$HOME/.config/pipewire/hrtf-sofa/sadie_d1.sofa"
    get_status_token() {
      if [[ -f "$CONFIG_FILE" && -f "$HRTF_FILE" ]]; then
        echo "enable"
      else
        echo "disable"
      fi
    }
    get_current_status() {
      if [[ "$(get_status_token)" == "enable" ]]; then
        echo "Enabled"
      elif [[ -f "$CONFIG_FILE" || -f "$HRTF_FILE" ]]; then
        echo "Partially Enabled"
      else
        echo "Disabled"
      fi
    }
    OPTION="{{ ACTION }}"
    if [ "$OPTION" == "help" ]; then
      echo "Usage: ujust setup-virtual-surround <option>"
      echo "  <option>: Specify the quick option to skip the prompt"
      echo "  Use 'status' to print the current portal token"
      echo "  Use 'enable' to select Enable Virtual Headphone Surround"
      echo "  Use 'disable' to select Disable Virtual Headphone Surround"
      exit 0
    elif [ "$OPTION" == "status" ]; then
      get_status_token
      exit 0
    elif [ "$OPTION" == "" ]; then
      echo "${bold}Virtual Headphone Surround configuration${normal}"
      echo "Current status: $(get_current_status)"
      OPTION=$(ugum choose "Enable Virtual Headphone Surround" "Disable Virtual Headphone Surround" "Exit without changes")
    fi
    if [[ "${OPTION,,}" =~ ^enable ]]; then
      mkdir -p ~/.config/pipewire/pipewire.conf.d
      mkdir -p ~/.config/pipewire/hrtf-sofa
      echo "Downloading Valve's Steam Audio HRTF..."
      wget -O "$HRTF_FILE" https://github.com/ValveSoftware/steam-audio/raw/480dd64f513cc8a6437e7d5b9eb0d3f1d30c2fac/core/data/hrtf/sadie_d1.sofa
      if [ -f "$LEGACY_CONFIG_FILE" ]; then
        mv "$LEGACY_CONFIG_FILE" ~/.config/pipewire/virtual-surround-71.conf.bak
      fi
      bash -c 'cat << SPATIALIZER > ~/.config/pipewire/pipewire.conf.d/spatializer-7.1.conf
    # Headphone surround sink
    #
    # Adjust the paths to the sofa file to match your system.
    # Preferably, use absolute paths.
    #
    context.modules = [
        { name = libpipewire-module-filter-chain
            flags = [ nofail ]
            args = {
                node.description = "Virtual Headphone Surround"
                media.name       = "Virtual Headphone Surround"
                filter.graph = {
                    nodes = [
                        {
                            type = sofa
                            label = spatializer
                            name = spFL
                            config = {
                                filename = "$HOME/.config/pipewire/hrtf-sofa/sadie_d1.sofa"
                            }
                            control = {
                                "Azimuth"    = 30.0
                                "Elevation"  = 0.0
                                "Radius"     = 3.0
                            }
                        }
                        {
                            type = sofa
                            label = spatializer
                            name = spFR
                            config = {
                                filename = "$HOME/.config/pipewire/hrtf-sofa/sadie_d1.sofa"
                            }
                            control = {
                                "Azimuth"    = 330.0
                                "Elevation"  = 0.0
                                "Radius"     = 3.0
                            }
                        }
                        {
                            type = sofa
                            label = spatializer
                            name = spFC
                            config = {
                                filename = "$HOME/.config/pipewire/hrtf-sofa/sadie_d1.sofa"
                            }
                            control = {
                                "Azimuth"    = 0.0
                                "Elevation"  = 0.0
                                "Radius"     = 3.0
                            }
                        }
                        {
                            type = sofa
                            label = spatializer
                            name = spRL
                            config = {
                                filename = "$HOME/.config/pipewire/hrtf-sofa/sadie_d1.sofa"
                            }
                            control = {
                                "Azimuth"    = 150.0
                                "Elevation"  = 0.0
                                "Radius"     = 3.0
                            }
                        }
                        {
                            type = sofa
                            label = spatializer
                            name = spRR
                            config = {
                                filename = "$HOME/.config/pipewire/hrtf-sofa/sadie_d1.sofa"
                            }
                            control = {
                                "Azimuth"    = 210.0
                                "Elevation"  = 0.0
                                "Radius"     = 3.0
                            }
                        }
                        {
                            type = sofa
                            label = spatializer
                            name = spSL
                            config = {
                                filename = "$HOME/.config/pipewire/hrtf-sofa/sadie_d1.sofa"
                            }
                            control = {
                                "Azimuth"    = 90.0
                                "Elevation"  = 0.0
                                "Radius"     = 3.0
                            }
                        }
                        {
                            type = sofa
                            label = spatializer
                            name = spSR
                            config = {
                                filename = "$HOME/.config/pipewire/hrtf-sofa/sadie_d1.sofa"
                            }
                            control = {
                                "Azimuth"    = 270.0
                                "Elevation"  = 0.0
                                "Radius"     = 3.0
                            }
                        }
                        {
                            type = sofa
                            label = spatializer
                            name = spLFE
                            config = {
                                filename = "$HOME/.config/pipewire/hrtf-sofa/sadie_d1.sofa"
                            }
                            control = {
                                "Azimuth"    = 0.0
                                "Elevation"  = -60.0
                                "Radius"     = 3.0
                            }
                        }

                        { type = builtin label = mixer name = mixL }
                        { type = builtin label = mixer name = mixR }
                    ]
                    links = [
                        # output
                        { output = "spFL:Out L"  input="mixL:In 1" }
                        { output = "spFL:Out R"  input="mixR:In 1" }
                        { output = "spFR:Out L"  input="mixL:In 2" }
                        { output = "spFR:Out R"  input="mixR:In 2" }
                        { output = "spFC:Out L"  input="mixL:In 3" }
                        { output = "spFC:Out R"  input="mixR:In 3" }
                        { output = "spRL:Out L"  input="mixL:In 4" }
                        { output = "spRL:Out R"  input="mixR:In 4" }
                        { output = "spRR:Out L"  input="mixL:In 5" }
                        { output = "spRR:Out R"  input="mixR:In 5" }
                        { output = "spSL:Out L"  input="mixL:In 6" }
                        { output = "spSL:Out R"  input="mixR:In 6" }
                        { output = "spSR:Out L"  input="mixL:In 7" }
                        { output = "spSR:Out R"  input="mixR:In 7" }
                        { output = "spLFE:Out L" input="mixL:In 8" }
                        { output = "spLFE:Out R" input="mixR:In 8" }
                    ]
                    inputs  = [ "spFL:In" "spFR:In" "spFC:In" "spLFE:In" "spRL:In" "spRR:In", "spSL:In", "spSR:In" ]
                    outputs = [ "mixL:Out" "mixR:Out" ]
                }
                capture.props = {
                    node.name      = "effect_input.spatializer"
                    media.class    = Audio/Sink
                    audio.channels = 8
                    audio.position = [ FL FR FC LFE RL RR SL SR ]
                }
                playback.props = {
                    node.name      = "effect_output.spatializer"
                    node.passive   = true
                    audio.channels = 2
                    audio.position = [ FL FR ]
                    channelmix.max-volume = 0.255
                }
            }
        }
    ]
    SPATIALIZER'
      echo ""
      echo "Virtual surround sound has been successfully set up. Reboot your system or restart PipeWire for changes to take effect. ${bold}TIP:${normal} Use Bazzite Portal > Troubleshooting > Restart PipeWire or run 'ujust restart-pipewire' in the Terminal. Select 'Virtual Headphone Surround' as the default audio device to enable surround virtualization. ${bold}This setup is incompatible with EasyEffects or JamesDSP;${normal} make sure neither is currently running."
    elif [[ "${OPTION,,}" =~ ^disable ]]; then
      if [ -f "$LEGACY_CONFIG_FILE" ]; then
        rm "$LEGACY_CONFIG_FILE"
      fi
      rm -f "$CONFIG_FILE"
      rm -f "$HRTF_FILE"
      echo "Virtual surround configuration file and HRTF removed, please reboot or restart PipeWire for changes to take effect. ${bold}TIP:${normal} Use Bazzite Portal > Troubleshooting > Restart PipeWire or run 'ujust restart-pipewire'."
    fi

# Encode all audio as Dolby Digital 5.1 (AC3) and send it over HDMI, for TVs and AV receivers that only accept stereo PCM over HDMI ARC/eARC
[group("audio")]
setup-ac3-surround ACTION="":
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    set -euo pipefail

    # Based on Basso's AC3-over-HDMI guide, which is also the place to look when troubleshooting:
    # https://gist.github.com/basso/04cbdc9cad5629f2ae83a941875c4ad5

    ASOUNDRC="${HOME}/.asoundrc"
    STATE_DIR="${HOME}/.config/ac3-surround"
    UNIT_DIR="${HOME}/.config/systemd/user"
    # Overridable so a candidate template can be tested before it ships in an image.
    TEMPLATE="${AC3_SURROUND_TEMPLATE:-/usr/share/ublue-os/ac3-surround/asoundrc}"
    # The candidate config is tested with HOME pointed at the state dir, so the user's real
    # ~/.asoundrc is only written to once the test tone has been confirmed.
    CANDIDATE="${STATE_DIR}/.asoundrc"
    SINK_NAME="TV_AC3"
    # sink_properties values cannot contain spaces, so this is the name shown in KDE/GNOME audio settings.
    SINK_DESCRIPTION="TV_Surround_5.1"
    BLOCK_BEGIN="# >>> bazzite-ac3-surround >>>"
    BLOCK_END="# <<< bazzite-ac3-surround <<<"

    state_get() {
      [[ -f "${STATE_DIR}/state" ]] || return 0
      sed -n "s/^$1=//p" "${STATE_DIR}/state" | head -n1
    }

    get_status_token() {
      if systemctl --user is-enabled --quiet ac3-surround.service 2>/dev/null &&
        grep -qF -- "${BLOCK_BEGIN}" "${ASOUNDRC}" 2>/dev/null; then
        echo "enable"
      else
        echo "disable"
      fi
    }

    # PulseAudio modules that own our ALSA device, including ones created by hand or by the older guide.
    a52_module_indexes() {
      pactl list short modules 2>/dev/null |
        grep -E "module-alsa-sink.*(sink_name=${SINK_NAME}|device=a52_safe)" |
        cut -f1
    }

    # Stop everything that may be holding the HDMI PCM: our unit, the older guide's units, and any sink they loaded.
    PREVIOUS_UNITS=()

    stop_services() {
      local unit idx
      PREVIOUS_UNITS=()
      for unit in ac3-surround.service ac3-keepalive.service ac3.service; do
        if systemctl --user is-active --quiet "${unit}" 2>/dev/null; then
          PREVIOUS_UNITS+=("${unit}")
        fi
        systemctl --user stop "${unit}" >/dev/null 2>&1 || true
      done
      while read -r idx; do
        pactl unload-module "${idx}" >/dev/null 2>&1 || true
      done < <(a52_module_indexes)
      return 0
    }

    # Bring back whatever was running before an aborted run, so aborting never leaves the TV silent.
    restore_services() {
      [[ ${#PREVIOUS_UNITS[@]} -eq 0 ]] && return 0
      systemctl --user start "${PREVIOUS_UNITS[@]}" >/dev/null 2>&1 || true
    }

    # "hw:CARD=id,DEV=n" survives card indices shuffling between reboots, but only if the card id is unambiguous.
    alsa_device_name() {
      local card="$1" id="$2" dev="$3"
      if [[ "${id}" =~ ^[A-Za-z0-9_-]+$ && "$(grep -c "\[${id} *\]" /proc/asound/cards 2>/dev/null)" -eq 1 ]]; then
        printf 'hw:CARD=%s,DEV=%s' "${id}" "${dev}"
      else
        printf 'hw:%s,%s' "${card}" "${dev}"
      fi
    }

    # Every HDMI/DisplayPort PCM in ALSA: card index, card id, device, pcm name (which includes the display's name).
    hdmi_outputs() {
      aplay -l 2>/dev/null |
        sed -n 's/^card \([0-9][0-9]*\): \([^ ]*\) \[\([^]]*\)\], device \([0-9][0-9]*\): \(.*\)$/\1\t\2\t\4\t\5/p' |
        awk -F'\t' 'tolower($4) ~ /hdmi|displayport/'
    }

    # Sets SLAVE_PCM (the ALSA device to encode into) and SLAVE_CARD (its card index, used for the PipeWire card lookup).
    choose_output() {
      local card id dev pcm_name slave choice i
      local -a menu=() slaves=() cards=()
      while IFS=$'\t' read -r card id dev pcm_name; do
        [[ -z "${card}" ]] && continue
        slave="$(alsa_device_name "${card}" "${id}" "${dev}")"
        menu+=("${pcm_name} — ${slave}")
        slaves+=("${slave}")
        cards+=("${card}")
      done < <(hdmi_outputs)

      if [[ ${#menu[@]} -eq 0 ]]; then
        echo "${yellow}No HDMI or DisplayPort audio output was found.${normal}"
        echo "Make sure the TV or AV receiver is connected and switched on."
      fi
      menu+=("Enter an ALSA device name manually" "Exit without changes")

      choice="$(ugum choose --header "Select the HDMI output connected to your TV or AV receiver" "${menu[@]}")" || return 1
      [[ -z "${choice}" || "${choice}" == "Exit without changes" ]] && return 1
      if [[ "${choice}" == "Enter an ALSA device name manually" ]]; then
        choice="$(ugum input --header "ALSA device to use (see 'aplay -l')" --placeholder "hw:1,9 or hw:CARD=HDMI,DEV=9")" || return 1
        if [[ -z "${choice}" || ! "${choice}" =~ ^[A-Za-z0-9_:,.=-]+$ ]]; then
          echo "${red}'${choice}' does not look like an ALSA device name.${normal}"
          return 1
        fi
        SLAVE_PCM="${choice}"
        SLAVE_CARD=""
        return 0
      fi
      for i in "${!slaves[@]}"; do
        if [[ "${menu[$i]}" == "${choice}" ]]; then
          SLAVE_PCM="${slaves[$i]}"
          SLAVE_CARD="${cards[$i]}"
          return 0
        fi
      done
      return 1
    }

    write_candidate() {
      mkdir -p "${STATE_DIR}"
      sed "s|@SLAVE_PCM@|${SLAVE_PCM}|" "${TEMPLATE}" > "${CANDIDATE}"
    }

    # Returns 0 when the output is confirmed (or the test was skipped), 1 when it failed,
    # and 2 when the user backed out — so callers can tell "wrong device" from "changed my mind".
    test_output() {
      local output choice
      echo ""
      echo "${bold}Next: a test tone in each of the six speakers, one after another.${normal}"
      echo "It plays at full digital volume for about 15 seconds, so turn the TV or receiver down first."
      choice="$(ugum choose --header "Test ${SLAVE_PCM}?" "Play the test tone" "Skip the test and enable anyway" "Cancel")" || return 2
      case "${choice}" in
        "Play the test tone") ;;
        "Skip the test and enable anyway") return 0 ;;
        *) return 2 ;;
      esac

      if ! output="$(HOME="${STATE_DIR}" timeout 60 speaker-test -D a52_safe -c 6 -r 48000 -t sine -l 1 2>&1)"; then
        echo "${red}The AC3 device could not be opened:${normal}"
        printf '%s\n' "${output}" | tail -n 4
        return 1
      fi
      ugum confirm "Did you hear the test tone from every speaker?"
    }

    # Copy the confirmed candidate into the real configuration, replacing the block from any earlier run.
    commit_asoundrc() {
      local tmp
      tmp="$(mktemp)"
      if [[ -f "${ASOUNDRC}" ]]; then
        awk -v b="${BLOCK_BEGIN}" -v e="${BLOCK_END}" '$0==b{s=1;next} $0==e{s=0;next} !s{print}' "${ASOUNDRC}" > "${tmp}"
      else
        touch "${tmp}"
      fi
      [[ -s "${tmp}" ]] && echo "" >> "${tmp}"
      cat "${CANDIDATE}" >> "${tmp}"
      mv "${tmp}" "${ASOUNDRC}"
    }

    # Remove our block; delete the file entirely if it contained nothing else.
    remove_asoundrc_block() {
      [[ -f "${ASOUNDRC}" ]] || return 0
      local tmp
      tmp="$(mktemp)"
      awk -v b="${BLOCK_BEGIN}" -v e="${BLOCK_END}" '$0==b{s=1;next} $0==e{s=0;next} !s{print}' "${ASOUNDRC}" > "${tmp}"
      if [[ -s "${tmp}" ]]; then
        mv "${tmp}" "${ASOUNDRC}"
      else
        rm -f "${tmp}" "${ASOUNDRC}"
      fi
    }

    # Best usable output profile for a card, for when the original one is unknown.
    card_output_profile() {
      pactl -f json list cards 2>/dev/null | jq -r --arg c "$1" '
        .[] | select(.name == $c) | .profiles
        | to_entries
        | map(select(.key != "off" and (.value.available // true) and ((.value.sinks // 0) > 0)))
        | sort_by(.value.priority) | reverse | (.[0].key // "off")' || true
    }

    # Work out which PipeWire card the unit has to keep off, so it cannot fight the encoder for the device.
    # Sets RELEASE_CARD (empty when the card should be left alone) and RELEASE_FROM (what to restore on disable).
    plan_release() {
      RELEASE_CARD=""
      RELEASE_FROM=""
      [[ -z "${SLAVE_CARD:-}" ]] && return 0
      local card current
      # Look the card up by its ALSA card index, which works even while its profile is off.
      card="$(pactl -f json list cards 2>/dev/null | jq -r --arg i "${SLAVE_CARD}" \
        '.[] | select((.properties["alsa.card"] // "") == $i) | .name' | head -n1)" || true
      [[ -z "${card}" ]] && return 0
      current="$(pactl -f json list cards 2>/dev/null | jq -r --arg c "${card}" '.[] | select(.name == $c) | .active_profile // empty')" || true
      [[ -z "${current}" ]] && return 0
      RELEASE_FROM="${current}"
      # Only a card without any non-HDMI/DP output (a GPU's audio device) can be switched off safely;
      # on cards shared with speakers, the silence stream wins the device instead.
      if [[ "${current}" == "off" ]] || pactl -f json list cards 2>/dev/null |
        jq -e --arg c "${card}" '[.[] | select(.name == $c) | .profiles | keys[]
          | select(. != "off" and ((test("hdmi|displayport"; "i")) | not))] | length == 0' >/dev/null; then
        RELEASE_CARD="${card}"
      fi
    }

    do_enable() {
      local a52_module="" candidate original_card original_profile legacy input rc
      for candidate in /usr/lib64/alsa-lib/libasound_module_pcm_a52.so /usr/lib/alsa-lib/libasound_module_pcm_a52.so; do
        [[ -e "${candidate}" ]] && a52_module="${candidate}" && break
      done
      if [[ -z "${a52_module}" ]]; then
        echo "${red}The ALSA AC3 plugin (alsa-plugins-a52) is missing from this image.${normal}"
        echo "Update Bazzite with 'ujust update' or the Bazzite Updater, then try again."
        return 1
      fi
      if [[ ! -f "${TEMPLATE}" ]]; then
        echo "${red}The AC3 configuration template '${TEMPLATE}' is missing.${normal}"
        echo "It ships in newer Bazzite images; update, or set AC3_SURROUND_TEMPLATE to a copy."
        return 1
      fi
      if ! systemctl --user cat ac3-surround.service >/dev/null 2>&1; then
        echo "${red}The 'ac3-surround.service' user unit is missing.${normal}"
        echo "It ships in newer Bazzite images; update Bazzite and try again."
        return 1
      fi
      # paplay (pulseaudio-utils) feeds the sink and speaker-test (alsa-utils) plays the test tone;
      # both come from the base image, so a missing one means the image regressed.
      for tool in paplay speaker-test; do
        if ! command -v "${tool}" >/dev/null 2>&1; then
          echo "${red}The '${tool}' command is missing from this image.${normal}"
          echo "Please report this at https://github.com/ublue-os/bazzite/issues"
          return 1
        fi
      done

      mkdir -p "${STATE_DIR}"
      echo "Stopping any existing AC3 surround setup..."
      stop_services

      while :; do
        SLAVE_PCM=""
        SLAVE_CARD=""
        if ! choose_output; then
          restore_services
          echo "No changes were made."
          return 1
        fi
        write_candidate
        rc=0
        test_output || rc=$?
        if [[ "${rc}" -eq 2 ]]; then
          restore_services
          echo "No changes were made."
          return 1
        elif [[ "${rc}" -eq 0 ]]; then
          break
        elif ! ugum confirm "Try a different HDMI output?"; then
          restore_services
          echo "No changes were made."
          return 1
        fi
      done

      # Remember what to restore, in case this is a re-run or a takeover from the older guide.
      original_card="$(state_get original_card)"
      original_profile="$(state_get original_profile)"
      plan_release
      [[ -z "${original_card}" ]] && original_card="${RELEASE_CARD}"
      [[ -z "${original_profile}" ]] && original_profile="${RELEASE_FROM}"
      # Keep the card from an earlier run when the new one cannot be identified (manual entry).
      [[ -z "${RELEASE_CARD}" ]] && RELEASE_CARD="$(state_get AC3_CARD)"

      commit_asoundrc

      # Take over from the units from the older manual guide, so they cannot fight over the device at login.
      local -a legacy_units=()
      for legacy in "${UNIT_DIR}/ac3-keepalive.service" "${UNIT_DIR}/ac3.service"; do
        if [[ -f "${legacy}" ]]; then
          systemctl --user disable "${legacy##*/}" >/dev/null 2>&1 || true
          legacy_units+=("${legacy##*/}")
          echo "Disabled the old '${legacy##*/}' unit so it does not conflict with this setup."
        fi
      done

      {
        echo "slave_pcm=${SLAVE_PCM}"
        [[ -n "${RELEASE_CARD}" ]] && echo "AC3_CARD=${RELEASE_CARD}"
        [[ -n "${original_card}" ]] && echo "original_card=${original_card}"
        [[ -n "${original_profile}" ]] && echo "original_profile=${original_profile}"
        [[ ${#legacy_units[@]} -gt 0 ]] && echo "legacy_units=${legacy_units[*]}"
      } > "${STATE_DIR}/state"

      # The unit ships with an image update, so make sure the user manager has seen it before enabling.
      systemctl --user daemon-reload
      if ! systemctl --user enable --now ac3-surround.service; then
        echo "${red}The AC3 sink could not be started.${normal}"
        echo "Run 'systemctl --user status ac3-surround.service' for details."
        return 1
      fi

      while read -r input; do
        pactl move-sink-input "${input}" "${SINK_NAME}" >/dev/null 2>&1 || true
      done < <(pactl list short sink-inputs 2>/dev/null | awk '{print $1}')

      echo ""
      echo "${bold}AC3 5.1 surround is enabled.${normal}"
      echo "- Audio sent to '${SINK_DESCRIPTION}' is encoded as Dolby Digital 5.1 at 640 kbit/s (7.1 sources are downmixed)."
      echo "- Restart apps that were already playing audio so they move to the new output."
      echo "- In Steam, set Settings > Audio > Output to 5.1 for surround in Game Mode."
      echo "- Undo at any time with 'ujust setup-ac3-surround disable'."
    }

    do_disable() {
      echo "Removing the AC3 surround setup..."
      systemctl --user disable --now ac3-surround.service >/dev/null 2>&1 || true
      while read -r idx; do
        pactl unload-module "${idx}" >/dev/null 2>&1 || true
      done < <(a52_module_indexes)

      local card profile legacy
      card="$(state_get original_card)"
      profile="$(state_get original_profile)"
      legacy="$(state_get legacy_units)"

      if [[ -n "${card}" ]]; then
        # A manual setup we took over needs the output released again, so restore its profile verbatim.
        # Otherwise put the card's best output profile back, so the TV is not left silent.
        if [[ -z "${legacy}" ]] && [[ -z "${profile}" || "${profile}" == "off" ]]; then
          profile="$(card_output_profile "${card}")"
        fi
        if [[ -n "${profile}" ]] && pactl list short cards 2>/dev/null | awk -v n="${card}" '$2 == n { found = 1 } END { exit !found }'; then
          pactl set-card-profile "${card}" "${profile}" >/dev/null 2>&1 || true
        fi
      fi

      remove_asoundrc_block
      rm -rf "${STATE_DIR}"

      if [[ -n "${legacy}" ]]; then
        local -a legacy_units=()
        read -r -a legacy_units <<< "${legacy}"
        systemctl --user enable --now "${legacy_units[@]}" >/dev/null 2>&1 || true
        echo "Re-enabled the previous setup ('${legacy_units[*]}')."
      else
        echo "Your normal HDMI output is available again."
      fi
      echo "Restart apps that were playing audio, or reboot, to return to normal output."
    }

    OPTION="{{ ACTION }}"
    if [ "$OPTION" == "help" ]; then
      echo "Usage: ujust setup-ac3-surround <option>"
      echo "  <option>: Specify the quick option to skip the prompt"
      echo "  Use 'status' to print the current portal token"
      echo "  Use 'enable' to encode all audio as Dolby Digital 5.1 (AC3) over HDMI"
      echo "  Use 'disable' to remove the AC3 sink and restore normal HDMI audio"
      echo "  Based on Basso's guide: https://gist.github.com/basso/04cbdc9cad5629f2ae83a941875c4ad5"
      exit 0
    elif [ "$OPTION" == "status" ]; then
      get_status_token
      exit 0
    elif [ "$OPTION" == "" ]; then
      echo "${bold}AC3 5.1 surround over HDMI${normal}"
      echo "Encodes all audio as Dolby Digital 5.1 and sends it to the HDMI output,"
      echo "for TVs and AV receivers that only accept stereo PCM over HDMI ARC/eARC."
      if [[ "$(get_status_token)" == "enable" ]]; then
        echo "Current status: Enabled"
      else
        echo "Current status: Disabled"
      fi
      echo ""
      OPTION=$(ugum choose "Enable AC3 5.1 Surround" "Disable AC3 5.1 Surround" "Exit without changes") || true
    fi

    if [[ "${OPTION,,}" =~ ^enable ]]; then
      do_enable
    elif [[ "${OPTION,,}" =~ ^disable ]]; then
      do_disable
    fi

# Restart PipeWire
[group("audio")]
restart-pipewire:
    echo "Restarting PipeWire..."
    systemctl --user restart pipewire.service
