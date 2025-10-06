if (NOT MSVC)
    target_link_libraries(${PROJECT_LIB} PRIVATE m) # add math library
endif()