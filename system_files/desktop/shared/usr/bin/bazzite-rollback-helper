#!/bin/bash

if [[ $UID -eq 0 ]]; then
  echo "This script must not run as root" >&2
  exit 1
fi

# Source ujust library for colors and gum functionality
source /usr/lib/ujust/ujust.sh

image="$(echo "$2" | cut -d ':' -f1)"
branch="$(echo "$2" | cut -d ':' -f2)"

IMAGE_INFO="/usr/share/ublue-os/image-info.json"
DEFAULT_IMAGE=$(jq -r '."image-name"' < $IMAGE_INFO)
DEFAULT_BRANCH=stable

# Cache skopeo output if possible
# shellcheck disable=SC1090
[[ $- != *i* ]] && source <(/home/linuxbrew/.linuxbrew/bin/brew shellenv)
if command -v >/dev/null 2>&1 bkt; then
    skopeo() { bkt --ttl=30m --stale=5m -- command skopeo "$@"; }
else
    nohup brew install bkt > /dev/null 2>&1 &
fi


helptext=$(cat << EOF

====== Bazzite Rollback Helper Util ======

This tool aims to help with rollbacks and rebases

NOTE: Rebasing to different desktop environments usually breaks things and is unsupported

Usage: bazzite-rollback-helper [OPTION] [ARGUMENT]

Options:
  list [BRANCH]      List available Bazzite images, Default is "$DEFAULT_BRANCH"
  rollback           Rolls back to previously installed Bazzite image. alias for "rpm-ostree rollback"
  current            Show currently active Bazzite image
  rebase             Rebase/rollback to specified Bazzite image, Default is $DEFAULT_IMAGE:$DEFAULT_BRANCH

Examples:
  bazzite-rollback-helper list stable
  bazzite-rollback-helper rollback
  bazzite-rollback-helper current
  bazzite-rollback-helper rebase 40-stable-20240722
  bazzite-rollback-helper rebase bazzite-deck:40-stable-20240722
  bazzite-rollback-helper rebase bazzite-deck:stable
  bazzite-rollback-helper rebase stable
  bazzite-rollback-helper rebase testing

For more help, visit https://discord.bazzite.gg.

EOF
)


function list_images() {
  local _help="\
List images with a specified tag

INPUTS:
  \$1: branch   Branch we want to get tags from.
                Use 'all' to show all available tags.
                Fallbacks to \"$DEFAULT_BRANCH\"
"
  if [[ $* =~ --help ]]; then
    echo "$_help" && return
  fi
  local branch=${1:-$DEFAULT_BRANCH}
  
  if [[ "$branch" == "all" ]]; then
    echo -e >&2 "Listing all available images\nThis can take a bit of time..."
    skopeo list-tags docker://ghcr.io/ublue-os/bazzite | jq -r '.Tags[]' | sort
  else
    local regex='.Tags[]'
    regex="$regex"\ ' | select(test("^PLACEHOLDER|^PLACEHOLDER-(?:\\d+\\.\\d+|\\d+)"))'
    regex=${regex//PLACEHOLDER/$branch}
    echo -e >&2 "Listing images for $branch\nThis can take a bit of time..."
    skopeo list-tags docker://ghcr.io/ublue-os/bazzite | jq -r "$regex"
  fi
}

# Function to get available Bazzite image variants
get_bazzite_variants() {
  local provider=${1:-ublue-os}
  
  # Official Bazzite image variants based on README.md
  local variants=(
    "bazzite"
    "bazzite-deck"
    "bazzite-nvidia" 
    "bazzite-deck-nvidia"
    "bazzite-dx"
    "bazzite-gdx"
  )
  
  echo -e >&2 "Checking available variants from $provider..."
  
  # Verify which variants actually exist by checking if they have tags
  for variant in "${variants[@]}"; do
    if skopeo list-tags "docker://ghcr.io/$provider/$variant" >/dev/null 2>&1; then
      echo "$variant"
    fi
  done
}

# Function for interactive image selection
interactive_image_selection() {
  local provider=${1:-ublue-os}
  
  # Clear screen for clean interface
  clear
  
  echo
  echo "${bold}Available Bazzite Images from ${green}$provider${normal}:"
  echo
  
  # Get available image variants
  local image_variants=$(get_bazzite_variants "$provider")
  
  if [ -z "$image_variants" ]; then
    echo "${red}No Bazzite variants found for provider: $provider${normal}"
    echo "This provider may not host Bazzite images."
    return 1
  fi
  
  # Convert to array for gum choose
  local options=()
  while IFS= read -r line; do
    if [[ -n "$line" ]]; then
      options+=("$line")
    fi
  done <<< "$image_variants"
  
  # Add special options
  options+=("Back to Main Menu")
  
  echo "Choose an image to see available versions:"
  local OPTION=$(Choose "${options[@]}")
  
  case "$OPTION" in
    "Back to Main Menu")
      if [[ "$provider" == "ublue-os" ]]; then
        interactive_menu
      else
        custom_provider_menu "$provider"
      fi
      ;;
    *)
      if [[ -n "$OPTION" ]]; then
        echo
        echo "${bold}Available versions for ${green}$OPTION${normal}:"
        echo
        echo "Choose how to list versions:"
        local list_option=$(Choose "List Stable Versions" "List Testing Versions" "List All Versions" "Back to Image List")
        
        case "$list_option" in
          "List Stable Versions")
            clear
            echo "${bold}Stable versions for ${green}$OPTION${normal}:"
            echo
            local regex='.Tags[] | select(test("^stable"))'
            skopeo list-tags "docker://ghcr.io/$provider/$OPTION" | jq -r "$regex" | sort
            ;;
          "List Testing Versions")  
            clear
            echo "${bold}Testing versions for ${green}$OPTION${normal}:"
            echo
            local regex='.Tags[] | select(test("^testing"))'
            skopeo list-tags "docker://ghcr.io/$provider/$OPTION" | jq -r "$regex" | sort
            ;;
          "List All Versions")
            clear
            echo "${bold}All versions for ${green}$OPTION${normal}:"
            echo
            skopeo list-tags "docker://ghcr.io/$provider/$OPTION" | jq -r '.Tags[]' | sort
            ;;
          "Back to Image List")
            interactive_image_selection "$provider"
            return
            ;;
        esac
        
        echo
        echo "Press Enter to continue..."
        read -r
        interactive_image_selection "$provider"
      fi
      ;;
  esac
}

