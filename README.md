# Breaking Correlations

7/23/19

This experiment seeks to explore methods for "breaking" correlations between some, or all, maximal
conductances between ion channels.

## Breakdown

### Two_Controllers

Utilizes two different controllers (integral & bang-bang) to break positive correlation

### BB_Cond_Two_Targets, BB_mRNA_Two_Targets, IC_Two_Targets

Utilizes either a bang-bang controller (mRNA or direct conductance modification) or an integral
controller to break correlation by connecting different conductances to different calcium targets.

### Hardwire

Hardwires some conductances to a fixed point, while allowing for some to be homeostatically regulated.

### Total protein

Conductances are homeostatically regulated dependent on the fraction of total proteins in the cell.
Degradation rate of proteins is indiscriminate. 

### Misc Files

compartment.hpp -- modified xolotl compartment constructor that allows for multiple calcium targets.
hacky implementation. beware! might break your xolotl/cpplab.
