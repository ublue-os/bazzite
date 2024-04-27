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

# Setup a simple Virtual Surround 7.1 sink using the ASH Control Room 1 convolver file (you can change this yourself after setup)
setup-virtual-surround ACTION="":
    #!/usr/bin/bash
    source /usr/lib/ujust/ujust.sh
    mkdir -p ~/.config/pipewire/pipewire.conf.d
    mkdir -p ~/.config/pipewire/hrir_hesuvi
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
      echo "Downloading HeSuVi convolver profile Control Room 1 from https://github.com/ShanonPearce/ASH-Listening-Set"
      wget -O ~/.config/pipewire/hrir_hesuvi/Control_Room_1.wav https://github.com/ShanonPearce/ASH-Listening-Set/raw/main/HeSuVi/hrir/_Control_Room_1.wav
      bash -c 'cat << HESUVI > ~/.config/pipewire/pipewire.conf.d/virtual-surround-71.conf
    context.modules = [
       { name = libpipewire-module-filter-chain
           flags = [ nofail ]
           args = {
               node.description = "Virtual Surround 7.1"
               media.name       = "Virtual Surround 7.1"
               filter.graph = {
                   nodes = [
                       # Duplicate inputs
                       { type = builtin label = copy name = copyFL  }
                       { type = builtin label = copy name = copyFR  }
                       { type = builtin label = copy name = copyFC  }
                       { type = builtin label = copy name = copyRL  }
                       { type = builtin label = copy name = copyRR  }
                       { type = builtin label = copy name = copySL  }
                       { type = builtin label = copy name = copySR  }
                       { type = builtin label = copy name = copyLFE }

                       # Apply hrir - HeSuVi 14-channel WAV (not the *-.wav variants) (note: */44/* in HeSuVi are the same, but resampled to 44100)
                       # The file paths HAS to be absolute paths
                       { type = builtin label = convolver name = convFL_L config = { filename = "$HOME/.config/pipewire/hrir_hesuvi/Control_Room_1.wav" channel =  0 } }
                       { type = builtin label = convolver name = convFL_R config = { filename = "$HOME/.config/pipewire/hrir_hesuvi/Control_Room_1.wav" channel =  1 } }
                       { type = builtin label = convolver name = convSL_L config = { filename = "$HOME/.config/pipewire/hrir_hesuvi/Control_Room_1.wav" channel =  2 } }
                       { type = builtin label = convolver name = convSL_R config = { filename = "$HOME/.config/pipewire/hrir_hesuvi/Control_Room_1.wav" channel =  3 } }
                       { type = builtin label = convolver name = convRL_L config = { filename = "$HOME/.config/pipewire/hrir_hesuvi/Control_Room_1.wav" channel =  4 } }
                       { type = builtin label = convolver name = convRL_R config = { filename = "$HOME/.config/pipewire/hrir_hesuvi/Control_Room_1.wav" channel =  5 } }
                       { type = builtin label = convolver name = convFC_L config = { filename = "$HOME/.config/pipewire/hrir_hesuvi/Control_Room_1.wav" channel =  6 } }
                       { type = builtin label = convolver name = convFR_R config = { filename = "$HOME/.config/pipewire/hrir_hesuvi/Control_Room_1.wav" channel =  7 } }
                       { type = builtin label = convolver name = convFR_L config = { filename = "$HOME/.config/pipewire/hrir_hesuvi/Control_Room_1.wav" channel =  8 } }
                       { type = builtin label = convolver name = convSR_R config = { filename = "$HOME/.config/pipewire/hrir_hesuvi/Control_Room_1.wav" channel =  9 } }
                       { type = builtin label = convolver name = convSR_L config = { filename = "$HOME/.config/pipewire/hrir_hesuvi/Control_Room_1.wav" channel = 10 } }
                       { type = builtin label = convolver name = convRR_R config = { filename = "$HOME/.config/pipewire/hrir_hesuvi/Control_Room_1.wav" channel = 11 } }
                       { type = builtin label = convolver name = convRR_L config = { filename = "$HOME/.config/pipewire/hrir_hesuvi/Control_Room_1.wav" channel = 12 } }
                       { type = builtin label = convolver name = convFC_R config = { filename = "$HOME/.config/pipewire/hrir_hesuvi/Control_Room_1.wav" channel = 13 } }

                       # Treat LFE as FC
                       { type = builtin label = convolver name = convLFE_L config = { filename = "$HOME/.config/pipewire/hrir_hesuvi/Control_Room_1.wav" channel =  6 } }
                       { type = builtin label = convolver name = convLFE_R config = { filename = "$HOME/.config/pipewire/hrir_hesuvi/Control_Room_1.wav" channel = 13 } }

                       # Stereo output
                       { type = builtin label = mixer name = mixL }
                       { type = builtin label = mixer name = mixR }
                   ]
                   links = [
                       # Input
                       { output = "copyFL:Out"  input="convFL_L:In"  }
                       { output = "copyFL:Out"  input="convFL_R:In"  }
                       { output = "copySL:Out"  input="convSL_L:In"  }
                       { output = "copySL:Out"  input="convSL_R:In"  }
                       { output = "copyRL:Out"  input="convRL_L:In"  }
                       { output = "copyRL:Out"  input="convRL_R:In"  }
                       { output = "copyFC:Out"  input="convFC_L:In"  }
                       { output = "copyFR:Out"  input="convFR_R:In"  }
                       { output = "copyFR:Out"  input="convFR_L:In"  }
                       { output = "copySR:Out"  input="convSR_R:In"  }
                       { output = "copySR:Out"  input="convSR_L:In"  }
                       { output = "copyRR:Out"  input="convRR_R:In"  }
                       { output = "copyRR:Out"  input="convRR_L:In"  }
                       { output = "copyFC:Out"  input="convFC_R:In"  }
                       { output = "copyLFE:Out" input="convLFE_L:In" }
                       { output = "copyLFE:Out" input="convLFE_R:In" }

                       # Output
                       { output = "convFL_L:Out"  input="mixL:In 1" }
                       { output = "convFL_R:Out"  input="mixR:In 1" }
                       { output = "convSL_L:Out"  input="mixL:In 2" }
                       { output = "convSL_R:Out"  input="mixR:In 2" }
                       { output = "convRL_L:Out"  input="mixL:In 3" }
                       { output = "convRL_R:Out"  input="mixR:In 3" }
                       { output = "convFC_L:Out"  input="mixL:In 4" }
                       { output = "convFC_R:Out"  input="mixR:In 4" }
                       { output = "convFR_R:Out"  input="mixR:In 5" }
                       { output = "convFR_L:Out"  input="mixL:In 5" }
                       { output = "convSR_R:Out"  input="mixR:In 6" }
                       { output = "convSR_L:Out"  input="mixL:In 6" }
                       { output = "convRR_R:Out"  input="mixR:In 7" }
                       { output = "convRR_L:Out"  input="mixL:In 7" }
                       { output = "convLFE_R:Out" input="mixR:In 8" }
                       { output = "convLFE_L:Out" input="mixL:In 8" }
                   ]
                   inputs  = [ "copyFL:In" "copyFR:In" "copyFC:In" "copyLFE:In" "copyRL:In" "copyRR:In", "copySL:In", "copySR:In" ]
                   outputs = [ "mixL:Out" "mixR:Out" ]
               }
               capture.props = {
                   node.name      = "effect_input.virtual-surround-7.1-hesuvi"
                   media.class    = Audio/Sink
                   audio.channels = 8
                   audio.position = [ FL FR FC LFE RL RR SL SR ]
               }
               playback.props = {
                   node.name      = "effect_output.virtual-surround-7.1-hesuvi"
                   node.passive   = true
                   audio.channels = 2
                   audio.position = [ FL FR ]
               }
           }
       }
    ]
    HESUVI'
      echo "Virtual Surround 7.1 has now been set up with a basic convolver file, either restart pipewire or reboot for it to take effect."
      echo "Then select the Virtual Surround 7.1 audio output as your default audio output."
      echo "If you want something like DTS, Atmos or OpenAL, you will have to acquire those convolver wav files yourself and edit ~/.config/pipewire/pipewire.conf.d/virtual-surround-71.conf to point to the one you want to use."
    elif [[ "${OPTION,,}" =~ ^disable ]]; then
      rm ~/.config/pipewire/pipewire.conf.d/virtual-surround-71.conf
      rm ~/.config/pipewire/hrir_hesuvi/Control_Room_1.wav
      echo "Virtual Surround 7.1 removed, please reboot or restart pipewire for it to take effect." 
    fi

# Restart pipewire
restart-pipewire:
    echo "Restarting pipewire..."
    systemctl --user restart pipewire.service
