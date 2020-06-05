import * as firebase from 'firebase/app'
import 'firebase/firestore'
import '@firebase/analytics'

import {firebaseConfig} from "./firebase.config";

// Initialize Firebase
firebase.initializeApp(firebaseConfig);
firebase.analytics();

export const db = firebase.firestore()

const emptyRune = {
  "main": "Precision",
  "mainSelected": [null, null, null, null],
  "sub": "Domination",
  "subSelected": [],
  "shardsSelected": [null, null, null]
}

export const getRune = (db, collection, key) => {
  return db.collection(collection).doc(key).get()
}

export const findRunes = (db, option) => {
  return db.collection("runes").limit(100).get()
}

export const setRune = (db, collection, key, data) => {
    return db.collection(collection).doc(key).set(data)
}

export const addRune = (db, collection, key, data) => {
  if (!key) {
    return db.collection(collection).add(data)
  } else {
    return db.collection(collection).set(data)
  }
}

export const subscribeRune = (db, key, onUpdate) => {
  return db.collection("live").doc(key).onSnapshot((doc) => {
    onUpdate(key, Object.assign(doc.data(), {key: doc.id}))
  })
}

