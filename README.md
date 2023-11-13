# Satis

Unser [Satis Server][] ist ein geforktes Repository von dem offiziellen [Satis Projekt][]
Den HTACCESS-Schutz kann man im LastPass finden.

## Satis Server neu aufsetzen

Um in Zukunft auch das eigene Projekt auf dem aktuellsten Stand zu haben, sollte das [Satis Projekt][]
geforkt werden.
```
git clone [URL of your fork]
```

Danach wird das Original Repository als sog. Upstream hinzugefügt.
```
git remote add upstream [URL of the original repository]
```

Damit man prüfen kann, ob die richtigen Repositories verknüpft werden kann man folgenden Befehl aufrufen:
```
git remote -v
```


## Satis Server konfigurieren

Bei einem Provider seines Vertrauens wird eine Subdomain mit gültigem SSL Zertifikat eingerichtet.
Am besten richtet man auch gleich einen einfachen HTTP-Basic-Auth Verzeichnisschutz mit ".htaccess" an.

Wenn nicht bereits geschehen, erstellt man auf dem Satis Server einen neuen SSH-Key und hinterlegt den öffentlichen 
Schlüsselteil auf dem Server, z.B. Bitbucket, der die privaten Repositories, die man auf dem Satis Server verknüpfen möchte,
speichert.

```
ssh-keygen -t ed25519 -C "your_email@example.com"
```

## Cronjob für Satis Build hinterlegen
Damit der Satis Server immer die aktuellsten Versionen der Repositories ausliefern kann, sollte der Sync-Prozess mit dem
Bitbucket Server in regelmäßigen Abständen ausgeführt werden. Am besten legt man dafür ein Shell-Skript an, dass per Cronjob
getriggert wird.

```
#!/bin/bash

cd <pfad zum satis server> || exit
COMPOSER_CACHE_DIR=<pfad zum composer cache> bin/satis build
exit 0
```

## Satis Server konfigurieren
Grundsätzlich muss man jetzt nur noch in eine "satis.json" alle Repositories angeben, die gesynct werden sollen.

**Beispiel:**
```
{
    "name": "convis/satis.con-vis.de",
    "homepage": "https://satis.con-vis.de",
    "output-dir": "public",
    "repositories": [
        { "type": "vcs", "url":  "git@bitbucket.org:con-vis/package1.git" },
        { "type": "vcs", "url":  "git@bitbucket.org:con-vis/package2.git" }
    ],
    "archive": {
        "directory": "dist",
        "skip-dev": true
    },
    "require-all": true
}
```

## Plugin Konfiguration
Die einzelnen privaten Repositories für die ausgelagerten Plugins, die man wiederverwenden möchte, werden wie folgt per composer.json
konfiguriert. Die einzelnen Versionen können an den entsprechenden Commits getaggt werden.

> Wichtig ist die Version in der composer.json und der Tag sollten immer gleich sein.

**Beispiel**
```
# tag
v1.1.0

# composer.json
{
    "name": "convis/devtools",
    "description": "Plugin for some DevTools",
    "version": "1.1.0",
    "type": "shopware-platform-plugin",
    "license": "MIT",
    "authors": [
        {
            "name": "ConVis GmbH"
        }
    ],
    "require": {
        "shopware/core": "^6.4.0",
        "shopware/administration": "^6.4.0"
    },
    "extra": {
        "shopware-plugin-class": "ConVis\\DevTools\\ConVisDevTools",
        "copyright": "(c) by ConVis GmbH",
        "label": {
            "de-DE": "Plugin ConVis DevTools",
            "en-GB": "Plugin ConVis DevTools",
            "fr-FR": "Plugin ConVis DevTools"
        },
        "description": {
            "de-DE": "Beschreibung für das Plugin ConVis DevTools",
            "en-GB": "Description for the plugin ConVis DevTools",
            "fr-FR": "Description for the plugin ConVis DevTools"
        }
    },
    "autoload": {
        "psr-4": {
            "ConVis\\DevTools\\": "src/"
        }
    },
    "autoload-dev": {
        "psr-4": {
            "ConVis\\DevTools\\ConVisDevToolsTests\\": "tests/"
        }
    },
    "conflict": {
        "shopware/storefront": "<6,>=7",
        "shopware/administration": "<6,>=7"
    }
}
```

## Client/Projekt konfigurieren

Wenn wir jetzt ein Projekt haben, in der wie die privaten Repositories als Abhängigkeit installieren möchten, werden nur
noch 2 Schritte benötigt

### HTTP-Basic-Auth in der Git-Konfiguration hinterlegen
Damit composer sicht mit dem Satis Server verbinden kann, sollte die http-basic Infos in der Git-Konfig hinterlegt sein.
```
composer config --global http-basic.satis.con-vis.de <username> <password>
```

### Composer anpassen
Einmal wird unter "repositories" der Satis Server verknüpft und anschließend kann wie gewohnt die Abhängigkeit angegeben werden.
Mittels "composer require" oder manuell als Eintrag in die json-Datei.
```
{
    "repositories": [ { "type": "composer", "url": "http://packages.example.org/" } ],
    "require": {
        "company/package": "1.2.0",
        "company/package2": "1.5.2",
        "company/package3": "dev-master"
    }
}
```

[satis server]: https://satis.con-vis.de
[satis projekt]: https://github.com/composer/satis
