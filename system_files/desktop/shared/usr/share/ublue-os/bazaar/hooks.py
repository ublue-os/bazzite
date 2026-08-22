# See https://github.com/bazaar-org/bazaar/blob/main/docs/overview.md#hooks

import os, subprocess, sys

# ---

#
# CONFIG
#

def make_shellcmd_argv(cmd):
    return [
        'xdg-terminal-exec',
        '--app-id=io.github.kolunmi.Bazaar',
        '--title=Bazaar',
        '--',
        'bash',
        '--noprofile',
        '--norc',
        '-lc',
        cmd
    ]

# ---

#
# BAZAAR STATE
#

unix_timestamp      = os.getenv('BAZAAR_HOOK_INITIATED_UNIX_STAMP')
unix_timestamp_usec = os.getenv('BAZAAR_HOOK_INITIATED_UNIX_STAMP_USEC')

hook_id            = os.getenv('BAZAAR_HOOK_ID')
hook_type          = os.getenv('BAZAAR_HOOK_TYPE')
was_aborted        = os.getenv('BAZAAR_HOOK_WAS_ABORTED')
dialog_id          = os.getenv('BAZAAR_HOOK_DIALOG_ID')
dialog_response_id = os.getenv('BAZAAR_HOOK_DIALOG_RESPONSE_ID')

non_transaction_appid = os.getenv('BAZAAR_APPID')
transaction_appid     = os.getenv('BAZAAR_TS_APPID')
transaction_type      = os.getenv('BAZAAR_TS_TYPE')

stage     = os.getenv('BAZAAR_HOOK_STAGE')
stage_idx = os.getenv('BAZAAR_HOOK_STAGE_IDX')

# ---

#
# UTIL
#

temp_file = "/tmp/bazaar-hook-choice"

def pick_action(action):
    file = open(temp_file, "w")
    file.write(action)
    file.close()

def find_action():
    file = open(temp_file)
    output = file.read()
    file.close()
    return output

def brew_eval(args):
    return f'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" && {args}'

def spawn_and_detach(args):
    subprocess.Popen(args, start_new_session=True, stdout=subprocess.DEVNULL)

def make_popup_terminal_shellcmd(cmd):
    preview = cmd.replace('$', '\\$')
    preview = preview.replace('(', '\\(')
    preview = preview.replace(')', '\\)')
    new_cmd =  f'{cmd} ; '
    new_cmd +=  'echo 1>&2 ; '
    new_cmd +=  'echo "------------------" 1>&2 ; '
    new_cmd += f'echo "Command \'{preview}\' completed. Press ENTER to finish!" 1>&2 ; '
    new_cmd +=  'read'
    new_cmd = new_cmd.replace('"', '\\"')
    return f'/bin/sh -c "{new_cmd}"'

def spawn_ujust(script):
    cmd  = make_popup_terminal_shellcmd(f'ujust {script}')
    args = make_shellcmd_argv(cmd)
    spawn_and_detach(args)

def spawn_brew_ublue(cask):
    brew = brew_eval(f'brew tap ublue-os/tap && brew install --cask {cask}')
    cmd  = make_popup_terminal_shellcmd(brew)
    args = make_shellcmd_argv(cmd)
    spawn_and_detach(args)

# ---

def handle_jetbrains():

    def appid_is_jetbrains(appid):
        if appid.startswith('com.jetbrains.') or appid == 'com.google.AndroidStudio':
            return True

    match stage:
        case 'setup':
            if transaction_type == 'install' and appid_is_jetbrains(transaction_appid):
                return 'ok'
            else:
                return 'pass'

        case 'setup-dialog':
            return 'ok'

        case 'teardown-dialog':
            if dialog_response_id == 'run-ujust':
                return 'ok'
            else:
                return 'abort'

        case 'catch':
            return 'abort'

        case 'action':
            try:
                spawn_ujust('install-jetbrains-toolbox')
            except:
                pass
            return ''

        case 'teardown':
            # always prevent installation of JetBrains flatpaks
            return 'deny'

def handle_vscode():

    def appid_is_vscode(appid):
        return appid.startswith('com.visualstudio.code')

    match stage:
        case 'setup':
            if transaction_type == 'install' and appid_is_vscode(transaction_appid):
                return 'ok'
            else:
                return 'pass'

        case 'setup-dialog':
            return 'ok'

        case 'teardown-dialog':
            if dialog_response_id == 'run-brew' or dialog_response_id == 'learn-dx':
                pick_action(dialog_response_id)
                return 'ok'
            else:
                return 'abort'

        case 'catch':
            return 'abort'

        case 'action':
            try:
                action = find_action()
                if action == 'run-brew':
                    spawn_brew_ublue('visual-studio-code-linux')
                elif action == 'learn-dx':
                    spawn_and_detach(['xdg-open', 'https://dev.bazzite.gg/'])
            except:
                pass
            return ''

        case 'teardown':
            # always prevent installation of VSCode flatpak
            return 'deny'

def handle_vscodium():

    def appid_is_vscodium(appid):
        return appid.startswith('com.vscodium.codium')

    match stage:
        case 'setup':
            if transaction_type == 'install' and appid_is_vscodium(transaction_appid):
                return 'ok'
            else:
                return 'pass'

        case 'setup-dialog':
            return 'ok'

        case 'teardown-dialog':
            if dialog_response_id == 'run-brew':
                return 'ok'
            else:
                return 'abort'

        case 'catch':
            return 'abort'

        case 'action':
            try:
                spawn_brew_ublue('vscodium-linux')
            except:
                pass
            return ''

        case 'teardown':
            # always prevent installation of VSCodium flatpak
            return 'deny'

# ---

response = 'pass'
match hook_id:
    case 'jetbrains-toolbox':
        response = handle_jetbrains()
    case 'vscode':
        response = handle_vscode()
    case 'vscodium':
        response = handle_vscodium()

print(response)
sys.exit(0)
