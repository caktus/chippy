// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

// Import local files
//
import socket from "./socket"
import {getCookie, setCookie, deleteCookie, uuidv4} from "./cookie"

if (!getCookie('user_id')) {
  setCookie('user_id', uuidv4())
}
