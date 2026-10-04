# Сторонние компоненты

Скилы в `.claude/skills/` ниже взяты у других авторов без изменений, кроме отмеченных. Лицензия каждого лежит в его папке.

| Скил | Источник | Версия | Лицензия | Изменения |
|---|---|---|---|---|
| `unlazy` | [Leonxlnx/unlazy](https://github.com/Leonxlnx/unlazy) | 2.1.0, коммит 1667149 | MIT | убраны тесты, CI и служебные файлы разработки |
| `find-skills` | [vercel-labs/skills](https://github.com/vercel-labs/skills), `skills/find-skills` | skills 1.7.0 | MIT | нет |
| `skill-creator` | [anthropics/skills](https://github.com/anthropics/skills), `skills/skill-creator` | коммит 8a1541c | Apache-2.0 | нет |
| `research-synthesis` | [anthropics/knowledge-work-plugins](https://github.com/anthropics/knowledge-work-plugins), `design/skills/research-synthesis` | коммит 8444efc | Apache-2.0 | удалена ссылка на файл `CONNECTORS.md` плагина, которого здесь нет |

Плагин [oh-my-claudecode](https://github.com/Yeachan-Heo/oh-my-claudecode) (MIT) в репозиторий не входит: он ставится при установке, версия закреплена в `.claude/settings.json` и `SETUP.md` (v5.6.1).
