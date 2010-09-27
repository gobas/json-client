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
    <number>                        #running order
      <user>:                       #user name, unter dem folgendes geschehen soll
        topics: <number>            #Legt number viele topics an
        images: <number>            #Legt number viele images an
        videos: <number>            #Legt number viele videos an
        audios: <number>            #Legt number viele audios an
        invites:
          user: <user>              #Lädt <user> für <number> viele random
          number_t: <number>        # topics ein
        accept: <number>            #akzeptiert number viele invites
        ignore: <number>            #ignoriert number viele inites
        user:
          <user>:                   #Legt einen neuen Benutzer an,
          .......                   # nach dem User Schema, wie oben