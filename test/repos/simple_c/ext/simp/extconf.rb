require 'mkmf'

dir_config('simp')
have_library('c', 'main')

create_makefile('simp')
