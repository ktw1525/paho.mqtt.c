#!/usr/bin/env bash
# Cross-build Eclipse Paho MQTT C (shared) for ARMv7 (Yocto SDK + OpenSSL 1.1.1g shared)
# 산출물은 DESTDIR 스테이징에 모음
set -Ee -o pipefail

### 0) 절대경로 (환경에 맞게 점검)
YOCTO_ENV="/home/ktw/Documents/tm2sdk-master/environment-setup-armv7a-vfp-neon-oe-linux-gnueabi"
PAHO_SRC="/home/ktw/Documents/GitHub/paho.mqtt.c"
OPENSSL_STAGE="/home/ktw/Documents/GitHub/openssl/output"   # shared로 빌드/설치된 OpenSSL의 DESTDIR 루트
BUILD_DIR="$PAHO_SRC/build-cross"
DESTDIR_STAGE="$PAHO_SRC/output"
INSTALL_PREFIX="/usr"

### 1) Yocto 환경 로드
[[ -f "$YOCTO_ENV" ]] || { echo "Yocto SDK env 없음: $YOCTO_ENV"; exit 1; }
# shellcheck disable=SC1090
source "$YOCTO_ENV"

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

### 4) OpenSSL 힌트 (shared 사용)
export OPENSSL_ROOT_DIR="$OPENSSL_STAGE/usr"
export OPENSSL_INCLUDE_DIR="$OPENSSL_ROOT_DIR/include"

# shared lib 확인 (DESTDIR 루트 기준)
[[ -f "$OPENSSL_STAGE/usr/lib/libssl.so.1.1" || -f "$OPENSSL_STAGE/usr/lib/libssl.so" ]] \
  || { echo "shared libssl.so(.1.1) 없음: $OPENSSL_STAGE/usr/lib"; exit 1; }
[[ -f "$OPENSSL_STAGE/usr/lib/libcrypto.so.1.1" || -f "$OPENSSL_STAGE/usr/lib/libcrypto.so" ]] \
  || { echo "shared libcrypto.so(.1.1) 없음: $OPENSSL_STAGE/usr/lib"; exit 1; }

# CMake FindOpenSSL에 힌트 제공 (가능하면 .so.1.1을 지정)
if [[ -f "$OPENSSL_STAGE/usr/lib/libssl.so.1.1" ]]; then
  export OPENSSL_SSL_LIBRARY="$OPENSSL_ROOT_DIR/lib/libssl.so.1.1"
else
  export OPENSSL_SSL_LIBRARY="$OPENSSL_ROOT_DIR/lib/libssl.so"
fi

if [[ -f "$OPENSSL_STAGE/usr/lib/libcrypto.so.1.1" ]]; then
  export OPENSSL_CRYPTO_LIBRARY="$OPENSSL_ROOT_DIR/lib/libcrypto.so.1.1"
else
  export OPENSSL_CRYPTO_LIBRARY="$OPENSSL_ROOT_DIR/lib/libcrypto.so"
fi

# pkg-config도 타깃 쪽 먼저 보게
export PKG_CONFIG_SYSROOT_DIR="$SDKTARGETSYSROOT"
export PKG_CONFIG_LIBDIR="$OPENSSL_ROOT_DIR/lib/pkgconfig:$SDKTARGETSYSROOT/usr/lib/pkgconfig:$SDKTARGETSYSROOT/usr/share/pkgconfig"
export PKG_CONFIG_PATH="$PKG_CONFIG_LIBDIR"

### 5) CMake 툴체인 파일 (shared 링크)
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

# shared 빌드
set(BUILD_SHARED_LIBS ON CACHE BOOL "Build shared libs" FORCE)

# .so 우선
set(CMAKE_FIND_LIBRARY_SUFFIXES ".so" ".a")

set(CMAKE_FIND_ROOT_PATH "$ENV{SDKTARGETSYSROOT}" "$ENV{OPENSSL_ROOT_DIR}")
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# MagicCrypto/의존성
# DSO(.so)로 링크하면 보통 -lMagicCrypto만으로 충분하지만,
# 환경에 따라 -lmc, -ldl, -lpthread, -lrt 등이 필요할 수 있음
set(CMAKE_C_STANDARD_LIBRARIES "${CMAKE_C_STANDARD_LIBRARIES} -lMagicCrypto -lmc -ldl -lpthread -lz -lrt")
EOF

### 6) CMake 설정 (shared Paho + SSL ON)
CMAKE_GEN="-G Ninja"
command -v ninja >/dev/null || CMAKE_GEN=""

cmake -S . -B "$BUILD_DIR" $CMAKE_GEN \
  -DCMAKE_TOOLCHAIN_FILE="$TOOLCHAIN_FILE" \
  -DCMAKE_INSTALL_PREFIX="$INSTALL_PREFIX" \
  -DPAHO_WITH_SSL=ON \
  -DPAHO_BUILD_SAMPLES=ON \
  -DPAHO_ENABLE_TESTING=OFF \
  -DOPENSSL_ROOT_DIR="$OPENSSL_ROOT_DIR" \
  -DOPENSSL_INCLUDE_DIR="$OPENSSL_INCLUDE_DIR" \
  -DOPENSSL_CRYPTO_LIBRARY="$OPENSSL_CRYPTO_LIBRARY" \
  -DOPENSSL_SSL_LIBRARY="$OPENSSL_SSL_LIBRARY" \
  -DOPENSSL_USE_STATIC_LIBS=OFF \
  -DBUILD_SHARED_LIBS=ON \
  -DPAHO_BUILD_SHARED=ON \
  -DPAHO_BUILD_STATIC=OFF

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

ls -l "$DESTDIR_STAGE$INSTALL_PREFIX/lib" || true

# 샘플 바이너리의 NEEDED 항목 확인 (shared이면 libssl/libcrypto 등이 보여야 함)
if command -v "${CROSS_COMPILE:-arm-oe-linux-gnueabi-}readelf" >/dev/null 2>&1; then
  for f in "$DESTDIR_STAGE$INSTALL_PREFIX/bin/"*; do
    echo "---- readelf -d $(basename "$f")"
    "${CROSS_COMPILE:-arm-oe-linux-gnueabi-}readelf" -d "$f" 2>/dev/null | egrep 'NEEDED|RPATH|RUNPATH' || true
  done
fi

echo "완료. 이 스테이징 트리를 타깃 / 에 복사하면 됩니다."
echo "런타임 주의:"
echo "  - 타깃에 /usr/lib/libssl.so.1.1, /usr/lib/libcrypto.so.1.1 이 있어야 합니다."
echo "  - MagicCrypto가 DSO(.so)라면 타깃 /usr/lib에 libMagicCrypto.so 가 있어야 합니다."

# Debugging
# export MQTT_C_CLIENT_TRACE=ON
# export MQTT_C_CLIENT_TRACE_LEVEL=PROTOCOL