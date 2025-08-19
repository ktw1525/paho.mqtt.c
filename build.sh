#!/usr/bin/env bash
# Cross-build Eclipse Paho MQTT C (static) for ARMv7 (Yocto SDK + OpenSSL 1.1.1g no-shared)
# 산출물은 DESTDIR 스테이징에 모음
set -Ee -o pipefail

### 0) 절대경로 (환경에 맞게 점검)
YOCTO_ENV="/home/ktw/Documents/tm2sdk-master/environment-setup-armv7a-vfp-neon-oe-linux-gnueabi"
PAHO_SRC="/home/ktw/Documents/GitHub/paho.mqtt.c"
OPENSSL_STAGE="/home/ktw/Documents/GitHub/openssl/output"   # no-shared로 빌드/설치된 OpenSSL의 DESTDIR 루트
BUILD_DIR="$PAHO_SRC/build-cross"
DESTDIR_STAGE="$PAHO_SRC/output"
INSTALL_PREFIX="/usr"

### 1) Yocto 환경 로드
[[ -f "$YOCTO_ENV" ]] || { echo "Yocto SDK env 없음: $YOCTO_ENV"; exit 1; }
# shellcheck disable=SC1090
source "$YOCTO_ENV"

# 타깃 OpenSSL 정적 라이브러리 확인
[[ -f "$OPENSSL_STAGE/usr/lib/libssl.a" ]] || { echo "정적 libssl.a 없음: $OPENSSL_STAGE/usr/lib/libssl.a"; exit 1; }
[[ -f "$OPENSSL_STAGE/usr/lib/libcrypto.a" ]] || { echo "정적 libcrypto.a 없음: $OPENSSL_STAGE/usr/lib/libcrypto.a"; exit 1; }

command -v cmake >/dev/null || { echo "cmake 필요"; exit 1; }
command -v ninja >/dev/null || echo "(참고) ninja가 있으면 더 빠릅니다."

### 2) 소스 준비
if [[ ! -d "$PAHO_SRC" ]]; then
  git clone --depth=1 https://github.com/eclipse/paho.mqtt.c.git "$PAHO_SRC"
fi
cd "$PAHO_SRC"
git submodule update --init --recursive || true
rm -rf "$BUILD_DIR" "$DESTDIR_STAGE"
mkdir -p "$BUILD_DIR" "$DESTDIR_STAGE"

### 3) CC/CXX 바이너리/플래그 분리
read -r -a CC_ARR <<< "${CC}"
CC_BIN="${CC_ARR[0]}"
CC_BIN_PATH="$(command -v "$CC_BIN")" || { echo "컴파일러 찾기 실패: $CC_BIN"; exit 1; }
CC_FLAGS="${CC#"$CC_BIN"}"

read -r -a CXX_ARR <<< "${CXX}"
CXX_BIN="${CXX_ARR[0]}"
CXX_BIN_PATH="$(command -v "$CXX_BIN")" || { echo "컴파일러 찾기 실패: $CXX_BIN"; exit 1; }
CXX_FLAGS="${CXX#"$CXX_BIN"}"

export CC_CMAKE="$CC_BIN_PATH"
export CXX_CMAKE="$CXX_BIN_PATH"
export EXTRA_C_FLAGS="$CC_FLAGS"
export EXTRA_CXX_FLAGS="$CXX_FLAGS"

### 4) OpenSSL 힌트 (정적만 사용)
export OPENSSL_ROOT_DIR="$OPENSSL_STAGE/usr"
export OPENSSL_INCLUDE_DIR="$OPENSSL_ROOT_DIR/include"
export OPENSSL_CRYPTO_LIBRARY="$OPENSSL_ROOT_DIR/lib/libcrypto.a"
export OPENSSL_SSL_LIBRARY="$OPENSSL_ROOT_DIR/lib/libssl.a"

# pkg-config도 타깃 쪽 먼저 보게 (정적 .pc가 있으면 사용)
export PKG_CONFIG_SYSROOT_DIR="$SDKTARGETSYSROOT"
export PKG_CONFIG_LIBDIR="$OPENSSL_ROOT_DIR/lib/pkgconfig:$SDKTARGETSYSROOT/usr/lib/pkgconfig:$SDKTARGETSYSROOT/usr/share/pkgconfig"
export PKG_CONFIG_PATH="$PKG_CONFIG_LIBDIR"

### 5) CMake 툴체인 파일 (정적 링크 강제)
TOOLCHAIN_FILE="$BUILD_DIR/toolchain.cmake"
cat > "$TOOLCHAIN_FILE" <<'EOF'
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR arm)
set(CMAKE_SYSROOT $ENV{SDKTARGETSYSROOT})

# 컴파일러 경로(바이너리) 고정
set(CMAKE_C_COMPILER   $ENV{CC_CMAKE})
set(CMAKE_CXX_COMPILER $ENV{CXX_CMAKE})
set(CMAKE_ASM_COMPILER $ENV{CC_CMAKE})

