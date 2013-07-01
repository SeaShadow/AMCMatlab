## Matlab code collection #

Matlab M-files to analyse experimental flow rate data. Collection will be extended to include M-files for other sensor analysis as well. Main purpose of repository is to act as backup and code collection. Code has not been optimised for performance just quick and dirty data analysis.

### Requirements ##

- Matlab 2007 or higher

**Note:** All required Matlab function M-files are included in repository so code hould work as is.

### Expected File Sctructure for DAQ Run Files ##

```
|Run files directory
    |_Matlab
    |01.run
    |02.run
    |03.run
    |04.run
    |...
```

Some more details about the directory structure:

```
|Run files directory
```
**Description:** Main data directory.

```
|Run files directory
    |_Matlab
```
**Description:** Directtory for Maltab M-files.

```
|Run files directory
    |_Matlab
    |01.run
    |02.run
    |03.run
    |04.run
    |...
```
**Description:** Run directories; stored experimental data as created by data acquisition (DAQ) system.

The expected run files names in the run directories are as follows:
```
|Run files directory
    |_Matlab
    |01.run
        |R01-01_zeros.dat
        |R01-02_moving.dat        
    |02.run
        |R02-01_zeros.dat
        |R02-02_moving.dat        
    |03.run
        |R03-01_zeros.dat
        |R03-02_moving.dat        
    |04.run
        |R04-01_zeros.dat
        |R04-02_moving.dat        
    |...
```
**Description:** Where R01, R02, etc. stands for run 1, run2, etc. `Rxx-01_zeros.dat` contains collected zero data and `Rxx-02_moving.dat` contains sensor data where `xx` stands for run number.

### To Do ##

1. Code needs to be restructured to adhere to OOP rules.
2. Functions should be moved in common directory

### License ##

Copyright (c) 2013 Konrad Zurcher

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
