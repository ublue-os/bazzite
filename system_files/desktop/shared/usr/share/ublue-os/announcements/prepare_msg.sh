#!/usr/bin/bash
# Utility to create a message json

{
    echo "Write whatever, then when finished, press Ctrl+D"

    echo "body:"
    body=$(cat)

    echo ""
    echo "seeMoreUrl:"
    seeMoreUrl=$(cat)

    echo ""
    echo "if:"
    if=$(cat)
} >&2

jq --null-input \
    --arg body "$body" \
    --arg seeMoreUrl "$seeMoreUrl" \
    --arg if "$if" \
    '{"body": $body, "if": $if, "seeMoreUrl": $seeMoreUrl}'
