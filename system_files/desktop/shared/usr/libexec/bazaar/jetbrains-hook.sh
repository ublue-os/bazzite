#!/usr/bin/env bash


handle_setup_stage() {

    # only proceed if the user is installing something
    if [ "$BAZAAR_TS_TYPE" = install ]; then
        case "$BAZAAR_TS_APPID" in
            com\.jetbrains\.*)
                # since the appid belongs to jetbrains, we continue
                # with the hook
                echo 'ok'
                ;;
            *)
                # otherwise, skip this hook
                echo 'pass'
                ;;
        esac
    else
        echo 'pass'
    fi
    
}


handle_setup_dialog_stage() {

    # we don't need to do anything here right now, just let Bazaar
    # know we should continue setting up the dialog
    echo 'ok'
    
}


handle_teardown_dialog_stage() {

    case "$BAZAAR_HOOK_DIALOG_RESPONSE_ID" in
        goto-web)
            # if the user pressed "Download Jetbrains Toolbox",
            # continue
            echo 'ok'
            ;;
        *)
            # otherwise, let's not do anything
            echo 'abort'
            ;;
    esac
    
}


handle_catch_stage() {

    # this only happens if the `teardown-dialog` stage echoed "abort",
    # we could echo "recover" at this point to still go to the
    # `action` stage, but we have no reason to do that right now
    echo 'abort'
    
}


handle_action_stage() {

    # this is where we do the thing! it is important to use `nohup`
    # here so bazaar doesn't hang
    nohup xdg-open 'https://www.jetbrains.com/toolbox-app/'
    
}


handle_teardown_stage() {

    # Let's always prevent the user from installing Jetbrains stuff
    echo 'deny'
    
}


# Branch based on the stage
case "$BAZAAR_HOOK_STAGE" in
    setup) handle_setup_stage ;;
    setup-dialog) handle_setup_dialog_stage ;;
    teardown-dialog) handle_teardown_dialog_stage ;;
    catch) handle_catch_stage ;;
    action) handle_action_stage ;;
    teardown) handle_teardown_stage ;;
esac


# exit successfully
exit 0
