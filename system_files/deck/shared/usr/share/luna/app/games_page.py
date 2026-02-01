from PyQt6.QtWidgets import QWidget, QVBoxLayout, QGridLayout, QScrollArea, QPushButton, QLabel
from PyQt6.QtCore import Qt
from app.game_tile import GameTile
from core.scanner import scan_all_games
from core.launcher import launch_game


class GamesPage(QWidget):
    def __init__(self):
        super().__init__()
        self.games = []
        layout = QVBoxLayout(self)
        layout.setContentsMargins(40, 40, 40, 40)

        # Header row: title + refresh button
        header = QWidget()
        header_layout = QVBoxLayout(header)
        title = QLabel('My Games')
        title.setObjectName('page-title')
        header_layout.addWidget(title)
        refresh_btn = QPushButton('Refresh')
        refresh_btn.setObjectName('refresh-btn')
        refresh_btn.clicked.connect(self.load_games)
        header_layout.addWidget(refresh_btn)
        layout.addWidget(header)

        # Scrollable grid area
        scroll = QScrollArea()
        scroll.setWidgetResizable(True)
        self.grid_widget = QWidget()
        self.grid_layout = QGridLayout(self.grid_widget)
        self.grid_layout.setSpacing(24)
        self.grid_layout.setContentsMargins(0, 0, 0, 0)
        scroll.setWidget(self.grid_widget)
        layout.addWidget(scroll)

        self.load_games()

    def load_games(self):
        """Scan for games and populate the grid."""
        # Clear existing tiles
        while self.grid_layout.count():
            self.grid_layout.takeAt(0).widget().deleteLater()
        self.games = scan_all_games()
        cols = 4  # 4-column grid
        for i, game in enumerate(self.games):
            tile = GameTile(game)
            tile.launch_signal.connect(lambda g=game: launch_game(g))
            self.grid_layout.addWidget(tile, i // cols, i % cols)

        if not self.games:
            label = QLabel('No games found.\nUse the Store tab to download games.')
            label.setObjectName('empty-label')
            label.setAlignment(Qt.AlignmentFlag.AlignCenter)
            self.grid_layout.addWidget(label, 0, 0, 1, cols)
