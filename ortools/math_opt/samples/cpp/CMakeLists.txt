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
if(NOT BUILD_SAMPLES)
  return()
endif()

if(BUILD_CXX_SAMPLES)
  file(GLOB CXX_SRCS "*.cc")
  list(FILTER CXX_SRCS EXCLUDE REGEX "area_socp.cc$")
  list(FILTER CXX_SRCS EXCLUDE REGEX "coil_in_the_box.cc$") # missing base/context.h

  if(NOT USE_SCIP)
    list(FILTER CXX_SRCS EXCLUDE REGEX "cocktail_hour.cc$")
    list(FILTER CXX_SRCS EXCLUDE REGEX "lagrangian_relaxation.cc$")
    list(FILTER CXX_SRCS EXCLUDE REGEX "time_indexed_scheduling.cc$")
  endif()
  # Name conflicts with samples in other components.
  list(FILTER CXX_SRCS EXCLUDE REGEX "basic_example.cc$")
  list(FILTER CXX_SRCS EXCLUDE REGEX "diet_problem.cc$")
  list(FILTER CXX_SRCS EXCLUDE REGEX "tsp.cc$")
  list(FILTER CXX_SRCS EXCLUDE REGEX "integer_programming.cc$")
  list(FILTER CXX_SRCS EXCLUDE REGEX "linear_programming.cc$")
  list(FILTER CXX_SRCS EXCLUDE REGEX "linear_regression.cc$")


  foreach(SAMPLE IN LISTS CXX_SRCS)
    add_cxx_sample(
      FILE_NAME ${SAMPLE}
      COMPONENT_NAME math_opt)
  endforeach()

  set(SAMPLE_NAME math_opt_basic_example)
  set(SAMPLE_FILE basic_example.cc)
  add_executable(${SAMPLE_NAME} ${SAMPLE_FILE})
  target_include_directories(${SAMPLE_NAME} PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
  target_compile_features(${SAMPLE_NAME} PRIVATE cxx_std_17)
  target_link_libraries(${SAMPLE_NAME} PRIVATE ${PROJECT_NAMESPACE}::ortools)

  include(GNUInstallDirs)
  if(APPLE)
    set_target_properties(${SAMPLE_NAME} PROPERTIES INSTALL_RPATH
      "@loader_path/../${CMAKE_INSTALL_LIBDIR};@loader_path")
  elseif(UNIX)
    cmake_path(RELATIVE_PATH CMAKE_INSTALL_FULL_LIBDIR
      BASE_DIRECTORY ${CMAKE_INSTALL_FULL_BINDIR}
      OUTPUT_VARIABLE libdir_relative_path)
    set_target_properties(${SAMPLE_NAME} PROPERTIES
      INSTALL_RPATH "$ORIGIN/${libdir_relative_path}")
  endif()
  install(TARGETS ${SAMPLE_NAME})

  if(BUILD_TESTING)
    add_test(
      NAME cxx_math_opt_${SAMPLE_NAME}
      COMMAND ${SAMPLE_NAME})
  endif()

  set(SAMPLE_NAME math_opt_diet_problem)
  set(SAMPLE_FILE diet_problem.cc)
  add_executable(${SAMPLE_NAME} ${SAMPLE_FILE})
  target_include_directories(${SAMPLE_NAME} PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
  target_compile_features(${SAMPLE_NAME} PRIVATE cxx_std_17)
  target_link_libraries(${SAMPLE_NAME} PRIVATE ${PROJECT_NAMESPACE}::ortools)

  if(APPLE)
    set_target_properties(${SAMPLE_NAME} PROPERTIES INSTALL_RPATH
      "@loader_path/../${CMAKE_INSTALL_LIBDIR};@loader_path")
  elseif(UNIX)
    set_target_properties(${SAMPLE_NAME} PROPERTIES
      INSTALL_RPATH "$ORIGIN/${libdir_relative_path}")
  endif()
  install(TARGETS ${SAMPLE_NAME})

  if(BUILD_TESTING)
    add_test(
      NAME cxx_math_opt_${SAMPLE_NAME}
      COMMAND ${SAMPLE_NAME})
  endif()
endif()
