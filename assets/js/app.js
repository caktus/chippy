import React from "react";
import ReactDOM from "react-dom";
import RandomNames from "random-human-name";

import SprintBoard from "./components/sprint-board.jsx";

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
import socket from "./socket";
import {getCookie, setCookie, deleteCookie} from "./cookie";

if (!getCookie('user_id')) {
  // FIXME: set this back to uuidv4() when we implement name customization
  setCookie('user_id', RandomNames.RandomNames(1)[0]);
}

const initializeApp = () => {
  const sprintBoard = document.getElementById("sprint-board");
  const sprintConfigEl = document.getElementById("sprint_config");

  if (sprintBoard && sprintConfigEl) {
    console.log("Starting ...");
    const {sid} = JSON.parse(sprintConfigEl.text);
    ReactDOM.render(
      <SprintBoard socket={socket} sid={sid} />,
      document.getElementById("sprint-board")
    );
  }
};

if (window.addEventListener) {
  window.addEventListener("load", initializeApp);
} else {
  window.attachEvent("onload", initializeApp);
}
