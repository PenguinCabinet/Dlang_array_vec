import vec;
import vec_outside_Exception;
import std.math;
import std.conv;
import std.random;

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
       "
      if(!vec_math_tool_OK!(T)){\n
           throw new vec_outside_Exception(\"Array element type is not numeric.\");\n
      };\n
        static if(!is(T==real)){\n
          return a.Get_cast!(real)().map(toDelegate(&"~e~")).Get_cast!(T)();\n
        }\n
        else{\n
          return a.map(toDelegate(&"~e~"));\n
        }\n
      };\n";
  }
  return A;
};


mixin(vec_math_tool_generator1());


array!T vec_math_tool_arange(T)(T stop){

  T temp;

  static if(is(T==float)||is(T==double)||is(T==real)){
    temp=ceil(stop);
  }
  else{
    temp=stop;
  }

  array!T A=new array!T([to!(uint)(temp)]);

  T i=start;
  for (uint i2=0;i2<to!(uint)(temp);i2++) {
    A[i2]=i;
    i++;
  }

  return A;
}

array!T vec_math_tool_arange(T)(T start,T stop){
  T temp;

  static if(is(T==float)||is(T==double)||is(T==real)){
    temp=ceil(stop-start);
  }
  else{
    temp=stop-start;
  }

  array!T A=new array!T([to!(uint)(temp)]);

  T i=start;
  for (uint i2=0;i2<to!(uint)(temp);i2++) {
    A[i2]=i;
    i++;
  }

  return A;
}

array!T vec_math_tool_arange(T)(T start,T stop,T step){
  T temp;

  static if(is(T==float)||is(T==double)||is(T==real)){
    temp=ceil((stop-start)/step);
  }
  else{
    temp=(stop-start)/step;
  }

  array!T A=new array!T([to!(uint)(temp)]);

  T i=start;
  for (uint i2=0;i2<to!(uint)(temp);i2++) {
    A[i2]=i;
    i+=stop;
  }

  return A;
}


array!T vec_math_tool_int_uniform(T)(long a1,long a2,uint size){
  auto rnd = Random(unpredictableSeed);

  array!T A=new array!T([size]);

  A=A.map((x)=>to!(T)(uniform(a1,a2,rnd)));

  return A;
};

array!T vec_math_tool_real_uniform(T)(real a1,real a2,uint size){
  auto rnd = Random(unpredictableSeed);

  array!T A=new array!T([size]);

  A=A.map((x)=>to!(T)(uniform(a1,a2,rnd)));

  return A;
};
