# E-mails d'authentification Allo Docteur

Templates HTML des e-mails Firebase Auth (vérification d'adresse, réinitialisation
de mot de passe, changement d'adresse), aux couleurs de la plateforme.

## Fichiers

| Fichier | Template Firebase | Usage dans l'app |
|---|---|---|
| `verification-email.html` | `verifyEmailTemplate` | envoyé à l'inscription (patient) |
| `reset-password-email.html` | `resetPasswordTemplate` | « Mot de passe oublié » (écran de connexion patient) |
| `change-email-email.html` | `changeEmailTemplate` | changement d'adresse e-mail |

## Charte reprise de l'application

Les tokens viennent de `src/index.css` (miroir exact de l'app Flutter) :

| Rôle | Valeur |
|---|---|
| Vert principal | `#14583D` |
| Vert secondaire | `#5B8E7B` |
| Corail (alerte) | `#F87849` |
| Texte | `#1A1C1B` / `#56605B` / `#9CA3AF` |
| Fonds | `#F8F9FA` (page) / `#FFFFFF` (carte) / `#F2F5F4` / `#E8EFE8` |
| Bordures | `#DADDDD` |
| Police | `Outfit` (pile système en repli) |
| Rayons | 12 px (bouton) / 16 px (carte) |
| Bouton | fond `#14583D`, texte blanc, `box-shadow 0 2px 6px rgba(20,88,61,.25)` |

Le logo est servi par le site web : `https://allo-doctor-app.web.app/logo.png`
(source : `public/logo.png`).

## Placeholders Firebase

| Placeholder | Valeur |
|---|---|
| `%LINK%` | lien d'action (à forcément garder) |
| `%DISPLAY_NAME%` | nom de l'utilisateur |
| `%EMAIL%` | adresse e-mail |
| `%APP_NAME%` | nom public du projet |

## Appliquer

```bash
npm run emails:check   # état courant (lecture seule)
npm run emails:apply   # applique
```

Le script réutilise le refresh token du CLI Firebase (`firebase login`).

## ⚠️ Plan gratuit (Spark) : ce qui est bloqué

Le projet `allo-doctor-app` est en `billingEnabled: false`. L'API Identity
Toolkit applique alors des restrictions :

| Champ | Plan gratuit | Plan Blaze |
|---|---|---|
| `notification.defaultLocale` | ✅ | ✅ |
| `...verifyEmailTemplate.replyTo` | ✅ | ✅ |
| `...verifyEmailTemplate.senderLocalPart` | ✅ | ✅ |
| `...verifyEmailTemplate.body` | ⚠️ écriture acceptée (HTTP 200) **mais ignorée** | ✅ |
| `...resetPasswordTemplate.body` | ❌ `EMAIL_TEMPLATE_UPDATE_NOT_ALLOWED` | ✅ |
| `...<template>.subject` | ❌ `EMAIL_TEMPLATE_UPDATE_NOT_ALLOWED` | ✅ |

Le blocage ne vient **pas** des permissions : un compte de service porteur de
`roles/firebaseauth.admin` obtient exactement la même erreur.

### Débloquer

1. Console Firebase → **Upgrade** → activer le plan **Blaze** (pay-as-you-go,
   un budget de sécurité suffit).
2. `npm run emails:apply`

### Sans Blaze

Les corps peuvent être collés manuellement dans
**Console Firebase → Authentication → Templates → Modifier**. Si la console
refuse aussi, il faut Blaze.

## Point d'attention : URL d'action

L'URL d'action (`callbackUri`) pointe vers la page Firebase :
`https://allo-doctor-app.firebaseapp.com/__/auth/action`.

Pour que le lien atterrisse dans l'application mobile, il faut :

1. déployer l'app Flutter web sur `allo-doctor-app-92745.web.app` (le site
   existe déjà, il n'est pas déployé — l'API renvoie 404) ;
2. passer l'URL d'action sur ce domaine ;
3. gérer le `oobCode` dans l'app (`checkActionCode` / `applyActionCode` ne sont
   pas implémentés aujourd'hui, le changement de mot de passe se fait donc sur
   la page Firebase).

`allo-doctor-app-92745.web.app` a été ajouté aux domaines autorisés.
