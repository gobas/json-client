# JSON-Client
Mit dem JSON-Client können User, Topics und Sample Daten in die Webanwendung gepushed werden.

## Konfiguration

### run.rb
Sample Dateien:
    @samp_images = "../sample/images"
    @samp_videos = "../sample/videos"
    @samp_audios = "../sample/audio"

Einmal unter `Global Config` die Default Werte für die Webanwendung:
Dieser Werte werden benutzt, wenn neue User angelegt werden.
    @host = "failinc.localhost.local"
    @port = "8080"

Hiermit werden die beiden Default User konfiguriert, die initial benötigt werden, um üerhaupt neue User anlegen zu können.
    @@first_user = {}
    @@first_user[:user] = "test"
    @@first_user[:host] = @host
    @@first_user[:port] = @port

    @@second_user = {}
    @@second_user[:user] = "aaron"
    @@second_user[:host] = @host
    @@second_user[:port] = @port

In der `lib/client.rb` muss nichts mehr konfiguriert werden.

### runs.yml
Die `runs.yml` beschreibt den run, der durchgeführt werden soll:
Es gibt 2 Kategorien: **user** und **creations**:

User Syntax:
    <name>:
      login: <name>
      password: <passwort>
      email: <email>

Creations Syntax:
    <user>:                        #user name, unter dem folgendes geschehen soll
      {topics, medias}: <number>   #Legt number viele topics, medias an
      invite:
        user: <user>               #Lädt <user> für <number> viele random
        number_t: <number>         #topics ein
      user:
        <user>:                    #Legt einen neuen Benutzer an,
        .......                    #nach dem Schema, wie oben