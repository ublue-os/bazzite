#!/usr/bin/bash
conky -c /usr/share/conky/conky.conf &
# if CSM/Legacy show blocking message and power off
if [[ ! -d /sys/firmware/efi ]]; then
    yad --undecorated --on-top --timeout=0 --button=Shutdown:0 \
        --text="Bazzite does not support CSM/Legacy Boot. Please boot into your UEFI/BIOS settings, disable CSM/Legacy Mode, and reboot." || true
    systemctl poweroff || shutdown -h now || true
fi
block_low_memory_install(){
memory=$(sudo cat /proc/meminfo | grep 'MemTotal' | cut -d ":" -f 2 | cut -d "k" -f 1 | sed 's/ //g')
gb_memory=$(
  awk '/^MemTotal/{print $2*1024}' < /proc/meminfo |
    numfmt --to=iec --format=%0f --suffix=B
)
echo "$memory"
echo "$gb_memory"
if [[ $memory -eq 0 ]]; then
 echo "could not determine memory. Exiting."
 return 1
elif [[ $memory -lt  5000000 ]]; then
 echo "detected memory less than approx. 5GB, warning user"
else
 return 0
fi
serve_docs
   text="You need <b>at least 8GB of system memory</b>  to install Bazzite. \n\n Installation with 4GB or less memory will likely fail.\n\nDetected amount of memory: $gb_memory\n\n Please read <a href=\"http://127.0.0.1:1290/Gaming/Hardware_compatibility_for_gaming/#minimum-system-requirements\">here</a> about minimum system requirements for Bazzite."
    title="Not enough memory"
    while true; do
    yad --undecorated --on-top --timeout=0 --button=Shutdown:0  --warning --buttons-layout=center --text-align=center --title="$title" --text="$text"
     case $? in
            0)  systemctl poweroff || shutdown -h now || true
            break
            ;;
    esac
