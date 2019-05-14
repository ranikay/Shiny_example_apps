## Shiny app examples

### Shiny app authentication using the Google Sign-In API

A live demo is deployed to ShinyApps.io [here](https://ranipowers.shinyapps.io/Shiny_auth_example/).

The goal of this app was to build a simple authentication scheme using Google's federated login to avoid having to manage usernames and passwords. The Google Sign-In API does not require a secret and no other Google API services are needed. I initially based this app on [this example](https://github.com/dkulp2/Google-Sign-In), which I extended to illustrate how you could display, for example, a dashboard to users after they had logged in with a company email.

There are other ways to do Shiny app authentication with Google Sign-In (e.g. using the [GoogleAuthR](https://github.com/MarkEdmondson1234/GoogleAuthR) package). I just liked this way and it was the easiest for me to get up and running quickly.

#### Run this Shiny app with your own Google account: 

1. Log in to the [GCP console](https://console.cloud.google.com/apis/credentials) and create a new OAuth 2.0 client ID for a web application.
2. In both the "Authorized JavaScript origins" and "Authorized redirect URIs" sections, enter the domain for the client application (e.g. mine is https://ranipowers.shinyapps.io) as well as http://localhost:7445 for local testing (Google credentials don't accept IP addresses). Click Save.
3. Create a `.env` file and in the root directory with this format:

```
ORG_DOMAIN=<your whitelisted domain>
CLIENT_ID=<your client id>
```

`CLIENT_ID` will be the client ID created in steps 1-2. `ORG_DOMAIN` could be "gmail.com" or "yourcompany.com" etc.

Optional:

4. To run locally on a different port, edit `options(shiny.port = 7445)` accordingly.

#### Security

[Noted by David Kulp in his Google Sign-In app](https://github.com/dkulp2/Google-Sign-In): "The API documentation strongly encourages using a verified token to access a user profile on the server side because a client can spoof an ID. However, I simply use the Shiny.onInputChange javascript call to marshall messages from the client to the server. I can't vouch for the security of Shiny.onInputChange or this app, in general. Use at your own risk."
