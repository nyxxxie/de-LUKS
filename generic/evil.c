#define _GNU_SOURCE  // needed for RTLD_NEXT
#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <dlfcn.h>

int crypt_activate_by_passphrase(
        void* cd, const char* name, int keyslot, const char* passphrase,
        size_t passphrase_size, uint32_t flags) {

    int (*orig_cabp)(void*, const char*, int, const char*, size_t, uint32_t);
    orig_cabp = dlsym(RTLD_NEXT, "crypt_activate_by_passphrase");

    printf("CABP: KEYSLOT: %d |  NAME: \"%s\" | PASSPHRASE: \"%s\"\n", keyslot, name, passphrase);

    return orig_cabp(cd, name, keyslot, passphrase, passphrase_size, flags);
}

int crypt_keyfile_device_read(
        void* cd, const char* keyfile, char** key, size_t* key_size_read,
	uint64_t keyfile_offset, size_t keyfile_size_max, uint32_t flags) {
    int ret;
    int (*orig_ckdr)(void*, const char*, char**, size_t*, uint64_t, size_t, uint32_t);
    orig_ckdr = dlsym(RTLD_NEXT, "crypt_keyfile_device_read");

    ret = orig_ckdr(cd, keyfile, key, key_size_read, keyfile_offset,
		    keyfile_size_max, flags);

    printf("CKDR: KEYFILE: \"%s\"\n", keyfile);

    return ret;
}

int crypt_get_volume_key_size(void* cd) {
    int (*orig_cgvks)(void*);
    orig_cgvks = dlsym(RTLD_NEXT, "crypt_get_volume_key_size");

    printf("CGVKS\n");

    return orig_cgvks(cd);
}

void crypt_safe_free(void* buf) {
    void (*orig_csf)(void*);
    orig_csf = dlsym(RTLD_NEXT, "crypt_safe_free");

    printf("CSF\n");

    return orig_csf(buf);

}