function current() {
  local _help="\
Show currently active Bazzite image"
  if [[ $* =~ --help ]]; then
    echo "$_help" && return
  fi

  rpm-ostree status -vb
}

function rollback() {
  local _help="Rolls back to previously installed Bazzite image. alias for \"rpm-ostree rollback\""
  if [[ $* =~ --help ]]; then
    echo "$_help" && return
  fi

  rpm-ostree rollback && \
    echo >&2 "Reboot for changes to take effect"
}

function rebase() {
  local _help="\
Rebase/rollback to specified Bazzite image, Default is $DEFAULT_IMAGE:$DEFAULT_BRANCH

INPUTS:
  \$1: branch   Branch we want to rebase. Format must be 
                one of the following:
                  - ostree-image (ex.: 'ostree-image-signed:docker://ghcr.io/ublue-os/bazzite:stable')
                  - NAME:TAG (ex.: 'bazzite:stable-40')
                  - TAG (ex.: 'testing')
                Fallbacks to \"$DEFAULT_BRANCH\"\
"
  if [[ $* =~ --help ]]; then
  local _help
    echo "$_help" && return
  fi

  # Skip asking for confirmation by passing the '-y' flag
  local CONFIRM_YES
  CONFIRM_YES=$(
    while (( $# )); do
      case "$1" in
        -y|--yes) echo 1; return ;;
      esac
      shift
    done
    echo 0
  )

  # Fetch our image reference prefix (ex.: ostree-image-signed:docker://ghcr.io/ublue-os)
  # from rpm-ostree
  local base_img_pfx
  base_img_pfx=$(rpm-ostree status -b --json | jq -r '.deployments[]["container-image-reference"]')
  base_img_pfx=${base_img_pfx///${DEFAULT_IMAGE}*/}

  local img_ref # Final image ref string to rebase
  local usr_inpt="$1"
  case "$usr_inpt" in
  "") echo >&2 "$_help"; return ;;
  ostree-image-*)
    # ostree-image
    # echo >&2 "Format detected"
    img_ref=$usr_inpt
  ;;
  *:*)
    # IMG_NAME:TAG
    # echo >&2 "Format detected: IMG_NAME:TAG"
    img_ref="$base_img_pfx"/"$usr_inpt"
  ;;
  *)
    # TAG
    # echo >&2 "Format detected: TAG"
    img_ref="$base_img_pfx"/"$DEFAULT_IMAGE":"$usr_inpt"
  ;;
  esac

  # Ask for confirmation. If is okay, rebase.
  local question="\
Rebasing to $img_ref. Continue? [Y/n]: "
  local yn
  if [[ $CONFIRM_YES -ne 1 ]]; then
    read -rp "$question" yn
    yn=${yn:=y} # Default to yes
  else yn=y
  fi
  case $yn in
    # Finally, rebase
    [yY]) rpm-ostree rebase "$img_ref" || return 1 ;;
    *) echo >&2 "Stopping rebase..."; return 1 ;;
  esac
}

