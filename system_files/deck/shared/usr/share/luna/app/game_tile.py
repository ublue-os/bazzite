from PyQt6.QtWidgets import QWidget, QVBoxLayout, QLabel, QPushButton
from PyQt6.QtCore import Qt, pyqtSignal
from PyQt6.QtGui import QPixmap
from core.game_model import Game

PLACEHOLDER_ART = '/usr/share/luna/assets/placeholder.png'


class GameTile(QWidget):
    launch_signal = pyqtSignal()

    def __init__(self, game: Game):
        super().__init__()
        self.setObjectName('game-tile')
        self.setFocusPolicy(Qt.FocusPolicy.StrongFocus)

        layout = QVBoxLayout(self)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(8)

        # Game art
        art_label = QLabel()
        art_label.setObjectName('game-art')
        art_path = game.art_path if game.art_path else PLACEHOLDER_ART
        pixmap = QPixmap(art_path).scaled(300, 400, Qt.AspectRatioMode.KeepAspectRatio, Qt.TransformationMode.SmoothTransformation)
        art_label.setPixmap(pixmap)
        art_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        layout.addWidget(art_label)

        # Game name
        name_label = QLabel(game.name)
        name_label.setObjectName('game-name')
        name_label.setAlignment(Qt.AlignmentFlag.AlignCenter)
        name_label.setWordWrap(True)
        layout.addWidget(name_label)

        # Source badge
        badge = QLabel(game.source.value.upper())
        badge.setObjectName('source-badge')
        badge.setAlignment(Qt.AlignmentFlag.AlignCenter)
        layout.addWidget(badge)

    def keyPressEvent(self, event):
        if event.key() in (Qt.Key.Key_Return, Qt.Key.Key_Enter):
            self.launch_signal.emit()
        else:
            super().keyPressEvent(event)

    def mousePressEvent(self, event):
        if event.button() == Qt.MouseButton.LeftButton:
            self.launch_signal.emit()
