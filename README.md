# MyTrack
Приложение iOS для трекинга прогулок.

![Shot](https://github.com/DenDmitriev/MyTrack/assets/65191747/7fb86231-2bd7-4912-b588-ee9678f16d99)

# Начало
Я хотел научится работать с картой, получать координаты и обрабатывать их. Попытаться реализовать большинство возможных функций [Google Maps SDK](https://developers.google.com/maps/documentation/ios-sdk/overview?hl=ru):
  - рисование и окрашивание сплайна;
  - установка маркера на картк;
  - перемещение камеры на карте;
  - обрабатывает получаемые данные и показывать их в понятном виде.

# Содержание
- [Возможности](#возможности)
- [Реализация](#реализация)
  - [UIKit](#uikit)
  - [GoogleMaps](#googlemaps)
  - [RealmSwift](#realmswift)
  - [RxSwift](#rxswift)
- [TODO](#todo)

# Возможности
Главный экран реализован с использованием [Google Maps SDK](https://developers.google.com/maps/documentation/ios-sdk/overview?hl=ru). Приложение по кнопке СТАРТ начинает создавать трек пользователя по координатам. Отображается путь полилинией, которая окрашивается в цвет исходя из скорости перемещения пользователя с устройством. Для понимания логики окрашивания, есть выбор настройки типа прогулки внизу экрана. При прогулке есть скорость, путь и время, эти данные приложение показывает в удобном отформатированном варианте. При завершении трекинга, по кнопке ФИНИШ, приложение сохраняет трек. Прогулки можно увидеть по кнопке список. В ячейках трека приводится сводная информация и название района прогулки.

# Реализация
Библиотеки
- [UIKit](#uikit)
- [Google Maps SDK](#google-maps-sdk)
- [RealmSwift](#realmswift)
- [RxSwift](#rxswift)

## UIKit
Интерфейс приложения реализован классическим способом. 
За координацию контроллеров отвечает Coordinator. У каждого flow есть свой storyboard. Передаются данные между контроллерами через замыкание.
https://github.com/DenDmitriev/MyTrack/blob/1e961673b4d2e93221716e2cc1aea562ceee5db3/MyTrack/Flows/Track/TrackCoordinator.swift#L23-L37

## Google Maps SDK
Показ карты на экране и навигацию по нему осуществляет Google Maps SDK. Код начальной настройки.
https://github.com/DenDmitriev/MyTrack/blob/1e961673b4d2e93221716e2cc1aea562ceee5db3/MyTrack/Flows/Track/Track/TrackViewController.swift#L107-L115

Создание сплайна осуществляется следующей функцией
https://github.com/DenDmitriev/MyTrack/blob/1e961673b4d2e93221716e2cc1aea562ceee5db3/MyTrack/Flows/Track/Track/TrackViewController.swift#L312-L326

Установка маркера на карту
https://github.com/DenDmitriev/MyTrack/blob/1e961673b4d2e93221716e2cc1aea562ceee5db3/MyTrack/Flows/Track/Track/TrackViewController.swift#L117-L122

## RealmSwift
Хранения треков пользователя и точек локаций в нем
https://github.com/DenDmitriev/MyTrack/blob/1e961673b4d2e93221716e2cc1aea562ceee5db3/MyTrack/Model/Track.swift#L11-L16

## RxSwift
 - Подписки для обновления данных трека
 - Подписки для заполнение полей логина и пароля

![Auth](https://github.com/DenDmitriev/MyTrack/assets/65191747/300a2d78-3fac-4b79-8d32-e5780cf12508)

# TODO
- [ ] Добавить FireBase для сохранения профиля пользователя и его координат
- [ ] Добавить на окно профиля возможность загрузки фотографии пользователя и свойства
