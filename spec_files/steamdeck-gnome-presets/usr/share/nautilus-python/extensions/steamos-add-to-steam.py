import os
from urllib.parse import unquote
from gi.repository import Nautilus, GObject
from typing import List

class AddToSteamExtension(GObject.GObject, Nautilus.MenuProvider):
    def _add_to_steam(self, file: Nautilus.FileInfo) -> None:
        filename = unquote(file.get_uri()[7:])

        os.system("/usr/bin/steamos-add-to-steam " + filename)

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
        if file.get_uri_scheme() != "file":
            return []

        if file.is_directory():
            return []

        if not os.access(unquote(file.get_uri()[7:]), os.X_OK):
            return []

        item = Nautilus.MenuItem(
            name="SteamOS::steamos_add_to_steam",
            label="Add to Steam",
        )
        item.connect("activate", self.menu_activate_cb, file)

        return [
            item,
        ]
