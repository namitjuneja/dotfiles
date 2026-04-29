function wallpaper
    if test (count $argv) -ne 1
        echo "Usage: wallpaper /path/to/image"
        return 1
    end

    set img (realpath $argv[1])

    if not test -f $img
        echo "File not found: $img"
        return 1
    end

    hyprctl hyprpaper preload $img
    hyprctl hyprpaper wallpaper "HDMI-A-2,$img"

    # Update the config so the wallpaper persists after hyprpaper restarts
    sed -i "s|^preload = .*|preload = $img|" ~/.config/hypr/hyprpaper.conf
    sed -i "s|path = .*|path = $img|" ~/.config/hypr/hyprpaper.conf
end
