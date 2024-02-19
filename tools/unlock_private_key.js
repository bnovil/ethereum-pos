var keythereum = require("keythereum");

const address = "400ab0adb4fa0ae7e7486ef76be44e9d64fbfab4"
const datadir = "./data/gethdata/"
const password = ""   // password

var keyObject = keythereum.importFromFile(address, datadir);
var privateKey = keythereum.recover(password, keyObject);
console.log(privateKey.toString('hex'));