# Zephyr 🌪️

Конфиги и инсталлер для рабочего стола на [Niri](https://github.com/YaLTeR/niri) под Debian.
Не DE, не форк — аккуратно собранный набор конфигов, который ставится одной командой 
и меняет тему одной командой.

Сделан под себя (ASUS, Debian 13 trixie), выложен на случай, если пригодится кому-то ещё.

## Что внутри

- **Niri** — композитор (ставится отдельно, Zephyr только проверяет наличие)
- **Waybar** — бар (запускается через `dbus-run-session` для стабильности)
- **Fuzzel** — лаунчер
- **Mako** — уведомления
- **Gtklock** — локскрин
- **Wob** — OSD для громкости и яркости
- **Swayidle** — idle-менеджер
- **Swaybg** — обои
- **Foot** — терминал
- **Grim + Slurp + Swappy** — скриншоты
- **Cliphist + wl-clipboard** — история буфера обмена

## Установка

    git clone https://github.com/akunaiix/zephyr.git ~/projects/zephyr
    cd ~/projects/zephyr
    ./install.sh

Инсталлер:
1. Проверяет, что ты в Wayland-сессии и что niri установлен
2. Ставит пакеты из packages/debian.list
3. Бэкапит существующие конфиги в ~/.config/zephyr-backup-<дата>/
4. Симлинкает конфиги из репозитория в ~/.config/
5. Копирует скрипты в ~/.local/bin/
6. Применяет тему по умолчанию

**Внимание:** Убедись, что ~/.local/bin добавлен в твой $PATH (в ~/.bashrc).
Флаги: --theme <имя>, --copy, --keep-niri, --no-packages, --yes.

Удаление: ./uninstall.sh (симлинки убираются, последний бэкап восстанавливается).

## Темы

    zephyr-theme --list
    zephyr-theme catppuccin-mocha
    zephyr-theme tokyonight
    zephyr-theme gruvbox

Тема — это папка themes/<имя>/ с одним файлом colors.sh (~10 переменных). 
Скрипт zephyr-theme прогоняет цвета через все конфиги (Waybar, Fuzzel, Mako, Foot, Gtklock) 
и перезапускает бар.

## Полезные скрипты

- zephyr-theme <имя> — сменить тему
- zephyr-reload — перезапустить Waybar, Mako и Wob (удобно после правки конфигов)
- zephyr-osd-volume up/down/mute — громкость с полоской
- zephyr-osd-brightness up/down — яркость с полоской

## Горячие клавиши (Niri)

- Mod+T — Терминал (foot)
- Mod+D — Лаунчер (fuzzel)
- Mod+V — История буфера (cliphist + fuzzel)
- Mod+Escape — Заблокировать экран (gtklock)
- Print — Скриншот области (slurp + swappy)
- Mod+Print — Скриншот всего экрана в буфер
- Mod+H/J/K/L — Фокус (vim-style)
- Mod+1..5 — Воркспейсы

## Лицензия

MIT. См. LICENSE.
