#!/bin/sh

CLIENT=$1

[ -z "$CLIENT" ] && echo "Enter $0 username" && exit 64

ipsec pki --gen --outform pem > /etc/ipsec.d/private/${CLIENT}.pem

ipsec pki --pub --in /etc/ipsec.d/private/${CLIENT}.pem |
    ipsec pki --issue \
              --cacert /etc/ipsec.d/cacerts/ca.cert.pem \
              --cakey /etc/ipsec.d/private/ca.pem --dn "C=CN, O=strongSwan, CN=${CLIENT}@${VPN_DOMAIN}" \
              --san="${CLIENT}@${VPN_DOMAIN}" \
              --outform pem > /etc/ipsec.d/certs/${CLIENT}.cert.pem

openssl pkcs12 -export \
               -inkey /etc/ipsec.d/private/${CLIENT}.pem \
               -in /etc/ipsec.d/certs/${CLIENT}.cert.pem \
               -name "${CLIENT}@${VPN_DOMAIN}" \
               -certfile /etc/ipsec.d/cacerts/ca.cert.pem \
               -caname "strongSwan Root CA" \
               -out /etc/ipsec.d/${CLIENT}.cert.p12 \
               -passout pass:${VPN_P12_PASSWORD}

