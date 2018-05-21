test1:
		dmd -Isrc/ test_binary\\test1.exe src/vec.d src/vec_outside_Exception.d src/vec_math_tool.d  test/test_main.d
test2:
		dmd -gc -Isrc/ test_binary\\test2.exe src/vec.d src/vec_outside_Exception.d src/vec_math_tool.d test/test_main2.d
