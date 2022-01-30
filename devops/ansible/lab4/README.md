# Лабораторная 4 "Linux Hardening"

## Цель

С помощью ansible написать роль, которая будет выполнять настройку безопасности linux серверов. В идеале вы должны
будете написать роль которая умеет настраивать сервера с учетом их особенностей, учитывая как минимум deb* дистрибутивы
и rpm* дистрибутивы.

## Какие потребуются модули

- Для того чтобы убедиться что какая-то строка или набор строк есть в файле используйте модуль lineinfile.
- Если же строк больше чем 3-4, то иногда проще положить файл целиком и использовать модуль file или template (чтобы
  использовать функции jinja шаблонизации)
- Для отключения сервиса использовать модуль systemd
- Чтобы удалить пакет, используйте специфичный для дистрибутива модуль: apt/dnf/yum...

## Задание

0) с помощью модуля raw устанавливает python на сервер
1) настраивать timezone
2) настраивать любой клиент ntp
3) устанавливает набор пакетов на сервер: fail2ban,
4) настраивает ssh клиент:

    - Уровень логирования C2S/CIS: CCE-80645- 5 (Medium)
    - Отключение пустых паролей C2S/CIS: CCE- 27471-2 (High)
    - Минимальное кол-во активных сессий - C2 S/CIS: CCE-27082-7 (Medium)
    - Уменьшение времени ожидания при отсутствии активности в SSH сессии - C2S /CIS: CCE-27433-2 (Medium)
    - Установить по умолчанию одобренные FIPS криптографические хеш-функции - C2 S/CIS: CCE-27455-5 (Medium)
    - Включение протокола 2 версии - C2S/CIS: CCE-27320-1 (High)
    - Включение игнорирования rhosts - C2S /CIS: CCE-27377-1 (Medium)
    - Установить по умолчанию одобренные FIPS криптографические алгоритмы - C2S /CIS: CCE-27295-5 (High)
    - Отключение передачи x11 - C2S/CIS: CCE- 80226-4 (High):
    - Запрет на форвард портов
    - Запрет на туннелирования
    - Запрет на выполнение локальных команд
    - Убедиться что запрещено подключаться с использованием пароля
    - Запрет подключения напрямую от root


5) настраиваем autofs - останавливаем и убираем из автозагрузки autofs с помощью systemctl.
6) устанавливаем настройки grub:

    - `GRUB_CMDLINE_LINUX="ipv6.disable=1"`
    - Для включения аудита системы до начала запуска auditd:  
      `GRUB_CMDLINE_LINUX="audit=1"`
    - `GRUB_CMDLINE_LINUX="audit_backlog_limit=8192"`

7) для rpm дистрибутивов установить проверку подписей для пакетов:

    - В файлах `/etc/yum.conf` и `/etc/dnf/dnf.conf` изменить соответствующий параметр к рекомендованным: `gpgcheck=1`

8) настраиваем автоматические обновления security updates пакетов в системе

    - `dnf-automatic` для шапки и `unattended-upgrades` для debian

9) останавливаем и удаляем ненужные сервисы на сервере. Этот список включает как неиспользуемые в современном мире
   программы, которые включены в некоторых дистрибутивах как наследие и могут привести потенциально к успешной атаке на
   сервер, так и вполне нормальные современные сервисы, такие как nginx. Однако, это логично с точки зрения того что тот
   же nginx, например, должен располагаться только на серверах предоставляющих эту услугу, а на других его быть не
   должно. Поэтому в списке программ он есть, но в реальном мире мы можем просто написать фильтр exclude для программ
   которые не хотим удалять с сервера и объявлять эту переменную только в нужных серверах, а для остальных без
   исключения nginx должен быть удалён.
    
    | имя программы | security reference |
    |---------------|--------------------|
    | rlogin.socket | (C2S/CIS: CCE-27336-7 (High)) |
    | rexec.socket | (C2S/CIS: CCE-27408-4 (High)) |
    | rsh.socket | (C2S/CIS: CCE-27337-5 (High)) |
    | rm /etc/hosts.equiv rm ~/.rhosts | (C2S/CIS: CCE-27406-8 (High)) |
    | disable = yes | (Изменить значение в файле /etc/xinetd.d/telnet C2S/CIS: CCE-27401-9 (High)) |
    | tftp.service | (C2S/CIS: CCE-80212-4 (Medium)) |
    | xinetd.service | (C2S/CIS: CCE-27443-1 (Medium)) |
    | vsftpd.service | (C2S/CIS: CCE-80244-7 (Unknown)) |
    | rsh | (Удаление rsh - C2S/CIS: CCE-27274-0 (unknown)) |
    | ypserv | (Удаление ypserv - C2S/CIS: CCE-27399-5 (High)) |
    | talk | (Удаление talk - C2S/CIS: CCE-27432-4 (Medium)) |
    | talk-server | (Удаление talk-server - C2S/CIS: CCE-27210-4 (Medium)) |
    | xorg-x11-server-common | (Удаление пакета xorg-x11 C2S/CIS: CCE-27218-7 (Medium)) |
    | openldap-servers | (Удаление openldap-servers - C2S/CIS: CCE-80293-4 (Unknown)) |
    | avahi-daemon.service | (C2S/CIS: CCE-80338-7 (Unknown)) |
    | snmpd.service | (C2S/CIS: CCE-80274-4 (Unknown)) |
    | named.service | (C2S/CIS: CCE-80325-4 (Unknown)) |
    | smb.service | (C2S/CIS: CCE-80277-7 (Unknown)) |
    | httpd.service | (C2S/CIS: CCE-80300-7 (Unknown)) |
    | nginx.service | - |
    | rhnsd.service | (C2S/CIS: CCE-80269-4 (Unknown)) |
    | squid.service | (C2S/CIS: CCE-80285-0 (Unknown)) |
    | dhcpd.service | (C2S/CIS: CCE-80330-4 (Medium)) |
    | dovecot.service | (C2S/CIS: CCE-80294-2 (Unknown)) |
    | rpcbind.service | (C2S/CIS: CCE-80230-6 (Medium)) |
    | nfs.service | (C2S/CIS: CCE-80237-1 (Unknown)) |
    | cups.service | (C2S/CIS: CCE-80282-7 (Unknown)) |

