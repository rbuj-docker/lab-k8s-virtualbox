# Creació d'un entorn de laboratori per a Kubernetes amb VirtualBox

En aquest laboratori, es crearà un entorn de Kubernetes utilitzant VirtualBox com a plataforma de virtualització. L'objectiu és proporcionar un entorn de prova i desenvolupament per a Kubernetes, permetent als usuaris experimentar amb la configuració i gestió de clústers de Kubernetes en un entorn controlat.

El laboratori es compatible amb els cursos de The Linux Foundation:

- [Kubernetes Fundamentals (LFS258)](https://training.linuxfoundation.org/training/kubernetes-fundamentals/)
- [Kubernetes for Developers (LFD259)](https://training.linuxfoundation.org/training/kubernetes-for-developers/)
- [Kubernetes Security Essentials (LFS260)](https://training.linuxfoundation.org/training/kubernetes-security-essentials/)

Es crearan dues màquines virtuals amb VirtualBox: una per al node mestre (control plane) i una altra per al node de treball (worker node). Aquestes màquines virtuals s'utilitzaran per desplegar un clúster de Kubernetes i experimentar amb les seves funcionalitats.

El sistema operatiu amfitrió (host) que allotjarà les màquines virtuals és un sistema operatiu macOS Tahoe amb VirtualBox instal·lat. Les màquines virtuals utilitzaran [Ubuntu Server 26.04 LTS (arm)](https://ubuntu.com/download/server/arm) com a sistema operatiu convidat (guest OS).

Generació de les claus SSH per accedir a les màquines virtuals sense contrasenya:

```bash
ssh-keygen -t rsa -b 4096 -C "k8s-lab-student" -f ~/.ssh/id_rsa_k8s-lab-student
```

## Creació de la màquina virtual del node mestre

Recursos de la màquina virtual del node mestre:

- Memòria RAM: 2 GB (2048 MB)
- Disc dur virtual: 20 GB (dinàmicament assignat)
- CPUs: 2
- Xarxes de la màquina virtual:
  - NIC1 = NAT → sortida a internet + SSH via port forwarding (2222:22)
  - NIC2 = xarxa interna → comunicació entre nodes del clúster

Podem crear la màquina virtual del node mestre amb VirtualBox utilitzant la interfície gràfica i la línia d'ordres. A continuació, es detallen els passos per crear la màquina virtual del node mestre.

> [!IMPORTANT]
> La creació de la màquina virtual  també es pot fer de manera desatesa amb l'script [vb-k8s-master.sh](./scripts/vb-k8s-master.sh).

> [!TIP]
> La màquina virtual es pot eliminar amb la comanda següent:

```bash
VBoxManage unregistervm k8s-master --delete
```

> [!TIP]
> Per comprovar que la màquina virtual s'ha creat correctament, podeu utilitzar la comanda següent:

```bash
VBoxManage list vms
```

> [!TIP]
> Després de crear la màquina virtual del node mestre, podeu iniciar-la amb la comanda següent:

```bash
VBoxManage startvm k8s-master --type headless
```

> [!TIP]
> Per aturar la màquina virtual del node mestre, podeu utilitzar la comanda següent:

```bash
VBoxManage controlvm k8s-master acpipowerbutton
```

> [!TIP]
> L'estat de la màquina es pot comprovar amb la següent ordre:

```bash
VBoxManage guestproperty enumerate k8s-master
```

1. Obriu VirtualBox i feu clic a "Nou" per crear una nova màquina virtual.
2. Instal·leu Ubuntu Server a la màquina virtual amb instal·lació desatesa. Creeu una nova màquina virtual per mostrar els diàlegs:
   1. `Virtual machine name and operating system`
      - VM Name:"k8s-master"
      - Marqueu la casella "Proceed with Unattended installation"
      - Seleccione el camí al fitxer ISO d'Ubuntu Server 26.04 LTS (arm) que heu baixat.
   2. `Set up user unattended guest OS installation`
      - User name: "student"
      - Password: "k8s12345"
      - Confirm password: "k8s12345"
      - Hostname: "k8s-master"
      - Domain name: "laboratory.org"
   3. `Specify virtual hardware`
      - Base Memory: 2048 MB
      - Number of CPUs: 2
      - Marqueu la casella "Use EFI"
   4. `Specify virtual hard disk`
      - Seleccioneu l'opció `Create a virtual hard disk now`
      - Disk Size: 20 GB
      - Hard Disk File Type and Format: VDI (VirtualBox Disk Image)
        - no marqueu la casella `Pre-allocate Full Size` perquè volem que el disc dur virtual sigui dinàmicament assignat.

Per habilitar ssh a la màquina virtual del node mestre, executeu les ordres següents:

```bash
sudo systemctl enable ssh
sudo systemctl start ssh
```

També heu d'afegir "Port Forwarding" a la màquina virtual del node mestre per permetre l'accés remot am ssh, podeu utilitzar l'ordre següent (cal aturar la màquina virtual abans d'afegir el port forwarding):

```bash
VBoxManage modifyvm k8s-master --natpf1 "ssh,tcp,,2222,,22"
```

Per connectar-vos a la màquina virtual:

```bash
ssh student@127.0.0.1 -p 2222
```

Configuració del fitxer ssh config:

```bash
Host k8s-master
  HostName 127.0.0.1
  User student
  Port 2222
  IdentityFile ~/.ssh/id_rsa_k8s-lab-student
```

Copieu la clau pública SSH generada a l'amfitrió al node mestre per permetre l'autenticació sense contrasenya. Podeu fer-ho utilitzant la comanda `ssh-copy-id` o manualment afegint la clau pública al fitxer `~/.ssh/authorized_keys` del node mestre.

```bash
ssh-copy-id -i ~/.ssh/id_rsa_k8s-lab-student.pub -p 2222 student@127.0.0.1
```

Ara podeu connectar-vos al node mestre amb la comanda següent:

```bash
ssh k8s-master
```

o bé

```bash
ssh student@127.0.0.1 -p 2222 -i ~/.ssh/id_rsa_k8s-lab-student
```

1. Inicieu la màquina virtual del node mestre i configureu la interfície de xarxa interna amb una adreça IP estàtica. Podeu fer-ho editant el fitxer de configuració de xarxa a Ubuntu Server, normalment ubicat a `/etc/netplan/00-installer-config.yaml`.
   - Executeu la següent ordre per obtenir les interfícies de xarxa disponibles: `ip addr`
   - Editeu el fitxer `/etc/netplan/00-installer-config.yaml` i afegiu la configuració de la interfície de xarxa interna amb l'adreça IP estàtica `192.168.2.1/24`.
   - Apliqueu la configuració de xarxa amb la comanda `sudo netplan apply`
   - Modificacions del fitxer `/etc/netplan/00-installer-config.yaml`:

```text
    enp0s4:
      dhcp4: false
      dhcp6: false
      match:
        macaddress: 08:00:27:00:00:02
      set-name: enp0s4
      addresses:
        - 192.168.2.1/24
```

## Creació de la màquina virtual del node de treball

Recursos de la màquina virtual del node de treball:

- Memòria RAM: 2 GB (2048 MB)
- Disc dur virtual: 20 GB (dinàmicament assignat)
- CPUs: 2
- Xarxes de la màquina virtual:
  - NIC1 = NAT → sortida a internet + SSH via port forwarding (2223:22)
  - NIC2 = xarxa interna → comunicació entre nodes del clúster

Podem crear la màquina virtual del node de treball amb VirtualBox utilitzant la interfície gràfica i la línia d'ordres. A continuació, es detallen els passos per crear la màquina virtual del node de treball.

> [!IMPORTANT]
> La creació de la màquina virtual  també es pot fer de manera desatesa amb l'script [vb-k8s-worker.sh](./scripts/vb-k8s-worker.sh).

> [!TIP]
> La màquina virtual es pot eliminar amb la comanda següent:

```bash
VBoxManage unregistervm k8s-worker-01 --delete
```

> [!TIP]
> Per comprovar que la màquina virtual s'ha creat correctament, podeu utilitzar la comanda següent:

```bash
VBoxManage list vms
```

> [!TIP]
> Després de crear la màquina virtual del node de treball, podeu iniciar-la amb la comanda següent:

```bash
VBoxManage startvm k8s-worker-01 --type headless
```

> [!TIP]
> Per aturar la màquina virtual del node de treball, podeu utilitzar la comanda següent:

```bash
VBoxManage controlvm k8s-worker-01 acpipowerbutton
```

> [!TIP]
> L'estat de la màquina es pot comprovar amb la següent ordre:

```bash
VBoxManage guestproperty enumerate k8s-worker-01
```

1. Obriu VirtualBox i feu clic a "Nou" per crear una nova màquina virtual.
2. Instal·leu Ubuntu Server a la màquina virtual amb instal·lació desatesa. Creeu una nova màquina virtual per mostrar els diàlegs:
   1. `Virtual machine name and operating system`
      - VM Name:"k8s-worker-01"
      - Marqueu la casella "Proceed with Unattended installation"
      - Seleccione el camí al fitxer ISO d'Ubuntu Server 26.04 LTS (arm) que heu baixat.
   2. `Set up user unattended guest OS installation`
      - User name: "student"
      - Password: "k8s12345"
      - Confirm password: "k8s12345"
      - Hostname: "k8s-worker-01"
      - Domain name: "laboratory.org"
   3. `Specify virtual hardware`
      - Base Memory: 2048 MB
      - Number of CPUs: 2
      - Marqueu la casella "Use EFI"
   4. `Specify virtual hard disk`
      - Seleccioneu l'opció `Create a virtual hard disk now`
      - Disk Size: 20 GB
      - Hard Disk File Type and Format: VDI (VirtualBox Disk Image)
        - no marqueu la casella `Pre-allocate Full Size` perquè volem que el disc dur virtual sigui dinàmicament assignat.

Per habilitar ssh a la màquina virtual del node de treball, executeu les ordres següents:

```bash
sudo systemctl enable ssh
sudo systemctl start ssh
```

També heu d'afegir "Port Forwarding" a la màquina virtual del node de treball per permetre l'accés remot am ssh, podeu utilitzar la comanda següent (cal aturar la màquina virtual abans d'afegir el port forwarding):

```bash
VBoxManage modifyvm k8s-worker-01 --natpf1 "ssh,tcp,,2223,,22"
```

Per connectar-vos a la màquina virtual:

```bash
ssh student@127.0.0.1 -p 2223
```

Configuració del fitxer ssh config:

```bash
Host k8s-worker-01
  HostName 127.0.0.1
  User student
  Port 2223
  IdentityFile ~/.ssh/id_rsa_k8s-lab-student
```

Copieu la clau pública SSH generada a l'amfitrió al node de treball per permetre l'autenticació sense contrasenya. Podeu fer-ho utilitzant la comanda `ssh-copy-id` o manualment afegint la clau pública al fitxer `~/.ssh/authorized_keys` del node de treball.

```bash
ssh-copy-id -i ~/.ssh/id_rsa_k8s-lab-student.pub -p 2223 student@127.0.0.1
```

Ara podeu connectar-vos al node de treball amb la comanda següent:

```bash
ssh k8s-worker-01
```

o bé

```bash
ssh student@127.0.0.1 -p 2223 -i ~/.ssh/id_rsa_k8s-lab-student
```

1. Inicieu la màquina virtual del node de treball i configureu la interfície de xarxa interna amb una adreça IP estàtica. Podeu fer-ho editant el fitxer de configuració de xarxa a Ubuntu Server, normalment ubicat a `/etc/netplan/00-installer-config.yaml`.
   - Executeu la següent ordre per obtenir les interfícies de xarxa disponibles: `ip addr`
   - Editeu el fitxer `/etc/netplan/00-installer-config.yaml` i afegiu la configuració de la interfície de xarxa interna amb l'adreça IP estàtica `192.168.2.2/24`.
   - Apliqueu la configuració de xarxa amb la comanda `sudo netplan apply`
   - Modificacions del fitxer `/etc/netplan/00-installer-config.yaml`:

```text
    enp0s4:
      dhcp4: false
      dhcp6: false
      match:
        macaddress: 08:00:27:00:00:FF
      set-name: enp0s4
      addresses:
        - 192.168.2.2/24
```
