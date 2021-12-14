# Simple nginx setup role

## Задача (общее описание)

Поднять любое "приложение" на 2 серверах (одинаковое), выполнить доступ к этому приложению через балансировщик с
авторизацией через сертификаты.

### Поднимаем приложение

1. Кладём index-файл Это может быть абсолютно что угодно, для простоты в примере будут только странички hello-world. Для
   этого мы воспользуемся задачей "ensure static files" из lab7/site.yaml и будем класть на сервера nginx-{2,3}
   статический index.html В этот файл вы можете положить что угодно, для примера это просто приветствие с указанием на
   какой сервер мы приземлились.
2. Формируем простой конфиг, который будет указывать ngnix о том, что при обращениях на него, нужно будет отталкиваться
   от корневой директории mywebsite, для этого запишем в переменную nginx_configs содержимое конфига. Эти значения нужно
   поместить в lab7/host_vars/nginx-{2,3}.yml. Таким образом мы скажем роли nginx чтобы она сформировала файл с именем
   mywebsite.conf в директории /etc/nginx/conf.d.
   ```bash
   nginx_configs:
   - name: mywebsite.conf
     value: |
       server {
         listen 80;
         location / {
           access_log off;
           root /var/www/mywebsite;
         }
       }
   ```
3. Формируем конфиг для сервера-балансировщика.

   Для начала сделаем простой конфиг (lab7/host_vars/nginx-1.yml), чтобы проверить и убедиться что теория работает. Этот
   конфиг будет диктовать nginx, что при обращении к корневому маршруту (/) нужно будет в режиме round-robin отправить
   запросы по-очерёдно на 2 и 3 сервера. На этом этапе мы можем поднимать vagrant и проверять с помощью curl
   работоспособность балансировки, а именно, сделайте на хостовой ОС curl 127.0.0.1:8081 несколько раз, в ответ вы
   должны получить ответ от nginx-2 и nginx-3.

   З.Ы. Vagrant up(rsync&&provision) сфейлится, потому что потребуется время на закачку контейнера с nginx. Подождите
   некоторое время перед тем как выполнять curl.
   ```yaml
   nginx_configs:
   - name: mywebsite.conf
     value: |
       upstream backend {
         server 192.168.56.22:80;
         server 192.168.56.23:80;
       }
       server {
         listen 80;
         server_name nginx-1.local;
         location / {
           proxy_pass http://backend;
         }
       }
   ```

4. Генерируем сертификаты.

   Дальнейшая работа по данному пункту предполагается в lab7/ssl

   4.1 Создание сертификатов УЦ
   ```bash
   openssl genrsa -out ca.key 2048
   openssl req -new -x509 -days 3650 -key ca.key -out ca.crt
   ```

   4.2 Создание сертификата сервера.

   Создадим конфигурационный файл server.cnf
   ```bash
   cat >server.cnf <<EOF
   [req]
   prompt = no
   distinguished_name = dn
   req_extensions = ext
   
   [dn]
   CN = nginx-1.local
   emailAddress = my.email@example.com
   O = Private person
   OU = Alter ego dept
   L = Korolyov
   C = RU
   
   [ext]
   subjectAltName = DNS:nginx-1.local,IP:127.0.0.1
   EOF
   ```

   4.3 Создание запроса на сертификат для сервера.

   ```bash
   openssl req -new -utf8 -nameopt multiline,utf8 -config server.cnf -newkey rsa:2048 -keyout server.key -nodes -out server.csr
   ```

   4.4 Создание сертификата по запросу из пункта 4.3.

   ```bash
   openssl x509 -req -days 3650 -in server.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out server.crt -extfile server.cnf -extensions ext
   ```

   4.5 Создание сертификата клиента (Обязательно указываем уникальные Organization Name, Organizational Unit Name,
   Common Name для каждого клиента и они не должны совпадать с указанными для сервера или корневого УЦ)

   ```bash
   openssl req -new -utf8 -nameopt multiline,utf8 -newkey rsa:2048 -nodes -keyout client.key -out client.csr
   openssl x509 -req -days 3650 -in client.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out client.crt
   ```

   4.6 Проверка

   В результате вы должны получить следующий набор файлов:
    - Корневые сертификат и ключ (ca.crt, ca.key)
    - Сертификат, ключ и запрос для клиента (client.crt, client.csr, client.key)
    - Сертификат, ключ и запрос для сервера (server.key, server.crt, server.csr)
    - Конфиг для генерирования сертификатов (server.cnf)

