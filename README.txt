Автоматично
sudo ./deployFromServer.sh 10.168.103.70 deck 11111111 "-P 2222 pi@77.222.152.213" 11111111

В ручну
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

sshpass
echo "11111111" | sshpass  ssh-copy-id -f -i keyTo0007 deck@10.168.103.7





 