## A) About

This is version 0.2.8 of `ParforProgress2`, a simple parfor progress monitor for matlab. See also http://www.mathworks.com/matlabcentral/fileexchange/35609-matlab-parforprogress2.

This progress monitor comes with a nice wrapper [`ParforProgressStarter2.m`](ParforProgressStarter2.m) which will take care of adding the classes to the java class path, depending on whether matlabpool / parpool is enabled or not.

## B) Setup

* clone this directory 
* add directory to matlab path: `addpath('/path/to/matlab-ParforProgress2')`

## C) How to use
By default `ParforProgress2` is very easy to use: 

1) add program location to matlab path  
2) run `ParforProgress2`.  
See *C1 - no globals* below for details.  

In case your Matlab programs make use of `global` variables, things are a bit more complicated. See *C2 - with globals* below for details.  


### C1) no globals

See [`ParforProgressStressTest2.m`](ParforProgressStressTest2.m) or [`ParforProgressStarter2.m`](ParforProgressStarter2.m) for usage instructions.


### C2) with globals
`ParforProgress2` makes use of `javaaddpath` and `javaclasspath`. Using either of these functions makes Matlab call `clear java` which does clear all global variables. This Matlab behaviour is intentional. See http://www.mathworks.com/help/matlab/matlab_external/bringing-java-classes-and-methods-into-matlab-workspace.html for details.

In order to make `ParforProgress2` work with globals, see the following instructions, which depend on your used Matlab version.


#### C2.1) Matlab 2012b and later:
- create `javaclasspath.txt` file in your preference directory.
- add path to `ParforProgressStarter2` to this file.

On Linux this translates to:
```
$ cd .matlab/R2013a
$ echo "/path/to/matlab-ParforProgress2" > javaclasspath.txt
```

Next, startup Matlab and call `ParforProgressStarter2`, but do not run `javaddpath`:


```
 >> % setup parameters
 >> show_execution_time = 1;
 >> run_javaaddpath = 0;
 >> s = 'dummy task';
 >> n = 100;
 >> percentage = 0.1;
 >> do_debug = 0;
 >>
 >> % initialize the ProgressMonitor
 >> ppm = ParforProgressStarter2(s, n, percentage, do_debug, run_javaaddpath, show_execution_time)
 >> 
 >> % run your computation
 >> for j = 1 : n
 >>     your_computation();
 >>     ppm.increment(i); 
 >> end
 >>
 >> % delete the ProgressMonitor
 >> delete(ppm);
```


#### C2.2) Matlab 2012a and earlier:

Unfortunately Matlab 2012a and earlier versions of Matlab do not support customized
`javaclasspath.txt` files, instead, you need to edit the `classpath.txt` file that is
part of the Matlab installation. You might need administrator / superuser privileges to 
edit this file. Here's how you can locate it:

```
>> which classpath.txt -all
/share/pkgs/MATLAB/R2012a/toolbox/local/classpath.txt
>> edit classpath.txt 
```




