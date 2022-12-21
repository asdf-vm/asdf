#!/usr/bin/env python3
import re
import sys
import os
import argparse
from pathlib import Path
from typing import List, Dict, Any # compat

# This file checks Bash and Shell scripts for violations not found with
# shellcheck or existing methods. You can use it in several ways:
#
# Lint all .bash, .sh, and .bats files and print out violations
# $ ./scripts/checkstyle.py
#
# The former, but also fix all violations. This must be ran until there
# are zero violations since any line can have more than one violation
# $ ./scripts/checkstyle.py --fix
#
# Lint a particular file
# $ ./scripts/checkstyle.py ./lib/functions/installs.bash

class c:
    RED = '\033[91m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    MAGENTA = '\033[95m'
    CYAN = '\033[96m'
    RESET = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

# Before: printf '%s\\n' '^w^'
# After: printf '%s\n' '^w^'
def noDoubleBackslashFixer(line: str, rule: Dict[str, str], m: re.Match[str]) -> str:
    prestr = line[0:m.start('match')]
    midstr = line[m.start('match'):m.end('match')]
    poststr = line[m.end('match'):]

    fixed_line = f'{prestr}{midstr[1:]}{poststr}'
    return fixed_line

def lintfile(filepath: Path, rules: List[Dict[str, str]], options: Dict[str, Any]):
    content_arr = filepath.read_text().split('\n')

    for line_i, line in enumerate(content_arr):
        for rule in rules:
            m = re.search(rule['regex'], line)
            if m is not None and m.group('match') is not None:
                dir = os.path.relpath(filepath.resolve(), Path.cwd())
                prestr = line[0:m.start('match')]
                midstr = line[m.start('match'):m.end('match')]
                poststr = line[m.end('match'):]

                print(f'{c.CYAN}{dir}{c.RESET}:{line_i + 1}')
                print(f'{c.MAGENTA}{rule["name"]}{c.RESET}: {rule["reason"]}')
                print(f'{prestr}{c.RED}{midstr}{c.RESET}{poststr}')
                print()

                if options['fix']:
                    content_arr[line_i] = rule['fixer_fn'](line, rule, m)

                rule['found'] += 1

    if options['fix']:
        filepath.write_text('\n'.join(content_arr))

def main():
    rules = [
        {
            'name': 'no-double-backslash',
            'regex': '".*?(?P<match>\\\\\\\\[abeEfnrtv\'"?xuUc]).*?(?<!\\\\)"',
            'reason': 'Backslashes are only required if followed by a $, `, ", \\, or <newline>',
            'fixer_fn': noDoubleBackslashFixer,
            'found': 0
        },
    ]

    parser = argparse.ArgumentParser()
    parser.add_argument('files', metavar='FILES', nargs='*')
    parser.add_argument('--fix', action='store_true')
    args = parser.parse_args()

    options = {
        'fix': args.fix
    }

    # parse files and print matched lints
    if len(args.files) > 0:
        for file in args.files:
            p = Path(file)
            if p.is_file():
                lintfile(p, rules, options)
    else:
        for file in Path.cwd().glob('**/*'):
            if file.name.endswith('.bash') or file.name.endswith('.sh') or file.name.endswith('.bats'):
                if file.is_file():
                    lintfile(file, rules, options)

    # print final results
    print(f'{c.UNDERLINE}TOTAL ISSUES{c.RESET}')
    for rule in rules:
        print(f'{c.MAGENTA}{rule["name"]}{c.RESET}: {rule["found"]}')

    grand_total = sum([rule['found'] for rule in rules])
    print(f'GRAND TOTAL: {grand_total}')

    # exit
    if grand_total == 0:
        exit(0)
    else:
        exit(2)

main()
