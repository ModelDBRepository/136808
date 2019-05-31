Simulation and fitting of two-compartment (active soma, passive dendrite) 
for different classes of cortical neurons.

The fitting technique indirectly matches neuronal currents derived from 
somatic membrane potential data rather than fitting the voltage traces 
directly. The method uses an analytic solution for the somatic ion channel 
maximal conductances given approximate models of the channel kinetics, 
membrane dynamics and dendrite. This approach is tested on model-derived 
data for various cortical neurons. 

The fitting method and models are described in

Lepora N., Overton P. and Gurney K.
Efficient fitting of conductance-based model neurons from somatic current 
clamp. 
Journal Computational Neuroscience 2011

The models are two compartment versions of the single compartment cortical 
neuron models described in (see also modelDB entry)

Pospischil, M., Toledo-Rodriguez, M., Monier, C., Piwkowska, Z., 
Bal, T., Fregnac, Y., Markram, H. and Destexhe, A.
Minimal Hodgkin-Huxley type models for different classes of
cortical and thalamic neurons.
Biological Cybernetics 99: 427-441, 2008.

Intrinsic currents: INa, IKd for action potentials, IM for spike-frequency 
adaptation, ICaL for high-threshold calcium current, ICaT for the 
low-threshold calcium current.  

Usage:
------

Requires GENESIS 2.3 in linux/unix. GENESIS must run from the command line.

Extract zipped folder and navigate to within the directory demo_modelDB.
Run fig1_tar.m in MATLAB to simulate the neurons, for generating the target 
data. Then run fig1.m in MATLAB to run the fitting routines and output jpg 
plots of the fits. The figure is based on fig1 in the paper (with a longer 
time-step to hasten running speed and minimize RAM use).

The properties of the simulated neurons and fit routine parameters can be 
changed by editing these two files.

Note that most of the figures in the paper were generated from compiled 
versions of this software on a small cluster.

Problems:
---------

Tested on three different installations (VMware Ubuntu, and two clusters 
with Scientific Linux).

If you have problems:
1) Can you run GENESIS from the command prompt in the extracted directory 
demo_modelDB?
If not you need the appropriate path (see GENESIS instructions).
2) Do you have enough RAM?
The routines are quite RAM intensive. Try commenting out some of the 
simulations and editing the code to use a larger time-step.


