#include <ruby.h>


VALUE SimpleCModule = Qnil;

VALUE simple_module_simple_method() {
  return INT2NUM(1);
}

void Init_simp() {
  SimpleCModule = rb_define_module("SimpleC");
  rb_define_module_function(SimpleCModule,
                            "simple",
                            simple_module_simple_method,
                            0
                            );
}
