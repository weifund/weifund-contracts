# Documentation

## Table of Contents

- [General](general)
  - [**Developer Guide**](developer-guide.md)
  - [**User Guide**](user-guide.md)
  - [**Contract Readiness**](contract-readiness.md)

## Overview

### Development

Run `npm start`...

### Building & Deploying

1. Run `npm run build`, which will compile all the necessary files to the
`dist` folder.

### Structure

The [`src/`](../../../tree/master/src) directory contains your entire application code, including JavaScript, and tests.

The rest of the folders and files only exist to make your life easier, and
should not need to be touched.

For more in-depth structure, see the developer-guide.md.

*(If they do have to be changed, please [submit an issue](https://github.com/weifund/weifund-contracts/issues)!)*

### Testing

For a thorough explanation of the testing procedure, see the
[testing documentation](./developer-guide/README.md)!

#### Unit testing

Unit tests live in `tests/` directories right next to the components being tested
and are run with `npm test`.
