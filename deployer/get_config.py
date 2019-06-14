#!/usr/bin/env python2

import sys

from argparse import ArgumentParser


import schema_values_common


def main():
    parser = ArgumentParser(description="Returns a config value")
    schema_values_common.add_to_argument_parser(parser)

    parser.add_argument(
        '--key', help='The name of the variable to get ')
    args = parser.parse_args()

    values = schema_values_common.load_values(args)
    sys.stdout.write(values[args.key])


if __name__ == "__main__":
    main()