# Function for guided rebase selection
guided_rebase_selection() {
  local provider=${1:-ublue-os}
  local from_custom=${2:-false}
  
  clear
  echo "${bold}Select Image for Rebase - Provider: ${green}$provider${normal}"
  echo
  
  # Get available image variants
  local image_variants=$(get_bazzite_variants "$provider")
  
  if [ -z "$image_variants" ]; then
    echo "${red}No Bazzite variants found for provider: $provider${normal}"
    echo "This provider may not host Bazzite images."
    echo
    echo "Press Enter to continue..."
    read -r
    if [[ "$from_custom" == "true" ]]; then
      custom_provider_menu "$provider"
    else
      interactive_menu
    fi
    return 1
  fi
  
  # Convert to array for gum choose
  local options=()
  while IFS= read -r line; do
    if [[ -n "$line" ]]; then
      options+=("$line")
    fi
  done <<< "$image_variants"
  
  # Add back option
  options+=("Back to Previous Menu")
  
  echo "Choose an image variant:"
  local OPTION=$(Choose "${options[@]}")
  
  case "$OPTION" in
    "Back to Previous Menu")
      if [[ "$from_custom" == "true" ]]; then
        custom_provider_menu "$provider"
      else
        interactive_menu
      fi
      ;;
    *)
      if [[ -n "$OPTION" ]]; then
        guided_version_selection "$provider" "$OPTION" "$from_custom"
      fi
      ;;
  esac
}

# Function for guided version selection
guided_version_selection() {
  local provider="$1"
  local image_name="$2"
  local from_custom="$3"
  
  clear
  echo "${bold}Select Version for ${green}$image_name${normal} - Provider: ${green}$provider${normal}"
  echo
  
  echo "Choose version type:"
  local version_type=$(Choose "Stable Versions" "Testing Versions" "All Versions" "Back to Image Selection")
  
  case "$version_type" in
    "Back to Image Selection")
      guided_rebase_selection "$provider" "$from_custom"
      ;;
    "Stable Versions")
      show_version_menu "$provider" "$image_name" "stable" "$from_custom"
      ;;
    "Testing Versions")
      show_version_menu "$provider" "$image_name" "testing" "$from_custom"
      ;;
    "All Versions")
      show_version_menu "$provider" "$image_name" "all" "$from_custom"
      ;;
  esac
}

# Function to show version menu and handle selection
show_version_menu() {
  local provider="$1"
  local image_name="$2"
  local version_type="$3"
  local from_custom="$4"
  
  clear
  echo "${bold}${version_type^} versions for ${green}$image_name${normal}:"
  echo
  
  # Get versions based on type
  local versions=()
  case "$version_type" in
    "stable")
      local regex='.Tags[] | select(test("^stable"))'
      ;;
    "testing")
      local regex='.Tags[] | select(test("^testing"))'
      ;;
    "all")
      local regex='.Tags[]'
      ;;
  esac
  
  # Get the versions and convert to array
  local version_list=$(skopeo list-tags "docker://ghcr.io/$provider/$image_name" | jq -r "$regex" | sort)
  
  if [ -z "$version_list" ]; then
    echo "${red}No $version_type versions found for $image_name${normal}"
    echo
    echo "Press Enter to continue..."
    read -r
    guided_version_selection "$provider" "$image_name" "$from_custom"
    return
  fi
  
  local options=()
  while IFS= read -r line; do
    if [[ -n "$line" ]]; then
      options+=("$line")
    fi
  done <<< "$version_list"
  
  # Add navigation options
  options+=("Back to Version Type Selection")
  
  echo "Choose a version to rebase to:"
  local OPTION=$(Choose "${options[@]}")
  
  case "$OPTION" in
    "Back to Version Type Selection")
      guided_version_selection "$provider" "$image_name" "$from_custom"
      ;;
    *)
      if [[ -n "$OPTION" ]]; then
        # Perform the rebase
        perform_rebase "$provider" "$image_name" "$OPTION" "$from_custom"
      fi
      ;;
  esac
}

