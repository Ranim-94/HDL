
# Thermostat Part 2

## Table of Contents

- [Thermostat Part 2](#thermostat-part-2)
  - [Table of Contents](#table-of-contents)
  - [Context](#context)
  - [Report](#report)
    - [My Implementation](#my-implementation)
    - [Correction: 1st implementation](#correction-1st-implementation)
    - [Correction: 2nd implementation using default assignments](#correction-2nd-implementation-using-default-assignments)
    - [A simple Run example](#a-simple-run-example)
    - [Special Case: both temperatures are equal](#special-case-both-temperatures-are-equal)
  - [Miscellaneous Mistakes](#miscellaneous-mistakes)
    - [Port declaration in the entity](#port-declaration-in-the-entity)
    - [The if-else](#the-if-else)
    - [Signal assignment](#signal-assignment)
    - [Test bench must be updated](#test-bench-must-be-updated)
  - [Extra Notes](#extra-notes)
    - [Comparing bit\_vector with \> and \<](#comparing-bit_vector-with--and-)
  - [Test bench](#test-bench)
    - [Test cases](#test-cases)
    - [wait for statement](#wait-for-statement)
    - [assert](#assert)

## Context

This doc contains some mistakes while implementing part 2

## Report

Recall from [`Thermostat_Lab.md`](Thermostat_Lab.md) (section [Part 2](Thermostat_Lab.md#part-2)), that we added 2 extra features (cooling and heating)
controlled by 2 switches, and these features operate under certain conditions:

- **AC is ON** when `sw_cool = '1'` **and** `temp_current > temp_desired` (it is hot)
- **Furnace is ON** when `sw_heat = '1'` **and** `temp_current < temp_desired` (it is cold)
- in **every other case**, the AC and the furnace must be **OFF**

### My Implementation

The process in `thermostat_src.vhd` (section *My solution to part 2*):

```vhdl
process(select_disp,
        sw_cool,sw_heat,
        temp_current,temp_desired)
begin

    if select_disp = '1' then
        temp_disp <= temp_current;
    else
        temp_disp <= temp_desired;
    end if;

    -- My solution to part 2:
    -- adding AC and Furnace functionality according to conditions
    if sw_cool = '1' and temp_current > temp_desired
        ac = '1'

    if sw_heat = '1' and temp_current < temp_desired
        furnace = '1'

end process;
```

<u>What is missing in this implementation:</u>

The conditions are correct: the AC (and the furnace) **turns ON** in the right case. But **nothing ever turns it OFF**.

- The `if` only says what happens when the condition is **true**, there is no `else` for when it is **false**.
- In VHDL, a signal that is **not assigned** in a process **keeps its old value**.

Example with the AC:

1. `sw_cool = '1'` and it is hot → `ac` becomes `'1'` ✔
2. Now we turn `sw_cool` OFF (or the room cools down) → the `if` is false, `ac` is not assigned → `ac` **stays `'1'`** ✘

So the AC never turns off.

In synthesis, this "keep the old value" behaviour is implemented as a **latch** (Vivado gives a warning about an inferred latch). This is not what we want for combinational logic.

> **Rule (combinational process):** every output must be assigned a value on **every** path through the process.

### Correction: 1st implementation

Add an `else` branch that sets the output back to `'0'`:

```vhdl
process(select_disp,
        sw_cool,sw_heat,
        temp_current,temp_desired)
begin

    if select_disp = '1' then
        temp_disp <= temp_current;
    else
        temp_disp <= temp_desired;
    end if;

    -- Part 2: AC and Furnace
    if sw_cool = '1' and temp_current > temp_desired then
        ac <= '1';
    else
        ac <= '0';
    end if;

    if sw_heat = '1' and temp_current < temp_desired then
        furnace <= '1';
    else
        furnace <= '0';
    end if;

end process;
```

### Correction: 2nd implementation using default assignments

Assign default values at the top of the process, then only set the outputs to `'1'` inside the `if`s. Since the last assignment in a process wins, this has the same behaviour as the `else` version:

```vhdl
process(select_disp,
        sw_cool,sw_heat,
        temp_current,temp_desired)
begin

    if select_disp = '1' then
        temp_disp <= temp_current;
    else
        temp_disp <= temp_desired;
    end if;

    -- Part 2: AC and Furnace
    ac      <= '0';  -- defaults (must come BEFORE the ifs)
    furnace <= '0';

    if sw_cool = '1' and temp_current > temp_desired then
        ac <= '1';
    end if;

    if sw_heat = '1' and temp_current < temp_desired then
        furnace <= '1';
    end if;

end process;
```

<u>Why the logic is sound:</u>

- `>` and `<` can never be true at the same time → the AC and the furnace can **never be ON together**.
- When `temp_current = temp_desired` → both stay OFF.

### A simple Run example 

The 2 approaches, using either `if-else` (section [Correction: 1st implementation](#correction-1st-implementation)) or default assignments (section [Correction: 2nd implementation using default assignments](#correction-2nd-implementation-using-default-assignments)), both give the same result.

To see why, we need 2 rules about how a process runs.

<u>Rule 1: the process runs again from the top every time an input changes</u>

- `sw_cool`, `sw_heat`, `temp_current` and `temp_desired` are all in the **sensitivity list**.
- When one of them changes, the process wakes up and executes **from the first line**, not from where it stopped last time.
- So on **every run**, the default line `ac <= '0';` is executed again.

<u>Rule 2: signals are updated at the end of the process, and the last assignment wins</u>

- Inside a process, `<=` does **not** change the signal immediately, it only **schedules** a new value.
- If the same signal is assigned several times in one run, only the **last** scheduled value is kept.
- The signal takes this value when the process finishes (suspends).

<u>Example run (AC, default assignment version)</u>

Scenario: `sw_cool = '1'`, it is hot so the AC turns ON. After some time the room cools down and `temp_current` becomes less than `temp_desired`.

| Moment | Default line `ac <= '0';` | `if` condition | Last assignment | `ac` after the process |
|---|---|---|---|---|
| Hot, `sw_cool = '1'` | schedules `'0'` | true → `ac <= '1'` runs | `'1'` | **`'1'`** (AC ON) |
| Later, room is cold (`temp_current` changed → process runs again) | schedules `'0'` | false → `if` is skipped | `'0'` | **`'0'`** (AC OFF) |

- In the 1st run, the `'0'` from the default is replaced by `'1'` before the process ends, so it **never appears on the output**: there is no glitch (`ac` does not flicker to `'0'` and back to `'1'`).
- In the 2nd run, the default is the **only** assignment to `ac`, so `ac` goes back to `'0'`.
- The same happens if we turn `sw_cool` OFF while it is still hot, since `sw_cool` is also in the sensitivity list.

With the `if-else` version, the 2nd run goes into the `else` branch and assigns `ac <= '0'` → same result.

<u>Comparison with my first implementation</u>

In my implementation there was **no default and no `else`**. In the 2nd run nothing assigns `ac`, so it keeps its old value `'1'` → latch. Both corrections guarantee that `ac` is assigned on **every** run, which is exactly the rule for combinational logic.

> **Watch out: order matters.** The default must come **before** the `if`. If `ac <= '0';` is placed **after** the `if`, it is always the last assignment, and the AC would **never** turn ON.

### Special Case: both temperatures are equal

In `thermostat_src.vhd` I added an extra block for the case when the temperatures are equal:

```vhdl
    -- special case (edge case): when temperatures are equal
    if temp_current = temp_desired then
        ac <= '0';
        furnace <= '0';
    end if; -- End special case
```

<u>Is it needed?</u> **No.** Both corrected versions (`if-else` and default assignment) already handle it.

Both conditions use **strict** comparisons (`>` and `<`). When `temp_current = temp_desired`:

- `temp_current > temp_desired` is **false** → `ac <= '0'` (from the `else`, or from the default)
- `temp_current < temp_desired` is **false** → `furnace <= '0'` (from the `else`, or from the default)

So both outputs are already `'0'` before the special-case block is even reached.

<u>What does the extra block do then?</u>

- Since the last assignment wins, its `ac <= '0'` simply replaces a `'0'` with another `'0'` → **nothing changes**.
- It is **harmless**: no latch, no wrong behaviour. In simulation, `ac` and `furnace` are exactly the same with or without it.
- **Vivado**: during synthesis it sees that the block adds no logic and **removes it** (optimizes it away).

<u>Recommendation</u>

Remove the block and keep a short comment instead. This keeps all the logic for each output in one place, and avoids a future reader thinking equality needs special handling (or missing that the block overrides earlier assignments):

```vhdl
    -- Note: when temp_current = temp_desired, both '>' and '<' are false,
    -- so ac and furnace are already '0' (no special case needed)
```

> **Note:** equality is handled because the comparisons are **strict**. If one day `>` is changed to `>=`, equality would turn the AC ON. In that case, it is better to fix the condition than to add a separate special case.

## Miscellaneous Mistakes

### Port declaration in the entity

Each port is separated by `;`, but the **last port must not end with `;`**.

Wrong (missing `;` after `temp_disp`, extra `;` after the last port):

```vhdl
-- output
temp_disp: out bit_vector(6 downto 0)
ac, furnace: out bit;

); -- End port
```

Correct:

```vhdl
-- output
temp_disp  : out bit_vector(6 downto 0);
ac, furnace: out bit

); -- End port
```

### The if-else

- `if` should always end with the keyword `then`
- every `if` must be closed with `end if;`

```vhdl
if condition then
    ...
else
    ...
end if;
```

### Signal assignment

- `=` is a **comparison** (used in conditions, e.g. `if sw_cool = '1' then`)
- `<=` is a **signal assignment**, and the statement ends with `;`

```vhdl
ac = '1'     -- wrong: this is a comparison, not an assignment
ac <= '1';   -- correct
```

### Test bench must be updated

The test bench `test_theromstat.vhd` still declares the component with only the Part 1 ports. Since `sw_cool` and `sw_heat` are **inputs**, the simulation will fail to elaborate until they are connected.

To do:

- add `sw_cool`, `sw_heat`, `ac`, `furnace` to the `component` declaration and the `port map`
- declare the matching internal signals
- add test cases, for example:
  - `sw_cool = '1'` and hot → `ac = '1'`
  - then `sw_cool = '0'` while still hot → `ac = '0'` (this is the case that failed in my implementation)
  - `sw_cool = '1'` but cold → `ac = '0'`
  - `temp_current = temp_desired` → `ac = '0'` and `furnace = '0'`

## Extra Notes

### Comparing bit_vector with > and <

- On `bit_vector`, `>` and `<` compare **bit by bit from the left** (lexicographic order), not as numbers.
- For two vectors of the **same length** (like our two 7-bit vectors), this gives the same result as an **unsigned** number comparison, so it works here.
- Later, it is better to use the `unsigned` type from `numeric_bit` (or `numeric_std` with `std_logic`), which makes the numeric meaning explicit.

## Test bench

The test bench is `test_theromstat.vhd`. It has 2 main tests:

1. **Display** functionality (`select_disp` → `temp_disp`)
2. **AC and Furnace** functionality, split into sub-cases

### Test cases

Recall the rule: an output is **ON** only if **all** its conditions are true (its switch is ON **and** the temperature condition is met). In **every other case** it must be **OFF**.

When writing tests, the natural thing is to test the **ON cases**, i.e. checking that the AC or furnace works. But most bugs hide in the cases we tend to forget:

- **ON → OFF transitions:** an output that **was** ON must turn OFF when one of its conditions stops being true (e.g. we slide its switch OFF). This is exactly the case my first implementation failed (the latch kept `ac = '1'`).
- **OFF cases:** if only **one** of the two conditions is true, the output must stay OFF. Both combinations must be tested:
  - temperature condition true, but switch OFF
  - switch ON, but temperature condition false

<u>Summary of the test cases</u>

| Test | Purpose | `sw_cool` | `sw_heat` | Temperatures | Expected |
|---|---|---|---|---|---|
| 1 | Display: `select_disp = '0'` then `'1'` | – | – | current = 00, desired = 7F | `temp_disp` = 7F then 00 |
| 2.1.a | ON: furnace | `'0'` | `'1'` | cold (current < desired) | furnace ON, AC OFF |
| 2.1.b | ON: AC | `'1'` | `'0'` | hot (current > desired) | AC ON, furnace OFF |
| 2.1.c | ON → OFF: AC switch slid OFF, still hot | `'0'` | `'0'` | hot (unchanged) | both OFF |
| 2.2.a | OFF: hot, but switches OFF | `'0'` | `'0'` | hot | both OFF |
| 2.2.b | OFF: cold, but switches OFF | `'0'` | `'0'` | cold | both OFF |
| 2.3.a | OFF: AC switch ON, but cold | `'1'` | `'0'` | cold | both OFF |
| 2.3.b | OFF: furnace switch ON, but hot | `'0'` | `'1'` | hot | both OFF |
| 2.4 | Edge case: equal temperatures | see below | see below | current = desired = 7F | both OFF |

<u>Set inputs explicitly, or say that you rely on the previous value</u>

A signal keeps its value until it is assigned again. So if a test does not set an input, it **silently inherits** the value left by the previous test. This causes 2 problems:

- the test **depends on the order** of the tests: if someone reorders or removes the previous test, this one silently tests something different;
- a reader **cannot tell** whether the inherited value is intended or a mistake.

**Rule:** each test case sets **all** the inputs it depends on and has one stated purpose. If a test **must** rely on the previous state, say so in a comment.

Review of each case:

| Test | Inputs set explicitly | Inputs inherited | OK? |
|---|---|---|---|
| 1 | temps, `select_disp` | switches (initial value `'0'` of type `bit`) | OK: the switches don't affect the display |
| 2.1.a | temps, `sw_heat` | `sw_cool` (`'0'` from initial value) | **Better:** add `sw_cool <= '0';` so the case does not depend on the start state |
| 2.1.b | temps, `sw_cool`, `sw_heat` | – | ✔ fully explicit (and the comment explains why `sw_heat` is reset) |
| 2.1.c | `sw_cool` | temps, `sw_heat` (from 2.1.b) | ✔ **intended:** a transition test **must** start from the previous state (AC ON). The comment says so. |
| 2.2.a | temps, both switches (set once for all 2.2.x) | – | ✔ |
| 2.2.b | temps | switches (from the 2.2 group line) | ✔ the comment "for all 2.2.x cases, switches are off" documents it |
| 2.3.a | temps, both switches | – | ✔ fully explicit |
| 2.3.b | temps, both switches | – | ✔ fully explicit |
| 2.4 | temps | `sw_heat = '1'`, `sw_cool = '0'` (from 2.3.b) | **To fix:** set the switches explicitly, and add an assert (see below) |

<u>Suggested 2.4</u>

The strongest edge-case test is with **both switches ON**: if the outputs stay OFF even then, it is only because of the equal temperatures.

```vhdl
  -- 2.4) Edge case: both temps are equal, both switches ON
  -- -> neither '>' nor '<' is true, so both outputs must stay OFF
  sw_cool <= '1'; sw_heat <= '1';
  temp_current <= "1111111"; temp_desired <= "1111111";

  wait for 10 ns;

  assert furnace = '0' and ac = '0'
    report "2.4) failed: equal temps, AC and Furnace should be off" severity error;

  wait; -- End testing
```

<u>Another case worth adding: both switches ON ("auto" mode)</u>

With both switches ON, the temperature decides: hot → only the AC, cold → only the furnace. This is a realistic use (like the "auto" mode of a real thermostat) and checks that the AC and the furnace never fight each other.

### wait for statement

<u>Changing an input takes effect only at a `wait`</u>

In a process, a signal assignment `<=` does **not** change the signal immediately: it only **schedules** the new value. The new value is applied only when the process **suspends**, i.e. reaches a `wait`.

After the test bench sets the inputs, 2 things must happen before the outputs are correct:

1. **The test bench inputs update:** when the test bench reaches `wait`, `temp_current`, `temp_desired`, `sw_heat`, ... take their new values.
2. **The design reacts:** these inputs are in the design's sensitivity list, so its process wakes up, runs, and schedules new values for `ac` and `furnace`. They update when the design's process suspends.

These 2 steps take **no simulated time**: they happen in **delta cycles**, small ordering steps inside the same instant (e.g. "20 ns + 1 delta", "20 ns + 2 deltas"). `wait for 10 ns` leaves more than enough room for them. Note that `wait for 0 ns` is **not** enough: it gives only 1 delta, so the inputs are updated but the design has not reacted yet.

The `wait for 10 ns` also gives each test case its own **10 ns slot in the waveform**, which makes it easy to read.

<u>What happens without `wait for`</u>

- **Between 2 test cases:** both cases' assignments are scheduled in the same instant, and for each signal the **last assignment wins**. The first case **never happens**. Example: removing the `wait` after 2.2.a means the temps of 2.2.a are immediately replaced by those of 2.2.b, so 2.2.a is never applied.
- **After the last test case (no `wait` at all after 2.4):** a process without a sensitivity list is an **infinite loop**. At `end process` it jumps straight back to `begin`, and the 2.4 values are overwritten in the same instant by test 1. So 2.4 is never seen.
- **A process with no `wait` at all:** it loops forever at time 0, and the simulation **hangs**.

<u>Why the final `wait;`</u>

With only `wait for 10 ns;` after 2.4, the edge case is seen, but the process loops back to test 1 and the **whole test repeats** until the simulation time limit (1000 ns by default in Vivado). Also, the 2nd round is **not** the same as the 1st, because the switches keep the values left by the last test (another reason to set inputs explicitly).

`wait;` with nothing after it means **suspend forever**:

- the stimulus runs **exactly once**, in a known order, from a known start state;
- the inputs keep their last values, and the waveform stays flat;
- no events are left, so with "run all" the simulator stops on its own;
- each assert fires at most once (no repeated error messages).

| Ending of the process | Result |
|---|---|
| no `wait` after 2.4 | 2.4 is overwritten instantly and never seen |
| `wait for 10 ns;` only | 2.4 is seen, but the whole test repeats forever, with different starting switch values |
| `wait for 10 ns;` + `wait;` | 2.4 is seen, the test runs once, the simulation can end cleanly |

### assert

<u>What `assert` means</u>

An `assert` is a statement about the design: "at this point, this condition **must** be true". The simulator checks it. If it is true, nothing happens. If it is false, the simulator prints a message.

It works like `assert` in other languages:

| Language | Syntax |
|---|---|
| Python | `assert x > 0, "x must be positive"` |
| C++ | `assert(x > 0);` |
| MATLAB | `assert(x > 0, 'x must be positive')` |
| VHDL | `assert x > 0 report "x must be positive" severity error;` |

> We write the condition we **expect**, not the error condition: `assert ac = '1'` means "I expect `ac` to be `'1'`, complain if it isn't".

<u>The 3 parts</u>

```vhdl
assert   <condition>        -- what should be true
report   "<message>"        -- printed only if the condition is false
severity <level>;           -- how serious the failure is
```

| Level | Meaning | Effect in Vivado |
|---|---|---|
| `note` | information | print and continue |
| `warning` | suspicious | print and continue |
| `error` | the test failed | print and continue → all failures are seen in one run |
| `failure` | fatal | print and **stop the simulation** |

Unlike Python or C++, a failed VHDL assert does not necessarily stop the program: with `severity error`, the simulation continues, so one run can report several failed tests.

The message appears in the **Tcl Console** (bottom of Vivado), with the simulation time:

```
Error: 2.1.a) failed: furnace should be ON
Time: 30 ns  Iteration: 0  Process: /T_TEMPMUX/line__53  File: .../test_theromstat.vhd
```

<u>Why use asserts</u>

- **No more checking the waveform by eye:** expectations written as comments (`-- temp_disp = 7F`) become checks done by the simulator. A comment can be wrong without anyone noticing; an assert can't.
- **Regression testing:** after changing the design, re-run the test bench: a quiet Tcl console means nothing broke.
- **Simulation only:** synthesis ignores asserts, so they cost nothing in hardware. They can also be put in the design itself to check something that must always hold:

```vhdl
assert not (ac = '1' and furnace = '1')
  report "AC and furnace ON at the same time!" severity failure;
```

<u>The importance of `wait` before `assert`</u>

The pattern is always: **set inputs → wait → assert outputs.**

The assert checks the **outputs**, and they are only correct after the 2 steps described in [wait for statement](#wait-for-statement). If the assert comes **before** the `wait`, it reads the **old** values, from before the inputs were changed.

Timing example with 2.1.a, if the assert is moved before the wait:

```vhdl
  temp_current <= "0000000"; temp_desired <= "1111111";
  sw_heat <= '1';
  assert furnace = '1' and ac = '0'   -- runs NOW, at 20 ns
    report "2.1.a) failed: furnace should be ON" severity error;
  wait for 10 ns;
```

At 20 ns, when the assert runs:

| Signal | Value seen by the assert | Why |
|---|---|---|
| `sw_heat` | `'0'` | the new `'1'` is only scheduled |
| `furnace` | `'0'` | left over from test 1 (both switches OFF) |
| `ac` | `'0'` | left over from test 1 |

`furnace = '1'` is false → the assert reports **"2.1.a) failed"** even though the design is correct. The test bench is wrong, not the design.

It can also go the other way: a **false pass**. If the previous test happened to leave the expected values on the outputs, the assert passes even if the design is broken for the new case. This is worse, because it goes unnoticed.

With the assert **after** `wait for 10 ns`, it runs at 30 ns, when the inputs and outputs have settled: `furnace = '1'`, `ac = '0'` → the assert passes silently.

<u>Timeline of the whole test bench</u>

| Time | Test | Assert checked at the end of the slot |
|---|---|---|
| 0 – 10 ns | 1, `select_disp = '0'` | – |
| 10 – 20 ns | 1, `select_disp = '1'` | – |
| 20 – 30 ns | 2.1.a | at 30 ns |
| 30 – 40 ns | 2.1.b | at 40 ns |
| 40 – 50 ns | 2.1.c | at 50 ns |
| 50 – 60 ns | 2.2.a | at 60 ns |
| 60 – 70 ns | 2.2.b | at 70 ns |
| 70 – 80 ns | 2.3.a | at 80 ns |
| 80 – 90 ns | 2.3.b | at 90 ns |
| 90 – 100 ns | 2.4 | at 100 ns (once the assert is added) |
| 100 ns → | `wait;` | process suspended forever |

<u>Trying it out: a deliberately false assert</u>

To see what a failure looks like, add a wrong check right after the 2.1.a assert (the furnace is ON there, so this must fail), run the simulation and look at the Tcl Console:

```vhdl
  -- DEMO: deliberately wrong check, remove after testing
  assert furnace = '0'
    report "DEMO) this assert is meant to fail: furnace is ON" severity error;
```

- With `severity error`: the message appears at 30 ns and the simulation continues.
- With `severity failure`: the simulation **stops** at 30 ns.

Remove the demo assert afterwards.

<u>Going further</u>

- **Exhaustive testing:** the AC/furnace logic has only 7 + 7 + 2 = 16 input bits (about 65 000 combinations), so 2 nested loops over all temperature pairs, checked against an integer comparison (`i > j`), can test every case in a few seconds of simulation.
- For bigger designs, where testing everything is impossible: randomized tests and frameworks like VUnit or OSVVM.
