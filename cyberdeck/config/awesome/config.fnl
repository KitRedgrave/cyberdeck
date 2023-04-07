;; Standard awesome library
(local gears (require "gears"))
(local awful (require "awful"))
(require "awful.autofocus")
;; Widget and layout library
(local wibox (require "wibox"))

(local battery (require "awesome-wm-widgets.battery-widget.battery"))
(local cpu (require "awesome-wm-widgets.cpu-widget.cpu-widget"))
(local ram (require "awesome-wm-widgets.ram-widget.ram-widget"))
(local brightness (require "awesome-wm-widgets.brightness-widget.brightness"))

;; Theme handling library
(local beautiful (require "beautiful"))
(local machi (require "layout-machi"))
(local machina (require "machina"))
(local cyclefocus (require "awesome-cyclefocus"))

;; Notification library
(local naughty (require "naughty"))
(local menubar (require "menubar"))
(local hotkeys_popup (require "awful.hotkeys_popup"))

;; Error handling
;; Check if awesome encountered an error during startup and fell back to
;; another config (This code will only ever execute for the fallback config)
(when awesome.startup_errors
  (naughty.notify {:preset naughty.config.presets.critical
                   :title "Oops, there were errors during startup!"
                   :text awesome.startup_errors}))

;; Handle runtime errors after startup
(do
  (var in_error false)
  (awesome.connect_signal
   "debug::error" (fn [err]
                    ;; Make sure we don't go into an endless error loop
                    (when (not in_error)
                      (set in_error true)
                      (naughty.notify {:preset naughty.config.presets.critical
                                       :title "Oops, an error happened!"
                                       :text (tostring err)})
                      (set in_error false)))))

;; Variable definitions
;; Themes define colours, icons, font and wallpapers.
(beautiful.init (.. (gears.filesystem.get_themes_dir) "zenburn/theme.lua"))

;; This is used later as the default terminal and editor to run.
(var terminal "alacritty")
(var editor (or (os.getenv "EDITOR") "emacsclient"))
(var editor_cmd (.. terminal " -e " editor))

;; Default modkey.
;; Usually, Mod4 is the key with a logo between Control and Alt.
;; If you do not like this or do not have such a key,
;; I suggest you to remap Mod4 to another key using xmodmap or other tools.
;; However, you can use another modifier like Mod1, but it may interact with others.
(var modkey "Mod4")

;; Table of layouts to cover with awful.layout.inc, order matters.
(set awful.layout.layouts
     [
      machi.default_layout
      ])

;; Menubar configuration
(set menubar.utils.terminal terminal) ;; Set the terminal for applications that require it

;; Create a wibox for each screen and add it
(local taglist_buttons
       (gears.table.join
        (awful.button [] 1 (fn [t] (: t :view_only)))
        (awful.button [ modkey ] 1 (fn [t] (when client.focus (: client.focus :move_to_tag t))))
        (awful.button [] 3 awful.tag.viewtoggle)
        (awful.button [ modkey ] 3 (fn [t] (when client.focus (: client.focus :toggle_tag t))))))

(awful.screen.connect_for_each_screen
 (fn [s]
   (awful.tag [ "1" "2" "3" "4" "5" "6" "7" "8" "9" ] s machi.default_layout)
   (gears.wallpaper.fit (.. (gears.filesystem.get_configuration_dir) "wallpaper.jpg") s)

   ;; Create a taglist widget
   (set s.mytaglist (awful.widget.taglist {
                                           :screen s
                                           :filter awful.widget.taglist.filter.all
                                           :buttons taglist_buttons
                                           }))

   ;; Create the wibox
   (set s.mywibox (awful.wibar { :position "top" :screen s }))

   ;; Add widgets to the wibox
   (: s.mywibox :setup {
                        :layout wibox.layout.align.horizontal
                        1 { ;; Left widgets
                           :layout wibox.layout.fixed.horizontal
                           1 s.mytaglist
                           }
                        2 {:layout wibox.layout.fixed.horizontal}
                        3 { ;; Right widgets
                           :layout wibox.layout.fixed.horizontal
                           :align "right"
                           1 (wibox.widget.systray)
                           2 (cpu)
                           3 (ram {:widget_show_buf false})
                           4 (battery {
                                      :path_to_icons "/home/alice/.guix-profile/share/icons/Arc/status/symbolic/"
                                       })
                           5 (wibox.widget.textclock)
                           }
                        })))