# Function to perform the actual rebase
perform_rebase() {
  local provider="$1"
  local image_name="$2"
  local version="$3"
  local from_custom="$4"
  
  clear
  echo "${bold}Confirm Rebase${normal}"
  echo
  
  # Get current image prefix but replace the provider if needed
  local current_prefix=$(rpm-ostree status -b --json | jq -r '.deployments[]["container-image-reference"]')
  local signing_scheme
  if [[ "$current_prefix" == *"ostree-image-signed"* ]]; then
    signing_scheme="ostree-image-signed:docker://ghcr.io"
  else
    signing_scheme="ostree-unverified-registry:docker://ghcr.io"
  fi
  
  local target_ref="$signing_scheme/$provider/$image_name:$version"
  
  echo "Rebasing to: ${bold}$target_ref${normal}"
  echo
  echo "Are you sure? ${yellow}(y/N)${normal}"
  read -r confirm
  
  if [[ "${confirm,,}" =~ ^y ]]; then
    echo
    echo "Performing rebase..."
    if rpm-ostree rebase "$target_ref"; then
      echo
      echo "${green}Rebase successful!${normal}"
      echo "Reboot for changes to take effect."
    else
      echo
      echo "${red}Failed to rebase.${normal} The image may not exist or be accessible."
    fi
  else
    echo "Rebase cancelled."
  fi
  
  echo
  echo "Press Enter to continue..."
  read -r
  
  if [[ "$from_custom" == "true" ]]; then
    custom_provider_menu "$provider"
  else
    interactive_menu
  fi
}
show_current_status() {
  echo "${bold}Current System Status:${normal}"
  echo
  local current_deployment=$(rpm-ostree status --json | jq -r '.deployments[] | select(.booted == true) | .["container-image-reference"]')
  if [ -n "$current_deployment" ]; then
    echo "  ${bold}Active Image:${normal} ${green}$current_deployment${normal}"
  fi
  
  local pending_deployment=$(rpm-ostree status --json | jq -r '.deployments[] | select(.booted != true) | .["container-image-reference"]' | head -1)
  if [ -n "$pending_deployment" ] && [ "$pending_deployment" != "null" ]; then
    echo "  ${bold}Pending Image:${normal} ${yellow}$pending_deployment${normal} ${yellow}(will boot next)${normal}"
  fi
  echo
}

# Function to handle custom provider rebase
custom_provider_menu() {
  local provider="$1"
  
  # Clear screen for clean interface
  clear
  
  echo
  echo "${bold}Custom Provider: ${green}$provider${normal}"
  echo
  echo "${bold}Choose an action:${normal}"
  local OPTION=$(Choose "List Available Images" "Select from List for Rebase" "Manual Rebase Entry" "Back to Main Menu")
  
  case "$OPTION" in
    "List Available Images")
      interactive_image_selection "$provider"
      ;;
    "Select from List for Rebase")
      guided_rebase_selection "$provider" "true"
      ;;
    "Manual Rebase Entry")
      clear
      echo "${bold}Manual Rebase Entry - Provider: ${green}$provider${normal}"
      echo
      echo "Enter the image:tag to rebase to:"
      echo "Examples:"
      echo "  - ${bold}bazzite:stable${normal}"
      echo "  - ${bold}bazzite-deck:testing${normal}"
      echo "  - ${bold}bazzite-deck:40-stable-20240722${normal}"
      echo
      echo "Enter image:tag (or press Enter to cancel):"
      read -r image_tag
      if [ -n "$image_tag" ]; then
        # Get current image prefix but replace the provider
        local current_prefix=$(rpm-ostree status -b --json | jq -r '.deployments[]["container-image-reference"]')
        local signing_scheme
        if [[ "$current_prefix" == *"ostree-image-signed"* ]]; then
          signing_scheme="ostree-image-signed:docker://ghcr.io"
        else
          signing_scheme="ostree-unverified-registry:docker://ghcr.io"
        fi
        
        local custom_ref="$signing_scheme/$provider/$image_tag"
        echo
        echo "Rebasing to: ${bold}$custom_ref${normal}"
        echo "Are you sure? ${yellow}(y/N)${normal}"
        read -r confirm
        if [[ "${confirm,,}" =~ ^y ]]; then
          rpm-ostree rebase "$custom_ref" || echo "Failed to rebase. The image may not exist or be accessible."
        else
          echo "Rebase cancelled."
        fi
      else
        echo "Rebase cancelled."
      fi
      echo
      echo "Press Enter to continue..."
      read -r
      custom_provider_menu "$provider"
      ;;
    "Back to Main Menu")
      interactive_menu
      ;;
    *)
      echo "Invalid option selected."
      custom_provider_menu "$provider"
      ;;
  esac
}

