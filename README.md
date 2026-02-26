# 🍕 Livraison de Pizza (Pizza Job)

Un script de livraison de pizza propre, optimisé et entièrement configurable pour **ESX Legacy**.

## ✨ Fonctionnalités

- **Flux de travail fluide** : Récupérez un scooter, livrez les pizzas et revenez pour terminer votre service.
- **Paiements dynamiques** : Récompenses basées sur la distance de livraison avec des chances de pourboires aléatoires.
- **Visuels personnalisés** : Accessoire de boîte à pizza parfaitement aligné avec l'animation de transport appropriée.
- **Code optimisé** : Haute performance, sans fioritures et logique sans erreur.

## 📦 Dépendances

> [!IMPORTANT]
> Les scripts suivants **doivent impérativement être lancés AVANT** `pizza_job` dans votre `server.cfg`.

Ces ressources sont incluses dans le dossier `[dependence]` du script :

- `rep-talkNPC2`
- `vPrompt`

## 🛠️ Installation

1.  Placez le contenu du dossier `[dependence]` dans votre dossier `resources`.
2.  Placez le dossier `pizza_job` dans votre dossier `resources`.
3.  Dans votre `server.cfg`, assurez-vous de respecter cet ordre :
    ```cfg
    ensure rep-talkNPC2
    ensure vPrompt
    ensure pizza_job
    ```
4.  **Optionnel** : Modifiez le fichier `config.lua` pour changer les montants des paiements ou les lieux de livraison.

## ⚙️ Configuration (`config.lua`)

- `Config.Pizzeria` : Emplacement de la boutique et du PNJ Luigi.
- `Config.Job` : Modèle du scooter et nombre maximum de pizzas par trajet.
- `Config.Payouts` : Pourcentages de pourboires et bonus de fin de service.
- `Config.DeliveryPoints` : Liste des points de livraison potentiels (ajoutez-en autant que vous le souhaitez).
- `Config.Outfit` : Changement de tenue automatique pour hommes et femmes.

## 🕹️ En Jeu

1.  Rendez-vous à la **Pizzeria Luchetti's** (Blip ou Coordonnées).
2.  Parlez à **Luigi** pour commencer votre service.
3.  Montez sur le scooter fourni.
4.  Livrez les pizzas aux endroits indiqués.
5.  Revenez voir Luigi une fois que vous n'avez plus de pizzas ou que vous souhaitez arrêter.

---

_Créé avec ❤️ par RiverFreez_
