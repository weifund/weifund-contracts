const padToEven = require('ethjs-util').padToEven;

function contractFactory(eth, contracts, name, defaultTxObject) {
  return eth.contract(JSON.parse(contracts[name].interface),
    contracts[name].bytecode,
    defaultTxObject);
}

function getTransactionSuccess(eth, txHash, callback) {
  const cb = callback || function cb() {};
  return new Promise((resolve, reject) => {
    const txInterval = setInterval(() => {
      eth.getTransactionReceipt(txHash, (err, result) => {
        if (err) {
          clearInterval(txInterval);
          cb(err, null);
          reject(err);
        }

        if (!err && result && result !== null) {
          clearInterval(txInterval);
          cb(null, result);
          resolve(result);
        }
      });
    }, 2000);
  });
}

function bnToString(objInput, baseInput, hexPrefixed) {
  var obj = objInput; // eslint-disable-line
  const base = baseInput || 10;

  // obj is an array
  if (typeof obj === 'object' && obj !== null) {
    if (Array.isArray(obj)) {
      // convert items in array
      obj = obj.map((item) => bnToString(item, base, hexPrefixed));
    } else {
      if (obj.toString && (obj.lessThan || obj.dividedToIntegerBy || obj.isBN || obj.toTwos)) {
        return hexPrefixed ? `0x${padToEven(obj.toString(16))}` : obj.toString(base);
      } else { // eslint-disable-line
        // recurively converty item
        Object.keys(obj).forEach((key) => {
          obj[key] = bnToString(obj[key], base, hexPrefixed);
        });
      }
    }
  }

  return obj;
}

module.exports = {
  contractFactory,
  getTransactionSuccess,
  bnToString,
};
