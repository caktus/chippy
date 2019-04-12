import { getCookie, setCookie } from "./cookie";
import RandomNames from "random-human-name";

export const getUserName = () => {
  var name = getCookie('user_id');
  var color = getCookie('user_color');
  if (!name) {
    name = prompt("Please enter your name", RandomNames.RandomNames(1)[0]);
    setCookie('user_id', name);
    document.getElementById('user_id').innerHTML = name;
  }
  if (!color) {
    color = prompt("Please choose your favorite color");
    setCookie("user_color", color);
  }
  return name;
}
