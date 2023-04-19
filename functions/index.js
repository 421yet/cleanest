const functions = require("firebase-functions");
// const express = require('express');

// const app = express();

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
exports.helloWorld = functions.https.onRequest((request, response) => {
  functions.logger.info("Hello logs!", {structuredData: true});
  response.send("Hello from Firebase!");
});

// exports.makeLowercase = functions.database.ref('/messages/{pushId}/original')
// .onCreate((snapshot, context) => {
//   const original = snapshot.val();
//   console.log('Lowercasing', context.params.pushId, original);
//   const lowercase = original.toLowerCase();
//   return snapshot.ref.parent.child('loewrcase').set(lowercase);
// });

exports.checkDigits = functions.https.onRequest((request, response) => {
  functions.logger.info("Checking digits...", {structuredData: ture});
  
})