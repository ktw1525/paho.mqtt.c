/*
 * Copyright 2009 DreamSecurity, Co.,Ltd.
 * All rights reserved.
 * Use is subject to license terms.
 *
 * by phyoon - phyoon@dreamsecurity.com
 * eng_mc.h
 */

#ifndef  __ENG_MC_H__
#define  __ENG_MC_H__

/**
 * error code start index
 */
#define ERR_R_MC_BASEINDEX  (400)

/**
 * NOTE:
 * If the function binds MagicCrypto(tm) successfully, the return value is 1.
 * Otherwise, the return value is 0.
 *
 */
int bindMagicCryptoEngine(void);

/**
 * NOTE:
 * It unbind all elements releated with MagicCrypto.
 *
 */
void unbindMagicCryptoEngine(void);

#endif /* __ENG_MC_H__ */

