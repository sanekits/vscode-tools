# textmate_snippet_xform.py
""" Given a stream of text:
For each line:
    replace chars with textmate metachars (escaping)
    surround resulting line with quotes
    append comma

This renders a text stream suitable for textmate snippet
json"""

import sys
import fileinput

def escapeLine(line:str):
    #escChars=['\\','$','{','}','"']
    ovw=""
    for c in line:
        if c == '\n':
            continue
        if c == '\r':
            continue
        if c == '\\':
            ovw = ovw + '\\\\'
        elif c == '"':
            ovw = ovw + '\\"'
        # elif c == '{':
        #     ovw = ovw + '\\\\{'
        # elif c == '}':
        #     ovw = ovw + '\\\\}'
        elif c == '$':
            ovw = ovw + '\\\\$'
        else:
            ovw = ovw + c
    return ovw


for line in fileinput.input():
    print(f'"{escapeLine(line)}",')
