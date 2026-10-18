# Zephyr

Конфиги и инсталлер для рабочего стола на [Niri](https://github.com/YaLTeR/niri)
под Debian. Не DE, не форк — аккуратно собранный набор конфигов, который
ставится одной командой и меняет тему одной командой.

## Что внутри

- **Niri** — композитор (ставится отдельно, Zephyr только проверяет наличие)
- **Waybar** — бар
- **Fuzzel** — лаунчер
- **Mako** — уведомления
- **gtklock** — локскрин
- **swayosd** — OSD для громкости и яркости
- **swayidle** — idle-менеджер
- **swaybg** — обои
- **foot** — терминал
- **grim + slurp + swappy** — скриншоты
- **cliphist + wl-clipboard** — история буфера обмена

## Установка

    git clone https://github.com/akunaiix/zephyr.git ~/projects/zephyr
    cd ~/projects/zephyr
    ./install.sh

Инсталлер проверяет Wayland-сессию и наличие niri, ставит пакеты из
`packages/debian.list`, бэкапит старые конфиги в `~/.config/zephyr-backup-<дата>/`,
симлинкает конфиги в `~/.config/`, применяет тему, валидирует запуск.

Флаги: `--theme <имя>`, `--copy`, `--keep-niri`, `--no-packages`, `--yes`.
Подробнее — `./install.sh --help`.

Удаление: `./uninstall.sh` (симлинки убираются, последний бэкап восстанавливается).

## Темы

    zephyr-theme catppuccin-mocha
    zephyr-theme tokyonight
    zephyr-theme --list

Тема — папка `themes/<имя>/` с одним файлом `colors.sh` (~15 переменных:
фон, текст, акцент, urgent и т.д.). Хочешь свою — копируешь любую, правишь
переменные, кладёшь в `themes/`, вызываешь `zephyr-theme <имя>`.

## Кастомизация

Каждый компонент настраивается в одном файле:

- Раскладка, биндинги, анимации — `~/.config/niri/config.kdl`
- Модули бара — `~/.config/waybar/config.jsonc`
- Размеры, отступы бара — `~/.config/waybar/style.css`
- Лаунчер — `~/.config/fuzzel/fuzzel.ini`
- Уведомления — `~/.config/mako/mako.ini`
- Терминал — `~/.config/foot/foot.ini`

После правки: `zephyr-reload` (или хоткей внутри niri).

## Зависимости

- Debian 13 (trixie) или новее
- Niri (установленный и работающий)
- Wayland-сессия

## Статус

В разработке.

## Лицензия

MIT. См. `LICENSE`.