;; key bindings
(var globalkeys
      (gears.table.join
       (awful.key [ modkey ] "s"
                  hotkeys_popup.show_help
                  { :description "show help" :group "awesome"})
       (awful.key [ modkey] "Tab"
                  #(machi.switcher.start)
                  { :description "open machi switcher" :group "awesome" })
       ;; Standard program
       (awful.key [ modkey ] "Return"
                  #(awful.spawn terminal)
                  {:description "open a terminal" :group "launcher"})
       (awful.key [ modkey "Shift" ] "r"
                  awesome.restart
                  {:description "reload awesome" :group "awesome"})
       (awful.key [ modkey "Shift"] "Tab"
                  #(machi.default_editor.start_interactive)
                  {:description "edit current layout" :group "layout"})

       ;; Prompt
       (awful.key [ modkey ] "r"
                  #(awful.spawn "rofi -show drun")
                  {:description "run rofi (drun)" :group "launcher"})

       (awful.key [ modkey ] "p"
                  #(awful.spawn "rofi-pass")
                  {:description "run rofi-pass" :group "launcher"})
       (awful.key [] "XF86AudioLowerVolume"
                  #(awful.spawn "amixer set Master 2%-"))
       (awful.key [] "XF86AudioRaiseVolume"
                  #(awful.spawn "amixer set Master 2%+"))))

(local clientkeys
       (gears.table.join
        (awful.key [ modkey ] "f"
                   (fn [c] (set c.fullscreen (not c.fullscreen)) (: c :raise))
                   {:description "toggle fullscreen" :group "client"})
        (cyclefocus.key [ "Mod1" ] "Tab"
                        {:cycle_filters [ cyclefocus.filters.same_screen
                                          cyclefocus.filters.common_tag ]
                         :keys [ "Tab" "ISO_Left_Tab" ]})
        (awful.key [ modkey "Shift" ] "c"
                   (fn [c] (: c :kill))
                   {:description "close" :group "client"})
        (awful.key [ modkey "Control" ] "space"
                   awful.client.floating.toggle
                   {:description "toggle floating" :group "client"})
        (awful.key [ modkey ] "h"
                   #(machina.focus_by_direction "left")
                   {:description "focus left" :group "client"})
        (awful.key [ modkey ] "j"
                   #(machina.focus_by_direction "down")
                   {:description "focus down" :group "client"})
        (awful.key [ modkey ] "k"
                   #(machina.focus_by_direction "up")
                   {:description "focus up" :group "client"})
        (awful.key [ modkey ] "l"
                   #(machina.focus_by_direction "right")
                   {:description "focus right" :group "client"})
        (awful.key [ modkey "Shift" ] "h"
                   #(machina.shift_by_direction "left")
                   {:description "move focused client left" :group "client"})
        (awful.key [ modkey "Shift" ] "j"
                   #(machina.shift_by_direction "down")
                   {:description "move focused client down" :group "client"})
        (awful.key [ modkey "Shift" ] "k"
                   #(machina.shift_by_direction "up")
                   {:description "move focused client up" :group "client"})
        (awful.key [ modkey "Shift" ] "l"
                   #(machina.shift_by_direction "right")
                   {:description "move focused client right" :group "client"})))

(local clientbuttons
        (gears.table.join
         (awful.button [] 1 (fn [c] (c:emit_signal "request::activate" "mouse_click" {:raise true})))
         (awful.button [ modkey ] 1 (fn [c]
                                      (c:emit_signal "request::activate" "mouse_click" {:raise true})
                                      (awful.mouse.client.move c)))))

;; Bind all key numbers to tags.
;; Be careful: we use keycodes to make it work on any keyboard layout.
;; This should map on the top row of your keyboard, usually 1 to 9.
(for [i 1 9]
  (set globalkeys
          (gears.table.join
           globalkeys
           ;; View tag only.
           (awful.key [ modkey ] (.. "#" (+ i 9))
                      (fn []
                        (let [screen (awful.screen.focused)
                              tag    (. screen.tags i)]
                          (when tag
                            (: tag :view_only))))
                      {:description (.. "view tag #" i) :group "tag"})
           ;; Toggle tag display
           (awful.key [ modkey "Control" ] (.. "#" (+ i 9))
                      (fn []
                        (let [screen (awful.screen.focused)
                              tag    (. screen.tags i)]
                          (when tag
                            (awful.tag.viewtoggle))))
                      {:description (.. "toggle tag #" i) :group "tag"})
           ;; Move client to tag
           (awful.key [ modkey "Shift" ] (.. "#"  (+ i 9))
                      (fn []
                        (when client.focus
                          (let [tag (. client.focus.screen.tags i)]
                            (when tag
                              (: client.focus :move_to_tag tag)))))
                      {:description (.. "move focused client to tag #" i) :group "tag"})
           ;; Toggle tag on focused client.
           (awful.key [ modkey "Control" "Shift" ] (.. "#" (+ i 9))
                      (fn []
                        (when client.focus
                          (let [tag (. client.focus.screen.tags i)]
                            (when tag
                              (: client.focus :toggle_tag tag)))))
                      {:description (.. "toggle focused client on tag #" i) :group "tag"}))))
;; Set keys
(root.keys globalkeys)

;; Rules
;; Rules to apply to new clients (through the "manage" signal)
(set awful.rules.rules
     [
      ;; All clients will match this rule.
      {
       :rule { }
       :properties { :border_width beautiful.border_width
                    :border_color beautiful.border_normal
                    :focus awful.client.focus.filter
                    :raise true
                    :keys clientkeys
                    :buttons clientbuttons
                    :screen awful.screen.preferred
                    :placement (+ awful.placement.no_overlap awful.placement.no_offscreen)
                    :maximized false
                    :minimized false
                    :maximized_horizontal false
                    :maximized_vertical false
                    }
       }
      {
       ;; Firefox gets stuck if it ever gets maximized, so don't let it
       :rule {
              :class "firefox"
              }
       :properties {:opacity 1
                    :maximized false
                    :maximized_horizontal false
                    :maximized_vertical false
                    :floating false}
       }
      {
       :rule {
              :class "Steam"
              }
       :properties {:floating true
                    :size_hints_honor false
                    :border_width 0
                    :titlebars_enable false
                    }
       }

      ;; Floating clients.
      {
       :rule_any {
                  :instance [
                             "DTA" ;; Firefox addon DownThemAll.
                             "copyq" ;; Includes session name in class.
                             "pinentry"
                             ] 
                  :class [
                          "Arandr"
                          "Blueman-manager"
                          "Gpick"
                          "Kruler"
                          "MessageWin" ;; kalarm.
                          "Sxiv"
                          "Tor Browser" ;; Needs a fixed window size to avoid fingerprinting by screen size.
                          "Wpa_gui"
                          "veromix"
                          "xtightvncviewer"
                          ]
                  ;; Note that the name property shown in xprop might be set slightly after creation of the client
                  ;; and the name shown there might not match defined rules here.
                  :name [
                         "Event Tester"  ;; xev
                         ]
                  :role [
                         "AlarmWindow" ;; Thunderbird's calendar.
                         "ConfigManager" ;; Thunderbird's about:config.
                         "pop-up" ;; e.g. Google Chrome's (detached) Developer Tools.
                         ]
                  }
       :properties {:floating true }}

      {
       :rule_any {:type [ "normal" "dialog" ] }
       :properties {:titlebars_enabled false }
       }
      ])

;; Signals
;; Signal function to execute when a new client appears.
(client.connect_signal
 "manage"
 (fn [c]
   (when (and awesome.startup
              (not c.size_hints.user_position)
              (not c.size_hints.program_position))
     ;; Prevent clients from being unreachable after screen count changes.
     (awful.placement.no_offscreen c))))

;; Enable sloppy focus, so that focus follows mouse.
(client.connect_signal "mouse::enter" (fn [c] (c:emit_signal "request::activate" "mouse_enter" {:raise false})))

(client.connect_signal "focus" (fn [c] (set c.border_color beautiful.border_focus)))
(client.connect_signal "unfocus" (fn [c] (set c.border_color beautiful.border_normal)))

;; autostart useful tools
(awful.spawn "picom -b")
(awful.spawn "nm-applet")
