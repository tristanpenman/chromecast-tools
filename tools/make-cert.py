#!/usr/bin/env python3

from OpenSSL import crypto
from datetime import date, datetime, time, timedelta, timezone
import hashlib
import os
import sys

today = date.today()

def get_timestamp(day_offset):
  timestamp_string = datetime.combine(today + timedelta(days = day_offset), time(0, 0, 0), tzinfo=timezone.utc).strftime('%Y%m%d%H%M%S')
  return str.encode(timestamp_string + 'Z')

if len(sys.argv) < 3:
    print('Usage:')
    print(f'  {sys.argv[0]} <target> <offset>')
    exit(1)

offset = int(sys.argv[2])
target = sys.argv[1]

cert = crypto.X509()
cert.get_subject().CN = 'GoCast'
cert.set_serial_number(001891360103749373019587830806931297564229337938)

# Set the validity period
cert.set_notBefore(get_timestamp(offset))
cert.set_notAfter(get_timestamp(offset + 2))

# The subject of this cert is also the issuer (self-signed cert)
cert.set_issuer(cert.get_subject())

# Set the public key of the cert
k = crypto.PKey()
k.generate_key(crypto.TYPE_RSA, 2048)
cert.set_pubkey(k)

# Sign the cert
cert.sign(k, 'sha1')

f = open(os.path.join(target, 'peer.crt'), 'wb')
f.write(crypto.dump_certificate(crypto.FILETYPE_PEM, cert))
f.close()

f = open(os.path.join(target, 'peer.key'), 'wb')
f.write(crypto.dump_privatekey(crypto.FILETYPE_PEM, k))
f.close()

der = crypto.dump_certificate(crypto.FILETYPE_ASN1, cert)
sha = hashlib.sha256(der).hexdigest()
print(sha)
