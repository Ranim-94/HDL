
# VHDL

## Table of Contents

- [VHDL](#vhdl)
  - [Table of Contents](#table-of-contents)
  - [Goal](#goal)
  - [Developement Board](#developement-board)
    - [FPGA Target](#fpga-target)
  - [Developement Environment](#developement-environment)
    - [Installation Steps:](#installation-steps)
    - [Post Installation Step](#post-installation-step)
    - [Board Files](#board-files)
  - [Resources](#resources)
    - [Digital Desing theory](#digital-desing-theory)

## Goal

This readme contains explanation about my `VHDL` repository.

## Developement Board

The dev board I use is the [`Basys 3`](https://digilent.com/reference/programmable-logic/basys-3/start?srsltid=AfmBOoqGVJbxlMW3PSAckmjN5O8TFJ62KncVzTbJ7KuzSHw_93Lp0EJg) board from Digilent.

### FPGA Target

Since we working with `Basys 3` board, we enter directly the name of the FPGA part <-> that is xc7a35tcpg236-1
- xc7a35t → Artix-7 FPGA,cpg236 → Package (236-pin) and -1 → Speed grade
  
Knowing FPGA target is require when developing `HDL` program using tools such `Vivado`

## Developement Environment

we will use [`Vivado`](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools.html) design suite from AMD

Select the `web installer` version, because it is faster and takes less space.

### Installation Steps:

1. Downloded `FPGAs_AdaptiveSoCs_Unified_SDI_2025.1_0530_0145_Lin64.bin`.

2. Give it access using the `chmod` command:

<pre> chmod +x  FPGAs_AdaptiveSoCs_Unified_SDI_2025.1_0530_0145_Lin64.bin </pre>

3. Then run the installer:

<pre> sudo ./ FPGAs_AdaptiveSoCs_Unified_SDI_2025.1_0530_0145_Lin64.bin</pre>

- make sure to use `sudo` so we have permission to create folders,...

When the installer runs, it will ask us to sing in using our AMD account. Then we do these below steps:

a. Select `Vivado`  
b. then `Vivado ML Standard`  
c. make sure to select the tools as shown in  [pic tools install](install_pic/tools_download.png)  
d. Agree to all licesense  
e. When reaching [install directory step](install_pic/install_dir.png), install the software under `/opt/Xilinx`  

Now wait for the installer that can finish.

Then after finishing installation, run the command

### Post Installation Step

1. Running the software

After finishing installation, we should add these 2 lines to our `.bashrc` file:

<pre>export PATH=/opt/Xilinx/2025.1/Vivado/bin:$PATH</pre>

Now we can run `Vivado` from the terminal to lauch the program.

### Board Files

Since we are using `Basys3` baord, we need to import its definitions files from [`Digilent board files`](https://github.com/Digilent/vivado-boards), then install the `Basys3` board file under:

<pre>/opt/Xilinx/2025.1/Vivado/data/boards</pre>

If the directory `board_files` doesn't exist, creat it.

Note: refer to this [installation board files blog](https://digilent.com/reference/programmable-logic/guides/install-board-files?srsltid=AfmBOoqQD9M7llt2N_LTotKYk3l4MBvAOoUDobAd6zG2Iro0cniw1Hhp) for more info if needed

<u>Steps</u>:

1. Clone the repository

<pre>git clone https://github.com/Digilent/vivado-boards.git</pre>

2. Use the command:

<pre> sudo cp -r vivado-boards/new/board_files/basys3 /opt/Xilinx/2025.1/Vivado/data/boards/board_files/ </pre>

## Resources

Here I put different resources, grouping youtube channel, gihutbs,....

- [FPGARevolution](https://www.youtube.com/@FPGARevolution)
   - Nice channle in `VHDL`
- [VisualElectric](https://www.youtube.com/@VisualElectric_)
  - nice tutorial about spectrum analyser using `Verilog`

- [TheHardwareDeveloper](https://www.youtube.com/@TheHardwareDeveloper)
  - nice ideas about using FPGA with other hardwares, like motors,sensors,...
  - he uses `Verilog`

- [Steven Bell](https://www.youtube.com/@botsnlinux/videos)
  - nice expalantion about digital desing and `VHDL`

- [VHDLwhiz](https://www.youtube.com/@VHDLwhiz)
  - mainly about `VHDL`
  - [website](https://vhdlwhiz.com/)
  - it can be nice for project, like bleutooth

- [Nandland](https://www.youtube.com/@Nandland)

### Digital Desing theory

- [DrLaMeres](https://www.youtube.com/@digitallogicprogramming2199/featured)
  - this is my refernce
  - playlist explain his textbook

- [OnurMutluLectures](https://www.youtube.com/@OnurMutluLectures)
  - Nice lectures, but very big and detailed
  - contains also advanced topics
  - uses `Verilog`
  - Maybe use it to review combinational and sequential logic later

