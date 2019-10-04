# Пояснительная записка к л\р №1

## Требования к инструментам для выполнения л\р:
* UNIX-окружение, например ОС Debian 9.9.
* Установленный ansible
* Развернутые 2-4 виртуальных машины на Linux:
  - Ресурсы выдавать по-минимуму (например 1 ядро, 256mb ram)
  - Возможно использование различных семейств: Centos, ubuntu, debian...
  - Поднять машинки можно с помощью приложенного файла Vagrant и одноименной утилиты vagrant (рекомендованный способ)

### Итоговая конфигурация виртуальных машин:


```
VM1:
  name: web1
  ip  : 192.168.33.10
  port: 2001
VM2:
  name: web2
  ip  : 192.168.33.20
  port: 2002
VM3:
  name: db1
  ip  : 192.168.33.30
  port: 2003
VM4:
  name: db2
  ip  : 192.168.33.40
  port: 2004
```

### Задание

Выбрать место, откуда вы будете работать с ansible, все дальнейшие интсрукции рассчитаны на работу в одной виртуальной машине (или на хосте, смотря где у вас ansible)

0) Установить ansible

https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html

1) Внести в конфиг /etc/ansible/ansible.cfg в директиву строчку

```text
[defaults]
host_key_checking = False
```

2) на хосте с ansible создать некоторую директорию, в которой предполагается вся дальнейшая работа. в этой директории создать файл hosts, в который будет помещена информация о способе подключения к остальным серверам. Пример для одной машины.

```text
[group_name]
vm_name ansible_host=XXX ansible_user=vagrant

```

Где ххх - это ip адрес машины, посмотреть его можно с помощью команды `ip a`
Дописать для всех 4 машин.

3) Проверяем работоспособность

```
ansible all -i hosts -m ping
```

```text
ansible all -i hosts -m shell -a 'free -m'
```

4) Создать пробный site.yaml. В нем необходимо написать задачу установки веб-сервера nginx на группу веб серверов.
Обратитесь к документации модуля установки программ: https://docs.ansible.com/ansible/latest/modules/apt_module.html


```text

---
- hosts: web
  tasks:
  - name: Install apache httpd but avoid starting it immediately (state=present is optional)
    apt:
      name: nginx
      state: present
```

Запустите playbook:

```text
ansible-playbook -i hosts site.yaml -b
```
