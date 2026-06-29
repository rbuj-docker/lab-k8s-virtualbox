# sudo sense contrasenya

Per fer que sudo no demani la contrasenya cada vegada l'usuari `student` executa una ordre, es pot fer de dos maneres:

Modificant el fitxer `/etc/sudoers` amb l'ordre `visudo` i afegint la següent línia al final del fitxer:

```text
student ALL=(ALL) NOPASSWD: ALL
```

o bé creant un fitxer nou a `/etc/sudoers.d/` amb el nom `student` i afegint-hi la mateixa línia:

```text
student ALL=(ALL) NOPASSWD: ALL
```

Després cal modificar els permisos del fitxer amb l'ordre:

```bash
sudo chmod 440 /etc/sudoers.d/student
```

Per validar que la configuració és correcta, es pot executar l'ordre següent:

```bash
sudo visudo -cf /etc/sudoers.d/student
```