# Interactive menu function
interactive_menu() {
  # Clear screen for clean interface
  clear
  
  # Show help text and current status
  echo "$helptext"
  show_current_status
  
  echo "${bold}Choose an action:${normal}"
  local OPTION=$(Choose "List Images" "Show Current Image" "Rollback" "Rebase" "Custom Image Provider" "Exit")
  
  case "$OPTION" in
    "List Images")
      interactive_image_selection "ublue-os"
      ;;
    "Show Current Image")
      clear
      echo "${bold}Current System Information:${normal}"
      echo
      current
      echo
      echo "Press Enter to continue..."
      read -r
      interactive_menu
      ;;
    "Rollback")
      clear
      echo "${bold}Rollback to Previous Image${normal}"
      echo
      echo "Are you sure you want to rollback to the previous image? ${yellow}(y/N)${normal}"
      read -r confirm
      if [[ "${confirm,,}" =~ ^y ]]; then
        rollback
      else
        echo "Rollback cancelled."
      fi
      echo
      echo "Press Enter to continue..."
      read -r
      interactive_menu
      ;;
    "Rebase")
      clear
      echo "${bold}Rebase to Different Image${normal}"
      echo
      echo "Choose rebase method:"
      local rebase_method=$(Choose "Select from List" "Manual Entry" "Back to Main Menu")
      
      case "$rebase_method" in
        "Select from List")
          guided_rebase_selection "ublue-os" "false"
          ;;
        "Manual Entry")
          clear
          echo "${bold}Manual Rebase Entry${normal}"
          echo
          echo "Enter the image/tag to rebase to:"
          echo "Examples:"
          echo "  - ${bold}stable${normal} (rebase to stable branch)"
          echo "  - ${bold}testing${normal} (rebase to testing branch)"
          echo "  - ${bold}bazzite-deck:stable${normal} (specific image and tag)"
          echo "  - ${bold}40-stable-20240722${normal} (specific tag)"
          echo
          echo "Enter rebase target (or press Enter to cancel):"
          read -r rebase_input
          if [ -n "$rebase_input" ]; then
            rebase "$rebase_input" -y
          else
            echo "Rebase cancelled."
          fi
          echo
          echo "Press Enter to continue..."
          read -r
          interactive_menu
          ;;
        "Back to Main Menu")
          interactive_menu
          ;;
      esac
      ;;
    "Custom Image Provider")
      clear
      echo "${bold}Custom Image Provider${normal}"
      echo
      echo "Enter the custom provider/organization name:"
      echo "  - Default: ${bold}ublue-os${normal}"
      echo "  - Examples: ${bold}my-org${normal}, ${bold}custom-builder${normal}, ${bold}fork-maintainer${normal}"
      echo
      echo "Enter provider name (or press Enter for 'ublue-os'):"
      read -r provider_input
      provider_input=${provider_input:-ublue-os}
      # Convert to lowercase for ghcr.io compatibility
      provider_input=$(echo "$provider_input" | tr '[:upper:]' '[:lower:]')
      
      echo
      echo "Using provider: ${bold}$provider_input${normal}"
      custom_provider_menu "$provider_input"
      ;;
    "Exit")
      echo "Exiting..."
      exit 0
      ;;
    *)
      echo "Invalid option selected."
      interactive_menu
      ;;
  esac
}

if [[ "$1" == "list" ]]; then
  list_images "${@:2}"
  exit

elif [[ "$1" == "rollback" ]]; then
  rollback "${@:2}"
  exit

elif [[ "$1" == "current" ]]; then
  current "${@:2}"
  exit

elif [[ "$1" == "rebase" ]]; then
  rebase "${@:2}"
  exit

# display the helptext and start interactive mode
elif [[ "$1" == "-h" || "$1" == "--h" || "$1" == "-help" || "$1" == "--help" || "$1" == "help" || -z "$1" ]]; then
 interactive_menu
else
 echo "Unsupported Option: $1"
 echo "run 'bazzite-rollback-helper help' for more details"
fi