done
}
serve_docs() {
    ADDRESS=127.0.0.1
    PORT=1290
    { python -m http.server -b $ADDRESS $PORT -d /usr/share/ublue-os/docs/html; } >/dev/null 2>&1 &
    if [[ $- == *i* ]]; then
        fg >/dev/null 2>&1 || true
    fi
}
welcome_dialog() {
    _EXITLOCK=1
    _RETVAL=0
    local welcome_text="
Welcome to the Live ISO for Bazzite\\!

The Live ISO is designed for installation and troubleshooting.
It does <b>not</b> have drivers and is <b>not capable of playing games.</b>

Please <b>do not use it in benchmarks</b> as it
does not represent the installed experience."
    while [[ $_EXITLOCK -eq 1 ]]; do
        yad \
            --no-escape \
            --on-top \
            --timeout-indicator=bottom \
            --text-align=center \
            --buttons-layout=center \
            --title="Welcome" \
            --text="$welcome_text" \
            --button="Install Bazzite":10 \
            --button="Launch Bootloader Restoring tool":20 \
            --button="Close dialog":0
        _RETVAL=$?
        case $_RETVAL in
        10)
            liveinst &
            disown $!
            _EXITLOCK=0
            ;;
        20)
            /usr/bin/bootloader_restore &
            disown $!
            _EXITLOCK=0
            ;;
        0) _EXITLOCK=0 ;;
        esac
    done
    unset -v _EXITLOCK
    unset -v _RETVAL
}
nvidia_hardware_helper() {
    timeout_seconds=15
    local recommend_wrong_image="" # Initialize to prevent SC2154
    if ! gpuinfo="$(timeout $timeout_seconds lspci -nn | grep '\[03')"; then
        return 124
    fi
    image_name=$(timeout $timeout_seconds sudo podman images --format '{{ index .Names 0 }}\n' 'bazzite*')
    if [ -z "$image_name" ]; then
        return 124
    fi
    #call NVIDIA detection script
    if [[ -f "/usr/libexec/bazzite_detect_nvidia_support_status" ]]; then
        output=$("/usr/libexec/bazzite_detect_nvidia_support_status")
        ret_val=$?
        # handle exit codes
        if [ $ret_val -eq 0 ] && [ "$output" == "" ]; then
            echo "no NVIDIA GPU"
            return 0
        fi
        if [ $ret_val -eq 124 ]; then
            return 124
        fi
        support_status=$output
        echo "support status: $support_status"
        if [ "$support_status" == "legacy" ]; then
            correct_image="<b>Nvidia (GTX 9xx-10xx Series)</b>\n"
        fi
        if [ "$support_status" == "supported" ]; then
            correct_image="<b>Nvidia (RTX Series | GTX 16xx Series+)</b>"
        fi
        # parse image information
        if [[ $image_name == *-nvidia-open* ]]; then
            echo "modern nvidia desktop image detected"
            image="nvidia-desktop"
        elif [[ $image_name == *-deck-nvidia* ]]; then
            echo "modern nvidia deck image detected!"
            image="nvidia-deck"
        elif [[ $image_name == *-nvidia:* ]]; then
            echo "legacy nvidia image detected!"
            image="legacy"
        else
            echo "AMD/Intel image detected!"
            image="amd_intel"
        fi
        #user facing text
        title="Bazzite Hardware Helper"
        image_detected="Detected Bazzite version: $(echo "$image_name" |  cut -d '/' -f3)\n\n"
        qrencode -o "\$SUPPORT_QR" "https://discord.bazzite.gg"
        support="\n\n\nPlease join our <a href=\"https://discord.bazzite.gg\"><b>Discord Server</b></a> (scan the QR code) for support."
        heading_nvidia_deck="<b>STEAM GAMING MODE IN BETA ON NVIDIA HARDWARE</b>\n"
        detected_nvidia_deck="WARNING: Nvidia GPU Support in Steam Gaming mode and on HTPCs is available as a beta with known issues that <b>cannot be fixed</b> by Bazzite.\n\n"
        recommend_nvidia_deck="Unless you're a Linux driver developer, or looking for a known-broken toy to play with, we <b>strongly recommend</b> using one of our Desktop images without Steam Gaming Mode."
        heading_unsupported="<b>Unsupported Graphics Card</b>\n"
        detected_unsupported="We've detected you're using a now unsupported NVIDIA GPU.\nUnfortunately, we cannot provide good support for your hardware ourselves.\n"
        recommend_unsupported="Please read our <a href=\"http://127.0.0.1:1290/General/FAQ/#will-support-for-much-older-nvidia-graphics-cards-be-added\"><b>documentation</b></a> for more information.\n"
        heading_unknown="<b>Unknown Graphics Card</b>\n"
        detected_unknown="We could not identify your NVIDIA graphics card.\n"
        recommend_unknown="It is not recommended to install Bazzite as we cannot guarantee your hardware will work."
        heading_wrong_image="<b>WRONG IMAGE DETECTED</b>\n"
        detected_wrong_image="Your $support_status NVIDIA graphics card needs a different version of Bazzite.\n"
        recommend_wrong_image="Pick $correct_image as \"vendor of your primary GPU\" on the website to download and install the correct version instead."
        button1="I KNOW WHAT I AM DOING. Install Bazzite Anyway:0"
        button2="Power Off:1"
        heading2="More Information"
        button3="More Information:2"
        if [[ "$support_status" = "unsupported" ]]; then
            serve_docs
            heading="$heading_unsupported"
            gpu_detected="$detected_unsupported"
            recommendation="$recommend_unsupported"
        elif [[ "$support_status" = "unknown" ]]; then
            heading="$heading_unknown"
            gpu_detected="$detected_unknown"
            recommendation="$recommend_unknown"
        elif [[ "$support_status" = "legacy" ]] && [[ "$image" = "legacy" ]]; then
            echo "legacy GPU matches legacy image. Nothing to do. Exiting…"
            return 0
        elif [[ "$support_status" = "supported" ]] && [[ "$image" = "nvidia-deck"  ]]; then
            heading="$heading_nvidia_deck"
            gpu_detected="$detected_nvidia_deck"
            recommendation="$recommend_nvidia_deck"
        elif [[ "$support_status" = "supported" ]] && [[ "$image" = "nvidia-desktop" ]]; then
            echo "supported GPU matches modern desktop image. Nothing to do. Exiting…"
            return 0
        elif [[ "$support_status" = "supported" ]] && [[ "$image" != "nvidia-desktop" ]] || [[ "$image" != "nvidia-deck"  ]]; then
            heading="$heading_wrong_image"
            gpu_detected="$detected_wrong_image"
            recommendation="$recommend_wrong_image"
        elif [[ "$support_status" = "legacy" ]] && [[ "$image" != "legacy" ]]; then
            heading="$heading_wrong_image"
            gpu_detected="$detected_wrong_image"
            recommendation="$recommend_wrong_image"
        fi
        while true; do
            yad --warning --buttons-layout=center --text-align=center --title="$title" --text="$heading""$gpu_detected""$recommendation" \
                --button="$button1" \
                --button="$button2" \
                --button="$button3"
            case $? in
            0) return 0 ;;
            1)
                systemctl poweroff || shutdown -h now || true
                break
                ;;
            2) yad  --info --title="$heading2" --text="$image_detected""\nDetected Graphics Adapters:$gpuinfo""$support" --image=\$SUPPORT_QR ;;
            esac
        done
    fi
}
block_low_memory_install
efi="c12a7328-f81f-11d2-ba4b-00a0c93ec93b"
declare -A mount
while read -r device path; do
    mount["$device"]="-o bind,ro $path"
