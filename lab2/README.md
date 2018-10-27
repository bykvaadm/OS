# Пояснительная записка к л\р №2

## Требования к инструментам для выполнения л\р:
* UNIX-окружение, например ОС Debian 9.5.
* пакет build-essential

## компиляция и запуск

Для компиляции использовать такую команду:

```
gcc -o binary_name sources_name.c
```

Для запуска использовать один из вариантов:

```
sh binary_name
./binary_name
/path/to/binary_name
```

## Задание
1. Написать программу, которая делает системный вызов fork(). Перед вызовом fork() в главной функции main() должна задаваться некоторая переменная и присваиваться ей некоторое значение. Вывести значение переменной в родителе и в потомке. Изменить значение переменной в родителе и потомке в процессе их выполнения. Вывести значения на экран. Какое значения у вас получились? Почему? Что произойдет с переменной, когда и родитель и потомок изменят ее значение? Почему?
2. Написать программу, открывающую файл (например с помощью системного вызова open()), а затем делающую вызов fork() для создания нового процесса. Могут ли и родитель и потомок иметь доступ к файловому дескриптору, который возвращается после вызова open()? Что произойдет если и предок и потомок будут писать в этот файл одновременно?
3. Напишите программу, использующую вызов fork(). Процесс-ребенок должен вывести приветственное сообщение, а проесс-родитель должен вывести прощальное сообщение. Следует убедиться, что процессы выводят строки в правильном проядке. Можно ли сделать это без использования вызова wait()?
4. Напишите программу, делающую системный вызов fork() а после него вызов exec() для запуска программы ls. Попробуйте все варианты этого вызова (execl(), execle(), execlp(), execv(), execvp(), execvpe()). Почему существует такое количество вариантов одного и того же вызова?
5. Напишите программу, которая использует вызов wait() для ожидания потомка. Что возвращает вызов wait()? Что произойдет, если использовать вызов wait() в потомке?
6. Модифицируйте предыдущую программу, использовав waitpid() вместо wait(). Когда новый вызов может быть полезен?
7. Напишите программу, которая создает дочерний процесс, а затем закрывает в потомке поток стандартного вывода (STDOUT_FILENO). Что произойдет когда потомок вызовет функцию printf() для вывода какой-либо информации после закрытия дескриптора?
8. Напишите программу, которая нескольких потомков и соединяющаяя стандартный поток вывода одной программы со стандартным потоком ввода другой, используя системный вызов pipe().
9. Выполните команду: chmod -x /bin/chmod. Напишите программу, которая вернет флаг исполнения этой программе.