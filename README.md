## CONVERT TABLES FML32 TO FILES JAVA

This application convert tables FML32 from Tuxedo to files Java and generate a package .JAR for use in projects of Oracle Service Bus and give it integration with Oracle Tuxedo Services.

# Requirements

1. JDK >= 6u45
2. Oracle WebLogic Server >= 10.3.6
3. OS Linux
4. Basic knowledge of Linux Systems

# File Structure

- **FML13** _root dir_
    - **bin** _contains final .JAR after execute process_
    - **conf** _contains config files por generate package java_
        - map.txt _example config file for map package java_
    - **fml** _contains all files FML32 for convert_
        - * _Any file FML32 type_
    - **java** _Contains unordered POJO files to compile_
    - **log** _Contains log files with errors info_
    - **src** _Contains the structure of package with POJO's to compile_
        - **tables** _dir example simulating package Java_
        - **opge** _dir example simulating package java_
        - **ppcs** _dir example simulating package java_
        - **ppga** _dir example simulating package java_
- generateTuxedoTransformFML.sh _Shell script to initiate the convert process_

# Execute Process

Basically the process is execute the shell `generateTuxedoTransformFML.sh` from a terminal Linux. The shell will ask for 3 paths:

1. Path JDK
2. WebLogic Library (`weblogic.jar` from dir install of product WebLogic)
3. Path FML13 (default is actual shell dir)

___Warning: You should put at least one file FML32 in dir `fml`.___
