# See https://github.com/kolunmi/bazaar/blob/main/docs/overview.md#hooks

import os, subprocess, sys

# ---

#
# CONFIG
#

def kde_make_shellcmd_argv(cmd):
    return ['konsole', '-e', cmd]
def gnome_make_shellcmd_argv(cmd):
    return ['ptyxis', '-x', cmd]

# ---

#
# ENVIRONMENT SETUP
#

desktop = os.getenv('XDG_CURRENT_DESKTOP')
if desktop == 'KDE':
    make_shellcmd_argv = kde_make_shellcmd_argv
else:
    make_shellcmd_argv = gnome_make_shellcmd_argv

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

def spawn_and_detach(args):
    subprocess.Popen(args, start_new_session=True, stdout=subprocess.DEVNULL)

def make_popup_terminal_shellcmd(cmd):
    new_cmd =  f'{cmd} ; '
    new_cmd +=  'echo 1>&2 ; '
    new_cmd +=  'echo "------------------" 1>&2 ; '
    new_cmd += f'echo "Command \'{cmd}\' completed. Press ENTER to finish!" 1>&2 ; '
    new_cmd +=  'read'
    new_cmd = new_cmd.replace('"', '\\"')
    return f'/bin/sh -c "{new_cmd}"'

def spawn_ujust(id):
    cmd  = make_popup_terminal_shellcmd(f'ujust {id}')
    args = make_shellcmd_argv(cmd)
    spawn_and_detach(args)

# ---

def handle_jetbrains():

    def appid_is_jetbrains(appid):
        return appid.startswith('com.jetbrains.')

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

# ---

response = 'pass'
match hook_id:
    case 'jetbrains-toolbox':
        response = handle_jetbrains()

print(response)
sys.exit(0)
