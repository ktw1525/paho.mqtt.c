# Install script for directory: /home/ktw/Documents/GitHub/paho.mqtt.c

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/usr")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Install shared libraries without execute permission?
if(NOT DEFINED CMAKE_INSTALL_SO_NO_EXE)
  set(CMAKE_INSTALL_SO_NO_EXE "1")
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "TRUE")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/doc/Eclipse Paho C/samples" TYPE FILE FILES
    "/home/ktw/Documents/GitHub/paho.mqtt.c/src/samples/MQTTAsync_publish.c"
    "/home/ktw/Documents/GitHub/paho.mqtt.c/src/samples/MQTTAsync_publish_time.c"
    "/home/ktw/Documents/GitHub/paho.mqtt.c/src/samples/MQTTAsync_subscribe.c"
    "/home/ktw/Documents/GitHub/paho.mqtt.c/src/samples/MQTTClient_publish.c"
    "/home/ktw/Documents/GitHub/paho.mqtt.c/src/samples/MQTTClient_publish_async.c"
    "/home/ktw/Documents/GitHub/paho.mqtt.c/src/samples/MQTTClient_subscribe.c"
    "/home/ktw/Documents/GitHub/paho.mqtt.c/src/samples/paho_c_pub.c"
    "/home/ktw/Documents/GitHub/paho.mqtt.c/src/samples/paho_c_sub.c"
    "/home/ktw/Documents/GitHub/paho.mqtt.c/src/samples/paho_cs_pub.c"
    "/home/ktw/Documents/GitHub/paho.mqtt.c/src/samples/paho_cs_sub.c"
    "/home/ktw/Documents/GitHub/paho.mqtt.c/src/samples/pubsub_opts.c"
    )
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xUnspecifiedx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/doc/Eclipse Paho C" TYPE FILE FILES
    "/home/ktw/Documents/GitHub/paho.mqtt.c/CONTRIBUTING.md"
    "/home/ktw/Documents/GitHub/paho.mqtt.c/epl-v20"
    "/home/ktw/Documents/GitHub/paho.mqtt.c/edl-v10"
    "/home/ktw/Documents/GitHub/paho.mqtt.c/README.md"
    "/home/ktw/Documents/GitHub/paho.mqtt.c/notice.html"
    )
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for each subdirectory.
  include("/home/ktw/Documents/GitHub/paho.mqtt.c/build-cross/src/cmake_install.cmake")
  include("/home/ktw/Documents/GitHub/paho.mqtt.c/build-cross/src/samples/cmake_install.cmake")

endif()

if(CMAKE_INSTALL_COMPONENT)
  set(CMAKE_INSTALL_MANIFEST "install_manifest_${CMAKE_INSTALL_COMPONENT}.txt")
else()
  set(CMAKE_INSTALL_MANIFEST "install_manifest.txt")
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
file(WRITE "/home/ktw/Documents/GitHub/paho.mqtt.c/build-cross/${CMAKE_INSTALL_MANIFEST}"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
