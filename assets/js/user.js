import { getCookie, setCookie } from "./cookie";
import RandomNames from "random-human-name";

export const getUserName = () => {
  var name = getCookie('user_id');
  if (!name) {
    name = prompt("Please enter your name", RandomNames.RandomNames(1)[0]);
    setCookie('user_id', name);
    document.getElementById('user_id').innerHTML = name;
  }
  return name;
}
