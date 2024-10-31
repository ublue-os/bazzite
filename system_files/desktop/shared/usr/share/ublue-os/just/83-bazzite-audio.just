# vim: set ft=make :

# Add virtual audio channels/sinks named Game, Voice, Browser and Music which you can split audio to using qpwgraph, helvum, carla or other pipewire patchbays for use in OBS and other use cases
setup-virtual-channels ACTION="":
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
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
    OPTION={{ ACTION }}
    if [ "$OPTION" == "help" ]; then
      echo "Usage: ujust setup-virtual-channels <option>"
      echo "  <option>: Specify the quick option to skip the prompt"
      echo "  Use 'create' to select Create Virtual Audio Channels"
      echo "  Use 'remove' to select Remove Virtual Audio Channels"
      exit 0
    elif [ "$OPTION" == "" ]; then
      echo "${bold}Virtual Audio Channels configuration${normal}"
      OPTION=$(Choose "Create Virtual Audio Channels" "Remove Virtual Audio Channels")
    fi
    if [[ "${OPTION,,}" =~ ^create ]]; then
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
      rm ~/.config/pipewire/pipewire.conf.d/virtual-channels.conf
      echo "Virtual audio channels config removed, the channels will be removed next time you login."
    fi

# Setup a virtual 7.1 surround sink for headphones using the PipeWire Spatializer module
setup-virtual-surround ACTION="":
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    mkdir -p ~/.config/pipewire/pipewire.conf.d
    mkdir -p ~/.config/pipewire/hrtf-sofa
    OPTION={{ ACTION }}
    if [ "$OPTION" == "help" ]; then
      echo "Usage: ujust setup-virtual-surround <option>"
      echo "  <option>: Specify the quick option to skip the prompt"
      echo "  Use 'enable' to select Enable Virtual Surround"
      echo "  Use 'disable' to select Disable Virtual Surround"
      exit 0
    elif [ "$OPTION" == "" ]; then
      echo "${bold}Virtual Surround configuration${normal}"
      OPTION=$(Choose "Enable Virtual Surround" "Disable Virtual Surround")
    fi
    if [[ "${OPTION,,}" =~ ^enable ]]; then
      echo "Downloading a sample HRTF .sofa from the Sofacoustics database..."
      wget -O ~/.config/pipewire/hrtf-sofa/mit_kemar_normal_pinna.sofa https://sofacoustics.org/data/database_sofa_0.6/mit/mit_kemar_normal_pinna.sofa
      if [ -f ~/.config/pipewire/pipewire.conf.d/virtual-surround-71.conf ]; then
        mv ~/.config/pipewire/pipewire.conf.d/virtual-surround-71.conf ~/.config/pipewire/virtual-surround-71.conf.bak
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
                node.description = "Spatial Sink"
                media.name       = "Spatial Sink"
                filter.graph = {
                    nodes = [
                        {
                            type = sofa
                            label = spatializer
                            name = spFL
                            config = {
                                filename = "$HOME/.config/pipewire/hrtf-sofa/mit_kemar_normal_pinna.sofa"
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
                                filename = "$HOME/.config/pipewire/hrtf-sofa/mit_kemar_normal_pinna.sofa"
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
                                filename = "$HOME/.config/pipewire/hrtf-sofa/mit_kemar_normal_pinna.sofa"
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
                                filename = "$HOME/.config/pipewire/hrtf-sofa/mit_kemar_normal_pinna.sofa"
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
                                filename = "$HOME/.config/pipewire/hrtf-sofa/mit_kemar_normal_pinna.sofa"
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
                                filename = "$HOME/.config/pipewire/hrtf-sofa/mit_kemar_normal_pinna.sofa"
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
                                filename = "$HOME/.config/pipewire/hrtf-sofa/mit_kemar_normal_pinna.sofa"
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
                                filename = "$HOME/.config/pipewire/hrtf-sofa/mit_kemar_normal_pinna.sofa"
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
                    audio.position = [ SL SR ]
                }
            }
        }
    ]
    SPATIALIZER'
      echo ""
      echo "Virtual surround has now been set up with a sample HRTF file; either restart PipeWire or reboot for it to take effect. If not using EasyEffects, you'll need to select Spatial Sink as your default audio output for it to work."
      echo ""
      echo "${bold}IMPORTANT:${normal}"
      echo "${bold}1.${normal} See https://youtu.be/VCXQp7swp5k for a demonstration of various HRTFs to find one that best matches your anatomy. Do note that correcting your headphones' response curve beforehand with something like https://autoeq.app/ is also recommended;"
      echo "${bold}2.${normal} Once you find an HRTF that suits you, you may download it from https://sofacoustics.org/data/database_sofa_0.6/;"
      echo "${bold}3.${normal} Then, open ~/.config/pipewire/pipewire.conf.d/spatializer-7.1.conf with a text editor, and replace the paths to the sample file with the path to yours."
    elif [[ "${OPTION,,}" =~ ^disable ]]; then
      if [ -f ~/.config/pipewire/pipewire.conf.d/virtual-surround-71.conf ]; then
        rm ~/.config/pipewire/pipewire.conf.d/virtual-surround-71.conf
      fi
      rm ~/.config/pipewire/pipewire.conf.d/spatializer-7.1.conf
      rm ~/.config/pipewire/hrtf-sofa/mit_kemar_normal_pinna.sofa
      echo "Surround configuration file and sample .sofa removed, please reboot or restart PipeWire for changes to take effect."
    fi

# Restart pipewire
restart-pipewire:
    echo "Restarting pipewire..."
    systemctl --user restart pipewire.service
