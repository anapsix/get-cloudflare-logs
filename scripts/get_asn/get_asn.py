#!/usr/bin/env python

from ipwhois import IPWhois
import sys

# from pprint import pprint
# import redis

if len(sys.argv) < 2:
  print("Error: pass a file with list of IPs as first argument")
  exit(1)

with open(sys.argv[1]) as data_file:
  for line in data_file:
    ip = line.strip()
    obj = IPWhois(ip)
    try:
      results = obj.lookup_rdap(depth=0,inc_raw=False,inc_nir=False,asn_methods=['dns'])
      print('%s %s' % (ip, results['asn']))
    except:
      print('%s %s' % (ip, 'unknown'))
