Другій стімдек.
== Створити папку /home/deck/Downloads/UpDt

== Скопіювіти файли в папку /home/deck/Downloads/UpDt
autorunSoftUpdate.sh
SoftUpdate
ToUpdateFromServer.sh
або
розархівувати файл
/SoftUpDt.7z

sudo chmod -R 777 /home/deck/Downloads/UpDt

== Налаштування Linux
Перевірити sudo без паролю
В файлі /etc/sudoers.d/wheel розкрментувати стрічку
%wheel ALL=(ALL) NOPASSWD:ALL
В файлі /etc/sudoers розкоментувати стрічки
root ALL=(ALL:ALL) ALL
%wheel ALL=(ALL:ALL) NOPASSWD: ALL
%sudo ALL=(ALL:ALL) ALL

echo "%wheel ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/wheel >/dev/null

Створення ярлика
Права кнопка миші на desktop / Create new / Link to Application… / 
	/ Application / Name: SoftUpdate 
	/ Application / Program: шлях до програми оновлення
	/ Application / Argument: –update
	/ Application / Work path: шлях до папки програми оновлення

Автозапуск при увівкненні
/System Settings / Autostart / + Add New (вверху зліва) / +Application… 
/ Browse / шлях до програми оновлення
