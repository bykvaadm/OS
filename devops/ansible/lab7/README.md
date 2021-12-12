# Simple nginx setup role


1) каким либо способом генерим сертификаты. Хорошо описано вот здесь: https://habr.com/ru/post/213741/#comment_10231686
По сути нам нужно будет получить пару для УЦ, пару для nginx, и N пар для клиентов. там же написано как это подключить, чтобы требовало проверки, используя  ssl_client_certificate и ssl_verify_client on;
2) для того чтобы ходить могли только конкретные сертификаты, нужно рассказать nginx какие из них доверенные. это сделать можно например проверяя сериал или хеш сертификата, в данном случае сериал. получаем его так:

cert=filename.crt
serial=$(openssl x509 -in ${cert} -text -noout | grep -A1 Serial | grep -v Serial | tr -d ' ') && \
echo classic serial: $serial && \
echo \$ssl_client_serial: $(echo $serial | tr -d ":" | tr '[:lower:]' '[:upper:]')

и интегрируем

    map $ssl_client_serial $reject {
        default 1;
        ..........C5CE16 0; #client1
        ..........635A2D60 0; # client2
    }
    server {
....
      location / { deny all; }
      location /secret {
        if ($reject) { return 403; }

тут мы запрещаем ходить везде кроме особого роута, чтобы клиент не мог случайно попасть на случайно открытые роуты которые ему не предназначены (когда разраб накосяпорил и выставил какой-то роут с дебагом или метриками)
3) получаем список ip подрядчика и пишем в роуте стандартные allow-deny

        allow 1.2.3.4 # client1
...
        deny all;
4) в качестве дополнительной проверки передаём апстриму инфу о том что за клиент пришёл

proxy_set_header X-Subject-Name $ssl_client_s_dn;

Таким образом, только конкретный ip только имея конкретный сертификат может сходить только на конкретный роут и о том какой пришёл клиент узнаёт бекэнд.


УЦ -> private.key CA
->
->->->->->->
->->
->->->

-> Server -> ssl_server.key ssl_server.crt CA
-> Client -> ssl_client.key ssl_client.crt CA !!!!!!


 {clients} ->>>>>   :443[nginx gw]  :9000 [application] (:22, 80, 123123)
 -> company.com {
   proxy_pass {
     app:9000 weight 1;
     app1:123 weight 50;
     app2:1231 weight 49;
   }
 }
 
company.com/apiv1 -> 10xApp1
company.com/apiv2 -> 24xApp2