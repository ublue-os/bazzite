LUNA_STYLESHEET = """
/* ─── Base ─── */
QWidget {
    background-color: #0f172a;
    color: #e2e8f0;
    font-family: 'Segoe UI', 'Noto Sans', Arial, sans-serif;
}

/* ─── Tab Bar ─── */
QTabBar::tab {
    background: #1e293b;
    color: #94a3b8;
    padding: 18px 48px;
    font-size: 20px;
    font-weight: bold;
    border: none;
    border-bottom: 3px solid transparent;
}
QTabBar::tab:selected {
    color: #ffffff;
    border-bottom-color: #3b82f6;
}
QTabBar::tab:hover:!selected {
    color: #cbd5e1;
}
QTabWidget::pane {
    border: none;
    background: #0f172a;
}

/* ─── Page Titles ─── */
QLabel#page-title {
    font-size: 32px;
    font-weight: bold;
    color: #f1f5f9;
    margin-bottom: 20px;
}

/* ─── Game Tiles ─── */
QWidget#game-tile {
    background: #1e293b;
    border: 2px solid #334155;
    border-radius: 8px;
    padding: 12px;
}
QWidget#game-tile:focus {
    border-color: #3b82f6;
    background: #1e3a5f;
}
QLabel#game-art {
    background: #0f172a;
    border-radius: 4px;
}
QLabel#game-name {
    font-size: 16px;
    color: #e2e8f0;
}
QLabel#source-badge {
    font-size: 11px;
    color: #64748b;
    text-transform: uppercase;
}

/* ─── Store Buttons ─── */
QPushButton#store-steam,
QPushButton#store-epic,
QPushButton#store-xbox {
    background: #1e293b;
    color: #e2e8f0;
    font-size: 26px;
    font-weight: bold;
    border: 2px solid #334155;
    border-radius: 8px;
}
QPushButton#store-steam:hover,
QPushButton#store-epic:hover,
QPushButton#store-xbox:hover {
    background: #1e3a5f;
    border-color: #3b82f6;
}
QPushButton#store-steam:focus,
QPushButton#store-epic:focus,
QPushButton#store-xbox:focus {
    border-color: #3b82f6;
}

/* ─── Buttons ─── */
QPushButton#refresh-btn {
    background: #334155;
    color: #cbd5e1;
    border: none;
    border-radius: 4px;
    padding: 8px 20px;
    font-size: 14px;
}
QPushButton#refresh-btn:hover {
    background: #475569;
}

/* ─── Hints & Empty States ─── */
QLabel#store-hint, QLabel#empty-label {
    color: #64748b;
    font-size: 16px;
}

/* ─── Scroll Bars ─── */
QScrollBar:vertical {
    background: #0f172a;
    width: 10px;
}
QScrollBar::handle:vertical {
    background: #334155;
    border-radius: 5px;
}
QScrollBar::add-line:vertical, QScrollBar::sub-line:vertical {
    height: 0px;
}
"""
