# Задание

## Окружение

- Есть Host-A - Ansible Controller - с которого запускаем Ansible
- Есть Host-B - целевой хост, на котором выполняем действия
- На Host-A используется Ansible 2.8.x
- На Host-B - Docker-CE
- Есть Memcached, который доступен с Host-A (можно запустить на Host-B в качестве контейнера)
- В Memcached лежит ключ `filepath` со значением `/usr/share/nginx/html/cron.html`
- Есть сервер с HTTP API, который доступен с Host-B (можно запустить на Host-B в качестве контейнера и взять любую болванку с Google, которая отвечает "200 OK" на любой запрос, к примеру https://gist.github.com/huyng/814831)

## Задача

- Необходимо написать роль `cron` для Ansible, которая:
  - настраивает на целевом хосте (Host-B) cron-задачи из `cronJobs` для запуска **внутри** контейнера `containerName`
  - в теле команд могут использоваться строковые переменные вида `%filepath%` (`%имя%`), которые нужно заменить на значения соответствующего ключа из Memcached в момент применения роли
  - результат каждого выполнения cron-задачи должен быть отправлен POST-запросом в API по адресу из переменной `apiEndpoint` с JSON-телом `{"id":"<job_id>","stdout":"<job_stdout>"}`

- Необходимо написать плейбук `setup_cron`, который на Host-B:
  - запускает контейнер с именем `containerName` и образом `containerImage`
  - применяет роль `cron` для `containerName`, используя `cronJobs` в качестве списка cron-задач

## Факультативно

- Плейбук для деплоя на Host-B: Memcached с ключом и болванки HTTP API
- Плейбук для тестирования своей роли `cron` (что она работает как нужно)

## YAML-файл с переменными

```
---
apiEndpoint: 'http://host-b:8080/api'
containerImage: 'nginx:stable-alpine'
containerName: 'nginx'
cronJobs:
  - id: jid1
    time: '* * * * *'
    command: 'echo "$(date) => ping" >> %filepath%'
  - id: jid2
    time: '*/5 * * * *'
    command: |
             echo Five Minutes
             echo -n $(date) >> %filepath%
             echo " => pong" >> %filepath%
```

## Что должно получиться

Если запустить плейбук с текущими переменными, то после его выполнения на Host-B:

- работает контейнер `nginx`
- по адресу http://host-b/cron.html каждую минуту добавляется сообщение `ping` и каждые 5 минут `pong`
- в логах API-сервера мы должны увидеть POST запросы от `jid1` и `jid2`, у последних должен быть `Five Minutes` в качестве stdout.
