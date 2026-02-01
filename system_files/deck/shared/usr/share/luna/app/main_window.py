from PyQt6.QtWidgets import QMainWindow, QWidget, QVBoxLayout, QTabWidget
from PyQt6.QtCore import Qt
from app.games_page import GamesPage
from app.store_page import StorePage
from app.styles import LUNA_STYLESHEET


class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowFlags(Qt.WindowFlag.FramelessWindowHint | Qt.WindowFlag.Window)
        self.showFullScreen()
        self.setStyleSheet(LUNA_STYLESHEET)

        # Hide mouse cursor — this is a console, use keyboard/controller
        from PyQt6.QtGui import QCursor
        self.setCursor(QCursor(Qt.CursorShape.BlankCursor))

        # Central widget with tab navigation
        central = QWidget()
        layout = QVBoxLayout(central)
        layout.setContentsMargins(0, 0, 0, 0)

        self.tabs = QTabWidget()
        self.tabs.addTab(GamesPage(), 'Games')
        self.tabs.addTab(StorePage(), 'Store')
        layout.addWidget(self.tabs)

        self.setCentralWidget(central)

    def keyPressEvent(self, event):
        # Escape quits Luna (for development; remove or gate in production)
        if event.key() == Qt.Key.Key_Escape:
            self.close()
        else:
            super().keyPressEvent(event)
