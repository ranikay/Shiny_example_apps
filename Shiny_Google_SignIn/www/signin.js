// Modified from https://github.com/dkulp2/Google-Sign-In

function onSignIn(googleUser) {
  var profile = googleUser.getBasicProfile();
  Shiny.onInputChange("g_id", profile.getId());
  Shiny.onInputChange("g_name", profile.getName());
  Shiny.onInputChange("g_image", profile.getImageUrl());
  Shiny.onInputChange("g_email", profile.getEmail());
}
function signOut() {
  var auth2 = gapi.auth2.getAuthInstance();
  auth2.signOut();
  // I'm handling this part in server.R instead
  //Shiny.onInputChange("g_id", null);
  //Shiny.onInputChange("g_name", null);
  //Shiny.onInputChange("g_image", null);
  //Shiny.onInputChange("g_email", null);
}
  
if (typeof gapi == 'undefined') {
  alert("Failed to load Google API.\nCheck your ad blocker.\nYou will not be able to authenticate.");
}