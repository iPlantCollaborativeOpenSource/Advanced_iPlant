#!/usr/bin/env python

import collections
import re
import time

def __init__(self, commandline_args):
        args = commandline_args
        self.ignore_list = str(args.ignore_list).split(",")

class wordlengthcounter:
    args = 0
    ignore_list = []
    out = 0
    max_length = 0
    words = []
    counters = []
    n_words = []
    allow_digits = 0
    total = 0

    def __init__(self, commandline_args):
        args = commandline_args
        self.ignore_list = str(args.ignore_list).split(",")

    def init_word_counters(self):
        self.max_length = args.max_length
        self.n_words = ['' for i in range(self.max_length)]
        self.counters = [0]*self.max_length
        self.total = 0

    def read_file(self):
        print "Analysing '" + args.inputfile + "'"
        if args.allow_digits:
            self.words = re.findall(r"['\-\w]+", open(args.inputfile).read().lower())
        else:
            self.words = re.findall(r"['\-A-Za-z]+", open(args.inputfile).read().lower())

    def compute_stats(self):
        print "Computing stats..."
        for word in self.words:

            if word in self.ignore_list:
                continue

            word = word.strip(r"&^%$#@!")
            if word == '-':
                continue

            length = len(word)

            if length > self.max_length:
                continue

            self.counters[length] = self.counters[length] + 1
            self.total = self.total + 1

    def print_results(self):

        timestr = time.strftime("%Y%m%d-%H%M%S")
        fname = args.inputfile.split('.')[0] + '-stats-' + timestr + '.csv'
        self.out = open(fname, 'w')
        print "Printing results to " + fname
        self.out.write('length,count,percent\n')
        for i in range(1, self.max_length):
            pct = round ( 100.0 * ((self.counters[i] * 1.0) / (self.total * 1.0)), 2)
            self.out.write(str(i) + ',' + str( self.counters[i] ) + ',' + str( pct ) + '\n' )

if __name__ == '__main__':
    import argparse

    parser = argparse.ArgumentParser(description='Perform word-length frequency analysis on a document.')
    parser.add_argument('--filename', '-f', dest='inputfile', required=True, help='Text file to parse.')
    parser.add_argument('--max', '-m', dest='max_length', required=False, default=32, type=int, help='The maximum word length to count. Default is 32.')
    parser.add_argument('--allow-digits', '-d', dest='allow_digits', default=False, required=False, help='Allow digits to be parsed (true/false). Default is false.')
    parser.add_argument('--ignore', '-i', dest='ignore_list', required=False, help='Comma-delimted list of words to ignore')

    args = parser.parse_args()

    w = wordlengthcounter(args)
    w.init_word_counters()
    w.read_file()
    w.compute_stats()
    w.print_results()
