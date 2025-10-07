if (NOT MSVC)
    target_link_libraries(${PROJECT_LIB} PRIVATE m) # add math library
endif()

set_tests_properties(utils/sum PROPERTIES LABELS "test label")
