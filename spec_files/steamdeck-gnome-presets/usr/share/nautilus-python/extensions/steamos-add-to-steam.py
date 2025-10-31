import os
from urllib.parse import unquote
from gi.repository import Nautilus, GObject
from typing import List

SUPPORTED_MIMES = (
    "application/x-desktop",
    "application/x-executable",
    "application/vnd.appimage",
    "application/x-shellscript",
    "application/x-ms-dos-executable"
)

class AddToSteamExtension(GObject.GObject, Nautilus.MenuProvider):
    def _add_to_steam(self, file: Nautilus.FileInfo) -> None:
        filename = unquote(file.get_uri()[7:])

        os.popen(f'/usr/bin/steamos-add-to-steam "{filename}"')

    def menu_activate_cb(
        self,
        menu: Nautilus.MenuItem,
        file: Nautilus.FileInfo,
    ) -> None:
        self._add_to_steam(file)

    def get_file_items(
        self,
        files: List[Nautilus.FileInfo],
    ) -> List[Nautilus.MenuItem]:
        if len(files) != 1:
            return []

        file = files[0]
        mime = file.get_mime_type()

        if file.get_uri_scheme() != "file":
            return []

        if file.is_directory():
            return []
        
        if not mime in SUPPORTED_MIMES:
            return []

        if not os.access(unquote(file.get_uri()[7:]), os.X_OK) and not mime == "application/x-ms-dos-executable":
            return []

        item = Nautilus.MenuItem(
            name="SteamOS::steamos_add_to_steam",
            label="Add to Steam",
        )
        item.connect("activate", self.menu_activate_cb, file)

        return [
            item,
        ]
