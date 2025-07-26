if (NOT MSVC)
    target_link_libraries(${LIB_NAME} PUBLIC m) # add math library
endif()