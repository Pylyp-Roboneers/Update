АВТОМАТИЧНЕ РОЗГОРТАННЯ  
sudo ./deployFromServer.sh 10.168.103.70 deck 11111111 "-P 2222 pi@77.222.152.213" 11111111
sudo ./deployFromServer.sh AlowVPNadress deck Steam_PW "-P 2222 pi@77.222.152.213" ServerPW

AlowVPNadress  дозволена VPN адреса
deck           user name steamdeck
Steam_PW       пароль steamdeck
"-P 2222 pi@77.222.152.213" адреса сервера в формі scp команди
ServerPW       пароль сервера

ОПИС роботи програми розгортання

1) /home/deck/Downloads/deployFromServer.sh  на стімдеку клієнт
- Перевірка інтернет підключення
- Перевірка з'єднання з Сервером
- Перевірка встановлення програми sshpass, щоб не використовувати ssh пароль. Якщо програма не встановлена то встановлює її
- Перевірка ssh паролю до сервера
- Перевірка, чи вказана дозволена VPN адреса (перший аргумент AlowVPNadress) ще не використовується на сервері: якщо використовується то програма завершується
- Копіює архівний файл з програмою розгортання з Сервера на стімдек
- Розархівовує файл з програмою розгортання
- Запускає програму розгортання на стімдеку SoftUpdateDeploy.sh розархівованих файлів
 
2) /home/deck/Downloads/UpDt/0_SoftUpdate/SoftUpdateDeploy.sh
- Визначає Inet адресу стімдека для wireguard конфігурації 
- Визначає підключення до інтернету та наявність з'єднання з сервером
- Створює ярлик програми оновлення 
- Створює автозапуск програми оновлення 
- Змінює конфігурацію Linux, щоб sudo було без паролю  
- Визначає наявність необхідних програм: 
             resolvconf - для розв'язання конфлікту конфігурації wireguard 
             net-tools - щоб прочитати поточну inet адресу стімдеку  
             sshpass
             wireguard
- Створює ключи wireguard
- Створює wireguard конфігураційний файл клієнта на стімдеку 
- Створює абзац peer для конфігураційного файлу сервера
- Перезавантажує wireguard на стімдеку
- Копіює по ssh на сервер файл з peer для конфігураційного файлу сервера
- Запускає на сервері програму розгортання  /home/pi/deploy через ssh

3) /home/pi/deploy на сервері
- Додає абзац Peer в конфігураційний файл wireguard (wg0.conf) який був надісланий зі стемдека
- Перезапускає wireguard
- Пингую наву адресу wireguard
- Генерує нові ключи ssh з'єднання
 - Копіює ключ клієнту (стімдек) функцією ssh-copy-id
- Додає стрічку в список клієнтів на сервері 


РОЗГОРТАННЯ В РУЧНУ
- Перевірити підключення стімдека до Інтернету
ping 8.8.8.8
або значок на панелі завдань
- Перевірити з'єднання з Сервером
ping 77.222.152.213
- Скопіювати архівний файл програми оновлення з Сервера на стімдек
scp -P 2222 pi@77.222.152.213:/home/pi/theWD/SoftUpDt.7z /home/deck/Downloads/
- На стімдеці розархівувати файл  SoftUpDt.7z,
cd /home/deck/Downloads/; sudo chmod 777 SoftUpDt.7z; sudo 7z x -y SoftUpDt.7z; sudo chmod -R 777 UpDt/
З'явиться папка UpDt
- запустити  програму розгортання
sudo /home/deck/Downloads/UpDt/0_SoftUpdate/SoftUpdateDeploy.sh 10.168.103.7
- (необов'язково) перевірити створення конфігураційних файлів
sudo -s
cd /etc/wireguard/; ls -l; cat includeToServer_wg0_conf.txt
Повинно створитись чотири файли
#total 4
#-rw-r--r-- 1 root root 200 Jun 30 13:40 includeToServer_wg0_conf.txt
#-rw-r--r-- 1 root root  45 Jun 30 13:40 privatekey
#-rw-r--r-- 1 root root  45 Jun 30 13:40 publickey
#-rw-r--r-- 1 root root 331 Jun 30 13:40 wg0.conf
- копіювати вміст файлу includeToServer_wg0_conf.txt та додати в файл на сервері. 
Для цього зайти по ssh на сервер та вставити wg0.conf в файлі скопійований вміст. Після цього перезавантажити Сервер
sudo -s
sudo nano /etc/wireguard/wg0.conf
ctrl+o що зберегти
- Перезавантажити wireguard на стімдеку
sudo systemctl start wg-quick@wg0
sudo systemctl reload wg-quick@wg0
- Перезавантажити wireguard на Сервері
sudo systemctl reload wg-quick@wg0
- перезавантаження стімдек та перевірити зв'язок з сервером по VPN
ping 10.168.103.7
- Зайти на Сервер та створити SSH ключ зєднання сервера зі стімдеком
sudo ssh-keygen -R 10.168.103.7; sudo ssh-keygen -R 10.168.103.7; sudo /home/pi/theWD/setSSHconnection.sh deck@10.168.103.7 keyTo10.168.103.7
зачекати (???)
- Перевірити ssh зєднання з Сервера до стімдека 
ssh -i keyTo10.168.103.7 deck@10.168.103.7	
- Додати стрічку на Сервері /home/pi/theWD/ClientList.txt
10.168.103.7 update.7z NON_SHA deck /home/deck/Downloads/UpDt/ /home/pi/.ssh/keyTo10.168.103.7
- Створення ярлика на стімдеці
Права кнопка миші на desktop / Create new / Link to Application… / 
	/ Application / Name: SoftUpdate 
	/ Application / Program: шлях до програми оновлення
	/ Application / Argument: –update
	/ Application / Work path: шлях до папки програми оновлення
- Автозапуск при увімкненні на стімдеці
/System Settings / Autostart / + Add New (вверху зліва) / +Application… 
/ Browse / шлях до програми оновлення
Перезавантажит стімдек
