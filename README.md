# breaking-correlation

7/23/19

This experiment seeks to explore methods for breaking correlations between some, or all, maximal
conductances found in the bursting neuron. Presently, the use of one (1) integral controller, as per
O'Leary et al. 2014, results in the expression of positive correlations between all maximal conductances.
This, however, is not biophysically realistic. Though Liu et al. 1999 was more biophysically realistic,
the model is slow and the choice of control is not necessarily realistic, though biological
experiments have yet to confirm this.

## Breakdown

### Two_Controllers

Utilizes two different controllers (integral & bang-bang) to break positive correlation

### BB_Cond_Two_Targets, BB_mRNA_Two_Targets, IC_Two_Targets

Utilizes either a bang-bang controller (mRNA or direct conductance modification) or an integral
controller to break correlation by connecting different conductances to different calcium targets.

(NOTE: Unlikely to be biophysically realistic due to potential issues with wind-up. This has yet
to be confirmed; it is possible that two targets can be used without wind-up, though mathematically
much more challenging to implement, if not impossible.)

### Hardwire

Hardwires some conductances to a fixed point, while allowing for some to be homeostatically regulated.

### Total protein

Conductances are homeostatically regulated dependent on the fraction of total proteins in the cell.
Degradation rate of proteins is indiscriminate. 

### Misc Files

compartment.hpp -- modified xolotl compartment constructor that allows for multiple calcium targets.
hacky implementation. beware! might break your xolotl/cpplab.
