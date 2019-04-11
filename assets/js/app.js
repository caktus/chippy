// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css";

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html";

// Import local files
//
import LiveSocket from "phoenix_live_view";
import { getUserName } from "./user";

const initializeApp = () => {
  // Assign ourselves a username, if needed, and make sure it appears in the header
  const userName = getUserName();
  const liveSocket = new LiveSocket("/live");
  liveSocket.connect();
  console.log(`Hi, ${userName}! Eventually we'll do something with the name you chose … maybe?`);
};

if (window.addEventListener) {
  window.addEventListener("load", initializeApp);
} else {
  window.attachEvent("onload", initializeApp);
}
