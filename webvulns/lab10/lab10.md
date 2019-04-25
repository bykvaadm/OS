# Работа 10 Практика

[http://cats.p.myctf.ru/](http://cats.p.myctf.ru/)

```php
if (!isset($_COOKIE['username']) || empty($_COOKIE['username']))
{
    setcookie('username', base64_encode(serialize('user')), time()+3600, '/', '',0);
}
?>
```

```php
<?php
if (isset($_COOKIE['username']) && !empty($_COOKIE['username']))
{
    $username = unserialize(base64_decode($_COOKIE['username']));
    echo "<strong>Hello, ".$username."</strong>!<br/>";
    echo "Some news for you: <br/>";
    echo new FileClass();
}
?>
```