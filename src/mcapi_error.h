/************************************************************************/
/* Copyright (c) 2007, Dreamsecurity co., ltd. All Rights Reserved.     */
/*                                                                      */
/* 본 소스코드의 일부 또는 전체를 (주)드림시큐리티의 사전 승낙 없이     */
/* 다른 프로그램이나 다른 사람에게 복사, 변경, 전재, 배포 및 다른       */
/* 컴퓨터언어로 변환 등 기타 불법적인 사용을 금합니다.                  */
/*                                                                      */
/*     회사 : (주)드림시큐리티                                          */
/*     주소 : 서울시 송파구 문정동 150-28 서경빌딩 5층                  */
/*     연락처 : (02)2233-5533                                           */
/*     개발자 : 김대식(kalacus@dreamsecurity.com)                       */
/*              장형도(hdjang@dreamsecurity.com)                        */
/************************************************************************/

/*-[ History ]------------------------------------------------------------
설명 : mcapi_error.h 

2007-08-24 : v1.0.1
	- 에러코드 추가 (MC_ERR_NOT_SESSION_OBJECT) by hdjang
2007-03-06 : v1.0
	- 생성 by hdjang
------------------------------------------------------------------------*/

#ifndef _MC_HEADER_9330603E_D03D_4B8B_9746_9ED098D8A5CB
#define _MC_HEADER_9330603E_D03D_4B8B_9746_9ED098D8A5CB


#define MC_ERR_BASE							0x1000
#define MC_ERR_NULL_DATA_POINTER			MC_ERR_BASE+1
#define MC_ERR_DATA_LENGTH					MC_ERR_BASE+2
#define MC_ERR_MEMORY_ALLOC_FAILED			MC_ERR_BASE+3
#define MC_ERR_MCAPI_NOT_INITIALIZED		MC_ERR_BASE+4
#define MC_ERR_MCAPI_ALREADY_INITIALIZED	MC_ERR_BASE+5
#define MC_ERR_SESSION_NOT_OPENED			MC_ERR_BASE+6
#define MC_ERR_SESSION_ALREADY_OPENED		MC_ERR_BASE+7
#define MC_ERR_INVALID_POINTER				MC_ERR_BASE+8
#define MC_ERR_INVALID_HANDLE				MC_ERR_BASE+9
#define MC_ERR_DATA_NOT_CREATED				MC_ERR_BASE+10
#define MC_ERR_DATA_CREATED					MC_ERR_BASE+11
#define MC_ERR_UNSUPPORTED_ALGORITHM		MC_ERR_BASE+12
#define MC_ERR_UNSUPPORTED_PADTYPE			MC_ERR_BASE+13
#define MC_ERR_UNSUPPORTED_MODE				MC_ERR_BASE+14
#define MC_ERR_INIT_PROCESS_MISSING			MC_ERR_BASE+15
#define MC_ERR_UPDATE_PROCESS_MISSING		MC_ERR_BASE+16
#define MC_ERR_OTHER_PROCESS_RUNNING		MC_ERR_BASE+17
#define MC_ERR_SET_KEY						MC_ERR_BASE+18
#define MC_ERR_SET_IV						MC_ERR_BASE+19
#define MC_ERR_SET_PUBKEY					MC_ERR_BASE+20
#define MC_ERR_SET_PRIKEY					MC_ERR_BASE+21
#define MC_ERR_SET_PARAM					MC_ERR_BASE+22
#define MC_ERR_PROCESS_FAILED				MC_ERR_BASE+23
#define MC_ERR_ENCRYPTED_DATA_LENGTH		MC_ERR_BASE+24
#define MC_ERR_DECRYPT_FAILED				MC_ERR_BASE+25
#define MC_ERR_VERIFY_FAILED				MC_ERR_BASE+26
#define MC_ERR_NOT_ENOUGH_BUFFER			MC_ERR_BASE+27
#define MC_ERR_NOT_SESSION_OBJECT			MC_ERR_BASE+28

//MC_STR MC_GetErrorString(MC_RV rv);


#endif /* _MC_HEADER_9330603E_D03D_4B8B_9746_9ED098D8A5CB */

