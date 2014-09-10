# BirjaKreditov API on Rails!

## Дизклеймер

Простой враппер для запросов к API birjakreditov.com. 
Гем писался для личного использования и **никак не претендует на звание официального**.

## Установка

Сначала генерируем конфиг и настраиваем его под себя, убирая комментарии:

``` ruby
rails g birja_kreditov:initializer
```

Генерируем миграцию и убираем комментарии с несуществующих строк:

``` ruby
rails g active_record:birja_kreditov
```

Не забываем про команду `rake db:migrate` после настройки файла миграции.

## Возможности

### Словари

``` ruby
# Статусы
BirjaKreditov::Status.all # {"10"=>"Новые", "1"=>"В магазине", "2"=>"На доработке" ...}
BirjaKreditov::Status[10] # "Новые"

# Причины отказов
BirjaKreditov::Reason.all # {"1"=>"Купил за наличные", "2"=>"Передумал брать кредит" ... }
BirjaKreditov::Reason[30] # "Клиент из другого региона (невозможно осуществить доставку)"

# Запрос к серверу делается один раз. Потом все это кешируется. 
# Если вдруг надо пересинхронизировать с сервером БК:
BirjaKreditov::Status.reload!
BirjaKreditov::Reason.reload!
```

### XML Builder

Для построения xml можно использовать класс `BirjaKreditov::Builder`. Данный класс автоматически подписывает пакет с помощью ключа, указанного в конфиге. Используется гем Nokogiri.

``` ruby
@xml = BirjaKreditov::Builder.new

# Если у вас уже есть некий XML и вы хотите его просто подредактировать
# Если структура xml не подходит под структуру Биржи, то получите ошибку bad xml
@xml = BirjaKreditov::Builder.new(xml: '<xml....'>)

# Если вам нужен пакет без данных для аутентификации
@xml = BirjaKreditov::Builder.new(with_auth_data: false)

# Иногда для запросов используется PartnerID, а иногда StoreID
# смотрите документацию API на сайте БК, чтобы выбрать нужное
@xml.set_partner         # добавить ноду PartnerID
@xml.set_store           # добавить ноду StoreID
@xml.set_partner(123456) # установить кастомный ID

# Информация о клиенте
@xml.user = {
  email: 'example@bk.ru',
  phone: '9001234567',
  first_name: 'Иван',
  last_name: 'Петров',
  middle_name: 'Васильевич'
}

# Информация о товарах
# Либо хэш (для одного товара), либо массив хэшей (для нескольких товаров)
# Ключи: { :name, :details, :price, :quantity, :image, :articul, :url }
# Обязательные ключи: :name, :price, :quantity
@xml.products = { name: 'Последний айфон', price: 50000, quantity: 1 }
# или
@xml.products = [
  { name: 'Последний айфон', price: 50000, quantity: 1 },
  { name: 'Чехол для последнего айфона', price: 3000, quantity: 2 }
]

# Установить идентификатор заявки со стороны приложения
@xml.uid = '№9023-12'

# Добавить свою кастомную ноду
# Параметры: куда добавить, ключ, значение
# Куда добавить: @xml.xml_package_data - нода PackageData, @xml.xml_root - нода Root
@xml.add_node @xml.xml_package_data, 'Key', 'some value'

# Посмотреть результат сформированного XML
@xml.body
```

### Общение с API

Взаимодействие с API происходит в формировании `BirjaKreditov::Request` и получением и обработкой  `BirjaKreditov::Response`

``` ruby
# Пример.
# Создание запроса на добавление кредитной заявки с помощью API сервиса 'order'
@response = BirjaKreditov::Request.fetch 'order', @xml

@response.success?  # ответ пришел положительный?
@response.failure?  # ответ пришел с ошибкой?

@response.verified? # пакет подписан корректно?

@response.body      # ответ от сервера
@response.xml       # ответ от сервера в виде объекта Nokogiri
```

### Обработка запросов от API

Когда статус заявки меняется, то сервер БиржиКредитов может сделать запрос на ваш сервер с сообщением об этом.

Для начала надо подготовить контроллер:

``` ruby
class BirjaKreditovController < ApplicationController
  include BirjaKreditov::ResponseController
  layout false
end
```

И добавить нужные роуты:

``` ruby
# config/routes.rb

# include BirjaKreditov routes
birja_kreditov_response
```

По умолчанию адрес для БК будет: `www.your-project.com/birja_kreditov/update_info`
