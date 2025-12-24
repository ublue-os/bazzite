# dgoss tests

This directory relies on some conventional structure inside of tests to make running multiple isolated dgoss test suites viable.

Inside of the tests.d directory, each test needs to be defined in its own subdirectory.

Each test subdirectory must contain at least two things:

1. A `goss.yaml` file containing any [valid gossfile configuration](https://goss.readthedocs.io/en/stable/gossfile/). This file is where all of your goss test assertions will be defined.
2. A `test.sh` file that runs `dgoss run`. This file MUST take $1 as an argument for the image to perform the test on. Additional volume mounts can be specified using the `-v` flag to inject fixture data into the filesystem.

Addition documentation for goss' capabilities can be found at [https://goss.readthedocs.io](https://goss.readthedocs.io).
