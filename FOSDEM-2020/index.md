---
title: Support for mini-debuginfo in LLDB
subtitle: 'How to read the .gnu_debugdata section'
subject: LLDB development
institute: Red Hat
category: FOSDEM 2020 talk
author:
- Konrad Kleine
keywords: [lldb, gdb, gnu_debugdata, minidebuginfo]
abstract: |
  Some text
  that can spread
  multiple lines
date: February 2, 2020
lang: en-GB
...

##  \faicon{user} About me

:::::::::::::: {.columns}
::: {.column width="70%"}
![](img/redhat.pdf){height=0.5cm}

* LLDB, C/C++, ELF, DWARF since 2019
* joined and worked on OpenShift in 2016

:::
::: {.column width="30%"}
![](img/llvm-circle-metropolis.pdf)
:::
::::::::::::::

### \faicon{comments-o} Reach out

* \faicon{github-square} <https://github.com/kwk/talks/>
* \faicon{linkedin-square} <https://www.linkedin.com/in/konradkleine>
<!-- * \faicon{rss} <https://developers.redhat.com/blog/author/kkleine/> -->

## \faicon{crosshairs} Overall goal

### Improve LLDB for Fedora and RHEL binaries

* when no debug symbols installed
  * backtraces only show addresses
  * runtime symbols stored in special location

### Approach

* make LLDB understand mini-debuginfo
  * that's where runtime symbols are stored

## \faicon{lightbulb-o} Why was mini-debuginfo invented and how?

* without installing debug infos
  * be able to generate a backtrace for crashes with ABRT[^abrt]
  * ~~have symbol table (`.symtab`)~~
  * ~~have line information (`.debug_line`)~~
  * \faicon{arrow-right} *more than two sections make up an ELF file \faicon{smile-o}*

* eventually only one relevant section
  * stripped `.symtab` (only function symbols)
  * rest was too big
  * ELF format remained
  * **no replacement** for separate full debug info
  * **not related** to DWARF
    * *just symbol tables*

[^abrt]: Automatic Bug Reporting Tool

## Symbol tables in an ELF file

![](img/symtab-dynsym.pdf)

## Where and since when is mini-debuginfo being used?

