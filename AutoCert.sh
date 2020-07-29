#!/bin/bash
#
# Initial Concept: Darryl H (https://github.com/darryl-h/)
# Maintainer: Darryl H (https://github.com/darryl-h/)
# Purpose: Automatically downloads public .crt file from specified domain and uses it in MeshCentral
# Version: 0.1000
Domain=yourcompany.com
SiteTempTLSCertificate=/tmp/webserver-cert-public.crt
MeshTLSCertificate=/opt/meshcentral/meshcentral-data/webserver-cert-public.crt
MeshAccount=meshcentral
function DownloadCurrentTLSCertificate () {
  echo -n | openssl s_client -connect ${Domain}:443 2> /dev/null| sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > ${SiteTempTLSCertificate}
}
function UpdateMeshTLSCertificate () {
  logger --tag MeshTLSCert "Detected TLS certificate update on ${Domain}! Updating local MeshCentral TLS certificate and restarting MeshCentral server"
  cp ${SiteTempTLSCertificate} ${MeshTLSCertificate}
  chown --recursive ${MeshAccount}:${MeshAccount} /opt/meshcentral
  service meshcentral restart
}
function CompareTLSCertificate () {
  if ! cmp ${SiteTempTLSCertificate} ${MeshTLSCertificate}~ >/dev/null 2>&1
  then
    UpdateMeshTLSCertificate
  fi
  rm ${SiteTempTLSCertificate}
}
DownloadCurrentTLSCertificate
CompareTLSCertificate