done < <(lsblk -o PATH,MOUNTPOINTS -nQ 'PARTTYPE=="'$efi'" && MOUNTPOINTS' 2> /dev/null || true)

for device in $(lsblk -o PATH -nQ 'PARTTYPE=="'$efi'" && !MOUNTPOINTS' 2> /dev/null || true); do
    mount["$device"]="-o ro -t vfat $device"
done

export mnt=$(mktemp -d)
trap "rmdir '$mnt'" EXIT

for device in "${!mount[@]}"; do
    export device
    msg=$(sudo -E unshare -m sh -c '
        mount '"${mount[$device]} '$mnt'"' 2> /dev/null || exit 0
        shopt -s nullglob nocaseglob
        for dir in "$mnt"/EFI/*; do
            [ -d "$dir" ] || continue
            base=$(basename "$dir" | tr "[:upper:]" "[:lower:]")
            [[ "$base" == "fedora" || "$base" == "boot" ]] && continue
            grub=("$dir"/grub*.efi)
            (( ! ${#grub[@]} )) && continue
            echo "The GRUB bootloader seems to be installed on $device at ${dir#$mnt}\nBazzite <a href=\"http://127.0.0.1:1290/General/Installation_Guide/troubleshoot_guide/#error-code-1\">does not support dual boot with any other Linux installation.</a> \nInstalls to this disk that attempt to reuse this EFI partition will fail.\nEither Bazzite must be installed to a different disk, or this partition or boot loader must be removed.\n\nPlease see the <a href=\"http://127.0.0.1:1290/General/Installation_Guide/troubleshoot_guide/#how-to-remove-an-orphaned-copy-of-grub\">documentation</a> for instructions.\n"
        done
    ' || true)
    [ "$msg" ] || continue
    serve_docs
    yad --image=dialog-warning --button=OK --buttons-layout=center --title="Existing Linux bootloader detected" --text="$msg"
done


nvidia_hardware_helper
result=$?
if [ $result -eq 0 ] || [ $result -eq 1 ] || [ $result -eq 124 ]; then
    echo 'launch welcome dialog'
    welcome_dialog
fi