<!-- * [RPM since 4.13.0-rc2 (2016)](https://rpm.org/timeline.html) -->
* On by default since Fedora 18 (2013, [Release Notes 4.2.4.1.](https://docs.fedoraproject.org/en-US/Fedora/18/pdf/Release_Notes/Fedora-18-Release_Notes-en-US.pdf#page=23))
* Red Hat Enterprise Linux (RHEL) since 7

## \faicon{map-signs} Approach

### Not focus on backtraces

* but make LLDB see mini-debuginfo
  * set and hit breakpoint
  * dump symbols (`(lldb) image dump symtab`)

### Take existing Fedora binary (`/usr/bin/zip`)
* identify a symbol/function
* shootout: GDB vs. LLDB
* hurdles:
  * not from `.dynsym`
  * from within `.gnu_debugdata`

## \faicon{folder-open-o} Extract + decompress `.gnu_debugdata` from `/usr/bin/zip`

```{.bash .small .numberLines}
# Dump section
~$ objcopy --dump-section .gnu_debugdata=zip.gdd.xz zip

# Determine file type of section
~$ file zip.gdd.xz
zip.gdd.xz: XZ compressed data

# Decompress section
~$ xz --decompress --keep zip.gdd.xz

# Determine file type of decompressed section
~$ file zip.gdd
zip.gdd: ELF 64-bit LSB executable, x86-64, version 1 [...]
```

<!-- * `eu-readelf -Ws --elf-section` can directly access `.gnu_debugdata` -->


## \faicon{eye} Identify symbol in `zip.gdd` but not in main binary

```{.bash .tiny .numberLines}
# Show symbols
~$ eu-readelf -s zip.gdd

Symbol table [28] '.symtab' contains 202 entries:
 82 local symbols  String table: [29] '.strtab'
  Num:            Value   Size Type    Bind   Vis          Ndx Name
    0: 0000000000000000      0 NOTYPE  LOCAL  DEFAULT    UNDEF 
    1: 0000000000408db0    494 FUNC    LOCAL  DEFAULT       15 freeup
    2: 0000000000408fa0   1015 FUNC    LOCAL  DEFAULT       15 DisplayRunningStats
    3: 00000000004093a0    128 FUNC    LOCAL  DEFAULT       15 help
[...]
```

### **`help`** looks promising[^promising].

```{.bash .scriptsize .numberLines startFrom=11}
~$ eu-readelf --symbols /usr/bin/zip | grep help
~$
```

[^promising]: Promising as in: we may be able to trigger it with `/usr/bin/zip --help`.

## ![](img/Archer Fish.pdf){width=1cm height=1cm} Set and hit breakpoint on `help` with GDB 8.3[^gdb83]

```{.bash .tiny .numberLines}
~$ gdb --nx --args /usr/bin/zip --help

Reading symbols from /usr/bin/zip...
Reading symbols from .gnu_debugdata for /usr/bin/zip...
(No debugging symbols found in .gnu_debugdata for /usr/bin/zip)
Missing separate debuginfos, use: dnf debuginfo-install zip-3.0-25.fc31.x86_64

(gdb) b help
Breakpoint 1 at 0x4093a0

(gdb) r
Starting program: /usr/bin/zip --help

Breakpoint 1, 0x00000000004093a0 in help ()
(gdb) 
```

### Success and two things to note:

1. Symbols read from `.gnu_debugdata`
2. No debug symbols installed for zip

[^gdb83]: GDB 8.3  is what ships with Fedora 31

## ![](img/llvm-circle-white.pdf){width=0.5cm height=0.5cm} Set and hit breakpoint on `help` with LLDB 9.0.0[^lldb9]

```{.bash .scriptsize .numberLines}
~$ lldb -x /usr/bin/zip -- --help

(lldb) target create "/usr/bin/zip"
Current executable set to '/usr/bin/zip' (x86_64).
(lldb) settings set -- target.run-args  "--help"

(lldb) b help
Breakpoint 1: no locations (pending).
WARNING:  Unable to resolve breakpoint to any actual locations.

(lldb)
```

[^lldb9]: LLDB 9.0.0 is what ships with Fedora 31

## \faicon{exclamation-triangle} Let's talk `.symtab`

### Symtab
* normally, `.dynsym` is subset
* **but** for mini-debuginfo `.dynsym` symbols are stripped[^strippedsymtab]

### Implications for LLDB (and other tools)
* parse `.dynsym` when
  * no `.symtab` found **or**
  * mini-debuginfo present and smuggled in

[^strippedsymtab]: https://sourceware.org/gdb/current/onlinedocs/gdb/MiniDebugInfo.html


## \faicon{check-square-o} Show that LLDB can now find `help` symbol

```{.bash .tiny .numberLines}
$ lldb -x /usr/bin/zip -- --help

(lldb) target create "/usr/bin/zip"
Current executable set to '/usr/bin/zip' (x86_64).
(lldb) settings set -- target.run-args  "--help"

(lldb) b help
Breakpoint 1: where = zip`help, address = 0x00000000004093a0

(lldb) r
Process 277525 launched: '/usr/bin/zip' (x86_64)
Process 277525 stopped
* thread #1, name = 'zip', stop reason = breakpoint 1.1
    frame #0: 0x00000000004093a0 zip`help
zip`help:
->  0x4093a0 <+0>:  pushq  %r12
    0x4093a2 <+2>:  movq   0x2af6f(%rip), %rsi       ;  + 4056
    0x4093a9 <+9>:  movl   $0x1, %edi
    0x4093ae <+14>: xorl   %eax, %eax
(lldb)
```

[\faicon{heart-o} shipping with LLVM 10]{.large}

# \faicon{ship} Ready to ship?

## \faicon{question-circle-o} What tests exists for mini-debuginfo?

* \faicon{search} find symbol from `.gnu_debugdata`
* \faicon{exclamation-triangle} warning when mini-debuginfo w/o LZMA support
* \faicon{exclamation-circle} error when decompressing corrupted xz
* \faicon{gears} full example with compiled and modified code in accordance to gdb's documentation 

# \faicon{moon-o} fell asleep yet?

## \faicon{code} Example test file in Shell test suite

**lldb/test/Shell/Breakpoint/example.c:**
```{.scriptsize .cpp .numberLines}
// REQUIRES: system-linux, lzma, xz
// RUN: gcc -g -o %t %s
// RUN: %t 1 2 3 4 | FileCheck %s

#include <stdio.h>
int main(int argc, char* argv[]) {

  // CHECK: Number of {{.*}}: 5
  printf("Number of arguments: %d\n", argc);

  return 0;
}
```

* features added: `lzma`, `xz`
  * just some CMake canonisation and Python config
    ```{.python .tiny .numberLines}
    if config.lldb_enable_lzma:
      config.available_features.add('lzma')
    if find_executable('xz') != None:
      config.available_features.add('xz')
    ```

## You might wonder...

### What was the hardest part?
* \faicon{smile-o} setting a breakpoint worked
* \faicon{frown-o} hitting a breakpoint didn't work 
  * non-runnable/sparse ELF files in YAML form didn't cut it
* \faicon{map-o} dealing with tests
  * `yaml2obj`[^yaml2obj] always produced `.symtab`
    * made my tests go nuts

### Community aspects 
* \faicon{balance-scale} polishing for upstream
* \faicon{github} repo migration to github, review in phabricator
  * strong opinions add unconstructive noise on LLVM mailing lists 

[^yaml2obj]: *"yaml2obj takes a YAML description of an object file and converts it to a binary file."*  (<https://llvm.org/docs/yaml2obj.html>)

## Real example of sparse ELF test file

### \faicon{search} Check to find symbol `multiplyByFour` in mini-debuginfo

\vspace{0.4cm}

```{.yaml .tiny .numberLines}
# REQUIRES: lzma
# RUN: yaml2obj %s > %t.obj
# RUN: llvm-objcopy --remove-section=.symtab %t.obj
# RUN: %lldb -b -o 'image dump symtab' %t.obj | FileCheck %s
# CHECK: [ 0] 1 X Code 0x00000000004005b0 0x000000000000000f 0x00000012 multiplyByFour

--- !ELF
FileHeader:
  Class:           ELFCLASS64
  Data:            ELFDATA2LSB
  Type:            ET_EXEC
  Machine:         EM_X86_64
  Entry:           0x00000000004004C0
Sections:
  - Name:            .gnu_debugdata
    Type:            SHT_PROGBITS
    AddressAlign:    0x0000000000000001
    Content:         FD377A585A000004E6 # ...
...
```

* notice line 4 manually removes `.symtab`
* meanwhile `yaml2obj` was fixed

##  {.standout}

\vfill{}
<!-- \begin{columns}
  \begin{column}{0.5\textwidth}
    \begin{flushright}
      \includegraphics[width=1.8cm,height=1.8cm]{img/llvm-circle-white.pdf}
    \end{flushright}
  \end{column}
  \begin{column}{0.5\textwidth}  
    \begin{flushleft}
      \includegraphics[width=2cm,height=2cm]{img/Logo-RedHat-Hat-White-RGB.pdf}
    \end{flushleft}
  \end{column}
\end{columns} -->

![](img/llvm-circle-and-red-hat.pdf){height=2cm}

\vspace{1cm}

[Thank you!]{.Huge}

[Please, share your feedback \faicon{star} \faicon{star} \faicon{star} \faicon{star} \faicon{star-half-full}]{.tiny}

[<https://submission.fosdem.org/feedback/10393>]{.tiny}
