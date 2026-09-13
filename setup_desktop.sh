#!/bin/bash
# Valkyrie AI - Desktop Icon Setup Script
# This script creates a desktop launcher icon for Valkyrie AI

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_PATH="$SCRIPT_DIR/venv"
PYTHON_PATH="$VENV_PATH/bin/python"

# Create the launcher script
cat > "$SCRIPT_DIR/valkyrie-launcher.sh" << 'LAUNCHER_EOF'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_PATH="$SCRIPT_DIR/venv"

# Activate virtual environment
source "$VENV_PATH/bin/activate"

# Start the Flask app in background
cd "$SCRIPT_DIR"
python app/main.py > /tmp/valkyrie.log 2>&1 &
APP_PID=$!

# Wait a moment for server to start
sleep 3

# Open browser
xdg-open http://localhost:5000 2>/dev/null || firefox http://localhost:5000 &

# Keep script running
wait $APP_PID
LAUNCHER_EOF

chmod +x "$SCRIPT_DIR/valkyrie-launcher.sh"

# Create desktop icon (for GNOME/KDE/Xfce)
mkdir -p ~/.local/share/applications
mkdir -p ~/.local/share/icons

# Download or create Viking logo (base64 encoded icon)
cat > ~/.local/share/icons/valkyrie-ai.png << 'ICON_EOF'
iVBORw0KGgoAAAANSUhEUgAAAIIAAABkCAYAAABV9JqxAAAACXBIWXMAAAsTAAALEwEAmpwYAAADZElEQVR4nO2dwW7bMAxG83s/bm4wGKgFOgyDbMuW5EgJ7SVLcgUu67btjuwMGFAgs2Qtzw5SQIJSKHF8T9Id5gn7u0ByZP8nmWVE5sICBEEQBEEQBEEQBEEQhH8ABSVnIWRJyUzIS0pWlLyi5JiSMyUpJUtKOkp2lLzOc1zn+QvWfzYsb5n/zPKWEryG+c95jiV5zmV5yWV+WV7yPL/Iq+H6rspzLBtfAQz6vgJY9HzfVwCL5Xlet9ttWZblfr+XZVn+9/tdy+VyUS3L0nRdV7Ztq5Zlabqu67Z37nrP5/NVu91W3W5XlWVZXa/XqtvtVrVbLVXXdXU4HJRlWWpZlnqz2ajBYKCGwyHVajUVx7G6Xq+qRqNRnWYzGgzUdDpVzWZTVa1WUz6fT/X7fRXHcVUqlaq4rutUvV5XQRDkw2QyUVEUqSAI8gEoqtGo3W6rWq2WH4fDQR0OBxXHsQrDUAVBoG63Wyg63W6Xcrmcn4e06xOLxUIuJ5a3TFFRpNLpdHGpxPG7OwLZJZLJZKrdbqlWq6XK5bK6Xq/qdDrlejyRz+dVp9NRQRDk3TzPq2azmSvzDMblcjG3JZLJZKrVVBRFKoqiqFar6fF4VFEUxcJ3u1213W6LqVSr1VShUNBXV1fq9XopR+MiRVFsY3mbFBWLRZ1Go6p0Oh0L32h00IlEDpNPLGeT4pPP51W9XtfNZlPVajXjrGp9u91ScRyb2xLJZDLVYDCot9ttVSwWjbOKVRzH/GK3Mb9HKBaLdbt9w7+rq6u66u1yOT4/P5vbEslkMtXj8ajT6XRu+U/f/1w6HQ419h0j6ItL/V3VajXl8/mMlHVcLkgKjUZDPT4+KqfTqbvdrgqCwL3BhFw8nU7zYTQaFSpyuVxVGIa62+1yx/n8/Hyh5FZFvV5Xj4+Plslk8tQvAZDiQeOSEsXcJK/iweOSEu7V0Hj8VnkV8cREEQBEEQBEEQBEEQBEEQBEEQBEEQBEH4s/kDyTjmP9gY+LoAAAAASUVORK5CYII=
ICON_EOF

# Create desktop entry file
cat > ~/.local/share/applications/valkyrie-ai.desktop << 'DESKTOP_EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Valkyrie AI
Comment=AI-Powered Code Generator with Viking Theme
Exec=$EXEC_PATH
Icon=valkyrie-ai
Categories=Development;IDE;
Terminal=false
StartupNotify=true
DESKTOP_EOF

# Replace placeholder with actual path
sed -i "s|\$EXEC_PATH|$SCRIPT_DIR/valkyrie-launcher.sh|g" ~/.local/share/applications/valkyrie-ai.desktop

# Make desktop entry executable
chmod +x ~/.local/share/applications/valkyrie-ai.desktop

# Update desktop database
update-desktop-database ~/.local/share/applications 2>/dev/null || true

echo "✅ Desktop icon installed successfully!"
echo ""
echo "🔍 Look for 'Valkyrie AI' in your application menu"
echo "📍 Desktop file location: ~/.local/share/applications/valkyrie-ai.desktop"
echo "🎨 Icon location: ~/.local/share/icons/valkyrie-ai.png"
echo ""
echo "You can also create a direct desktop shortcut:"
echo "cp ~/.local/share/applications/valkyrie-ai.desktop ~/Desktop/"
echo "chmod +x ~/Desktop/valkyrie-ai.desktop"
