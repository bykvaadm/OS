auditbeat
---

Elastic auditbeat для сбора важных событий ОС в хранилище департамента информационной безопасности.

### Переменные
- **`auditbeat_docker_image_tag`** (не обязательно)  
  Актуальный тег официального Docker образа [docker.elastic.co/r/beats/auditbeat](https://www.docker.elastic.co/r/beats/auditbeat), поддерживаемый ролью.  
  Пример: `7.10.2`
- **`security_elastic_beat_kafka_brokers`** (обязательно)  
  Список Kafka брокеров департамента информационной безопасности для транспорта событий.  
  Пример: `[eskfk1.city-srv.ru:9092, eskfk2.city-srv.ru:9092, eskfk3.city-srv.ru:9092]`

- **`security_elastic_beat_kafka_ca`** (обязательно)  
  Контент файла корневого сертификата(CA / Certificate Authority) для валидации серверных сертификатов Kafka брокеров.  
  Пример:
  ```
  -----BEGIN CERTIFICATE-----
  MIIDmTCCAoGgAwIBAgIJAOaoAB0t/tgfMA0GCSqGSIb3DQEBCwUAMGMxHjAcBgNV
  ...
  W2uuWxGIjt6zDw8X/g==
  -----END CERTIFICATE-----
  ```
