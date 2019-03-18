# Пояснительная записка к л\р №2

## Требования к инструментам для выполнения л\р:

* Средства виртуализации, например Virtualbox
* Установленная виртуальная машина с ОС Linux, например Debian 9
* Наличие интернета для скачивания нескольких пакетов
* Подключение по ssh к установленной VM

## Лабораторная работа состоит из 3-х частей:

* настройка работоспособной системы с использованием lvm, raid
* эмуляция отказа одного из дисков
* замена дисков на лету, с добавлением новых дисков и переносом разделов.

## Задание 1 (Установка ОС и настройка LVM, RAID)

1) Создайте новую виртуальную машину, выдав ей следующие характеристики:
* 1 gb ram
* 1 cpu
* 2 hdd (назвать их ssd1, ssd2 и назначить равный размер)

![select ssd disks](https://raw.githubusercontent.com/bykvaadm/OS/master/admin/lab2/images/disks-ssd.png)


2) Начать установку Linux и дойдя до выбора жестких дисков сделать следующее:
* Partitioning method: maual, после чего вы должны увидеть такую картину:
![partition disks](https://raw.githubusercontent.com/bykvaadm/OS/master/admin/lab2/images/VirtualBox_lab2_18_03_2019_17_21_05.png)
* Настройка RAID: Выберите первый диск и создайте на нем новую таблицу разделов
  * В качестве типа раздела выберите physical volume for RAID
  * Выберите "Done setting up the partition"
  * Повторите точно такую же настройку для второго диска, в результате получив следующее:
  ![partition disks](https://raw.githubusercontent.com/bykvaadm/OS/master/admin/lab2/images/VirtualBox_lab2_18_03_2019_17_23_37.png)
  * Выберите пункт "Configure software RAID"
    * Create MD device
    * Software RAID device type: Выберите зеркальный массив
    * Active devices for the RAID XXXX array: Выбрать оба диска
    * Finish
  * В итоге вы должны получить такую картину:
  ![partition disks](https://raw.githubusercontent.com/bykvaadm/OS/master/admin/lab2/images/VirtualBox_lab2_18_03_2019_17_25_05.png)
* Настройка LVM: Выберите Configure the Logical Volume Manager
  * Keep current partition layout and configure LVM: Yes
  * Create volume group
  * Volume group name: system
  * Devices for the new volume group: Выберите ваш созданный RAID
  * Create logical volume
    * logical volume name: root
    * logical volume size: 2\5 от размера вашего диска
  * Create logical volume
    * logical volume name: var
    * logical volume size: 2\5 от размера вашего диска
  * Create logical volume
    * logical volume name: log
    * logical volume size: 1\5 от размера вашего диска
  * Выбрав Display configuration details вы должны получить следующую картину:
  ![partition disks](https://raw.githubusercontent.com/bykvaadm/OS/master/admin/lab2/images/VirtualBox_lab2_18_03_2019_17_46_46.png)
  * Завершив настройку LVM вы должны увидеть следующее:
  ![partition disks](https://raw.githubusercontent.com/bykvaadm/OS/master/admin/lab2/images/VirtualBox_lab2_18_03_2019_17_47_24.png)
* Разметка разделов: по-очереди выберите каждый созданный в LVM том и разметьте его:
  * Use as: ext4
  * mount point: /
  * результат разметки корневого раздела должен получиться таким:
  ![partition disks](https://raw.githubusercontent.com/bykvaadm/OS/master/admin/lab2/images/VirtualBox_lab2_18_03_2019_17_47_38.png)
  * повторите операцию разметки для var, log выбрав соответствующие точки монтирования, получив следующий результат:
  ![partition disks](https://raw.githubusercontent.com/bykvaadm/OS/master/admin/lab2/images/VirtualBox_lab2_18_03_2019_17_48_23.png)
* Финальный результат должен получиться вот таким:
![partition disks](https://raw.githubusercontent.com/bykvaadm/OS/master/admin/lab2/images/VirtualBox_lab2_18_03_2019_17_48_31.png)

3) Закончить установку ОС и загрузиться в нее
4) Выполнить установку grub на второе устройство
* посмотреть диски в системе: fdisk -l
* Перечислите все диски которые вам выдала предыдущая команда и опишите что это за диск
* Найдите диск на который не была выполнена установка grub и выполните эту установку:
```grub-install /dev/XXXX```
где ХХХХ - найденный диск.
* просмотрите информацию о текущем raid командой cat /proc/mdstat и запишите что вы увидели.
* посмотрите выводы команд: pvs, vgs, lvs, mount и запишите что именно вы увидели

Опишите своими словами что вы сделали и какой результат получили в ите проделанного задания

## Задание 2 (Эмуляция отказа одного из дисков)

1) Найдите директорию, где хранятся файлы вашей виртуальной машины
2) Выполните принудительное удаление диска ssd1.vmdk
3) Убедитесь что ваша виртуальная машина по-прежнему работает
4) Выполните перезагрузку виртуальной машины и убедитесь что она по-прежнему работает
5) Выключите виртуальную машину и удалите диск ssd2 из ее свойств. Загрузите виртуальную машину и убедитесь что она все еще работает
6) проверьте статус RAID-массива: cat /proc/mdstat
7) добавьте в интерфейсе VM новый диск такого же размера
8) выполните операции:
* посмотрите что новый диск приехал в систему командой fdisk -l
* скопируйте таблицу разделов со старого диска на новый: sfdisk -d /dev/XXXX | sfdisk /dev/YYY
* посмотрите результат командой fdisk -l
* Добавьте в рейд массив новый диск: mdadm --manage /dev/md0 --add /dev/YYY
* Посмотрите результат: cat /proc/mdstat. Вы должны увидеть что началась синхронизация
9) После завершнения синхронизации установите grub на новый диск
10) Выполните перезагрузку ВМ, для того чтобы убедиться что все работает

Опишите своими словами что вы сделали и какой результат получили в ите проделанного задания

## Задание 3 (Добавление новых дисков и перенос раздела)