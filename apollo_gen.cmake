

function(PROTOBUF_GENERATE_SOURCE SRCS HDRS PYS PROTOBUF_IMPORT_DIRS PROTOBUF_CPP_EXPORT_DIR PROTOBUF_PYTHON_EXPORT_DIR)
  if(NOT ARGN)
    message(SEND_ERROR "Error: PROTOBUF_GENERATE_SOURCE() called without any proto files")
    return()
  endif()

  if(DEFINED PROTOBUF_IMPORT_DIRS)
    foreach(DIR ${PROTOBUF_IMPORT_DIRS})
      get_filename_component(ABS_PATH ${DIR} ABSOLUTE)
      list(FIND _protobuf_include_path ${ABS_PATH} _contains_already)
      if(${_contains_already} EQUAL -1)
          list(APPEND _protobuf_include_path -I ${ABS_PATH})
      endif()
    endforeach()
  endif()

  set(${SRCS})
  set(${HDRS})
  set(${PYS})
  foreach(FIL ${ARGN})
    set(ABS_FIL ${PROTOBUF_IMPORT_DIRS}/${FIL})
    get_filename_component(FIL_WE ${FIL} NAME_WE)
    get_filename_component(RELATIVE_PATH ${FIL} PATH)

    list(APPEND ${SRCS} "${PROTOBUF_CPP_EXPORT_DIR}/${RELATIVE_PATH}/${FIL_WE}.pb.cc")
    list(APPEND ${HDRS} "${PROTOBUF_CPP_EXPORT_DIR}/${RELATIVE_PATH}/${FIL_WE}.pb.h")
    list(APPEND ${PYS} "${PROTOBUF_PYTHON_EXPORT_DIR}/${RELATIVE_PATH}/${FIL_WE}_pb2.py")

    add_custom_command(
      OUTPUT "${PROTOBUF_CPP_EXPORT_DIR}/${RELATIVE_PATH}/${FIL_WE}.pb.cc"
             "${PROTOBUF_CPP_EXPORT_DIR}/${RELATIVE_PATH}/${FIL_WE}.pb.h"
             "${PROTOBUF_PYTHON_EXPORT_DIR}/${RELATIVE_PATH}/${FIL_WE}_pb2.py"
      COMMAND ${PROTOBUF_PROTOC_EXECUTABLE}
      ARGS --cpp_out ${PROTOBUF_CPP_EXPORT_DIR}
           --python_out ${PROTOBUF_PYTHON_EXPORT_DIR}
           -I${PROTOBUF_IMPORT_DIRS} ${ABS_FIL}
      DEPENDS ${ABS_FIL} ${PROTOBUF_PROTOC_EXECUTABLE}
      COMMENT "Running C++/Python protocol buffer compiler on ${FIL}"
      VERBATIM)
  endforeach()

  set_source_files_properties(${${SRCS}} ${${HDRS}} ${${PYS}} PROPERTIES GENERATED TRUE)
  set(${SRCS} ${${SRCS}} PARENT_SCOPE)
  set(${HDRS} ${${HDRS}} PARENT_SCOPE)
  set(${PYS} ${${PYS}} PARENT_SCOPE)
endfunction()

find_package(Protobuf REQUIRED)
include_directories(${PROTOBUF_INCLUDE_DIRS})
include_directories(${CMAKE_CURRENT_BINARY_DIR}/..)
include_directories(${PROJECT_INCLUDE_DIRS}/..)

find_package(Boost REQUIRED COMPONENTS iostreams)
include_directories(${Boost_INCLUDE_DIRS})



set(PROTOBUF_IMPORT_DIRS ${CMAKE_CURRENT_SOURCE_DIR}/..)
set(PROTOBUF_CPP_EXPORT_DIR ${CMAKE_CURRENT_BINARY_DIR}/..)
set(PROTOBUF_PYTHON_EXPORT_DIR ${CMAKE_CURRENT_BINARY_DIR}/..)

FILE(GLOB_RECURSE ProtoFiles RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}/.. *.proto)

PROTOBUF_GENERATE_SOURCE(
  PROTOSRCS PROTOHDRS PYS
  ${PROTOBUF_IMPORT_DIRS}
  ${PROTOBUF_CPP_EXPORT_DIR}
  ${PROTOBUF_PYTHON_EXPORT_DIR}
  ${ProtoFiles}
)

add_library(apollo SHARED ${PROTOSRCS}
            apollo/hdmap/hdmap_common.cc
            apollo/hdmap/hdmap.cc
            apollo/hdmap/hdmap_impl.cc
            apollo/hdmap/hdmap_util.cc
            apollo/proto_utils.cc
            apollo/math/aabox2d.cc
            apollo/math/angle.cc
            apollo/math/box2d.cc
            apollo/math/cartesian_frenet_conversion.cc
            apollo/math/linear_interpolation.cc
            apollo/math/line_segment2d.cc
            apollo/math/math_utils.cc
            apollo/math/polygon2d.cc
            apollo/math/qp_solver.cc
            apollo/math/vec2d.cc
            apollo/math/search.cc
            apollo/math/sin_table.cc
            apollo/math/linear_quadratic_regulator.cc
            apollo/pnc_map/path.cc            
            apollo/pnc_map/route_segments.cc
            apollo/pnc_map/pnc_map.cc
            apollo/common/file.cc
            apollo/common/vehicle_config_helper.cc
            apollo/common/config_gflags.cc
)

find_package(gflags REQUIRED)
include_directories(${GFLAGS_INCLUDE_DIRS})

target_link_libraries(apollo
                      ${Boost_LIBRARIES}
                      ${PROTOBUF_LIBRARIES}
                      ${GFLAGS_LIBRARIES}
)

install(TARGETS apollo
        ARCHIVE DESTINATION ${CATKIN_PACKAGE_LIB_DESTINATION}
        LIBRARY DESTINATION ${CATKIN_PACKAGE_LIB_DESTINATION}
        RUNTIME DESTINATION ${CATKIN_PACKAGE_BIN_DESTINATION}
)

install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/proto
        DESTINATION ${CATKIN_PACKAGE_INCLUDE_DESTINATION}
        FILES_MATCHING PATTERN "*.pb.h"
)

install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/apollo
        DESTINATION ${CATKIN_PACKAGE_INCLUDE_DESTINATION}
        FILES_MATCHING PATTERN "*.pb.h"
)


