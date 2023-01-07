(local theme_assets (require "beautiful.theme_assets"))
(local xresources (require "beautiful.xresources"))
(local dpi xresources.apply_dpi)
(local gfs (require "gears.filesystem"))
(local themes_path (gfs.get_configuration_dir))

(let
    [bg_minimize "#3f3f3f"
     fg_minimize "#7f7f7f"
     bg_normal "#112222"
     fg_normal "#aaaaaa"
     bg_focus "#3f7f7f"
     fg_focus "#ffffff"
     bg_urgent "#ff0000"
     fg_urgent "#ffffff"]
  {:font "source code pro 12"
   :bg_normal bg_normal
   :bg_focus bg_focus
   :bg_urgent bg_urgent
   :bg_systray bg_normal

   :fg_normal fg_normal
   :fg_focus fg_focus
   :fg_urgent fg_urgent

   :useless_gap (dpi 5)
   :border_width (dpi 1)
   :border_normal bg_minimize
   :border_focus bg_focus
   :border_marked "#91231c"

   :taglist_squares_sel (theme_assets.taglist_squares_sel (dpi 4) fg_normal)
   :taglist_squares_unsel (theme_assets.taglist_squares_unsel (dpi 4) fg_normal)
   :menu_height (dpi 15)
   :menu_width (dpi 100)

   :awesome_icon (theme_assets.awesome_icon (dpi 15) bg_focus fg_focus)
   :icon_theme nil

   :wallpaper (.. themes_path "/theme/wallpaper.jpg")})
