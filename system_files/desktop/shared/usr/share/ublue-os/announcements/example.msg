# This is an example file for /usr/libexec/bazzite-announcement
# Copy this file to serve as reference to a new announcement.

# The title of the message. Must be short
_msg_title="Announcement Title"

# The url to open when the button "See more" is pressed.
_btn_see_more_url="https://bazzite.gg"

# The body of the message.
{ _msg_body="$(</dev/stdin)"; } <<'EOF'
This is the body of the message.
<hr/>
<b>This is a bold text</b>
EOF
