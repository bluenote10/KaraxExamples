## Unit Testing

Experiment to get headless-browser testing to work.

### Usage

Install dependencies:

    $ npm install

To run Karma tests:

    $ npm test

This will internally run the npm scripts `test:build` (which runs the Nim compiler)
and `test:karma` (which runs Karma on the compiler output).

For a continous watch + build + test cycle run:

    $ npm run test:watch
