

# Thermostat Lab

## Table of Contents

- [Thermostat Lab](#thermostat-lab)
  - [Table of Contents](#table-of-contents)
  - [Introduction](#introduction)
    - [Intro to theremostat system](#intro-to-theremostat-system)
  - [Test bench](#test-bench)
  - [Part 2](#part-2)
  - [Some errors while coding](#some-errors-while-coding)
    - [if-else](#if-else)

## Introduction

To grasp different `VHDL` concept, we will work thgrough the **thermostat lab** through various stages, that is each time we learn a new `VHDL` concept, we add and expand more.

### Intro to theremostat system

[Figure 1](#fig1) presents the thermostat system we want to work with.

<div id="fig1">
<img src="Figures_VsCode/thermostat_system.png" 
alt="Widget Types" width="550">
<p><strong>Figure 1:</strong> Thermostat system</p>
</div>

<u>Description:</u>
- if `SELECT_DISP` = 1, then `DISPLAY_TEMP` get assigned to `TEMP_CURRENT`
- otherwise `DISPLAY_TEMP`get assigned to `TEMP_DESIRED`

This desing is implemented in `Vivado` inside the project `Thermostat`.
  - its source file `thermostat_src.vhd`

## Test bench

To test our desing we implement also a simple test bench file, called `test_thermostat.vhd`
- the test file is also created as seen in `Hello_VHDL_OR.md`
- however for test file, the `test_thermostat.vhd` need to be in `Simulation Sources`, under sources in project manager as shown in [Figure 2](#fig2)

<div id="fig2">
<img src="Figures_VsCode/thermostat_test.png" 
alt="Widget Types" width="550">
<p><strong>Figure 2:</strong> Thermostat test file location</p>
</div>

Now to run the simulation, in the **flow navigator** press **Run Simulation**. The results for the simulation is shown in [Figure 3](#fig3)

<div id="fig3">
<img src="Figures_VsCode/test_sim_wav.png" 
alt="Widget Types" width="850">
<p><strong>Figure 3:</strong> Running test file simlation</p>
</div>

<u>Note: time scaling</u>

Since in our test file we are waiting for 10 ns, it is preferred to adjust the time scale of the simulation, becaue `Vivado` may not run directly in our time scale. As a matter of fact, the result shown in [Figure 3](#fig3) was adjusted using the options underneath `Help` tab
- I modified the simulation time scale an choose ns (before it was autmatically set for in micro s)
- I then press `Restart` and `Run`, using buttons shown in [Figure 4](#fig4)

<div id="fig4">
<img src="Figures_VsCode/test_sim_buttons.png" 
alt="Widget Types" width="450">
<p><strong>Figure 4:</strong> Simulation Buttons</p>
</div>

Also to navigate the wave figure and see results, use navigation buttons shown in [Figure 5](#fig5)

<div id="fig5">
<img src="Figures_VsCode/navigation_wav.png" 
alt="Widget Types" width="450">
<p><strong>Figure 5:</strong> Navigating the wav test</p>
</div>

## Part 2

Now we move to part 2, where we extend our system of [Figure 1](#fig1).

The extended system is shown in [Figure 6](#fig6)

<div id="fig6">
<img src="Figures_VsCode/thermostat_part_2.png" 
alt="Widget Types" width="450">
<p><strong>Figure 6:</strong> Thermostat part 2</p>
</div>

Now our themostat lab has extra functionalities, that is we have AC (for cooling) and Furnance mode (for heating), controlled by 2 switches added to the input side

- so we added 2 inputs and 2 outputs

<u>AC is ON:</u>

1. `cool` switch is ON
2. `TEMP_CURRENT` > `TEMP_DESIRED`
   - `TEMP_CURRENT` is high so it is hot


<u>Furnance is ON:</u>

1. `heat` switch is ON
2. `TEMP_CURRENT` < `TEMP_DESIRED`
   - `TEMP_CURRENT` is low so it is cold


## Some errors while coding

### if-else

- don't forget the keyword `then` after the `if`
- not like normal programming languages, like no `then` is used in these languges, directly we type the statement