5. Загружаем сертификаты на сервер.

   Для этого мы запишем сертификаты в переменную nginx_ssl_certs расположив ее в lab7/host_vars/nginx-1.yml. В данном
   примере пропущены значения сертификатов для визуальной наглядности. Конечно, в вашем случае вместо многоточия должны
   быть значения из файлов сертификатов, которые вы ранее сгенерировали.
   ```yaml
   nginx_ssl_certs:
   - name: ca.crt
     value: |
       -----BEGIN CERTIFICATE-----
       ....
       -----END CERTIFICATE-----
   - name: server.crt
     value: |
       -----BEGIN CERTIFICATE-----
       ....
       -----END CERTIFICATE-----
   - name: server.key
     value: |
       -----BEGIN PRIVATE KEY-----
       ....
       -----END PRIVATE KEY-----
   ```

6. Настройка nginx-1 Приносим новую версию конфига с подключеним ssl в lab7/host_vars/nginx-1.yml. Раскатываем vagrant
   rsync && vagrant provision и проверяем: curl -Lk 127.0.0.1:8081. где -L - follow redirect (http->https) а -k -
   игнорировать что сертификат не доверенный.

   ```yaml
   nginx_configs:
   - name: mywebsite.conf
     value: |
       upstream backend {
         server 192.168.56.22:80;
         server 192.168.56.23:80;
       }
       server {
         listen 80;
         server_name nginx-1.local;
         return 301 https://$host:8443$request_uri;
       }
       server {
         listen 443 ssl http2;
         server_name nginx-1.local;
         access_log  /var/log/nginx/nginx-1.local.access.log main;
         error_log   /var/log/nginx/nginx-1.local.error.log debug;
         ssl_certificate     ssl/server.crt;
         ssl_certificate_key ssl/server.key;
         #ssl_client_certificate ssl/ca.crt;
         #ssl_verify_client on;
         location / {
           proxy_pass http://backend;
         }
       }  

7. Раскомментируем строки ssl_client_certificate и ssl_verify_client в кинфиге, который мы принесли в п.6 и раскатим
   этот конфиг. Теперь у нас не получится выполнить проверку командой проверки из п.6. Для того чтобы теперь обратиться
   к серверу нужно указать сертификат. Для этого выполним такую команду:
   ```bash
    curl --cacert ssl/ca.crt --cert ssl/client.crt --key ssl/client.key -L 127.0.0.1:8081
   ```
   В данном случае -k не требуется, т.к. мы знаем всю цепочку целиком, указывая ca.crt.

   На данном этапе считаем основную часть ЛР законченной. Дальнейшие пункты могут быть выполнены по желанию и описаны
   они менее подробно, рассчитывая что это задача "со звёздочкой"

8. Ограничиваем доступ только для конкретных сертификатов.

   Для того чтобы ходить могли только конкретные сертификаты, нужно рассказать nginx какие из них доверенные. это
   сделать можно например проверяя сериал или хеш сертификата, в данном случае сериал. получаем его так:

   ```bash
   cert=filename.crt serial=$(openssl x509 -in ${cert} -text -noout | grep -A1 Serial | grep -v Serial | tr -d ' ') && \
   echo classic serial: $serial && \
   echo \$ssl_client_serial: $(echo $serial | tr -d ":" | tr '[:lower:]' '[:upper:]')
   ```

   Для этой задачи сгенерируйте еще 2 клиентских сертификата, получите serial и интегрируйте в конфиг

   ```text
   map $ssl_client_serial $reject {
    default 1;
    ..........C5CE16 0; #client1
    ..........635A2D60 0; # client2
   }
   server {
   ...
   location / {
     if ($reject) { return 403; }
     proxy_pass http://backend;
   }
   ....
   ```

   После указанных процедур, приниматься будут только те сертификаты которые указаны в map. Попробуйте поиграться с
   сертификатами добавляя и убирая строки из map чтобы понять что будет возвращать nginx для разрешённого и
   неразрешённого сертификатов.

9. Опционально попробуйте директивы allow и deny для того чтобы разрешить подключаться только с определённых адресов.
