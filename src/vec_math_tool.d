import vec;
import vec_outside_Exception;
import std.math;

bool vec_math_tool_OK(T)(){
  return is(T==real)||is(T==double)||is(T==float)||is(T==long)||is(T==ulong)||
         is(T==int)||is(T==uint)||is(T==ushort)||is(T==short);
};

const string[] vec_math_tool_generator_list=[
"cos","sin","tan","acos","asin","atan","atan2",
"cosh","sinh","tanh","acosh","asinh","atanh",
"exp","exp2","log","log10","log1p","log2","cbrt","erf",
"ceil","floor","nearbyint","rint","lrint","round","lround",
"trunc","sqrt","abs"
];

string vec_math_tool_generator1(){
  string A;
  foreach(e;vec_math_tool_generator_list){
    A~="array!T vec_math_tool_"~e~"(T)(array!T a){\n"~
       "  if(!vec_math_tool_OK!(T)){\n
           throw new vec_outside_Exception(\"Array element type is not numeric.\");\n
      };\n
      return a.map(&"~e~");\n};\n";
  }
  return A;
};


mixin(vec_math_tool_generator1());
