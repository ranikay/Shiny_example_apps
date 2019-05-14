## Shiny app examples

### Shiny_Google_SignIn: Shiny app authentication using the Google Sign-In API

A live demo is deployed to ShinyApps.io [here](https://ranipowers.shinyapps.io/shiny_google_signin/).

The goal of this app was to build a simple authentication scheme using Google's federated login to avoid having to manage usernames and passwords. The Google Sign-In API does not require a secret and no other Google API services are needed. I initially based this app on [this example](https://github.com/dkulp2/Google-Sign-In), which I extended to illustrate how you could display, for example, a dashboard to users after they had logged in with a company email.

There are other ways to do Shiny app authentication with Google Sign-In (e.g. using the [GoogleAuthR](https://github.com/MarkEdmondson1234/GoogleAuthR) package). I just liked this way and it was the easiest for me to get up and running quickly.

#### Run this Shiny app with your own Google account: 

1. Log in to the [GCP console](https://console.cloud.google.com/apis/credentials) and create a new OAuth 2.0 client ID for a web application.
2. In both the "Authorized JavaScript origins" and "Authorized redirect URIs" sections, enter the domain for the client application (e.g. mine is https://ranipowers.shinyapps.io) as well as http://localhost:7445 for local testing (Google credentials don't accept IP addresses). Click Save.
3. Fork this project and create a `.env` file in the root (`Shiny_Google_SignIn`) directory with this format:

```
ORG_DOMAIN=<your whitelisted domain>
CLIENT_ID=<your client id>
```

`CLIENT_ID` will be the client ID created in steps 1-2. `ORG_DOMAIN` could be "gmail.com" or "yourcompany.com" etc.

Optional:

4. To run locally on a different port, edit `options(shiny.port = 7445)` accordingly.

#### Security

[Noted by David Kulp in his Google Sign-In app](https://github.com/dkulp2/Google-Sign-In): "The API documentation strongly encourages using a verified token to access a user profile on the server side because a client can spoof an ID. However, I simply use the Shiny.onInputChange javascript call to marshall messages from the client to the server. I can't vouch for the security of Shiny.onInputChange or this app, in general. Use at your own risk."

---

### Shiny_env: Shiny app simple user management with environment variables 

A live demo is deployed to ShinyApps.io [here](https://ranipowers.shinyapps.io/Shiny_env/).

This app was intended to demonstrate some basic login screen UI in front of an app, and how environment variables could be used in a Shiny app. It uses `Shiny.inputBindings` to bind a function (an [md5 hash](http://www.myersdaily.org/joseph/javascript/md5.js), in this case) to a shiny UI element (`shiny.passwordInput`). 

(Note: I *think* the original source for `www\passwdInputBinding.js` is [here](https://gist.github.com/withr/9001831) but I've seen it in multiple places so I'm not 100% sure...)

In my modified example, there are two users with these usernames and passwords:

```
noob: 123
pro: hell0w0rld
```

I used the `credentials` variable in `server.R` to illustrate 2 ways of handling this data. Noob's password is md5-hashed but in plain text in the source code. This is an example of what not to do. On the other hand, Pro's hashed password is obtained from an environment variable in a `.env` file which is slightly better, *assuming your `.env` file / environment variables are managed responsibly*.

#### Run this Shiny app

Fork this project and create a `.env` file in the root (`Shiny_env`) directory with this format:

```
LOGIN_HASH="28be1fa52ff6350eb913dd693a6c3098"
```

Run the app and log in as either of the two users.

#### Security

If you share an `.env` file with a third party or check in that file to Github, etc, that data is no longer guaranteed to be secure. If using RStudio Connect, for example, best practice would be to [set environment variables through the GUI/console](https://db.rstudio.com/best-practices/deployment/#credentials-inside-environment-variables-in-rstudio-connect). 
