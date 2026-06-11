#!/usr/bin/env bash
set -euo pipefail

# Gera o par de chaves RSA da demo do fcg-identity.
# Apenas GERA o material; não injeta a chave, não roda em build/boot, não versiona PEM.
# Colar o PEM no destino (override do compose / Secret do k8s) é passo manual.

PRIV="${1:-identity-rsa-private.pem}"

case "$PRIV" in
  *-private.pem) PUB="${PRIV%-private.pem}-public.pem" ;;
  *.pem)         PUB="${PRIV%.pem}-public.pem" ;;
  *)             PUB="${PRIV}-public.pem" ;;
esac

KEY_ID="fcg-identity-key-1"

if ! command -v openssl >/dev/null 2>&1; then
  echo "erro: openssl não encontrado no PATH. Instale o OpenSSL e tente de novo." >&2
  exit 1
fi

if [[ -e "$PRIV" || -e "$PUB" ]]; then
  echo "erro: '$PRIV' ou '$PUB' já existe — não vou sobrescrever." >&2
  echo "       remova o arquivo ou passe outro caminho:" >&2
  echo "       bash scripts/gen-rsa-key.sh caminho/da-chave-private.pem" >&2
  exit 1
fi

openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out "$PRIV"
openssl rsa -in "$PRIV" -pubout -out "$PUB"

cat <<EOF

Chaves geradas:
  privada : $PRIV
  pública : $PUB   (apenas conferência/inspeção da JWK)

Como aplicar a chave privada (nunca em arquivo versionado):
  Jwt__RsaPrivateKeyPem = conteúdo CRU do PEM ($PRIV), multilinha, como está
                          (lido via RSA.ImportFromPem — sem base64, sem path)
  Jwt__KeyId            = $KEY_ID

Destino:
  Compose : arquivo de override NÃO versionado (block scalar multilinha)
  k8s     : Secret 'identity-jwt'
EOF
