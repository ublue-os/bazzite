#!/usr/bin/env python3
"""Luna — Stellar OS Console Mode Entry Point"""

import sys
import os
from PyQt6.QtWidgets import QApplication
from app.main_window import MainWindow


def main():
    # Force fullscreen and hide cursor for console mode
    os.environ['QT_QPA_PLATFORM'] = 'wayland'

    app = QApplication(sys.argv)
    app.setStyle('Fusion')  # Clean base style before QSS override

    window = MainWindow()
    window.show()

    sys.exit(app.exec())


if __name__ == '__main__':
    main()
