---
title: "windows cmake 报错 make: *** No targets specified and no makefile found. Stop."
date: 2020-09-14 19:18:21
tags:
---

据nzh大佬说是没有指定编译器啥的

```
cmake .. -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++ -G "Unix Makefiles"
```

我的CMakeLists.txt
```
cmake_minimum_required(VERSION 3.2)
project(main)
set(CMAKE_CXX_FLAGS_DEBUG "$ENV{CXXFLAGS} -O0 -g -Wall -Wextra -fexceptions")
set(CMAKE_CXX_FLAGS_RELEASE "$ENV{CXXFLAGS} -O3 -Wall -Wextra -fexceptions")
IF (CMAKE_BUILD_TYPE STREQUAL Debug)
    ADD_DEFINITIONS(-DDEBUG)
ENDIF()

aux_source_directory(src SRCS)
add_executable(${PROJECT_NAME} ${SRCS})
target_include_directories(${PROJECT_NAME}
	PRIVATE
		${PROJECT_SOURCE_DIR}/include
)
target_link_libraries(${PROJECT_NAME}
	PRIVATE
)
target_compile_features(${PROJECT_NAME} PRIVATE cxx_auto_type)
#set(CMAKE_CXX_STANDARD 11)
```