10) Добавить сообщение в файл `/etc/motd`:

    > This system is for the use of authorised users only. Individuals using this computer system without authority, or in
    excess of their authority, are subject to having all of their activities on this system monitored and recorded by system
    personnel. In the course of monitoring individuals improperly using this system, or in the course of system maintenance,
    the activities of authorised users may also be monitored. Anyone using this system expressly consents to such monitoring
    and is advised that if such monitoring reveals possible criminal activity, system personnel may provide the evidence of
    such monitoring to law enforcement officials.

11) Чтобы соответствовать требованиям парольной политики, необходимо установить и настроить PAM-модуль cracklib:

    - Отредактируйте файл `/etc/pam.d/system-auth` следующим образом:

        ```bash
        password requisite pam_cracklib.so try_first_pass retry=3 minlen=9 difok=4 minclass=4 ucredit=-1 lcredit=- 1 dcredit=-1 ocredit=-1
        password sufficient pam_unix.so sha512 shadow nullok try_first_pass use_authtok remember=5
        ```

    - Для всех существующих локальных уз необходимо применить:
    
        ```bash
        chage -m 1 -M 90 <LOGIN>
        ```
    
    - Отредактируйте файл `/etc/default/useradd`:
        
        ```cfg
        INACTIVE = 90
        INACTIVE = -1
        ```

12) Настройки `sudo` и `su`
    
    - Включить псевдотерминал для SUDO — добавить в файл `/etc/sudoers` следующий параметр:
      
      ```
      Defaults use_pty
      ```
      
    - Включить логирование SUDO для выполняемых команд — добавить в файл `/etc/sudoers` следующий параметр:
      ```
      Defaults logfile="/var/log/sudo.log"
      ```
    - Включить дополнительные SUDO алиасы для различных команд. Если пользователю необходимо выполнять определенные действия
      от пользователя root, то необходимо создать группу `{group_name}` и добавить пользователя `{user_name}` в данную группу (
      пользователь не должен входить в группу sudo). Далее необходимо добавить в `/etc/sudoers` для данной группы
      `{group_name}` белый список команд, которые будут выполняться c привилегиями root. Добавить в файл `/etc/sudoers`
      следующие параметры (Пример белого списка команд):
      ```
      %group_name ALL=(root) /sbin/service httpd start, /sbin/service httpd stop, /sbin/service httpd restart
      ```
    - Ограничение прав доступа к `su`. Для того, чтобы определенные пользователи не могли использовать команду `su` для
      получения прав суперпользователя root, добавьте следующую строку в файл `/etc/pam.d/su`:
      ```
      auth required pam_wheel.so deny group=nosu use_uid
      ```

13) Установить парольную политику по-умолчанию в файле `/etc/login.defs`

    | параметр | значение |
    |----------|----------|
    | CREATE_HOME | yes |
    | ENCRYPT_METHOD | SHA512 |
    | FAIL_DELAY | 3 |
    | FAILLOG_ENAB | yes |
    | LOG_OK_LOGINS | yes |
    | LOG_UNKFAIL_ENAB | no |
    | OBSCURE_CHECKS_ENAB | yes |
    | PASS_ALWAYS_WARN | yes |
    | PASS_MAX_DAYS | 90 |
    | PASS_MIN_LEN | 9 |
    | PASS_WARN_AGE | 7 |
    | UMASK | 027 |
    | USERGROUPS_ENAB | yes |

