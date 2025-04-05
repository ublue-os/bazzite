#!/bin/bash

TEST_LOG="test.log"
TEST_RUN_IN_RAWHIDE=1

declare -i TEST_RUN_IN_RAWHIDE

if [ $# -gt 0 ] ; then
    TEST_LOG="$1"
    TEST_RUN_IN_RAWHIDE=$2
fi

gen_results()
{
    TEST_RUNTIME="$1"
    TEST_STATUS="$2"
    TEST_STATUS_UPPER="$(echo "$TEST_STATUS" | tr '[:lower:]' '[:upper:]')"
    cat > results.xml << _EOF
results:
- test: results
  result: $TEST_STATUS
  runtime: $TEST_RUNTIME
  logs:
  - ${TEST_STATUS_UPPER}-str_results.log

_EOF

    DIR=$(dirname "$TEST_LOG")
    if [ x"$TEST_LOG" != x ] ; then
       cp "$TEST_LOG" "$DIR/${TEST_STATUS_UPPER}-str_results.log"
    else
       touch "$DIR/${TEST_STATUS_UPPER}-str_results.log"
    fi
    if [ x"$DIR" != x. ] ; then
        mv results.xml "$DIR"
    fi
}

if [ $TEST_RUN_IN_RAWHIDE -eq 0 ] ; then
    if grep -q -i rawhide /etc/fedora-release &> /dev/null ; then
        gen_results "0" "pass"
        echo -n PASS
        exit 0
    fi
fi
if [ ! -f $TEST_LOG ] ; then
    gen_results "0" "fail"
    echo -n ERROR
else
    FAIL="$(grep "^FAIL: " $TEST_LOG | grep -v 'FAIL: 0$')"
    RUNTIME_FAIL="$(grep -v 'frame' $TEST_LOG | grep "^FAIL: " | sed -e "s/FAIL: //")"
    RUNTIME_PASS="$(grep -v 'frame' $TEST_LOG | grep "^PASS: " | sed -e "s/PASS: //")"
    if [ x"$RUNTIME_FAIL" = x ] ; then
        RUNTIME_FAIL="0"
    fi
    if [ x"$RUNTIME_PASS" = x ] ; then
        RUNTIME_PASS="0"
    fi
    RUNTIME="$(expr $RUNTIME_FAIL + $RUNTIME_PASS)"
    if [ x"$FAIL" != x ] ; then
        gen_results "$RUNTIME" "fail"
        echo -n ERROR
    else
        gen_results "$RUNTIME" "pass"
        echo -n PASS
    fi
fi

