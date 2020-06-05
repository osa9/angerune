import './main.css';
import { Elm } from './Main.elm';
import * as serviceWorker from './serviceWorker';
import {db, findRunes, setRune, subscribeRune, addRune, getRune} from './firebase'

const app = Elm.Main.init({
  node: document.getElementById('root')
});

let unsubscribe = null;

const randomString = (length) => {
  const c = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";

  let res = "";
  for(let i=0; i<length; i++){
    res += c[Math.floor(Math.random()*(c.length))];
  }
  return res;
}

app.ports.startLive.subscribe(data => {
  data.key = data.key ? data.key : randomString(6)
  setRune(db, "live", data.key, data).then(() => {
    app.ports.liveStarted.send(data.key)
  })
})

app.ports.sendRune.subscribe(data => {
  setRune(db, "live", data.key, data)
})

app.ports.saveRune.subscribe(data => {
  addRune(db, "runes", data.key, data).then((doc) => {
    app.ports.savedRune.send(doc.id)
  })
})

app.ports.getRune.subscribe(key => {
  getRune(db, "runes", key).then((doc) => {
    app.ports.gotRune.send(JSON.stringify(Object.assign(doc.data(), {key: doc.id})))
  })
})

app.ports.subscribe.subscribe(key => {
  unsubscribe = subscribeRune(db, key, (key, data) => {
    app.ports.receiveRune.send(JSON.stringify(data))
  })
})

app.ports.findRunes.subscribe(options => {
  findRunes(db, options).then(snapshot => {
    const res = snapshot.docs.map(doc => { return Object.assign(doc.data(), {key: doc.id})})
    app.ports.foundRunes.send(JSON.stringify(res))
  })
})

app.ports.unsubscribe.subscribe(x => {
  if (unsubscribe) {
    unsubscribe();
    unsubscribe = null;
  }
})



// If you want your app to work offline and load faster, you can change
// unregister() to register() below. Note this comes with some pitfalls.
// Learn more about service workers: https://bit.ly/CRA-PWA
serviceWorker.unregister();
