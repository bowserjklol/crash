#ifndef crash_missing_h
#define crash_missing_h

extern "C" {
#include <openssl/opensslv.h>
#include <openssl/crypto.h>
}

#if OPENSSL_VERSION_NUMBER > 0x10100000L && !(defined HAVE_LIBRESSL) && !(defined BORINGSSL_API_VERSION)
#define EVP_MD_CTX_delete EVP_MD_CTX_free
#else
#define EVP_MD_CTX_delete EVP_MD_CTX_destroy
#endif

#if OPENSSL_VERSION_NUMBER >= 0x30000000L
#define EVP_PKEY_cmp EVP_PKEY_eq
#endif

#if OPENSSL_VERSION_NUMBER >= 0x30000000L || LIBRESSL_VERSION_NUMBER >= 0x30000000L
#ifndef NO_DTLS_LISTEN
#define HAVE_DTLS_LISTEN
#endif
#endif


#endif

