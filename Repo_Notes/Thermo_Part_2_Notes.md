
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