14) Настройка неиспользуемых файловых систем. Рекомендуется отключить те файловые системы, которые не будут
    использоваться в работе. Необходимо создать файл `/etc/modprobe.d/blacklist.conf` и добавить в него отключаемые
    модули:

    ```
    blacklist cramfs
    blacklist freevsx
    blacklist jffs2
    blacklist hfs
    blacklist hfsplus
    blacklist squashfs
    blacklist udf
    ``` 

15) Права доступа до критичных системных файлов:
    
    | Путь до файла | Владелец | Права доступа |
    |---------------|----------|---------------|
    | /etc/passwd | root:root | 644 |
    | /etc/passwd- | root:root | 644 |
    | /etc/group | root:root | 644 |
    | /etc/group- | root:root | 644 |
    | /etc/shadow | root:root | 600 |
    | /etc/shadow-  | root:root |  600 |
    | /etc/gshadow  | root:root |  600 |
    | /etc/gshadow- | root:root |   600 |
    | /etc/grub.cfg | root:root |   600 |
    | /boot/grub2/grubenv | root:root | 600 |
    | /boot/grub2/grub.cfg | root:root | 600 |
    | /etc/ssh/sshd_config | root:root | 600 |
    | /etc/cron.hourly | root:root | 700 |
    | /etc/cron.daily | root:root | 700 |
    | /etc/cron.weekly | root:root | 700 |
    | /etc/cron.monthly | root:root | 700 |
    | /etc/cron.d | root:root | 600 |
    | /etc/crontab | root:root | 600 |

16) Создаем белые списки пользователей которые могут использовать at и cron.

    - удаляем `/etc/cron.deny` и `/etc/at.deny`
    - создаем `/etc/cron.allow` и `/etc/at.allow` с правами `og-rwx` и владельцем `root:root`
    

17) Поиск и настройка доступа к файлам. **К найденным файлам применяются данные права при условии отсутствия нарушений в
    работе ПО, использующего эти файлы**
    
    - Настройка доступа к приватным и публичным SSH ключам.
    
        ```bash
        find /etc/ssh -xdev -type f -name 'ssh_host_*_key' -exec stat {} \;
        find /etc/ssh -xdev -type f -name 'ssh_host_*_key' -exec chown root:root {} \; find /etc/ssh -xdev -type f -name 'ssh_host_*_key' -exec chmod 0600 {} \;
        find /etc/ssh -xdev -type f -name 'ssh_host_*_key.pub' -exec chmod 0644 {} \; find /etc/ssh -xdev -type f -name 'ssh_host_*_key.pub' -exec chown root:root {} \;
        ```
    
    - Настройка ограничения доступа к лог файлам в директории /var/logs:
    
        ```bash
        find /var/log -type f -perm /037 -ls -o -type d -perm /026 -ls
        find /var/log -type f -exec chmod g-wx,o-rwx "{}" + -o -type d -exec chmod g- w,o-rwx "{}" +
        ```
    
    - Настройка прав доступа на домашние каталоги. Необходимо установить права 750 или более строгие на домашние каталоги
      пользователей.
    - Поиск исполняемых файлов с возможностью перезаписи для всех:
    
        ```bash
        df --local -P | awk '{if (NR!=1) print $6}' | xargs -I '{}' find '{}' -xdev -type f -perm -0002
        ```
    
    - Поиск файлов и директорий с не указанным владельцем:
    
        ```bash
        df --local -P | awk '{if (NR!=1) print $6}' | xargs -I '{}' find '{}' -xdev -type f -perm -0002
        ```
    
    - Поиск файлов и директорий с не указанным группой владельцев:
    
        ```bash
        df --local -P | awk '{if (NR!=1) print $6}' | xargs -I '{}' find '{}' -xdev -nogroup
        ```
    
    - Поиск исполняемых фаилов с установленным битом SUID/SGID:
    
        ```bash
        df --local -P | awk '{if (NR!=1) print $6}' | xargs -I '{}' find '{}' -xdev -type f -perm -4000
        ```

18) Поиск пользователей с небезопасными настройками
    
    - Поиск пользователей с пустыми паролями:

        ```bash
        awk -F: '($2 == "" ) { print $1 " does not have a password "}' /etc/shadow
        ```

    - Поиск всех пользователей с UID = 0:
    
        ```bash
        awk -F: '($3 == 0) { print $1 }' /etc/passwd
        ```

