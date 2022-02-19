## Info ##
Les fichiers avec extension `sh` nécessistent l'interpréteur bash, que l'on exécute dans la console comme suit:
```
./fichier.sh
```

## Nouveaux fichiers ##
Pour indexer un nouveau fichier, 

1. Le placer dan INBOX
Éxécuter:
2. ```./INBOX-gs.sh``` (optionellement)
3. ```./INBOX-zip-crypt.sh```(optionellement)
4. ```./INBOX-unique.sh```
5. ```./INBOX-dossier.sh```
6. Ajouter aux dossiers, fichiers *vides* destinés à la recherhe par mot-clé
7. Couper-coller les dossiers vers [identifiant](../identifiant)
8. Supprimer le contenu de [TRASH](../TRASH) (sauf dummy).
Cette étape est capitale si les fichiers ont été encryptés à l'étape 3.
9. À la [racine du dépôt](..), faire
```
git add -all
git commit -m "nouveaux identifiants"
git push
```
## Recherche ##
* Rechercher un motif parmi les fichiers pdf (1ère page)
```
./cherche-pdf.sh
```
## Maintenance ##
* Mettre à jour [motif](../motif)
```
./motif.sh
```
* Mettre à jour [nombre](../nombre)
```
./nombre.sh
```
* Mettre à jour [verification.log](../verification.log)
```
./verification-profond.sh
```
* Mettre à jour [verification.log](../verification.log)
```
./verification-unicite.sh
```
