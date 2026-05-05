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
      wget -O "$HRTF_FILE" https://github.com/ValveSoftware/steam-audio/raw/master/core/data/hrtf/sadie_d1.sofa
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

# Restart PipeWire
[group("audio")]
restart-pipewire:
    echo "Restarting PipeWire..."
    systemctl --user restart pipewire.service
