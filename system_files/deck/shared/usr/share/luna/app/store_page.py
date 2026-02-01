import subprocess
from PyQt6.QtWidgets import QWidget, QVBoxLayout, QHBoxLayout, QPushButton, QLabel
from PyQt6.QtCore import Qt
from PyQt6.QtGui import QPixmap

STORES = [
    {
        'name': 'Steam',
        'url': 'https://store.steampowered.com',
        'icon': '/usr/share/luna/assets/icons/steam.png',
        'object_name': 'store-steam',
    },
    {
        'name': 'Epic Games',
        'url': 'https://www.epicgames.com/store',
        'icon': '/usr/share/luna/assets/icons/epic.png',
        'object_name': 'store-epic',
    },
    {
        'name': 'Xbox',
        'url': 'https://www.xbox.com/en-US/games/store',
        'icon': '/usr/share/luna/assets/icons/xbox.png',
        'object_name': 'store-xbox',
    },
]


class StorePage(QWidget):
    def __init__(self):
        super().__init__()
        layout = QVBoxLayout(self)
        layout.setAlignment(Qt.AlignmentFlag.AlignCenter)
        layout.setContentsMargins(60, 60, 60, 60)
        layout.setSpacing(40)

        title = QLabel('Game Stores')
        title.setObjectName('page-title')
        layout.addWidget(title)

        for store in STORES:
            btn = QPushButton(store['name'])
            btn.setObjectName(store['object_name'])
            btn.setFixedHeight(120)
            btn.clicked.connect(lambda checked, url=store['url']: self._open_store(url))
            layout.addWidget(btn)

        hint = QLabel('Downloads will appear on the Games page automatically.')
        hint.setObjectName('store-hint')
        hint.setAlignment(Qt.AlignmentFlag.AlignCenter)
        layout.addWidget(hint)

    def _open_store(self, url: str):
        subprocess.Popen(['xdg-open', url])
