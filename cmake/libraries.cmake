if (NOT MSVC)
    target_link_libraries(${LIB_NAME} PRIVATE m) # add math library
endif()