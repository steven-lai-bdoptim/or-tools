# Copyright 2010-2025 Google LLC
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Check dependencies
set(CMAKE_THREAD_PREFER_PTHREAD TRUE)
set(THREAD_PREFER_PTHREAD_FLAG TRUE)
find_package(Threads REQUIRED)

# Tell find_package() to try “Config” mode before “Module” mode if no mode was specified.
# This should avoid find_package() to first find our FindXXX.cmake modules if
# distro package already provide a CMake config file...
set(CMAKE_FIND_PACKAGE_PREFER_CONFIG TRUE)

# libprotobuf force us to depends on ZLIB::ZLIB target
if(NOT BUILD_ZLIB AND NOT TARGET ZLIB::ZLIB)
 find_package(ZLIB QUIET)
 if(NOT ZLIB_FOUND)
  message(STATUS "ZLIB not found on the system, enabling bundled build")
  set(BUILD_ZLIB ON CACHE BOOL "Build the ZLIB dependency Library" FORCE)
 endif()
endif()

if(NOT BUILD_BZip2 AND NOT TARGET BZip2::BZip2)
 find_package(BZip2 QUIET)
 if(NOT BZip2_FOUND)
  message(FATAL_ERROR
    "BZip2 not found on the system. Install the system development package "
    "(for Debian/Ubuntu: libbz2-dev) or provide BZIP2_INCLUDE_DIR and "
    "BZIP2_LIBRARIES.")
 endif()
endif()

if(NOT BUILD_absl AND NOT TARGET absl::base)
  find_package(absl QUIET)
  if(NOT absl_FOUND)
    message(STATUS "absl not found on the system, enabling bundled build")
    set(BUILD_absl ON CACHE BOOL "Build the abseil-cpp dependency Library" FORCE)
  endif()
endif()

if(NOT BUILD_Protobuf AND NOT TARGET protobuf::libprotobuf)
  find_package(Protobuf QUIET)
  if(NOT Protobuf_FOUND)
    message(STATUS "Protobuf not found on the system, enabling bundled build")
    set(BUILD_Protobuf ON CACHE BOOL "Build the Protobuf dependency Library" FORCE)
  endif()
endif()

if(NOT BUILD_Eigen3 AND NOT TARGET Eigen3::Eigen)
  find_package(Eigen3 QUIET)
  if(NOT Eigen3_FOUND)
    message(STATUS "Eigen3 not found on the system, enabling bundled build")
    set(BUILD_Eigen3 ON CACHE BOOL "Build the Eigen3 dependency Library" FORCE)
  endif()
endif()

if(NOT BUILD_re2 AND NOT TARGET re2::re2)
  find_package(re2 QUIET)
  if(NOT re2_FOUND)
    message(STATUS "re2 not found on the system, enabling bundled build")
    set(BUILD_re2 ON CACHE BOOL "Build the re2 dependency Library" FORCE)
  endif()
endif()

# Third Party Solvers
if(USE_COINOR)
  set(_ortools_missing_coinor FALSE)
  if(NOT BUILD_CoinUtils AND NOT TARGET Coin::CoinUtils)
    find_package(CoinUtils QUIET)
    if(NOT CoinUtils_FOUND)
      set(_ortools_missing_coinor TRUE)
    endif()
  endif()

  if(NOT BUILD_Osi AND NOT TARGET Coin::Osi)
    find_package(Osi QUIET)
    if(NOT Osi_FOUND)
      set(_ortools_missing_coinor TRUE)
    endif()
  endif()

  if(NOT BUILD_Clp AND NOT TARGET Coin::ClpSolver)
    find_package(Clp QUIET)
    if(NOT Clp_FOUND)
      set(_ortools_missing_coinor TRUE)
    endif()
  endif()

  if(NOT BUILD_Cgl AND NOT TARGET Coin::Cgl)
    find_package(Cgl QUIET)
    if(NOT Cgl_FOUND)
      set(_ortools_missing_coinor TRUE)
    endif()
  endif()

  if(NOT BUILD_Cbc AND NOT TARGET Coin::CbcSolver)
    find_package(Cbc QUIET)
    if(NOT Cbc_FOUND)
      set(_ortools_missing_coinor TRUE)
    endif()
  endif()

  if(_ortools_missing_coinor)
    message(STATUS "COIN-OR not found on the system, disabling COIN-OR support")
    set(USE_COINOR OFF CACHE BOOL "Use the COIN-OR solver" FORCE)
  endif()
endif()

if(USE_CPLEX)
  if(NOT TARGET CPLEX::CPLEX)
    find_package(CPLEX REQUIRED)
  endif()
endif()

if(USE_GLPK)
  if(NOT BUILD_GLPK AND NOT TARGET GLPK::GLPK)
    find_package(GLPK REQUIRED)
  endif()
endif()

if(USE_HIGHS)
  if(NOT BUILD_HIGHS AND NOT TARGET highs::highs)
    find_package(HIGHS QUIET)
    if(NOT HIGHS_FOUND)
      message(STATUS "HiGHS not found on the system, enabling bundled build")
      set(BUILD_HIGHS ON CACHE BOOL "Build the HiGHS dependency Library" FORCE)
    endif()
  endif()
endif()

if(USE_PDLP)
  if(NOT BUILD_PDLP)
    find_package(PDLP REQUIRED)
  endif()
endif()

if(USE_SCIP)
  if(NOT BUILD_SCIP AND NOT TARGET SCIP::libscip)
    find_package(SCIP QUIET NO_MODULE)
    if(SCIP_FOUND)
      if(TARGET libscip AND NOT TARGET SCIP::libscip)
        message(WARNING "SCIP::libscip not provided")
        add_library(SCIP::libscip ALIAS libscip)
      endif()
    elseif(SCIP_ROOT OR DEFINED ENV{SCIP_ROOT})
      find_package(SCIP QUIET)
      if(SCIP_FOUND AND TARGET libscip AND NOT TARGET SCIP::libscip)
        message(WARNING "SCIP::libscip not provided")
        add_library(SCIP::libscip ALIAS libscip)
      endif()
    else()
      message(STATUS "SCIP not found on the system, disabling SCIP support")
      set(USE_SCIP OFF CACHE BOOL "Use the Scip solver" FORCE)
    endif()
  endif()
endif()

# CXX Test
if(BUILD_TESTING)
  if(NOT BUILD_googletest AND NOT TARGET GTest::gtest_main)
    find_package(GTest QUIET)
    if(NOT GTest_FOUND)
      message(STATUS "GTest not found on the system, enabling bundled build")
      set(BUILD_googletest ON CACHE BOOL "Build googletest" FORCE)
    endif()
  endif()

  if(NOT BUILD_benchmark AND NOT TARGET benchmark::benchmark)
    find_package(benchmark QUIET)
    if(NOT benchmark_FOUND)
      message(STATUS "benchmark not found on the system, enabling bundled build")
      set(BUILD_benchmark ON CACHE BOOL "Build benchmark" FORCE)
    endif()
  endif()
endif()

# Check language Dependencies
if(BUILD_PYTHON)
  if(NOT BUILD_pybind11 AND NOT TARGET pybind11::pybind11_headers)
    find_package(pybind11 REQUIRED)
  endif()

  if(NOT BUILD_pybind11_abseil AND NOT TARGET pybind11_abseil::absl_casters)
    find_package(pybind11_abseil REQUIRED)
  endif()

  if(NOT BUILD_pybind11_protobuf AND NOT TARGET pybind11_native_proto_caster)
    find_package(pybind11_protobuf REQUIRED)
  endif()
endif()