# 플래그 전달(필요 시 sysroot 재확인)
set(CMAKE_C_FLAGS               "${CMAKE_C_FLAGS} $ENV{EXTRA_C_FLAGS} --sysroot=$ENV{SDKTARGETSYSROOT}")
set(CMAKE_CXX_FLAGS             "${CMAKE_CXX_FLAGS} $ENV{EXTRA_CXX_FLAGS} --sysroot=$ENV{SDKTARGETSYSROOT}")
set(CMAKE_EXE_LINKER_FLAGS      "${CMAKE_EXE_LINKER_FLAGS} --sysroot=$ENV{SDKTARGETSYSROOT}")
set(CMAKE_SHARED_LINKER_FLAGS   "${CMAKE_SHARED_LINKER_FLAGS} --sysroot=$ENV{SDKTARGETSYSROOT}")

# 정적 라이브러리만 찾도록
set(BUILD_SHARED_LIBS OFF CACHE BOOL "Build shared libs" FORCE)
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
set(OPENSSL_USE_STATIC_LIBS ON)

# .a 우선
set(CMAKE_FIND_LIBRARY_SUFFIXES ".a")
set(CMAKE_FIND_ROOT_PATH "$ENV{SDKTARGETSYSROOT}" "$ENV{OPENSSL_ROOT_DIR}")
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# MagicCrypto/기본 정적 의존성 추가
# (bindMagicCryptoEngine() 심볼을 직접 링크하려면 -lMagicCrypto -lmc 필요)
# 정적 링크 특성상 pthread, dl, z, rt 등을 미리 지정
set(CMAKE_C_STANDARD_LIBRARIES "${CMAKE_C_STANDARD_LIBRARIES} -lMagicCrypto -lmc -ldl -lpthread -lz -lrt")
EOF

### 6) CMake 설정 (정적 Paho + SSL ON)
CMAKE_GEN="-G Ninja"
command -v ninja >/dev/null || CMAKE_GEN=""

cmake -S . -B "$BUILD_DIR" $CMAKE_GEN \
  -DCMAKE_TOOLCHAIN_FILE="$TOOLCHAIN_FILE" \
  -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
  -DPAHO_WITH_SSL=ON \
  -DPAHO_BUILD_SHARED=OFF \
  -DPAHO_BUILD_STATIC=ON \
  -DPAHO_BUILD_SAMPLES=ON \
  -DPAHO_ENABLE_TESTING=OFF \
  -DOPENSSL_ROOT_DIR="$OPENSSL_ROOT_DIR" \
  -DOPENSSL_INCLUDE_DIR="$OPENSSL_INCLUDE_DIR" \
  -DOPENSSL_CRYPTO_LIBRARY="$OPENSSL_CRYPTO_LIBRARY" \
  -DOPENSSL_SSL_LIBRARY="$OPENSSL_SSL_LIBRARY" \
  -DOPENSSL_USE_STATIC_LIBS=ON \
  -DBUILD_SHARED_LIBS=OFF

### 7) 빌드 & 설치(스테이징)
if command -v ninja >/dev/null; then
  ninja -C "$BUILD_DIR"
  DESTDIR="$DESTDIR_STAGE" ninja -C "$BUILD_DIR" install
else
  cmake --build "$BUILD_DIR" -j"$(nproc)"
  DESTDIR="$DESTDIR_STAGE" cmake --install "$BUILD_DIR"
fi

### 8) 결과 요약 & 링크 확인
echo
echo "== 설치(스테이징) 결과 =="
echo "  lib : $DESTDIR_STAGE$INSTALL_PREFIX/lib"
echo "  inc : $DESTDIR_STAGE$INSTALL_PREFIX/include"
echo "  bin : $DESTDIR_STAGE$INSTALL_PREFIX/bin"
echo

# 정적 라이브러리 산출 확인
ls -l "$DESTDIR_STAGE$INSTALL_PREFIX/lib" || true

# 샘플 바이너리의 NEEDED 항목(정적이면 거의 없음) 확인
if command -v "${CROSS_COMPILE:-arm-oe-linux-gnueabi-}readelf" >/dev/null 2>&1; then
  for f in "$DESTDIR_STAGE$INSTALL_PREFIX/bin/"*; do
    echo "---- readelf -d $(basename "$f")"
    "${CROSS_COMPILE:-arm-oe-linux-gnueabi-}readelf" -d "$f" 2>/dev/null | egrep 'NEEDED|RPATH' || true
  done
fi

echo "완료. 이 스테이징 트리를 타깃 / 에 복사하면 됩니다."
echo "런타임: MagicCrypto가 DSO(.so) 형태라면 타깃 /usr/lib에 libMagicCrypto.so가 있어야 하며, bindMagicCryptoEngine() 호출이 필요합니다."

#Debugging
# export MQTT_C_CLIENT_TRACE=ON
# export MQTT_C_CLIENT_TRACE_LEVEL=MAXIMUM 
# export MQTT_C_CLIENT_TRACE_DEST=/data/paho_trace.log 
# export MQTT_C_CLIENT_TRACE_MAX_LINES=100000 