19) Требования к сетевым настройкам. Добавить в конфигурационный файл `/etc/sysctl.d/network-stack.conf `следующие
    параметры:
    
    | Параметр и значение | Описание |
    |---------------------|----------|
    | `net.ipv6.conf.default.accept_redirects = 0`<br>`net.ipv6.conf.all.accept_redirects = 0` | C2S/CIS: CCE-80181-1 (Unknown)<br>C2S/CIS: CCE-80183-7 (Medium) |
    | `net.ipv6.conf.default.accept_ra = 0`<br>`net.ipv6.conf.all.accept_ra = 0` | C2S/CIS: CCE-80181-1 (Unknown)<br>C2S/CIS: CCE-80180-3 (Unknown) |
    | `net.ipv6.conf.all.disable_ipv6 = 1` | C2S/CIS: CCE-80175-3 (Medium) |
    | `net.ipv4.conf.default.accept_source_route = 0`<br>`net.ipv4.conf.all.accept_source_route = 0` | C2S/CIS: CCE-80162-1 (Medium)<br>>C2S/CIS: CCE-27434-0 (Medium) |
    | `net.ipv4.icmp_ignore_bogus_error_responses = 1` | C2S/CIS: CCE-80166-2 (Unknown) |
    | `net.ipv4.conf.default.accept_redirects = 0`<br>`net.ipv4.conf.all.accept_redirects = 0` | C2S/CIS: CCE-80181-1 (Unknown)<br>C2S/CIS: CCE-80183-7 (Medium) |
    | `net.ipv4.conf.default.rp_filter = 1`<br>`net.ipv4.conf.all.rp_filter = 1` | C2S/CIS: CCE-80168-8 (Medium)<br>C2S/CIS: CCE-80167-0 (Medium) |
    | `net.ipv4.conf.default.secure_redirects = 0`<br>`net.ipv4.conf.all.secure_redirects = 0` | C2S/CIS: CCE-80164-7 (Medium)<br>C2S/CIS: CCE-80159-7 (Medium) |
    | `net.ipv4.tcp_syncookies = 1` | C2S/CIS: CCE-27495-1 (Medium) |
    | `net.ipv4.conf.default.log_martians = 1`<br>`net.ipv4.conf.all.log_martians = 1` | C2S/CIS: CCE-80161-3 (Unknown)<br>C2S/CIS: CCE-80160-5 (Unknown) |
    | `net.ipv4.icmp_echo_ignore_broadcasts = 1` | C2S/CIS: CCE-80165-4 (Unknown) |
    | `net.ipv4.ip_forward = 0` | C2S/CIS: CCE-80157-1 (Medium) |
    | `net.ipv4.conf.default.send_redirects = 0`<br>`net.ipv4.conf.all.send_redirects = 0` | C2S/CIS: CCE-80156-3 (Medium)<br>C2S/CIS: CCE-80156-3 (Medium) |
    | `net.ipv4.tcp_fin_timeout = 30`<br> `net.ipv4.tcp_keepalive_time = 180`<br>`net.ipv4.tcp_keepalive_intvl = 10`<br>`net.ipv4.tcp_keepalive_probes = 3` | https://www.kernel.org/doc/Documentation/networking/ip-sysctl.txt |

20) Общие рекомендации для настройки firewall (не в составе лр):
    
    - Применить политику по умолчанию, которая будет отбрасывать все пакеты для INPUT, OUTPUT, FORWARD
    - Применить правила явно разрешающие доступ к необходимым сервисам.
    - Применить правило для разрешения трафика на loopback интерфейс.
    - Применить правило для запрета трафика к loopback интерфейсу с других интерфейсов.
    - Применить правила для разрешения трафика с состояними new,established для входящего трафика tcp, udp, icmp.
    - Применить правила для разрешения трафика с состояними new,related,established для исходящего трафика tcp, udp, icmp.

21) Требования по настройке механизмов защиты ядра:
    
    - Запрет загрузки модулей ядра. Отключение DCCP и SCTP в файле /etc/modprobe.d/modules.conf:
    
        | Модули | Описание |
        |--------|----------|
        | install dccp /bin/true | C2S/CIS: CCE-26828-4 (Medium) |
        | install sctp /bin/true | C2S/CIS: CCE-27106-4 (Medium) |
        
    - Включение дополнительной защиты ALSR и Exec-shield. Включение производится в файле /etc/sysctl.cfg:
    
        ```cfg
        kernel.randomize_va_space = 2
        kernel.exec-shield = 1
        ```
    
    - Запрет создания дампа памяти ядра. Отключение дампа производится в следующих файлах:
    
        | файл | параметр |
        |------|----------|
        | `/etc/security/limits.conf` | `* hard core 0` |
        | `/etc/sysctl.conf` | `fs.suid_dumpable = 0` |
        
    - Если установлен пакет coredump то необходимо настроить и его /etc/systemd/coredump.conf:
    
        ```cfg
        Storage=none
        ProcessSizeMax=0
        ```
